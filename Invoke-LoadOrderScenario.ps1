#Requires -Version 7.0
<#
.SYNOPSIS
Runs ONE Graph/EXO load-order scenario in the current process and records load state after every step.

.DESCRIPTION
Meant to be launched by Test-GraphExoLoadOrder.ps1 in a fresh, visible pwsh window, one scenario per process,
so that assembly load contexts are never polluted by a previous scenario and WAM prompts can appear.

Every step runs inside try/catch. A cancelled sign-in is just a caught exception; the script continues to the
snapshot and never exits before writing its JSON. The JSON is rewritten after every step so a hard crash
(native access violation, window closed by hand) still leaves the state up to the previous step on disk.

Nothing here installs, updates, or removes modules. If a required version is missing the import step fails
and that failure is recorded like any other.

.PARAMETER Scenario
One of the scenario names in scenarios.psd1.

.PARAMETER OutFile
JSON output path. The transcript goes next to it as <name>.transcript.txt.

.PARAMETER TenantId
Tenant for Connect-MgGraph and Connect-AzAccount. Never written to the JSON or the transcript (scrubbed on write).

.PARAMETER UserPrincipalName
Account hint for Connect-ExchangeOnline. Never written to the JSON or the transcript (scrubbed on write).

.PARAMETER GraphModulePath
Path to a Microsoft.Graph.Authentication.psd1 built from source (PR #3789). When given, import-graph imports that
manifest by path instead of the installed -GraphVersion.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $Scenario,

    [Parameter(Mandatory)]
    [string] $OutFile,

    [string] $TenantId,

    [string] $UserPrincipalName,

    [string] $GraphVersion = '2.40.0',

    [string] $ExoVersion = '3.10.1',

    [string] $GraphModulePath,

    # Any binary module outside $PSHOME's TPA list exercises PowerShell's Assembly.LoadFrom path,
    # which is what registers System.Reflection.Assembly.LoadFromResolveHandler.
    [string] $ProbeModule = 'Microsoft.PowerShell.ThreadJob',

    [int] $LingerSeconds = 4
)

# Non-terminating errors must flow into $Error (captured per step) instead of being promoted to exceptions,
# otherwise the first error would mask the one we are after.
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

$script:TrackedAssemblyPattern = '^(Microsoft\.Identity|Microsoft\.IdentityModel|Azure\.(Identity|Core)|Microsoft\.Graph|Microsoft\.Exchange|Microsoft\.Kiota|Microsoft\.Azure\.PowerShell\.Authentication|Microsoft\.PowerShell\.ThreadJob)'
$script:ScriptVersion = '2.2'
# Values that must never reach the JSON or the transcript; Protect-Text replaces them on every write.
$script:Secrets = @()

# Win32 lookups for the in-process bare-name question. GetModuleHandleW answers "which mapped module does a bare
# name resolve to right now" without loading anything; LoadLibraryW repeats what a DllImport by bare name ends up
# doing. Compiled once per process via Add-Type (Roslyn lands in Default; it touches none of the tracked assemblies).
$nativeProbeSource = @'
using System;
using System.Runtime.InteropServices;
using System.Text;

public static class LoadOrderNativeProbe
{
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern IntPtr GetModuleHandleW(string lpModuleName);

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern IntPtr LoadLibraryW(string lpLibFileName);

    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern uint GetModuleFileNameW(IntPtr hModule, StringBuilder lpFilename, uint nSize);

    [DllImport("kernel32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool FreeLibrary(IntPtr hModule);

    public static string GetModuleFileName(IntPtr hModule)
    {
        var sb = new StringBuilder(2048);
        uint n = GetModuleFileNameW(hModule, sb, (uint)sb.Capacity);
        return n == 0 ? null : sb.ToString();
    }
}
'@
$script:NativeProbeType = $null
$script:NativeProbeError = $null
try {
    Add-Type -TypeDefinition $nativeProbeSource -ErrorAction Stop
    $script:NativeProbeType = 'LoadOrderNativeProbe' -as [type]
}
catch {
    $script:NativeProbeError = $_.Exception.Message
}

#region helpers

function Get-DelegateTargets {
    # Invocation order of a multicast delegate is registration order, which is exactly the order
    # the runtime calls AssemblyResolve handlers (first non-null result wins).
    param([System.Delegate] $Delegate)
    if ($null -eq $Delegate) { return @() }
    @(foreach ($d in $Delegate.GetInvocationList()) {
            $m = $d.Method
            [ordered]@{
                Method   = '{0}.{1}' -f $m.DeclaringType.FullName, $m.Name
                Assembly = $m.DeclaringType.Assembly.GetName().Name
            }
        })
}

function Get-AssemblyResolveHandlerList {
    # AppDomain.AssemblyResolve is a facade on modern .NET: add/remove forward to a static field-like event
    # on System.Runtime.Loader.AssemblyLoadContext whose backing field is named AssemblyResolve.
    # Older layouts kept an instance field _assemblyResolve on AppDomain. Try both.
    $result = [ordered]@{ Source = 'unavailable'; Handlers = @() }
    try {
        $staticFlags = [System.Reflection.BindingFlags]'NonPublic,Public,Static'
        $field = [System.Runtime.Loader.AssemblyLoadContext].GetField('AssemblyResolve', $staticFlags)
        if ($field) {
            $result.Source = 'System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)'
            $result.Handlers = @(Get-DelegateTargets -Delegate $field.GetValue($null))
            return $result
        }
        $instanceFlags = [System.Reflection.BindingFlags]'NonPublic,Public,Instance'
        $field = [System.AppDomain].GetField('_assemblyResolve', $instanceFlags)
        if ($field) {
            $result.Source = 'System.AppDomain._assemblyResolve (instance field)'
            $result.Handlers = @(Get-DelegateTargets -Delegate $field.GetValue([System.AppDomain]::CurrentDomain))
            return $result
        }
    }
    catch {
        $result.Source = 'unavailable: {0}' -f $_.Exception.Message
    }
    return $result
}

function Get-ModuleOwnerMap {
    # Module roots at snapshot time, so every file location can be attributed to the module that shipped it
    # (a PR build of Graph lives outside the normal Modules folder, so a path pattern alone is not enough).
    $map = [ordered]@{}
    foreach ($pair in @(@('Graph', 'Microsoft.Graph.Authentication'), @('EXO', 'ExchangeOnlineManagement'), @('Az', 'Az.Accounts'))) {
        $m = Get-Module -Name $pair[1] | Select-Object -First 1
        if ($m -and $m.ModuleBase) { $map[$pair[0]] = $m.ModuleBase.TrimEnd('\') + '\' }
    }
    return $map
}

function Get-Owner {
    param([string] $Location, $OwnerMap)
    if ([string]::IsNullOrEmpty($Location)) { return $null }
    foreach ($key in $OwnerMap.Keys) {
        if ($Location.StartsWith($OwnerMap[$key], [System.StringComparison]::OrdinalIgnoreCase)) { return $key }
    }
    if ($Location -match '(?i)\\Microsoft\.Graph\.Authentication\\') { return 'Graph' }
    if ($Location -match '(?i)\\ExchangeOnlineManagement\\') { return 'EXO' }
    if ($Location -match '(?i)\\Az\.Accounts\\') { return 'Az' }
    return 'other'
}

function Get-ContextName {
    param([System.Reflection.Assembly] $Assembly)
    $alc = [System.Runtime.Loader.AssemblyLoadContext]::GetLoadContext($Assembly)
    if ($null -eq $alc) { return $null }
    return $alc.Name
}

function Get-NativeInProcessProbe {
    # What a DllImport by bare name would get right now. GetModuleHandleW never loads anything; LoadLibraryW is only
    # attempted once a copy is already mapped, so the probe itself never maps a msalruntime.
    param($NativeModules, $OwnerMap)

    $probe = [ordered]@{ Available = ($null -ne $script:NativeProbeType); GetModuleHandle = $null; LoadLibrary = $null }
    if (-not $probe.Available) {
        $probe.Error = $script:NativeProbeError
        return $probe
    }
    $type = $script:NativeProbeType
    $handle = $type::GetModuleHandleW('msalruntime.dll')
    if ($handle -eq [IntPtr]::Zero) {
        $probe.GetModuleHandle = [ordered]@{ Handle = '0x0'; Path = $null; Owner = $null; Matches = 'not mapped' }
        $probe.LoadLibrary = [ordered]@{ Skipped = 'no msalruntime.dll mapped; a LoadLibrary here would map one and perturb the process' }
        return $probe
    }
    $path = $type::GetModuleFileName($handle)
    $probe.GetModuleHandle = [ordered]@{
        Handle  = '0x{0:X}' -f $handle.ToInt64()
        Path    = $path
        Owner   = Get-Owner -Location $path -OwnerMap $OwnerMap
        Matches = Get-MappedMatch -Path $path -NativeModules $NativeModules
    }
    $loaded = $type::LoadLibraryW('msalruntime.dll')
    if ($loaded -eq [IntPtr]::Zero) {
        $probe.LoadLibrary = [ordered]@{ Handle = '0x0'; Win32Error = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error() }
        return $probe
    }
    $loadedPath = $type::GetModuleFileName($loaded)
    # Balance the reference LoadLibraryW added; the module stays mapped because its original owner still holds it.
    $freed = $type::FreeLibrary($loaded)
    $probe.LoadLibrary = [ordered]@{
        Handle                = '0x{0:X}' -f $loaded.ToInt64()
        Path                  = $loadedPath
        Owner                 = Get-Owner -Location $loadedPath -OwnerMap $OwnerMap
        Matches               = Get-MappedMatch -Path $loadedPath -NativeModules $NativeModules
        SameAsGetModuleHandle = ($loaded -eq $handle)
        Freed                 = $freed
    }
    return $probe
}

function Get-MappedMatch {
    param([string] $Path, $NativeModules)
    if ([string]::IsNullOrEmpty($Path)) { return 'no path' }
    foreach ($m in @($NativeModules)) {
        if ([string]::Equals($m.FileName, $Path, [System.StringComparison]::OrdinalIgnoreCase)) { return 'mapped entry: {0}' -f $m.FileName }
    }
    return 'no mapped entry with this path'
}

function Get-DllImportTargets {
    # Every DllImport in each loaded copy of Microsoft.Identity.Client.NativeInterop, grouped by library name.
    # "msalruntime" with no path confirms bare-name binding from inside the process rather than from offline metadata.
    param($OwnerMap)
    @(foreach ($asm in [System.AppDomain]::CurrentDomain.GetAssemblies()) {
            if ($asm.IsDynamic -or $asm.GetName().Name -ne 'Microsoft.Identity.Client.NativeInterop') { continue }
            $types = @()
            try { $types = @($asm.GetTypes()) }
            catch {
                $inner = $_.Exception.InnerException
                if ($inner -is [System.Reflection.ReflectionTypeLoadException]) { $types = @($inner.Types | Where-Object { $_ }) }
            }
            $counts = @{}
            $total = 0
            $flags = [System.Reflection.BindingFlags]'NonPublic,Public,Static,Instance,DeclaredOnly'
            foreach ($t in $types) {
                foreach ($method in $t.GetMethods($flags)) {
                    if (-not ($method.Attributes -band [System.Reflection.MethodAttributes]::PinvokeImpl)) { continue }
                    foreach ($attribute in $method.GetCustomAttributes([System.Runtime.InteropServices.DllImportAttribute], $false)) {
                        $total++
                        $key = [string] $attribute.Value
                        if ($counts.ContainsKey($key)) { $counts[$key]++ } else { $counts[$key] = 1 }
                    }
                }
            }
            [ordered]@{
                Context      = Get-ContextName -Assembly $asm
                Location     = $asm.Location
                Owner        = Get-Owner -Location $asm.Location -OwnerMap $OwnerMap
                PInvokeCount = $total
                Targets      = @($counts.Keys | Sort-Object | ForEach-Object { [ordered]@{ Value = $_; Count = $counts[$_] } })
            }
        })
}

function Get-DllImportResolverState {
    # NativeLibrary keeps DllImportResolver registrations in a private static ConditionalWeakTable<Assembly, DllImportResolver>
    # (s_nativeDllResolveMap on current runtimes; located by field type in case the name differs). A NativeInterop
    # assembly without an entry has nothing pinning its P/Invokes to the handle it preloaded.
    param($OwnerMap)
    $result = [ordered]@{ FieldName = $null; TableExists = $false; Entries = @(); NativeInterop = @() }
    $staticFlags = [System.Reflection.BindingFlags]'NonPublic,Static'
    $field = [System.Runtime.InteropServices.NativeLibrary].GetFields($staticFlags) | Where-Object { $_.FieldType.Name -like 'ConditionalWeakTable*' } | Select-Object -First 1
    $table = $null
    if ($field) {
        $result.FieldName = $field.Name
        $table = $field.GetValue($null)
        if ($null -ne $table) {
            $result.TableExists = $true
            foreach ($entry in $table) {
                $key = $entry.Key
                $result.Entries += [ordered]@{ Assembly = $key.GetName().Name; Context = Get-ContextName -Assembly $key; Owner = Get-Owner -Location $key.Location -OwnerMap $OwnerMap }
            }
        }
    }
    foreach ($asm in [System.AppDomain]::CurrentDomain.GetAssemblies()) {
        if ($asm.IsDynamic -or $asm.GetName().Name -ne 'Microsoft.Identity.Client.NativeInterop') { continue }
        $hasResolver = $false
        if ($null -ne $table) {
            $resolver = $null
            $hasResolver = [bool] $table.TryGetValue($asm, [ref] $resolver)
        }
        $result.NativeInterop += [ordered]@{
            Context     = Get-ContextName -Assembly $asm
            Location    = $asm.Location
            Owner       = Get-Owner -Location $asm.Location -OwnerMap $OwnerMap
            HasResolver = $hasResolver
        }
    }
    return $result
}

function Get-BrokerRuntimeState {
    # MSAL's RuntimeBroker keeps the outcome of its one-time native startup in private statics
    # (s_lazyCore, s_initException), one set per loaded copy of Microsoft.Identity.Client.Broker.
    # Reading them turns "the lazy Core came back null" from an inference into an observation.
    param($OwnerMap)
    $staticFlags = [System.Reflection.BindingFlags]'NonPublic,Public,Static'
    @(foreach ($asm in [System.AppDomain]::CurrentDomain.GetAssemblies()) {
            if ($asm.IsDynamic -or $asm.GetName().Name -ne 'Microsoft.Identity.Client.Broker') { continue }
            $type = $asm.GetType('Microsoft.Identity.Client.Platforms.Features.RuntimeBroker.RuntimeBroker', $false)
            if (-not $type) { continue }
            $state = [ordered]@{
                Context              = Get-ContextName -Assembly $asm
                Location             = $asm.Location
                Owner                = Get-Owner -Location $asm.Location -OwnerMap $OwnerMap
                LazyCoreValueCreated = $null
                CoreIsNull           = $null
                InitException        = $null
            }
            $lazyField = $type.GetField('s_lazyCore', $staticFlags)
            if ($lazyField) {
                $lazy = $lazyField.GetValue($null)
                if ($null -ne $lazy) {
                    $state.LazyCoreValueCreated = $lazy.IsValueCreated
                    # Value is read only once the factory has already run; reading it earlier would run the factory ourselves.
                    if ($lazy.IsValueCreated) { $state.CoreIsNull = ($null -eq $lazy.Value) }
                }
            }
            $initField = $type.GetField('s_initException', $staticFlags)
            if ($initField) {
                $init = $initField.GetValue($null)
                if ($null -ne $init) {
                    $props = [ordered]@{}
                    foreach ($p in $init.GetType().GetProperties()) {
                        if ($p.Name -in 'Data', 'InnerException', 'StackTrace', 'TargetSite') { continue }
                        try {
                            $value = [string] $p.GetValue($init)
                            if ($value.Length -gt 300) { $value = $value.Substring(0, 300) + '...' }
                            $props[$p.Name] = $value
                        }
                        catch { }
                    }
                    $state.InitException = [ordered]@{ Type = $init.GetType().FullName; Properties = $props; ToString = $init.ToString() }
                }
            }
            $state
        })
}

function Get-LoadStateSnapshot {
    param([string] $Label)

    $snapshot = [ordered]@{
        Label                    = $Label
        TakenUtc                 = [DateTime]::UtcNow.ToString('o')
        OwnerRoots               = @{}
        Assemblies               = @()
        LoadContexts             = @()
        NativeModules            = @()
        NativeBareNameResolvesTo = $null
        NativeInProcess          = $null
        DllImportTargets         = @()
        DllImportResolvers       = $null
        AssemblyResolveHandlers  = $null
        BrokerRuntimeState       = @()
        Modules                  = @()
        CaptureErrors            = @()
    }

    $ownerMap = [ordered]@{}
    try { $ownerMap = Get-ModuleOwnerMap; $snapshot.OwnerRoots = $ownerMap } catch { $snapshot.CaptureErrors += 'OwnerMap: {0}' -f $_.Exception.Message }

    # Managed assemblies of interest, with the load context each one actually landed in.
    try {
        $rows = foreach ($asm in [System.AppDomain]::CurrentDomain.GetAssemblies()) {
            if ($asm.IsDynamic) { continue }
            $name = $asm.GetName()
            if ($name.Name -notmatch $script:TrackedAssemblyPattern) { continue }
            $location = $null
            try { $location = $asm.Location } catch { $location = $null }
            $fileVersion = $null
            if ($location) {
                try { $fileVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($location).FileVersion } catch { $fileVersion = $null }
            }
            [ordered]@{
                Name        = $name.Name
                Version     = $name.Version.ToString()
                Context     = Get-ContextName -Assembly $asm
                Owner       = Get-Owner -Location $location -OwnerMap $ownerMap
                Location    = $location
                FileVersion = $fileVersion
            }
        }
        $snapshot.Assemblies = @($rows | Sort-Object -Property @{ Expression = { $_.Name } }, @{ Expression = { $_.Context } })
    }
    catch {
        $snapshot.CaptureErrors += 'Assemblies: {0}' -f $_.Exception.Message
    }

    # Every load context in the process, plus the per-context Resolving handlers (the PR's new code path
    # registers one of these on Default instead of an AppDomain.AssemblyResolve handler).
    try {
        $instanceFlags = [System.Reflection.BindingFlags]'NonPublic,Public,Instance'
        $resolvingField = [System.Runtime.Loader.AssemblyLoadContext].GetField('Resolving', $instanceFlags)
        $unmanagedField = [System.Runtime.Loader.AssemblyLoadContext].GetField('ResolvingUnmanagedDll', $instanceFlags)
        $snapshot.LoadContexts = @(foreach ($alc in [System.Runtime.Loader.AssemblyLoadContext]::All) {
                $resolving = @()
                $unmanaged = @()
                if ($resolvingField) { $resolving = @(Get-DelegateTargets -Delegate $resolvingField.GetValue($alc)) }
                if ($unmanagedField) { $unmanaged = @(Get-DelegateTargets -Delegate $unmanagedField.GetValue($alc)) }
                [ordered]@{
                    Name                          = $alc.Name
                    TypeName                      = $alc.GetType().FullName
                    IsCollectible                 = $alc.IsCollectible
                    AssemblyCount                 = @($alc.Assemblies).Count
                    ResolvingHandlers             = $resolving
                    ResolvingUnmanagedDllHandlers = $unmanaged
                }
            })
    }
    catch {
        $snapshot.CaptureErrors += 'LoadContexts: {0}' -f $_.Exception.Message
    }

    # Native msalruntime copies. The count matters: two paths means two copies of the native broker runtime
    # are mapped. NativeBareNameResolvesTo (NativeLibrary.TryLoad) and NativeInProcess (Win32 GetModuleHandleW /
    # LoadLibraryW) both show which copy a bare-name request returns; both only probe once a copy is mapped.
    $native = @()
    try {
        $process = Get-Process -Id $PID
        $native = @(foreach ($m in $process.Modules) {
                if ($m.ModuleName -notlike 'msalruntime*') { continue }
                [ordered]@{
                    ModuleName  = $m.ModuleName
                    FileName    = $m.FileName
                    Owner       = Get-Owner -Location $m.FileName -OwnerMap $ownerMap
                    FileVersion = $m.FileVersionInfo.FileVersion
                    BaseAddress = '0x{0:X}' -f $m.BaseAddress.ToInt64()
                }
            })
        $snapshot.NativeModules = $native
        if ($native.Count -gt 0) {
            $handle = [IntPtr]::Zero
            if ([System.Runtime.InteropServices.NativeLibrary]::TryLoad('msalruntime.dll', [ref] $handle)) {
                $address = '0x{0:X}' -f $handle.ToInt64()
                $match = @($native | Where-Object { $_.BaseAddress -eq $address })
                $snapshot.NativeBareNameResolvesTo = if ($match.Count -gt 0) { $match[0].FileName } else { 'handle {0} matched no listed module' -f $address }
                # Balance the reference TryLoad added; the module stays mapped because the original owner still holds it.
                [System.Runtime.InteropServices.NativeLibrary]::Free($handle)
            }
            else {
                $snapshot.NativeBareNameResolvesTo = 'TryLoad failed'
            }
        }
    }
    catch {
        $snapshot.CaptureErrors += 'NativeModules: {0}' -f $_.Exception.Message
    }

    try { $snapshot.NativeInProcess = Get-NativeInProcessProbe -NativeModules $native -OwnerMap $ownerMap } catch { $snapshot.CaptureErrors += 'NativeInProcess: {0}' -f $_.Exception.Message }
    try { $snapshot.DllImportTargets = @(Get-DllImportTargets -OwnerMap $ownerMap) } catch { $snapshot.CaptureErrors += 'DllImportTargets: {0}' -f $_.Exception.Message }
    try { $snapshot.DllImportResolvers = Get-DllImportResolverState -OwnerMap $ownerMap } catch { $snapshot.CaptureErrors += 'DllImportResolvers: {0}' -f $_.Exception.Message }

    $snapshot.AssemblyResolveHandlers = Get-AssemblyResolveHandlerList

    try { $snapshot.BrokerRuntimeState = @(Get-BrokerRuntimeState -OwnerMap $ownerMap) } catch { $snapshot.CaptureErrors += 'BrokerRuntimeState: {0}' -f $_.Exception.Message }

    try {
        $snapshot.Modules = @(foreach ($m in (Get-Module -Name 'Microsoft.Graph.Authentication', 'ExchangeOnlineManagement', 'Az.Accounts')) {
                [ordered]@{ Name = $m.Name; Version = $m.Version.ToString(); Path = $m.Path }
            })
    }
    catch {
        $snapshot.CaptureErrors += 'Modules: {0}' -f $_.Exception.Message
    }

    return $snapshot
}

function ConvertTo-ExceptionRecord {
    param($ErrorItem, [switch] $Brief)

    $exception = $null
    if ($ErrorItem -is [System.Management.Automation.ErrorRecord]) { $exception = $ErrorItem.Exception }
    elseif ($ErrorItem -is [System.Exception]) { $exception = $ErrorItem }

    $record = [ordered]@{
        TypeFullName          = if ($exception) { $exception.GetType().FullName } else { $null }
        Message               = if ($exception) { $exception.Message } else { [string] $ErrorItem }
        FullyQualifiedErrorId = if ($ErrorItem -is [System.Management.Automation.ErrorRecord]) { $ErrorItem.FullyQualifiedErrorId } else { $null }
        CategoryInfo          = if ($ErrorItem -is [System.Management.Automation.ErrorRecord]) { $ErrorItem.CategoryInfo.ToString() } else { $null }
        InnerChain            = @()
    }

    # The inner chain is where wrapped failures (Azure.Identity over MSAL, EXO over MSAL) keep the real cause.
    $inner = if ($exception) { $exception.InnerException } else { $null }
    while ($null -ne $inner) {
        $record.InnerChain += [ordered]@{ Type = $inner.GetType().FullName; Message = $inner.Message }
        $inner = $inner.InnerException
    }

    if (-not $Brief) {
        $record.ToString = if ($exception) { $exception.ToString() } else { $null }
        $record.ScriptStackTrace = if ($ErrorItem -is [System.Management.Automation.ErrorRecord]) { $ErrorItem.ScriptStackTrace } else { $null }
        $record.ErrorDetails = if ($ErrorItem -is [System.Management.Automation.ErrorRecord] -and $ErrorItem.ErrorDetails) { $ErrorItem.ErrorDetails.Message } else { $null }
    }
    return $record
}

function Protect-Text {
    # Tenant ID and UPN are not secrets, but they do not belong in files that may end up on GitHub.
    param([string] $Text)
    if ([string]::IsNullOrEmpty($Text)) { return $Text }
    $pairs = @(@($script:TenantId, '<tenant-id>'), @($script:UserPrincipalName, '<upn>'))
    foreach ($secret in $script:Secrets) { $pairs += , @($secret, '<token>') }
    # Longest value first: when the tenant is given as a domain name it is a substring of the UPN, and replacing it
    # first would leave the UPN's local part behind as "user@<tenant-id>".
    $pairs = @($pairs | Sort-Object -Property { [string] $_[0] } -Descending | Sort-Object -Property { ([string] $_[0]).Length } -Descending -Stable)
    foreach ($pair in $pairs) {
        $value = $pair[0]
        if ([string]::IsNullOrWhiteSpace($value)) { continue }
        $Text = [regex]::Replace($Text, [regex]::Escape($value), $pair[1], [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }
    return $Text
}

function Save-Result {
    # Rewritten after every step so a crash still leaves the last good state on disk.
    param($Result)
    $json = Protect-Text -Text ($Result | ConvertTo-Json -Depth 25)
    $params = @{
        Path     = $script:OutFile
        Value    = $json
        Encoding = 'utf8'
    }
    Set-Content @params
}

function Invoke-Step {
    param([string] $Name, [scriptblock] $Action)

    $record = [ordered]@{
        Name               = $Name
        StartedUtc         = [DateTime]::UtcNow.ToString('o')
        DurationMs         = $null
        Outcome            = 'ok'
        Exception          = $null
        ErrorStreamEntries = @()
        Notes              = [ordered]@{}
        Snapshot           = $null
    }

    $errorCountBefore = $Error.Count
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $notes = & $Action
        if ($notes -is [System.Collections.IDictionary]) { $record.Notes = $notes }
        elseif ($null -ne $notes) { $record.Notes = [ordered]@{ Output = ($notes | Out-String -Width 200).Trim() } }
    }
    catch {
        $record.Outcome = 'exception'
        $record.Exception = ConvertTo-ExceptionRecord -ErrorItem $_
    }
    finally {
        $stopwatch.Stop()
        $record.DurationMs = [int] $stopwatch.ElapsedMilliseconds
    }

    # Everything the step pushed onto $Error, newest first in $Error, recorded oldest first here.
    $newErrorCount = $Error.Count - $errorCountBefore
    if ($newErrorCount -gt 0) {
        $record.ErrorStreamEntries = @(for ($i = $newErrorCount - 1; $i -ge 0; $i--) { ConvertTo-ExceptionRecord -ErrorItem $Error[$i] -Brief })
        if ($record.Outcome -eq 'ok') { $record.Outcome = 'nonterminating-error' }
    }

    $record.Snapshot = Get-LoadStateSnapshot -Label ('after {0}' -f $Name)
    return $record
}

function Get-FirstLine {
    param([string] $Text)
    if ([string]::IsNullOrEmpty($Text)) { return '' }
    return ($Text -split "`r?`n")[0]
}

function Invoke-GraphConnect {
    # Shared by connect-graph and connect-graph-cancel; only the operator's action at the picker differs.
    if ([string]::IsNullOrWhiteSpace($script:TenantId)) { throw 'TenantId was not supplied; cannot run connect-graph.' }
    $params = @{
        TenantId     = $script:TenantId
        ContextScope = 'Process'
        Scopes       = 'User.Read'
        NoWelcome    = $true
    }
    Connect-MgGraph @params
    $ctx = Get-MgContext
    # Account and TenantId deliberately not recorded.
    [ordered]@{
        SignedIn            = [bool] ($ctx -and $ctx.Account)
        AuthType            = if ($ctx) { [string] $ctx.AuthType } else { $null }
        TokenCredentialType = if ($ctx) { [string] $ctx.TokenCredentialType } else { $null }
    }
}

function Invoke-ExoConnect {
    param([switch] $DisableWAM)
    if ([string]::IsNullOrWhiteSpace($script:UserPrincipalName)) { throw 'UserPrincipalName was not supplied; cannot run connect-exo.' }
    $params = @{
        UserPrincipalName = $script:UserPrincipalName
        ShowBanner        = $false
    }
    if ($DisableWAM) { $params.DisableWAM = $true }
    Connect-ExchangeOnline @params
    $connections = @(Get-ConnectionInformation)
    [ordered]@{
        Connected       = ($connections.Count -gt 0)
        ConnectionCount = $connections.Count
        State           = (@($connections | ForEach-Object { [string] $_.State }) -join ',')
        DisableWAM      = [bool] $DisableWAM
    }
}

#endregion helpers

#region step actions

$stepActions = @{
    'baseline'               = {
        [ordered]@{ Note = 'No action; captures the process before any module import.' }
    }
    'import-probe-module'    = {
        Import-Module -Name $script:ProbeModule -ErrorAction Stop
        $m = Get-Module -Name $script:ProbeModule
        [ordered]@{ Module = $m.Name; Version = $m.Version.ToString(); ModuleType = $m.ModuleType.ToString(); Path = $m.Path }
    }
    'import-graph'           = {
        if (-not [string]::IsNullOrWhiteSpace($script:GraphModulePath)) {
            # A source build is imported by manifest path so the installed 2.x is never touched or confused with it.
            Import-Module -Name $script:GraphModulePath -ErrorAction Stop
        }
        else {
            $params = @{
                Name            = 'Microsoft.Graph.Authentication'
                RequiredVersion = $script:GraphVersion
                ErrorAction     = 'Stop'
            }
            Import-Module @params
        }
        $m = Get-Module -Name 'Microsoft.Graph.Authentication'
        [ordered]@{ Version = $m.Version.ToString(); Path = $m.Path; Source = $(if ($script:GraphModulePath) { 'path' } else { 'installed' }) }
    }
    'connect-graph'          = { Invoke-GraphConnect }
    'connect-graph-cancel'   = { Invoke-GraphConnect }
    'connect-graph-accesstoken' = {
        # The harness hands over a Graph token in an environment variable: process memory only, never a file or a
        # command line. It is read once, removed from this process's environment, added to the scrub list, and given
        # to Connect-MgGraph as a SecureString, so Graph never touches WAM or msalruntime.
        $raw = [System.Environment]::GetEnvironmentVariable('LOADORDER_GRAPH_TOKEN')
        if ([string]::IsNullOrWhiteSpace($raw)) { throw 'LOADORDER_GRAPH_TOKEN is not set; the harness acquires it with Get-AzAccessToken before launching this scenario.' }
        [System.Environment]::SetEnvironmentVariable('LOADORDER_GRAPH_TOKEN', $null)
        $script:Secrets += $raw
        $secure = ConvertTo-SecureString -String $raw -AsPlainText -Force
        $raw = $null
        # The AccessToken parameter set has no ContextScope; a supplied token is never persisted anyway.
        Connect-MgGraph -AccessToken $secure -NoWelcome
        $ctx = Get-MgContext
        [ordered]@{
            SignedIn            = [bool] ($ctx -and $ctx.Account)
            AuthType            = if ($ctx) { [string] $ctx.AuthType } else { $null }
            TokenCredentialType = if ($ctx) { [string] $ctx.TokenCredentialType } else { $null }
        }
    }
    'connect-az'             = {
        if ([string]::IsNullOrWhiteSpace($script:TenantId)) { throw 'TenantId was not supplied; cannot run connect-az.' }
        Import-Module -Name Az.Accounts -ErrorAction Stop
        # Process scope keeps the sign-in out of the profile; system browser vs broker is whatever Az config says (never changed here).
        $null = Connect-AzAccount -Tenant $script:TenantId -Scope Process
        $ctx = Get-AzContext
        [ordered]@{ SignedIn = [bool] ($ctx -and $ctx.Account) }
    }
    'import-exo'             = {
        $params = @{
            Name            = 'ExchangeOnlineManagement'
            RequiredVersion = $script:ExoVersion
            ErrorAction     = 'Stop'
        }
        Import-Module @params
        $m = Get-Module -Name 'ExchangeOnlineManagement'
        [ordered]@{ Version = $m.Version.ToString(); Path = $m.Path }
    }
    'connect-exo'            = { Invoke-ExoConnect }
    'connect-exo-disablewam' = { Invoke-ExoConnect -DisableWAM }
}

# Steps where a sign-in UI may appear, so the operator is told to watch for it.
$promptingSteps = @('connect-graph', 'connect-graph-cancel', 'connect-az', 'connect-exo', 'connect-exo-disablewam')

#endregion step actions

#region main

$definitions = Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot 'scenarios.psd1')
$definition = $definitions.Scenarios[$Scenario]
if (-not $definition) { throw "Scenario '$Scenario' is not defined in scenarios.psd1." }
if ($definition.UsesPrBuild -and [string]::IsNullOrWhiteSpace($GraphModulePath)) { throw "Scenario '$Scenario' needs -GraphModulePath (a build of PR #3789)." }

$script:OutFile = $OutFile
$outDirectory = Split-Path -Path $OutFile -Parent
if ($outDirectory -and -not (Test-Path -LiteralPath $outDirectory)) { $null = New-Item -Path $outDirectory -ItemType Directory -Force }
$transcriptPath = [System.IO.Path]::ChangeExtension($OutFile, '.transcript.txt')

$transcriptStarted = $false
try {
    Start-Transcript -Path $transcriptPath -Force | Out-Null
    $transcriptStarted = $true
}
catch {
    Write-Warning ('Transcript could not be started: {0}' -f $_.Exception.Message)
}

try { $Host.UI.RawUI.WindowTitle = 'load-order: {0}' -f $Scenario } catch { }

$result = [ordered]@{
    Scenario        = $Scenario
    ScriptVersion   = $script:ScriptVersion
    StartedUtc      = [DateTime]::UtcNow.ToString('o')
    FinishedUtc     = $null
    Completed       = $false
    Instruction     = $definition.Instruction
    Expectation     = $definition.Expectation
    PlannedSteps    = @($definition.Steps)
    Requested       = [ordered]@{ GraphVersion = $GraphVersion; ExoVersion = $ExoVersion; GraphModulePath = $GraphModulePath; ProbeModule = $ProbeModule }
    Host            = [ordered]@{
        PSVersion            = $PSVersionTable.PSVersion.ToString()
        PSEdition            = $PSVersionTable.PSEdition
        OSVersion            = [System.Environment]::OSVersion.VersionString
        ProcessArchitecture  = [string] [System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture
        FrameworkDescription = [System.Runtime.InteropServices.RuntimeInformation]::FrameworkDescription
        ProcessId            = $PID
        PSHome               = $PSHOME
        NativeProbeAvailable = ($null -ne $script:NativeProbeType)
        NativeProbeError     = $script:NativeProbeError
    }
    TranscriptPath  = if ($transcriptStarted) { $transcriptPath } else { $null }
    Steps           = @()
    FrameworkError  = $null
}

Write-Host ''
Write-Host ('=== Load-order scenario: {0} ===' -f $Scenario) -ForegroundColor Cyan
Write-Host ('Steps: {0}' -f ($definition.Steps -join ' -> '))
Write-Host ('What to do: {0}' -f $definition.Instruction) -ForegroundColor Yellow
Write-Host ('Expectation: {0}' -f $definition.Expectation) -ForegroundColor DarkGray
Write-Host ('pwsh {0}, {1}, {2}' -f $result.Host.PSVersion, $result.Host.FrameworkDescription, $result.Host.ProcessArchitecture) -ForegroundColor DarkGray
if ($GraphModulePath) { Write-Host ('Graph module from path: {0}' -f $GraphModulePath) -ForegroundColor DarkGray }
if (-not $result.Host.NativeProbeAvailable) { Write-Host ('Win32 native probe unavailable: {0}' -f $script:NativeProbeError) -ForegroundColor DarkYellow }
Write-Host ''

$exitCode = 0
try {
    Save-Result -Result $result
    $stepIndex = 0
    foreach ($stepName in $definition.Steps) {
        $stepIndex++
        $action = $stepActions[$stepName]
        if (-not $action) { throw "Step '$stepName' has no action defined." }

        $prefix = '[{0}/{1}] {2}' -f $stepIndex, $definition.Steps.Count, $stepName
        if ($promptingSteps -contains $stepName) {
            Write-Host ('{0} ... watch for a sign-in prompt now' -f $prefix) -ForegroundColor Yellow
        }
        else {
            Write-Host ('{0} ...' -f $prefix)
        }

        $record = Invoke-Step -Name $stepName -Action $action
        $result.Steps += $record
        Save-Result -Result $result

        switch ($record.Outcome) {
            'ok' {
                Write-Host ('    -> ok ({0} ms)' -f $record.DurationMs) -ForegroundColor Green
            }
            'exception' {
                Write-Host ('    -> exception: {0}: {1}' -f $record.Exception.TypeFullName, (Protect-Text -Text (Get-FirstLine -Text $record.Exception.Message))) -ForegroundColor Red
            }
            default {
                Write-Host ('    -> {0} ({1} error stream entries)' -f $record.Outcome, $record.ErrorStreamEntries.Count) -ForegroundColor Red
            }
        }
        $snap = $record.Snapshot
        Write-Host ('    contexts: {0}; tracked assemblies: {1}; msalruntime copies: {2}; AssemblyResolve handlers: {3}' -f $snap.LoadContexts.Count, $snap.Assemblies.Count, $snap.NativeModules.Count, $snap.AssemblyResolveHandlers.Handlers.Count) -ForegroundColor DarkGray
    }
    $result.Completed = $true
}
catch {
    # A failure in the harness code itself, not in a step. Recorded so the report can say so.
    $result.FrameworkError = ConvertTo-ExceptionRecord -ErrorItem $_
    $exitCode = 1
    Write-Host ('Framework error: {0}' -f $_.Exception.Message) -ForegroundColor Red
}
finally {
    $result.FinishedUtc = [DateTime]::UtcNow.ToString('o')
    try { Save-Result -Result $result } catch { Write-Host ('Could not write JSON: {0}' -f $_.Exception.Message) -ForegroundColor Red; $exitCode = 1 }
}

Write-Host ''
Write-Host 'Step outcomes:' -ForegroundColor Cyan
$summary = foreach ($s in $result.Steps) {
    [pscustomobject]@{
        Step      = $s.Name
        Outcome   = $s.Outcome
        Exception = if ($s.Exception) { $s.Exception.TypeFullName } else { '' }
        Message   = if ($s.Exception) { Protect-Text -Text (Get-FirstLine -Text $s.Exception.Message) } else { '' }
    }
}
$summary | Format-Table -AutoSize | Out-String -Width 220 | Write-Host
Write-Host ('JSON: {0}' -f $OutFile)

if ($transcriptStarted) {
    try { Stop-Transcript | Out-Null } catch { }
    # Same scrub as the JSON; the transcript is host output and may echo the account hint.
    try {
        $text = Get-Content -LiteralPath $transcriptPath -Raw
        $params = @{
            LiteralPath = $transcriptPath
            Value       = (Protect-Text -Text $text)
            Encoding    = 'utf8'
        }
        Set-Content @params
    }
    catch { }
}

if ($LingerSeconds -gt 0) {
    Write-Host ('This window closes in {0} seconds.' -f $LingerSeconds) -ForegroundColor DarkGray
    Start-Sleep -Seconds $LingerSeconds
}
exit $exitCode

#endregion main
