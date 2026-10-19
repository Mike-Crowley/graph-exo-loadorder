#Requires -Version 7.0
<#
.SYNOPSIS
Harness for the Graph-then-EXO load-order diagnostic.

.DESCRIPTION
Checks prerequisites, then runs each scenario from scenarios.psd1 in its own fresh, visible
"pwsh -NoProfile -NoLogo" window via Start-Process -Wait. A fresh process per scenario keeps assembly
load contexts unpolluted; a visible window lets WAM prompts appear. The harness waits for the child and
never kills it. Afterwards it builds the report (report.md unless -ReportPath says otherwise) from the JSON files
in the results folder.

Nothing here installs, updates, or removes modules, touches the profile, or changes system or Az settings.

.PARAMETER TenantId
Tenant for Connect-MgGraph and Connect-AzAccount. Required for every scenario except probe-only and imports-only. Never written to the report.

.PARAMETER UserPrincipalName
Account hint for Connect-ExchangeOnline. Required for every scenario except probe-only and imports-only. Never written to the report.

.PARAMETER Scenario
Subset of scenarios to run, in the order defined by scenarios.psd1. Default: every scenario whose
preconditions are met (pr-* need -GraphModulePath; az-connect-then-exo needs Az.Accounts with EnableLoginByWam = true).

.PARAMETER GraphVersion
Installed Microsoft.Graph.Authentication version to import (exact). 2.40.0 is the release the original report was
written against; 2.41.0 and later contain PR #3789, and the report then treats the standard scenarios as the
isolated-Graph run (Finding 6) without needing -GraphModulePath.

.PARAMETER GraphModulePath
Path to a Microsoft.Graph.Authentication.psd1 built from PR #3789. Enables the pr-* scenarios; the installed
-GraphVersion is still used by every other scenario. Redundant once -GraphVersion is 2.41.0 or later.

.PARAMETER ResultsPath
Folder for <scenario>.json and the transcripts. Use one folder per Graph version (for example .\results-2.41.2)
so the runs behind an earlier report are not overwritten.

.PARAMETER ReportPath
Where the Markdown report is written. Default: report.md beside this script. Pair it with -ResultsPath
(for example .\report-2.41.2.md) to keep one report per Graph version.

.PARAMETER ReportOnly
Skip the runs and rebuild the report from whatever JSON already exists under -ResultsPath.

.PARAMETER SkipReport
Run the scenarios but do not rebuild the report (useful when running scenarios one at a time).

.PARAMETER Pause
Wait for Enter before launching each scenario.

.EXAMPLE
.\Test-GraphExoLoadOrder.ps1 -TenantId <guid> -UserPrincipalName <upn>

.EXAMPLE
.\Test-GraphExoLoadOrder.ps1 -Scenario probe-only -SkipReport

.EXAMPLE
.\Test-GraphExoLoadOrder.ps1 -TenantId <guid> -UserPrincipalName <upn> -GraphModulePath .\prbuild\Microsoft.Graph.Authentication.psd1 -Scenario pr-graph-connect-then-exo

.EXAMPLE
.\Test-GraphExoLoadOrder.ps1 -GraphVersion 2.41.2 -ResultsPath .\results-2.41.2 -ReportPath .\report-2.41.2.md -Scenario probe-only, imports-only

Dry run of the capture code on a released isolated Graph: no prompts, no identity needed.

.EXAMPLE
.\Test-GraphExoLoadOrder.ps1 -TenantId <guid> -UserPrincipalName <upn> -GraphVersion 2.41.2 -ResultsPath .\results-2.41.2 -ReportPath .\report-2.41.2.md

The full re-test on Microsoft.Graph.Authentication 2.41.2, kept apart from the 2.40.0 results and report.
#>
[CmdletBinding()]
param(
    [string] $TenantId,

    [string] $UserPrincipalName,

    [string[]] $Scenario,

    [string] $GraphVersion = '2.40.0',

    [string] $ExoVersion = '3.10.1',

    [string] $GraphModulePath,

    [string] $ResultsPath = (Join-Path $PSScriptRoot 'results'),

    [string] $ReportPath = (Join-Path $PSScriptRoot 'report.md'),

    [switch] $ReportOnly,

    [switch] $SkipReport,

    [switch] $Pause
)

$ErrorActionPreference = 'Stop'

$script:ChildScript = Join-Path $PSScriptRoot 'Invoke-LoadOrderScenario.ps1'
$script:Definitions = Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot 'scenarios.psd1')
$script:ReportPath = $ReportPath
$script:KeyAssemblies = @(
    'Microsoft.Identity.Client'
    'Microsoft.Identity.Client.Broker'
    'Microsoft.Identity.Client.NativeInterop'
    'Microsoft.IdentityModel.Abstractions'
    'Azure.Identity'
)
$script:LoadFromHandler = 'System.Reflection.Assembly.LoadFromResolveHandler'

#region run helpers

function Test-Prerequisite {
    # Read-only checks. A missing exact version stops the run; nothing is ever installed from here.
    param([bool] $NeedsPrBuild)

    $pwsh = Get-Command -Name pwsh -CommandType Application | Select-Object -First 1
    if (-not $pwsh) { throw 'pwsh was not found on PATH.' }
    $pwshVersion = & $pwsh.Source -NoProfile -NoLogo -Command '$PSVersionTable.PSVersion.ToString()'

    $graph = Get-Module -ListAvailable -Name 'Microsoft.Graph.Authentication' | Where-Object { $_.Version -eq [version] $GraphVersion } | Select-Object -First 1
    $exo = Get-Module -ListAvailable -Name 'ExchangeOnlineManagement' | Where-Object { $_.Version -eq [version] $ExoVersion } | Select-Object -First 1

    Write-Host 'Prerequisites' -ForegroundColor Cyan
    Write-Host ('  pwsh {0} at {1}' -f $pwshVersion, $pwsh.Source)
    Write-Host ('  Microsoft.Graph.Authentication {0}: {1}' -f $GraphVersion, $(if ($graph) { $graph.Path } else { 'NOT INSTALLED' }))
    Write-Host ('  ExchangeOnlineManagement {0}: {1}' -f $ExoVersion, $(if ($exo) { $exo.Path } else { 'NOT INSTALLED' }))

    if (-not $graph) { throw ('Microsoft.Graph.Authentication {0} is not installed. Install it yourself first; this harness never installs modules.' -f $GraphVersion) }
    if (-not $exo) { throw ('ExchangeOnlineManagement {0} is not installed. Install it yourself first; this harness never installs modules.' -f $ExoVersion) }
    if ([version] $pwshVersion -lt [version] '7.0') { throw ('pwsh on PATH is {0}; PowerShell 7 is required.' -f $pwshVersion) }

    $prBuildVersion = $null
    if ($NeedsPrBuild) {
        if (-not (Test-Path -LiteralPath $GraphModulePath)) { throw ('GraphModulePath not found: {0}' -f $GraphModulePath) }
        $manifest = Import-PowerShellDataFile -Path $GraphModulePath
        $prBuildVersion = $manifest.ModuleVersion
        Write-Host ('  PR build manifest {0}: ModuleVersion {1}' -f $GraphModulePath, $prBuildVersion)
        if ($manifest.ContainsKey('NestedModules') -or $manifest.ContainsKey('RequiredAssemblies')) {
            Write-Warning 'The PR build manifest declares NestedModules or RequiredAssemblies; the PR expects neither (the psm1 initializes the load context first).'
        }
    }

    return [pscustomobject]@{ PwshPath = $pwsh.Source; PwshVersion = $pwshVersion; GraphPath = $graph.Path; ExoPath = $exo.Path; PrBuildVersion = $prBuildVersion }
}

function Test-AzWamPrecondition {
    # az-connect-then-exo only makes sense when Az actually goes through the broker. Read-only: Get-AzConfig is a query.
    try {
        $az = Get-Module -ListAvailable -Name 'Az.Accounts' | Select-Object -First 1
        if (-not $az) { return $false }
        Import-Module -Name 'Az.Accounts' -ErrorAction Stop
        $config = Get-AzConfig -EnableLoginByWam -ErrorAction Stop
        return [bool] $config.Value
    }
    catch {
        return $false
    }
}

function Test-AzTokenPrecondition {
    # graph-accesstoken-then-exo needs Az.Accounts as a non-WAM token source; nothing about its config is changed.
    return [bool] (Get-Module -ListAvailable -Name 'Az.Accounts' | Select-Object -First 1)
}

function Get-GraphTokenViaAz {
    # A Graph token from a source that never starts msalruntime. Az on this machine uses the system browser, and the
    # sign-in is process-scoped, so nothing lands in the profile. The token lives in this process's memory and in
    # the child's environment block only; the child scrubs it from everything it writes.
    Import-Module -Name 'Az.Accounts' -ErrorAction Stop
    Write-Host '    Az browser sign-in for the Graph token: complete it now.' -ForegroundColor Yellow
    $params = @{
        Tenant      = $TenantId
        Scope       = 'Process'
        ErrorAction = 'Stop'
    }
    $null = Connect-AzAccount @params
    $token = Get-AzAccessToken -ResourceTypeName MSGraph -ErrorAction Stop
    $value = $token.Token
    if ($value -is [securestring]) { $value = ConvertFrom-SecureString -SecureString $value -AsPlainText }
    $null = Disconnect-AzAccount -ErrorAction SilentlyContinue
    if ([string]::IsNullOrWhiteSpace($value)) { throw 'Get-AzAccessToken returned no token.' }
    return $value
}

function Format-ProcessArgument {
    # Start-Process joins ArgumentList with spaces and does not quote for you.
    param([string] $Value)
    if ($Value -match '"') { throw ('Argument contains a double quote, which cannot be passed safely: {0}' -f $Value) }
    if ($Value -match '\s' -or [string]::IsNullOrEmpty($Value)) { return '"{0}"' -f $Value }
    return $Value
}

function Invoke-Scenario {
    param([string] $Name, [string] $PwshPath)

    $definition = $script:Definitions.Scenarios[$Name]
    $outFile = Join-Path $ResultsPath ('{0}.json' -f $Name)
    if (Test-Path -LiteralPath $outFile) { Remove-Item -LiteralPath $outFile -Force }

    $arguments = @(
        '-NoProfile'
        '-NoLogo'
        '-ExecutionPolicy', 'Bypass'
        '-File', (Format-ProcessArgument -Value $script:ChildScript)
        '-Scenario', $Name
        '-OutFile', (Format-ProcessArgument -Value $outFile)
        '-GraphVersion', $GraphVersion
        '-ExoVersion', $ExoVersion
    )
    if ($TenantId) { $arguments += @('-TenantId', (Format-ProcessArgument -Value $TenantId)) }
    if ($UserPrincipalName) { $arguments += @('-UserPrincipalName', (Format-ProcessArgument -Value $UserPrincipalName)) }
    if ($definition.UsesPrBuild) { $arguments += @('-GraphModulePath', (Format-ProcessArgument -Value $GraphModulePath)) }

    $params = @{
        FilePath     = $PwshPath
        ArgumentList = ($arguments -join ' ')
        Wait         = $true
        PassThru     = $true
    }
    $process = Start-Process @params

    $result = $null
    if (Test-Path -LiteralPath $outFile) { $result = Get-Content -LiteralPath $outFile -Raw | ConvertFrom-Json }
    return [pscustomobject]@{ Name = $Name; ExitCode = $process.ExitCode; OutFile = $outFile; Result = $result }
}

function Show-StepOutcome {
    param($Run)
    if (-not $Run.Result) {
        Write-Host ('  child exited with code {0} and wrote no JSON' -f $Run.ExitCode) -ForegroundColor Red
        return
    }
    $rows = foreach ($s in $Run.Result.Steps) {
        [pscustomobject]@{
            Step      = $s.Name
            Outcome   = $s.Outcome
            Exception = if ($s.Exception) { $s.Exception.TypeFullName } else { '' }
            Message   = if ($s.Exception) { Get-FirstLine -Text $s.Exception.Message } else { '' }
        }
    }
    $rows | Format-Table -AutoSize | Out-String -Width 220 | Write-Host
    if (-not $Run.Result.Completed) {
        Write-Host ('  child did not complete (exit code {0}); JSON holds the steps that finished' -f $Run.ExitCode) -ForegroundColor Red
    }
}

function Test-ProbeResult {
    # The probe validates the capture code: after a binary module import the AssemblyResolve list must show
    # LoadFromResolveHandler, otherwise the handler-order evidence in the real scenarios cannot be trusted.
    param($Result)
    if (-not $Result) { throw 'probe-only produced no JSON; fix the capture code before running real scenarios.' }
    $probeStep = $Result.Steps | Where-Object { $_.Name -eq 'import-probe-module' } | Select-Object -First 1
    if (-not $probeStep -or $probeStep.Outcome -ne 'ok') { throw 'probe-only: the probe module import did not succeed.' }
    $handlers = @($probeStep.Snapshot.AssemblyResolveHandlers.Handlers | ForEach-Object { $_.Method })
    if ($handlers -notcontains $script:LoadFromHandler) {
        throw ('probe-only: expected {0} in the AssemblyResolve list, got: {1} (source: {2})' -f $script:LoadFromHandler, ($handlers -join ', '), $probeStep.Snapshot.AssemblyResolveHandlers.Source)
    }
    $captureErrors = @($Result.Steps | ForEach-Object { $_.Snapshot.CaptureErrors } | Where-Object { $_ })
    if ($captureErrors.Count -gt 0) { throw ('probe-only: capture errors: {0}' -f ($captureErrors -join '; ')) }
    if (-not $Result.Host.NativeProbeAvailable) { throw ('probe-only: the Win32 native probe did not compile: {0}' -f $Result.Host.NativeProbeError) }
    Write-Host ('  probe ok: AssemblyResolve source = {0}; handlers = {1}; native probe compiled' -f $probeStep.Snapshot.AssemblyResolveHandlers.Source, ($handlers -join ' | ')) -ForegroundColor Green
}

#endregion run helpers

#region report helpers

function Get-FirstLine {
    param([string] $Text)
    if ([string]::IsNullOrEmpty($Text)) { return '' }
    return ($Text -split "`r?`n")[0]
}

function ConvertTo-MarkdownCell {
    param([string] $Text)
    if ($null -eq $Text) { return '' }
    return (($Text -replace '\|', '\|') -replace '\r?\n', ' ').Trim()
}

function Get-Prop {
    # JSON from older child versions lacks some properties; missing must read as null, not throw.
    param($Object, [string] $Name)
    if ($null -eq $Object) { return $null }
    $p = $Object.PSObject.Properties[$Name]
    if ($p) { return $p.Value } else { return $null }
}

function Get-ShortLocation {
    # <module>\... keeps the report free of local profile paths; a source build shows as artifacts\... or prbuild\...
    param([string] $Location)
    if ([string]::IsNullOrEmpty($Location)) { return '(none)' }
    $m = [regex]::Match($Location, '(?i)(Microsoft\.Graph\.Authentication|ExchangeOnlineManagement|Az\.Accounts|Microsoft\.PowerShell\.ThreadJob|artifacts|prbuild)\\.*$')
    if ($m.Success) { return $m.Value }
    if ($env:USERPROFILE -and $Location.StartsWith($env:USERPROFILE, [System.StringComparison]::OrdinalIgnoreCase)) { return '~' + $Location.Substring($env:USERPROFILE.Length) }
    return $Location
}

function Get-RowOwner {
    # Owner is recorded by child 2.0+; older JSON falls back to the path pattern.
    param($Row)
    $owner = Get-Prop -Object $Row -Name 'Owner'
    if ($owner) { return $owner }
    $location = Get-Prop -Object $Row -Name 'Location'
    if (-not $location) { $location = Get-Prop -Object $Row -Name 'FileName' }
    if ($location -match '(?i)\\ExchangeOnlineManagement\\') { return 'EXO' }
    if ($location -match '(?i)\\Microsoft\.Graph\.Authentication\\|\\artifacts\\|\\prbuild\\') { return 'Graph' }
    if ($location -match '(?i)\\Az\.Accounts\\') { return 'Az' }
    return 'other'
}

function Get-StepRecord {
    param($Result, [string] $Name)
    if (-not $Result) { return $null }
    return $Result.Steps | Where-Object { $_.Name -eq $Name } | Select-Object -First 1
}

function Get-FinalSnapshot {
    param($Result)
    if (-not $Result -or -not $Result.Steps -or @($Result.Steps).Count -eq 0) { return $null }
    return @($Result.Steps)[-1].Snapshot
}

function Get-LastConnectStep {
    param($Result)
    if (-not $Result) { return $null }
    $connects = @($Result.Steps | Where-Object { $_.Name -like 'connect-*' })
    if ($connects.Count -eq 0) { return $null }
    return $connects[-1]
}

function Get-ExceptionText {
    param($Step)
    if (-not $Step) { return '' }
    $parts = @()
    if ($Step.Exception) { $parts += $Step.Exception.TypeFullName; $parts += $Step.Exception.ToString; $parts += $Step.Exception.Message }
    foreach ($e in @($Step.ErrorStreamEntries)) { $parts += $e.TypeFullName; $parts += $e.Message; foreach ($i in @($e.InnerChain)) { $parts += $i.Type; $parts += $i.Message } }
    return ($parts -join "`n")
}

function Get-OutcomeClass {
    # Coarse classification used by the interpretation rules; the raw exception stays in the tables.
    param($Step)
    if (-not $Step) { return 'not-run' }
    $text = Get-ExceptionText -Step $Step
    if ($Step.Outcome -eq 'ok') {
        $notes = $Step.Notes
        if ($notes -and (((Get-Prop -Object $notes -Name 'SignedIn') -eq $true) -or ((Get-Prop -Object $notes -Name 'Connected') -eq $true))) { return 'signed-in' }
        return 'ok'
    }
    if ($text -match 'NullReferenceException' -and $text -match 'RuntimeBroker') { return 'nre-runtimebroker' }
    if ($text -match 'MissingMethodException' -and $text -match 'WithLogging') { return 'withlogging-missingmethod' }
    if ($text -match '(?i)cancel') { return 'cancelled' }
    if ($Step.Outcome -eq 'nonterminating-error') { return 'nonterminating-error' }
    return 'other-exception'
}

function Test-IsolatedGraph {
    # True when the Graph module in a run isolates its identity stack in its own AssemblyLoadContext: a source
    # build of PR #3789 (GraphModulePath), or the released 2.41.0 and later, which contain that PR.
    param($Result)
    if (-not $Result) { return $false }
    if (Get-Prop -Object $Result.Requested -Name 'GraphModulePath') { return $true }
    $version = Get-Prop -Object $Result.Requested -Name 'GraphVersion'
    if ([string]::IsNullOrWhiteSpace($version)) { return $false }
    try { return ([version] $version -ge [version] '2.41.0') } catch { return $false }
}

function Get-GraphContextName {
    # The context Graph's own identity assemblies landed in, read from the snapshot rather than assumed:
    # msgraph-load-context up to 2.40.0, Microsoft.Graph.Authentication (GraphAssemblyLoadContext) from 2.41.0.
    param($Snapshot)
    $rows = @(Get-KeyAssemblyRows -Snapshot $Snapshot -Names @('Microsoft.Graph.Authentication.Core', 'Microsoft.Identity.Client', 'Azure.Identity') | Where-Object { $_.Owner -eq 'Graph' -and $_.Context -notin @('Default', '(not loaded)') })
    if ($rows.Count -gt 0) { return $rows[0].Context }
    return 'msgraph-load-context'
}

function Format-BrokerState {
    # "created=True, null=False, init=none" for one owner's first RuntimeBroker row; used by the isolated-Graph claims.
    param($Rows)
    if (@($Rows).Count -eq 0) { return 'no Broker copy' }
    $row = @($Rows)[0]
    $init = if ($row.InitException) { '{0} "{1}"' -f $row.InitException.Properties.Status, $row.InitException.Properties.Context } else { 'none' }
    return ('created={0}, null={1}, init={2}' -f $row.LazyCoreValueCreated, $row.CoreIsNull, $init)
}

function Get-StepEvidence {
    param([string] $ScenarioName, $Step)
    if (-not $Step) { return ('{0}.json: step not recorded' -f $ScenarioName) }
    $detail = 'Outcome={0}' -f $Step.Outcome
    if ($Step.Exception) { $detail += '; Exception.TypeFullName={0}' -f $Step.Exception.TypeFullName }
    elseif (@($Step.ErrorStreamEntries).Count -gt 0) { $detail += '; ErrorStreamEntries[0]={0}' -f @($Step.ErrorStreamEntries)[0].TypeFullName }
    foreach ($key in 'SignedIn', 'Connected') {
        $value = Get-Prop -Object $Step.Notes -Name $key
        if ($null -ne $value) { $detail += '; Notes.{0}={1}' -f $key, $value }
    }
    return ('{0}.json Steps[{1}]: {2}' -f $ScenarioName, $Step.Name, $detail)
}

function Get-KeyAssemblyRows {
    param($Snapshot, [string[]] $Names)
    $rows = @()
    foreach ($name in $Names) {
        $matches = @($Snapshot.Assemblies | Where-Object { $_.Name -eq $name })
        if ($matches.Count -eq 0) { $rows += [pscustomobject]@{ Name = $name; Version = ''; Context = '(not loaded)'; Location = ''; Owner = ''; Duplicate = $false }; continue }
        foreach ($a in $matches) { $rows += [pscustomobject]@{ Name = $a.Name; Version = $a.Version; Context = $a.Context; Location = $a.Location; Owner = (Get-RowOwner -Row $a); Duplicate = ($matches.Count -gt 1) } }
    }
    return $rows
}

function Get-NativeSummary {
    # "2 (Graph: Microsoft.Graph.Authentication\...; EXO: ExchangeOnlineManagement\...)"
    param($Snapshot)
    $natives = @(Get-Prop -Object $Snapshot -Name 'NativeModules' | Where-Object { $_ })
    if ($natives.Count -eq 0) { return '0' }
    $parts = @($natives | ForEach-Object { '{0}: {1}' -f (Get-RowOwner -Row $_), (Get-ShortLocation -Location $_.FileName) })
    return ('{0} ({1})' -f $natives.Count, ($parts -join '; '))
}

function Get-BareNameSummary {
    # Prefer the Win32 probe (child 2.0+), fall back to NativeLibrary.TryLoad (child 1.x).
    param($Snapshot)
    $probe = Get-Prop -Object $Snapshot -Name 'NativeInProcess'
    if ($probe -and (Get-Prop -Object $probe -Name 'Available') -eq $true) {
        $gmh = Get-Prop -Object $probe -Name 'GetModuleHandle'
        $ll = Get-Prop -Object $probe -Name 'LoadLibrary'
        if ($gmh -and $gmh.Path) {
            $text = 'GetModuleHandleW -> {0} ({1})' -f (Get-RowOwner -Row $gmh), (Get-ShortLocation -Location $gmh.Path)
            if ($ll -and (Get-Prop -Object $ll -Name 'Path')) { $text += '; LoadLibraryW -> {0} ({1}), same handle: {2}, freed: {3}' -f (Get-RowOwner -Row $ll), (Get-ShortLocation -Location $ll.Path), $ll.SameAsGetModuleHandle, $ll.Freed }
            return [pscustomobject]@{ Method = 'Win32 GetModuleHandleW/LoadLibraryW'; Owner = (Get-RowOwner -Row $gmh); Text = $text }
        }
        return [pscustomobject]@{ Method = 'Win32 GetModuleHandleW/LoadLibraryW'; Owner = $null; Text = 'nothing mapped under that name' }
    }
    $tryLoad = Get-Prop -Object $Snapshot -Name 'NativeBareNameResolvesTo'
    if ($tryLoad) {
        $owner = Get-RowOwner -Row ([pscustomobject]@{ Location = $tryLoad })
        return [pscustomobject]@{ Method = 'NativeLibrary.TryLoad'; Owner = $owner; Text = ('TryLoad -> {0} ({1})' -f $owner, (Get-ShortLocation -Location $tryLoad)) }
    }
    return [pscustomobject]@{ Method = 'none'; Owner = $null; Text = 'not probed' }
}

function New-ClaimTable {
    param($Rows)
    $lines = @()
    $lines += '| Claim | Status | Evidence |'
    $lines += '|---|---|---|'
    foreach ($r in $Rows) { $lines += ('| {0} | {1} | {2} |' -f (ConvertTo-MarkdownCell -Text $r.Claim), $r.Status, (ConvertTo-MarkdownCell -Text $r.Evidence)) }
    $lines += ''
    return $lines
}

function New-Claim {
    param([string] $Claim, [string] $Status, [string] $Evidence)
    return [pscustomobject]@{ Claim = $Claim; Status = $Status; Evidence = $Evidence }
}

function New-ScenarioSection {
    param([string] $Name, $Result, [int] $ExitCode)

    $definition = $script:Definitions.Scenarios[$Name]
    $lines = @()
    $lines += ('## {0}' -f $Name)
    $lines += ''
    if ($definition) {
        # The child records the instruction it showed; prefer that over the current scenarios.psd1 text so a report
        # regenerated after the definitions change still says what the operator was told at the time.
        $instructionGiven = if ($Result -and (Get-Prop -Object $Result -Name 'Instruction')) { $Result.Instruction } else { $definition.Instruction }
        $lines += ('Steps: {0}. Instruction given: {1}' -f ($definition.Steps -join ' -> '), $instructionGiven)
        $lines += ''
    }
    if (-not $Result) {
        $lines += ('No JSON was produced (child exit code {0}).' -f $ExitCode)
        $lines += ''
        return $lines
    }
    if (-not $Result.Completed) {
        $lines += ('Incomplete: the child did not finish (exit code {0}); only the steps below were recorded.' -f $ExitCode)
        $lines += ''
    }
    $lines += ('Child script version {0}.{1}' -f (Get-Prop -Object $Result -Name 'ScriptVersion'), $(if ((Get-Prop -Object $Result.Requested -Name 'GraphModulePath')) { ' Graph imported from path (PR build).' } else { '' }))
    $lines += ''

    $lines += '### Steps'
    $lines += ''
    $lines += '| Step | Outcome | Exception type | Message (first line) |'
    $lines += '|---|---|---|---|'
    foreach ($s in $Result.Steps) {
        $type = ''
        $message = ''
        if ($s.Exception) { $type = $s.Exception.TypeFullName; $message = Get-FirstLine -Text $s.Exception.Message }
        elseif (@($s.ErrorStreamEntries).Count -gt 0) { $first = @($s.ErrorStreamEntries)[0]; $type = $first.TypeFullName; $message = Get-FirstLine -Text $first.Message }
        $lines += ('| {0} | {1} | {2} | {3} |' -f $s.Name, $s.Outcome, (ConvertTo-MarkdownCell -Text $type), (ConvertTo-MarkdownCell -Text $message))
    }
    $lines += ''

    # The inner chain is usually where the real cause sits (EXO and Azure.Identity both wrap MSAL).
    foreach ($s in $Result.Steps) {
        if ($s.Exception) {
            $lines += ('Exception detail for {0}:' -f $s.Name)
            $lines += ''
            $lines += ('- FullyQualifiedErrorId: {0}' -f (ConvertTo-MarkdownCell -Text $s.Exception.FullyQualifiedErrorId))
            foreach ($i in @($s.Exception.InnerChain)) { $lines += ('- inner: {0}: {1}' -f $i.Type, (ConvertTo-MarkdownCell -Text (Get-FirstLine -Text $i.Message))) }
            $stack = @(($s.Exception.ToString -split "`r?`n") | Where-Object { $_ -match '^\s+at ' } | Select-Object -First 6)
            if ($stack.Count -gt 0) {
                $lines += '- top of stack:'
                $lines += ''
                $lines += '```text'
                $lines += ($stack | ForEach-Object { $_.Trim() })
                $lines += '```'
            }
            $lines += ''
        }
        elseif (@($s.ErrorStreamEntries).Count -gt 0) {
            # Non-terminating errors (Connect-MgGraph writes one instead of throwing) only exist in the error stream.
            $lines += ('Error stream detail for {0}:' -f $s.Name)
            $lines += ''
            foreach ($e in @($s.ErrorStreamEntries)) {
                $lines += ('- {0}: {1}' -f $e.TypeFullName, (ConvertTo-MarkdownCell -Text (Get-FirstLine -Text $e.Message)))
                foreach ($i in @($e.InnerChain)) { $lines += ('  - inner: {0}: {1}' -f $i.Type, (ConvertTo-MarkdownCell -Text (Get-FirstLine -Text $i.Message))) }
            }
            $lines += ''
        }
    }

    # Host-stream text lives only in the transcript; the failing lines are quoted so the report stands alone.
    if (($Result.Steps | Where-Object { $_.Outcome -ne 'ok' }) -and $Result.TranscriptPath -and (Test-Path -LiteralPath $Result.TranscriptPath)) {
        # Keep host-emitted lines only; the child's own banner and summary lines repeat the same words.
        $excerpt = @(Get-Content -LiteralPath $Result.TranscriptPath | Where-Object { $_ -match 'TerminatingError|Acquiring Token|Method not found|NullReferenceException|wam_runtime|authentication failed' -and $_ -notmatch '^(What to do|Expectation|\s*->|\S+\s+(exception|nonterminating-error|ok)\s)' } | Select-Object -Unique -First 8)
        if ($excerpt.Count -gt 0) {
            $lines += 'Host stream (transcript excerpt):'
            $lines += ''
            $lines += '```text'
            $lines += ($excerpt | ForEach-Object { $_.Trim() })
            $lines += '```'
            $lines += ''
        }
    }

    $final = Get-FinalSnapshot -Result $Result
    $lines += ('### Final snapshot (after {0})' -f @($Result.Steps)[-1].Name)
    $lines += ''
    $lines += '| Assembly | Version | Context | Owner | Location |'
    $lines += '|---|---|---|---|---|'
    foreach ($r in (Get-KeyAssemblyRows -Snapshot $final -Names $script:KeyAssemblies)) {
        $flag = if ($r.Duplicate) { ' (duplicate)' } else { '' }
        $lines += ('| {0}{1} | {2} | {3} | {4} | {5} |' -f $r.Name, $flag, $r.Version, $r.Context, $r.Owner, (ConvertTo-MarkdownCell -Text (Get-ShortLocation -Location $r.Location)))
    }
    $lines += ''

    # Every tracked assembly with the step at which it first appeared, so lazy loading is visible.
    $firstSeen = @{}
    foreach ($s in $Result.Steps) {
        foreach ($a in @($s.Snapshot.Assemblies)) {
            $key = '{0}|{1}' -f $a.Name, $a.Context
            if (-not $firstSeen.ContainsKey($key)) { $firstSeen[$key] = $s.Name }
        }
    }
    $duplicateNames = @($final.Assemblies | Group-Object -Property Name | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })
    $lines += '<details><summary>All tracked assemblies in the final snapshot</summary>'
    $lines += ''
    $lines += '| Assembly | Version | Context | Owner | First seen | Location |'
    $lines += '|---|---|---|---|---|---|'
    foreach ($a in @($final.Assemblies)) {
        $flag = if ($duplicateNames -contains $a.Name) { ' (duplicate)' } else { '' }
        $key = '{0}|{1}' -f $a.Name, $a.Context
        $lines += ('| {0}{1} | {2} | {3} | {4} | {5} | {6} |' -f $a.Name, $flag, $a.Version, $a.Context, (Get-RowOwner -Row $a), $firstSeen[$key], (ConvertTo-MarkdownCell -Text (Get-ShortLocation -Location $a.Location)))
    }
    $lines += ''
    $lines += '</details>'
    $lines += ''

    $lines += '### Native msalruntime'
    $lines += ''
    $lines += ('Count in final snapshot: {0}' -f @($final.NativeModules).Count)
    $nativeFirst = @{}
    foreach ($s in $Result.Steps) {
        foreach ($n in @($s.Snapshot.NativeModules)) { if (-not $nativeFirst.ContainsKey($n.FileName)) { $nativeFirst[$n.FileName] = $s.Name } }
    }
    foreach ($n in @($final.NativeModules)) { $lines += ('- {0}: {1} (first mapped after {2}; file version {3}; base {4})' -f (Get-RowOwner -Row $n), (Get-ShortLocation -Location $n.FileName), $nativeFirst[$n.FileName], $(if ($n.FileVersion) { $n.FileVersion } else { 'not set' }), $n.BaseAddress) }
    $lines += ''
    $lines += 'Per step (count, then the bare-name resolution result):'
    $lines += ''
    foreach ($s in $Result.Steps) {
        $paths = @($s.Snapshot.NativeModules | ForEach-Object { '{0}: {1}' -f (Get-RowOwner -Row $_), (Get-ShortLocation -Location $_.FileName) })
        $bare = Get-BareNameSummary -Snapshot $s.Snapshot
        $lines += ('- after {0}: {1}{2}; {3}' -f $s.Name, $paths.Count, $(if ($paths.Count -gt 0) { ' (' + ($paths -join '; ') + ')' } else { '' }), $bare.Text)
    }
    $lines += ''

    $targets = @(Get-Prop -Object $final -Name 'DllImportTargets' | Where-Object { $_ })
    if ($targets.Count -gt 0) {
        $lines += '### DllImport targets in each loaded Microsoft.Identity.Client.NativeInterop (final snapshot)'
        $lines += ''
        $lines += '| NativeInterop copy | Context | P/Invokes | Library names (count) |'
        $lines += '|---|---|---|---|'
        foreach ($t in $targets) {
            $names = @($t.Targets | ForEach-Object { '{0} ({1})' -f $_.Value, $_.Count }) -join ', '
            $lines += ('| {0}: {1} | {2} | {3} | {4} |' -f (Get-RowOwner -Row $t), (ConvertTo-MarkdownCell -Text (Get-ShortLocation -Location $t.Location)), $t.Context, $t.PInvokeCount, (ConvertTo-MarkdownCell -Text $names))
        }
        $lines += ''
    }

    $resolvers = Get-Prop -Object $final -Name 'DllImportResolvers'
    if ($resolvers) {
        $lines += '### DllImportResolver registrations (final snapshot)'
        $lines += ''
        $lines += ('NativeLibrary field: {0}; table exists: {1}; entries: {2}' -f $(if ($resolvers.FieldName) { $resolvers.FieldName } else { '(not found)' }), $resolvers.TableExists, $(if (@($resolvers.Entries).Count -gt 0) { (@($resolvers.Entries | ForEach-Object { '{0} [{1}]' -f $_.Assembly, $_.Context }) -join ', ') } else { 'none' }))
        foreach ($n in @($resolvers.NativeInterop)) { $lines += ('- NativeInterop {0} ({1}): resolver registered = {2}' -f (Get-RowOwner -Row $n), $n.Context, $n.HasResolver) }
        $lines += ''
    }

    # One RuntimeBroker static set per loaded copy of Microsoft.Identity.Client.Broker (read by reflection;
    # absent from JSON written by child script versions before 1.1).
    $brokerStates = @(Get-Prop -Object $final -Name 'BrokerRuntimeState' | Where-Object { $_ })
    if ($brokerStates.Count -gt 0) {
        $lines += '### RuntimeBroker statics (final snapshot)'
        $lines += ''
        $lines += '| Broker copy | Context | Lazy Core created | Core is null | s_initException |'
        $lines += '|---|---|---|---|---|'
        foreach ($b in $brokerStates) {
            $init = '(null)'
            if ($b.InitException) {
                $props = $b.InitException.Properties
                $status = if ($props.PSObject.Properties['Status']) { $props.Status } else { '?' }
                $context = if ($props.PSObject.Properties['Context']) { $props.Context } else { (Get-FirstLine -Text $props.Message) }
                $init = '{0}, Status={1}, Context="{2}"' -f $b.InitException.Type, $status, $context
            }
            $lines += ('| {0} | {1} | {2} | {3} | {4} |' -f (Get-RowOwner -Row $b), $b.Context, $b.LazyCoreValueCreated, $b.CoreIsNull, (ConvertTo-MarkdownCell -Text $init))
        }
        $lines += ''
        $lines += 'Per step (Lazy Core created / Core is null, per Broker copy):'
        $lines += ''
        foreach ($s in $Result.Steps) {
            $states = @(Get-Prop -Object $s.Snapshot -Name 'BrokerRuntimeState' | Where-Object { $_ })
            if ($states.Count -eq 0) { $lines += ('- after {0}: no Broker assembly loaded' -f $s.Name); continue }
            $parts = @($states | ForEach-Object { '{0}: created={1}, null={2}' -f (Get-RowOwner -Row $_), $_.LazyCoreValueCreated, $_.CoreIsNull })
            $lines += ('- after {0}: {1}' -f $s.Name, ($parts -join '; '))
        }
        $lines += ''
    }

    $lines += '### AppDomain.AssemblyResolve handlers (invocation order)'
    $lines += ''
    $lines += ('Source: {0}' -f $final.AssemblyResolveHandlers.Source)
    $lines += ''
    foreach ($s in $Result.Steps) {
        $handlers = @($s.Snapshot.AssemblyResolveHandlers.Handlers | ForEach-Object { $_.Method })
        $lines += ('- after {0}: {1}' -f $s.Name, $(if ($handlers.Count -gt 0) { ($handlers -join ' -> ') } else { '(none)' }))
    }
    $lines += ''

    $lines += '### Load contexts (final snapshot)'
    $lines += ''
    $lines += '| Name | Type | Assemblies | Resolving handlers |'
    $lines += '|---|---|---|---|'
    foreach ($c in @($final.LoadContexts)) {
        $resolving = @($c.ResolvingHandlers | ForEach-Object { $_.Method }) -join ', '
        $lines += ('| {0} | {1} | {2} | {3} |' -f (ConvertTo-MarkdownCell -Text $(if ($null -eq $c.Name) { '(unnamed)' } else { $c.Name })), $c.TypeName, $c.AssemblyCount, (ConvertTo-MarkdownCell -Text $resolving))
    }
    $lines += ''
    if (@($final.CaptureErrors).Count -gt 0) {
        $lines += ('Capture errors: {0}' -f ($final.CaptureErrors -join '; '))
        $lines += ''
    }
    return $lines
}

function New-Interpretation {
    param([hashtable] $Results)

    $lines = @()
    $lines += '## Interpretation'
    $lines += ''
    $lines += 'Findings follow the decision rules fixed before the run. Every claim carries a status: Observed (a value in results\*.json or a transcript line, cited), Inferred (derived from observed values plus source or metadata that was read offline, with the basis named), Prediction (not yet tested), or Not run. Anything that fits neither mechanism is reported as unexplained.'
    $lines += ''

    $importThenExo = $Results['graph-import-then-exo']
    $connectThenExo = $Results['graph-connect-then-exo']
    $cancelThenExo = $Results['graph-cancel-then-exo']
    $disableWam = $Results['graph-connect-then-exo-disablewam']
    $exoThenGraph = $Results['exo-then-graph']
    $exoOnly = $Results['exo-only']
    $azThenExo = $Results['az-connect-then-exo']

    $importClass = Get-OutcomeClass -Step (Get-StepRecord -Result $importThenExo -Name 'connect-exo')
    $connectClass = Get-OutcomeClass -Step (Get-StepRecord -Result $connectThenExo -Name 'connect-exo')
    $exoOnlyClass = Get-OutcomeClass -Step (Get-StepRecord -Result $exoOnly -Name 'connect-exo')
    $importFinal = Get-FinalSnapshot -Result $importThenExo
    $connectFinal = Get-FinalSnapshot -Result $connectThenExo

    # ---------- Finding 1 ----------
    $lines += '### Finding 1: which mechanism'
    $lines += ''
    $rows = @()
    $rows += New-Claim -Claim 'exo-only: EXO alone signs in; its identity stack lands in Default from netCore with one msalruntime (EXO''s)' -Status $(if ($exoOnly) { 'Observed' } else { 'Not run' }) -Evidence $(if ($exoOnly) { '{0}; final NativeModules: {1}' -f (Get-StepEvidence -ScenarioName 'exo-only' -Step (Get-StepRecord -Result $exoOnly -Name 'connect-exo')), (Get-NativeSummary -Snapshot (Get-FinalSnapshot -Result $exoOnly)) } else { '' })
    $rows += New-Claim -Claim 'Importing Graph without connecting leaves EXO working (graph-import-then-exo reaches a sign-in)' -Status $(switch ($importClass) { 'signed-in' { 'Observed' } 'cancelled' { 'Observed' } 'not-run' { 'Not run' } default { 'Observed: contradicted' } }) -Evidence (Get-StepEvidence -ScenarioName 'graph-import-then-exo' -Step (Get-StepRecord -Result $importThenExo -Name 'connect-exo'))
    $rows += New-Claim -Claim 'A Graph WAM sign-in first makes Connect-ExchangeOnline throw the RuntimeBroker NullReferenceException' -Status $(switch ($connectClass) { 'nre-runtimebroker' { 'Observed' } 'not-run' { 'Not run' } default { 'Observed: contradicted' } }) -Evidence $(if ($connectThenExo) { '{0}; stack frame RuntimeBroker..ctor present: {1}' -f (Get-StepEvidence -ScenarioName 'graph-connect-then-exo' -Step (Get-StepRecord -Result $connectThenExo -Name 'connect-exo')), ((Get-ExceptionText -Step (Get-StepRecord -Result $connectThenExo -Name 'connect-exo')) -match 'RuntimeBroker\.\.ctor') } else { '' })

    if ($connectThenExo) {
        $afterImportGraph = Get-StepRecord -Result $connectThenExo -Name 'import-graph'
        $afterConnectGraph = Get-StepRecord -Result $connectThenExo -Name 'connect-graph'
        $afterImportExo = Get-StepRecord -Result $connectThenExo -Name 'import-exo'
        $afterConnectExo = Get-StepRecord -Result $connectThenExo -Name 'connect-exo'
        $rows += New-Claim -Claim 'Graph''s msalruntime is mapped during Connect-MgGraph, not at import' -Status 'Observed' -Evidence ('graph-connect-then-exo.json Steps[import-graph].Snapshot.NativeModules: {0}; Steps[connect-graph]: {1}' -f (Get-NativeSummary -Snapshot $afterImportGraph.Snapshot), (Get-NativeSummary -Snapshot $afterConnectGraph.Snapshot))
        $rows += New-Claim -Claim 'EXO''s msalruntime is mapped during Connect-ExchangeOnline, not at import' -Status 'Observed' -Evidence ('graph-connect-then-exo.json Steps[import-exo].Snapshot.NativeModules: {0}; Steps[connect-exo]: {1}{2}' -f (Get-NativeSummary -Snapshot $afterImportExo.Snapshot), (Get-NativeSummary -Snapshot $afterConnectExo.Snapshot), $(if ($exoOnly) { '; exo-only.json Steps[import-exo]: ' + (Get-NativeSummary -Snapshot (Get-StepRecord -Result $exoOnly -Name 'import-exo').Snapshot) + '; Steps[connect-exo]: ' + (Get-NativeSummary -Snapshot (Get-StepRecord -Result $exoOnly -Name 'connect-exo').Snapshot) } else { '' }))
        $natives = @($connectFinal.NativeModules)
        $owners = @($natives | ForEach-Object { Get-RowOwner -Row $_ } | Sort-Object -Unique)
        # On a build where EXO signs in after Graph (2.41.2 did), the same native rows describe a success, so the
        # failure-specific wording and inferences below switch on the observed class rather than assuming the NRE.
        $connectFailed = ($connectClass -eq 'nre-runtimebroker')
        $rows += New-Claim -Claim $(if ($connectFailed) { 'After the failure two msalruntime.dll files are mapped, one from each module' } else { 'After Connect-ExchangeOnline two msalruntime.dll files are mapped, one from each module' }) -Status $(if ($natives.Count -eq 2 -and $owners -contains 'Graph' -and $owners -contains 'EXO') { 'Observed' } else { 'Observed: contradicted' }) -Evidence ('graph-connect-then-exo.json Steps[connect-exo].Snapshot.NativeModules: {0}' -f (Get-NativeSummary -Snapshot $connectFinal))
        $bare = Get-BareNameSummary -Snapshot $connectFinal
        $rows += New-Claim -Claim 'A bare-name request for msalruntime.dll in that process resolves to Graph''s copy' -Status $(if ($bare.Owner -eq 'Graph') { 'Observed' } elseif ($bare.Owner) { 'Observed: contradicted' } else { 'Not captured' }) -Evidence ('graph-connect-then-exo.json Steps[connect-exo].Snapshot: {0}: {1}' -f $bare.Method, $bare.Text)

        $targets = @(Get-Prop -Object $connectFinal -Name 'DllImportTargets' | Where-Object { (Get-RowOwner -Row $_) -eq 'EXO' })
        if ($targets.Count -gt 0) {
            $names = @($targets[0].Targets | ForEach-Object { '{0} ({1})' -f $_.Value, $_.Count }) -join ', '
            $bareOnly = @($targets[0].Targets | Where-Object { $_.Value -match '[\\/]' }).Count -eq 0
            $rows += New-Claim -Claim 'EXO''s NativeInterop declares its runtime P/Invokes against the bare name "msalruntime" (no path)' -Status $(if ($bareOnly) { 'Observed' } else { 'Observed: contradicted' }) -Evidence ('graph-connect-then-exo.json Steps[connect-exo].Snapshot.DllImportTargets[EXO]: {0} P/Invokes; library names: {1}' -f $targets[0].PInvokeCount, $names)
        }
        else {
            $rows += New-Claim -Claim 'EXO''s NativeInterop declares its runtime P/Invokes against the bare name "msalruntime" (no path)' -Status 'Inferred' -Evidence 'Offline metadata read of netCore\Microsoft.Identity.Client.NativeInterop.dll: ModuleRef names msalruntime / msalruntime_x86 / msalruntime_arm64 / kernel32; no DefaultDllImportSearchPaths attribute. Not captured in-process by this JSON (child < 2.0).'
        }
        $resolvers = Get-Prop -Object $connectFinal -Name 'DllImportResolvers'
        if ($resolvers) {
            $interopRows = @($resolvers.NativeInterop)
            $none = @($interopRows | Where-Object { $_.HasResolver }).Count -eq 0
            $rows += New-Claim -Claim 'No DllImportResolver is registered for either NativeInterop copy, so nothing pins its P/Invokes to the handle it preloaded' -Status $(if ($none) { 'Observed' } else { 'Observed: contradicted' }) -Evidence ('graph-connect-then-exo.json Steps[connect-exo].Snapshot.DllImportResolvers: field {0}; table exists {1}; entries: {2}; NativeInterop HasResolver: {3}' -f $(if ($resolvers.FieldName) { $resolvers.FieldName } else { '(not found)' }), $resolvers.TableExists, $(if (@($resolvers.Entries).Count -gt 0) { (@($resolvers.Entries | ForEach-Object { $_.Assembly }) -join ', ') } else { 'none' }), (@($interopRows | ForEach-Object { '{0}={1}' -f (Get-RowOwner -Row $_), $_.HasResolver }) -join ', '))
        }
        else {
            $rows += New-Claim -Claim 'No DllImportResolver is registered for either NativeInterop copy' -Status 'Inferred' -Evidence 'Offline metadata: no MemberRef to NativeLibrary.SetDllImportResolver in NativeInterop 0.19.4. Not captured in-process by this JSON (child < 2.0).'
        }
        $rows += New-Claim -Claim 'EXO''s NativeInterop mapped its own msalruntime by full path (a kernel32 LoadLibrary preload from runtimes\win-x64\native)' -Status 'Inferred' -Evidence 'Basis: offline metadata of NativeInterop 0.19.4 (P/Invoke kernel32!LoadLibrary; string literals "runtimes", "win-x64\native\msalruntime.dll", "PATH") plus the observation that the second mapping appears exactly at connect-exo. The preload call itself was not traced.'
        $rows += New-Claim -Claim 'EXO''s P/Invokes therefore executed against Graph''s already-started runtime rather than its own mapped copy' -Status 'Inferred' -Evidence $(if ($connectFailed) { 'Basis: the observed bare-name resolution, the observed bare-name DllImport targets, the observed absence of a resolver, and the observed init-exception Context below (a copy that was never started cannot report itself as already started). Binding was not traced with a debugger.' } else { 'Basis: the observed bare-name resolution, the observed bare-name DllImport targets, and the observed absence of a resolver. Binding was not traced with a debugger.' })
        $brokerStates = @(Get-Prop -Object $connectFinal -Name 'BrokerRuntimeState' | Where-Object { $_ })
        $exoBroker = @($brokerStates | Where-Object { (Get-RowOwner -Row $_) -eq 'EXO' })
        $graphBroker = @($brokerStates | Where-Object { (Get-RowOwner -Row $_) -eq 'Graph' })
        if ($exoBroker.Count -gt 0) {
            $init = $exoBroker[0].InitException
            $status = if ($init -and $init.Properties.PSObject.Properties['Status']) { $init.Properties.Status } else { '(none)' }
            $context = if ($init -and $init.Properties.PSObject.Properties['Context']) { $init.Properties.Context } else { '(none)' }
            $exoBrokerEvidence = 'graph-connect-then-exo.json Steps[connect-exo].Snapshot.BrokerRuntimeState[EXO]: LazyCoreValueCreated={0}; CoreIsNull={1}; InitException.Type={2}; Status={3}; Context="{4}"' -f $exoBroker[0].LazyCoreValueCreated, $exoBroker[0].CoreIsNull, $(if ($init) { $init.Type } else { 'null' }), $status, $context
            if ($connectFailed) {
                $rows += New-Claim -Claim 'EXO''s RuntimeBroker copy: lazy Core created but null; s_initException = MsalRuntimeException with Status ApiContractViolation and Context "Authenticator Factory has already been started"' -Status $(if ($init -and $status -eq 'ApiContractViolation' -and $context -match 'already been started' -and $exoBroker[0].CoreIsNull) { 'Observed' } else { 'Observed: differs' }) -Evidence $exoBrokerEvidence
            }
            else {
                $rows += New-Claim -Claim 'EXO''s RuntimeBroker copy started: lazy Core created and live, no s_initException, so the runtime its P/Invokes reached accepted a second startup' -Status $(if (-not $init -and $exoBroker[0].LazyCoreValueCreated -and -not $exoBroker[0].CoreIsNull) { 'Observed' } else { 'Observed: differs' }) -Evidence $exoBrokerEvidence
            }
        }
        else {
            $rows += New-Claim -Claim 'EXO''s RuntimeBroker copy: lazy Core null with s_initException ApiContractViolation' -Status 'Not captured' -Evidence 'BrokerRuntimeState absent from this JSON (child < 1.1).'
        }
        if ($graphBroker.Count -gt 0) {
            $rows += New-Claim -Claim 'Graph''s RuntimeBroker copy in the same process has a live Core and no init exception' -Status $(if ($graphBroker[0].LazyCoreValueCreated -and -not $graphBroker[0].CoreIsNull -and -not $graphBroker[0].InitException) { 'Observed' } else { 'Observed: differs' }) -Evidence ('graph-connect-then-exo.json Steps[connect-exo].Snapshot.BrokerRuntimeState[Graph]: LazyCoreValueCreated={0}; CoreIsNull={1}; InitException={2}' -f $graphBroker[0].LazyCoreValueCreated, $graphBroker[0].CoreIsNull, $(if ($graphBroker[0].InitException) { $graphBroker[0].InitException.Type } else { 'null' }))
        }
        if ($connectFailed) {
            $rows += New-Claim -Claim 'The NullReferenceException is the null-Core dereference in RuntimeBroker''s constructor (s_lazyCore.Value under PiiLoggingEnabled); a DLL load failure would surface as MsalClientException wam_runtime_init_failed instead' -Status 'Inferred' -Evidence 'Basis: MSAL 4.83.1 source (src/client/Microsoft.Identity.Client.Broker/RuntimeBroker.cs: the lazy factory catches only MsalRuntimeException with ApiContractViolation and returns null; every other exception is rethrown as wam_runtime_init_failed) plus the observed null Core. The release build carries no line numbers, so the exact statement is not in the stack.'
        }
        else {
            # The native runtime has no file version resource, so the NativeInterop package version each module ships is the
            # citable number; which of the two sides (the runtime or how MSAL starts it) changed behaviour is not traced here.
            $interopRows = @(Get-KeyAssemblyRows -Snapshot $connectFinal -Names @('Microsoft.Identity.Client.NativeInterop') | Where-Object { $_.Owner })
            $interopText = @($interopRows | ForEach-Object { '{0}={1} ({2})' -f $_.Owner, $_.Version, $_.Context }) -join ', '
            $rows += New-Claim -Claim 'Why the second startup is accepted on this build: the runtime Graph maps comes from a newer NativeInterop package than the one EXO carries (and than the 0.19.4 both shipped when the failure was recorded); whether the change is in msalruntime itself or in how MSAL starts it was not traced' -Status 'Inferred' -Evidence ('graph-connect-then-exo.json Steps[connect-exo].Snapshot.Assemblies[Microsoft.Identity.Client.NativeInterop]: {0}; NativeModules FileVersion: {1}' -f $interopText, $(if (@($natives | Where-Object { $_.FileVersion }).Count -gt 0) { (@($natives | ForEach-Object { '{0}={1}' -f (Get-RowOwner -Row $_), $_.FileVersion }) -join ', ') } else { 'none (msalruntime.dll carries no version resource)' }))
        }
    }
    $lines += New-ClaimTable -Rows $rows

    if ($importClass -eq 'nre-runtimebroker') {
        $lines += 'The NRE appears with Graph merely imported, so a completed Graph WAM sign-in is not a precondition.'
        $brokerRows = @(Get-KeyAssemblyRows -Snapshot $importFinal -Names @('Microsoft.Identity.Client.Broker', 'Microsoft.Identity.Client.NativeInterop'))
        foreach ($r in $brokerRows) { $lines += ('- {0}: context {1}, owner {2}, location {3}' -f $r.Name, $r.Context, $r.Owner, (Get-ShortLocation -Location $r.Location)) }
        $graphContextImport = Get-GraphContextName -Snapshot $importFinal
        $inGraphContext = @($brokerRows | Where-Object { $_.Context -eq $graphContextImport -and $_.Owner -eq 'Graph' })
        $lines += ''
        if ($inGraphContext.Count -gt 0) { $lines += ('Mechanism A (managed resolution). EXO''s broker assemblies were served by Graph''s AssemblyResolve handler into {0} from Graph''s Dependencies folder, splitting type identity. PR #3789 removes that handler on PS7, so it removes this path.' -f $graphContextImport) }
        else { $lines += ('Unexplained. The NRE occurs without a Graph connection, but EXO''s Broker/NativeInterop are not in {0} from Graph''s folder, so mechanism A as stated does not describe it. Raw evidence above.' -f $graphContextImport) }
    }
    elseif (($importClass -in @('signed-in', 'cancelled', 'ok')) -and $connectClass -eq 'nre-runtimebroker') {
        $lines += ('Mechanism B (native, process-level). graph-import-then-exo reached a sign-in while graph-connect-then-exo threw the NRE, so Graph''s native runtime being started first is the precondition. Both modules hold a private managed MSAL stack (Graph in {0}, EXO in Default); the collision is in the one msalruntime.dll a bare-name P/Invoke can reach. The native runtime loaded fine and rejected EXO''s second startup as a contract violation.' -f (Get-GraphContextName -Snapshot $connectFinal))
        $transcript = $connectThenExo.TranscriptPath
        if ($transcript -and (Test-Path -LiteralPath $transcript) -and -not (Select-String -LiteralPath $transcript -Pattern 'Acquiring Token' -Quiet)) {
            $lines += ''
            $lines += 'The "Error Acquiring Token" host text quoted in the issue thread did not appear in this transcript; the failure surfaced as a terminating error from Get-ConnectionContext wrapping the same NullReferenceException stack.'
        }
    }
    elseif (($importClass -in @('signed-in', 'cancelled', 'ok')) -and ($connectClass -in @('signed-in', 'cancelled'))) {
        $successBare = Get-BareNameSummary -Snapshot $connectFinal
        $successInterop = @(Get-KeyAssemblyRows -Snapshot $connectFinal -Names @('Microsoft.Identity.Client.NativeInterop') | Where-Object { $_.Owner })
        $lines += ('No failure to explain on this build: Connect-ExchangeOnline signed in after a Graph WAM sign-in. The native picture is the one that failed on 2.40.0 ({0} msalruntime copies; bare name -> {1}; EXO''s P/Invokes bare-name; no resolver), so EXO''s second startup went against Graph''s mapped copy and was accepted. The difference is on the native side, in the runtime each module ships (NativeInterop {2}), not in managed resolution.' -f @($connectFinal.NativeModules).Count, $(if ($successBare.Owner) { $successBare.Owner } else { 'not captured' }), (@($successInterop | ForEach-Object { '{0} {1}' -f $_.Owner, $_.Version }) -join ' vs '))
    }
    else {
        $lines += ('Unexplained. connect-exo classes were {0} (import) and {1} (connect); this does not match either predicted pattern. See the raw step tables and exception details above.' -f $importClass, $connectClass)
    }
    $lines += ''

    # ---------- Finding 2 ----------
    $lines += '### Finding 2: can Graph''s AssemblyResolve handler run before LoadFromResolveHandler?'
    $lines += ''
    $rows = @()
    $orderSource = if ($connectThenExo) { $connectThenExo } else { $importThenExo }
    $orderName = if ($connectThenExo) { 'graph-connect-then-exo' } else { 'graph-import-then-exo' }
    $afterImportGraph = Get-StepRecord -Result $orderSource -Name 'import-graph'
    $baselineStep = Get-StepRecord -Result $orderSource -Name 'baseline'
    if ($afterImportGraph) {
        $handlers = @($afterImportGraph.Snapshot.AssemblyResolveHandlers.Handlers | ForEach-Object { $_.Method })
        $baselineHandlers = @()
        if ($baselineStep) { $baselineHandlers = @($baselineStep.Snapshot.AssemblyResolveHandlers.Handlers | ForEach-Object { $_.Method }) }
        $loadFromIndex = [array]::IndexOf($handlers, $script:LoadFromHandler)
        $graphIndex = -1
        for ($i = 0; $i -lt $handlers.Count; $i++) { if ($handlers[$i] -match 'Microsoft\.Graph\.PowerShell\.Authentication') { $graphIndex = $i; break } }
        $graphCount = @($handlers | Where-Object { $_ -match 'Microsoft\.Graph\.PowerShell\.Authentication' }).Count
        $rows += New-Claim -Claim 'LoadFromResolveHandler is registered at baseline, before any module import' -Status $(if ($baselineHandlers -contains $script:LoadFromHandler) { 'Observed' } else { 'Observed: contradicted' }) -Evidence ('{0}.json Steps[baseline].Snapshot.AssemblyResolveHandlers.Handlers: {1}' -f $orderName, $(if ($baselineHandlers.Count -gt 0) { ($baselineHandlers -join ' -> ') } else { '(none)' }))
        if (Test-IsolatedGraph -Result $orderSource) {
            $rows += New-Claim -Claim 'No Graph AssemblyResolve handler is registered: from 2.41.0 Graph resolves its dependencies inside GraphAssemblyLoadContext instead of hooking AppDomain.AssemblyResolve' -Status $(if ($graphIndex -lt 0) { 'Observed' } else { 'Observed: contradicted' }) -Evidence ('{0}.json Steps[import-graph].Snapshot.AssemblyResolveHandlers.Handlers: {1}' -f $orderName, ($handlers -join ' -> '))
        }
        else {
            $rows += New-Claim -Claim ('Graph''s ModuleInitializer.ResolvingHandler is appended after it ({0} registrations, one per import of the cmdlet assembly)' -f $graphCount) -Status $(if ($graphIndex -gt $loadFromIndex -and $loadFromIndex -ge 0) { 'Observed' } elseif ($graphIndex -lt 0) { 'Observed: no Graph handler' } else { 'Observed: contradicted' }) -Evidence ('{0}.json Steps[import-graph].Snapshot.AssemblyResolveHandlers.Handlers: {1}' -f $orderName, ($handlers -join ' -> '))
        }
        $rows += New-Claim -Claim 'The runtime invokes AssemblyResolve handlers in registration order and stops at the first non-null result' -Status 'Inferred' -Evidence 'Basis: .NET runtime source, System.Runtime.Loader.AssemblyLoadContext.InvokeResolveEvent (foreach over Delegate.EnumerateInvocationList, return first non-null). Documented behavior, not observed in this process.'
        $placements = @()
        foreach ($name in @('exo-only', 'graph-import-then-exo', 'graph-connect-then-exo', 'graph-connect-then-exo-disablewam', 'exo-then-graph')) {
            $r = $Results[$name]
            if (-not $r) { continue }
            $exoRows = @((Get-FinalSnapshot -Result $r).Assemblies | Where-Object { (Get-RowOwner -Row $_) -eq 'EXO' -and $_.Name -match '^(Microsoft\.Identity|Microsoft\.IdentityModel)' })
            $contexts = @($exoRows | ForEach-Object { $_.Context } | Sort-Object -Unique)
            $placements += '{0}: {1} EXO identity assemblies in {2}' -f $name, $exoRows.Count, $(if ($contexts.Count -gt 0) { ($contexts -join '/') } else { 'n/a' })
        }
        $allDefault = @($placements | Where-Object { $_ -notmatch ' in Default$' -and $_ -notmatch ' 0 EXO' }).Count -eq 0
        $rows += New-Claim -Claim 'EXO''s identity assemblies resolved from netCore into Default in every scenario; none came from Graph''s folder' -Status $(if ($allDefault) { 'Observed' } else { 'Observed: contradicted' }) -Evidence ('final snapshots: {0}' -f ($placements -join '; '))
        $rows += New-Claim -Claim 'Mechanism A cannot occur for EXO''s own dependencies: LoadFromResolveHandler answers first for any file beside a LoadFrom-loaded requester in Default, and all of EXO''s live in netCore beside the requesters' -Status 'Inferred' -Evidence 'Basis: the four rows above (by construction).'
    }
    else {
        $rows += New-Claim -Claim 'Handler order' -Status 'Not run' -Evidence 'No import-graph step was recorded.'
    }
    $lines += New-ClaimTable -Rows $rows

    # ---------- Finding 3 ----------
    $lines += '### Finding 3: the other two directions on the released modules'
    $lines += ''
    $rows = @()
    if ($disableWam) {
        $disableStep = Get-StepRecord -Result $disableWam -Name 'connect-exo-disablewam'
        $disableFinal = Get-FinalSnapshot -Result $disableWam
        $disableClass = Get-OutcomeClass -Step $disableStep
        $exoInterop = @(Get-KeyAssemblyRows -Snapshot $disableFinal -Names @('Microsoft.Identity.Client.NativeInterop') | Where-Object { $_.Owner -eq 'EXO' })
        $exoBrokerAsm = @(Get-KeyAssemblyRows -Snapshot $disableFinal -Names @('Microsoft.Identity.Client.Broker') | Where-Object { $_.Owner -eq 'EXO' })
        $rows += New-Claim -Claim 'With -DisableWAM after a Graph sign-in, EXO signs in; its Broker assembly loads but its NativeInterop never does, and only Graph''s msalruntime is mapped' -Status $(if ($disableClass -eq 'signed-in' -and $exoInterop.Count -eq 0) { 'Observed' } elseif ($disableClass -eq 'not-run') { 'Not run' } else { 'Observed: differs' }) -Evidence ('{0}; EXO Broker loaded: {1}; EXO NativeInterop loaded: {2}; NativeModules: {3}' -f (Get-StepEvidence -ScenarioName 'graph-connect-then-exo-disablewam' -Step $disableStep), $(if ($exoBrokerAsm.Count -gt 0) { 'yes (' + $exoBrokerAsm[0].Context + ')' } else { 'no' }), $(if ($exoInterop.Count -gt 0) { 'yes (' + $exoInterop[0].Context + ')' } else { 'no' }), (Get-NativeSummary -Snapshot $disableFinal))
        $rows += New-Claim -Claim 'With the broker bypassed the RuntimeBroker constructor never runs, so nothing touches the native runtime a second time' -Status 'Inferred' -Evidence 'Basis: the row above (no NativeInterop, no second mapping) and MSAL''s broker path being the only consumer of NativeInterop.'
    }
    else { $rows += New-Claim -Claim '-DisableWAM behaviour' -Status 'Not run' -Evidence '' }
    if ($exoThenGraph) {
        $reverseStep = Get-StepRecord -Result $exoThenGraph -Name 'connect-graph'
        $reverseFinal = Get-FinalSnapshot -Result $exoThenGraph
        $reverseClass = Get-OutcomeClass -Step $reverseStep
        $abstractions = @(Get-KeyAssemblyRows -Snapshot $reverseFinal -Names @('Microsoft.IdentityModel.Abstractions'))
        $msal = @(Get-KeyAssemblyRows -Snapshot $reverseFinal -Names @('Microsoft.Identity.Client'))
        $placementText = @(($abstractions + $msal) | ForEach-Object { '{0} {1} in {2} ({3})' -f $_.Name, $_.Version, $_.Context, $_.Owner }) -join '; '
        if (Test-IsolatedGraph -Result $exoThenGraph) {
            # Isolated Graph (2.41+ or a PR build): the 2026-09-25 prediction was that this direction is fixed by
            # construction, so the rows state the prediction and what the snapshot shows about the native side.
            $graphContext = Get-GraphContextName -Snapshot $reverseFinal
            $reverseStatus = switch ($reverseClass) { 'signed-in' { 'Prediction: confirmed' } 'cancelled' { 'Prediction: confirmed' } 'withlogging-missingmethod' { 'Prediction: refuted' } default { 'Observed: differs (class {0})' -f $reverseClass } }
            $rows += New-Claim -Claim 'Prediction made before any isolated build ran: EXO first, then Connect-MgGraph no longer fails on WithLogging and reaches a Graph prompt, because Graph''s Azure.Identity can no longer bind to EXO''s MSAL in Default' -Status $reverseStatus -Evidence (Get-StepEvidence -ScenarioName 'exo-then-graph' -Step $reverseStep)
            $graphMsal = @($msal | Where-Object { $_.Owner -eq 'Graph' -and $_.Context -eq $graphContext })
            $exoMsal = @($msal | Where-Object { $_.Owner -eq 'EXO' -and $_.Context -eq 'Default' })
            $rows += New-Claim -Claim ('Microsoft.Identity.Client is loaded twice in that process: EXO''s in Default and Graph''s in {0}' -f $graphContext) -Status $(if ($graphMsal.Count -eq 1 -and $exoMsal.Count -eq 1) { 'Observed' } else { 'Observed: differs' }) -Evidence ('exo-then-graph.json Steps[connect-graph].Snapshot.Assemblies: {0}' -f $placementText)
            $reverseBrokers = @(Get-Prop -Object $reverseFinal -Name 'BrokerRuntimeState' | Where-Object { $_ })
            $rows += New-Claim -Claim 'EXO then Graph on the native side: msalruntime copies mapped, bare-name resolution, and each RuntimeBroker''s startup state (a live Graph Core beside a live EXO Core means the already-started state is per mapped module; a Graph init exception means it is process-global)' -Status 'Observed' -Evidence ('exo-then-graph.json final snapshot: NativeModules {0}; {1}; Graph broker: {2}; EXO broker: {3}' -f (Get-NativeSummary -Snapshot $reverseFinal), (Get-BareNameSummary -Snapshot $reverseFinal).Text, (Format-BrokerState -Rows @($reverseBrokers | Where-Object { (Get-RowOwner -Row $_) -eq 'Graph' })), (Format-BrokerState -Rows @($reverseBrokers | Where-Object { (Get-RowOwner -Row $_) -eq 'EXO' })))
        }
        else {
            $rows += New-Claim -Claim 'EXO first, then Connect-MgGraph fails with MissingMethodException on BaseAbstractApplicationBuilder.WithLogging(IIdentityLogger, Boolean)' -Status $(if ($reverseClass -eq 'withlogging-missingmethod') { 'Observed' } else { 'Observed: differs' }) -Evidence (Get-StepEvidence -ScenarioName 'exo-then-graph' -Step $reverseStep)
            $rows += New-Claim -Claim 'In that process Microsoft.IdentityModel.Abstractions is loaded twice (EXO''s in Default, Graph''s in msgraph-load-context) while Microsoft.Identity.Client is EXO''s copy in Default only' -Status $(if (($abstractions | Where-Object { $_.Duplicate }).Count -gt 0 -and $msal.Count -eq 1 -and $msal[0].Context -eq 'Default' -and $msal[0].Owner -eq 'EXO') { 'Observed' } else { 'Observed: differs' }) -Evidence ('exo-then-graph.json Steps[connect-graph].Snapshot.Assemblies: {0}' -f $placementText)
            $rows += New-Claim -Claim 'The MissingMethodException is the split IIdentityLogger identity: Graph''s Azure.Identity binds to EXO''s MSAL in Default, whose WithLogging is typed to Default''s Abstractions, while Azure.Identity passes the IIdentityLogger from Graph''s context' -Status 'Inferred' -Evidence 'Basis: the placement row above plus the method signature in the error text. Type identity per context was not dumped.'
        }
    }
    else { $rows += New-Claim -Claim 'EXO-then-Graph behaviour' -Status 'Not run' -Evidence '' }
    $lines += New-ClaimTable -Rows $rows

    # ---------- Finding 4 ----------
    $lines += '### Finding 4: is a completed Graph sign-in required, or just the picker?'
    $lines += ''
    $rows = @()
    if ($cancelThenExo) {
        $cancelStep = Get-StepRecord -Result $cancelThenExo -Name 'connect-graph-cancel'
        $cancelExo = Get-StepRecord -Result $cancelThenExo -Name 'connect-exo'
        $cancelClass = Get-OutcomeClass -Step $cancelStep
        $cancelExoClass = Get-OutcomeClass -Step $cancelExo
        $graphBrokerAfterCancel = @(Get-Prop -Object $cancelStep.Snapshot -Name 'BrokerRuntimeState' | Where-Object { $_ -and (Get-RowOwner -Row $_) -eq 'Graph' })
        $signedIn = (Get-Prop -Object $cancelStep.Notes -Name 'SignedIn') -eq $true
        # A picker interaction takes seconds; a sub-two-second signed-in result means WAM used its cached account and showed nothing.
        $silent = $signedIn -and ($cancelStep.DurationMs -lt 2000)
        $nativeStarted = @($cancelStep.Snapshot.NativeModules).Count -ge 1 -and $graphBrokerAfterCancel.Count -gt 0 -and $graphBrokerAfterCancel[0].LazyCoreValueCreated -and -not $graphBrokerAfterCancel[0].CoreIsNull
        if ($silent) {
            $rows += New-Claim -Claim ('The Graph picker did not appear: WAM completed the sign-in silently in {0} ms, so the cancel condition could not be exercised on this machine' -f $cancelStep.DurationMs) -Status 'Observed' -Evidence ('{0}; DurationMs={1} (an earlier picker interaction in graph-connect-then-exo-disablewam took {2} ms)' -f (Get-StepEvidence -ScenarioName 'graph-cancel-then-exo' -Step $cancelStep), $cancelStep.DurationMs, $(if ($disableWam) { (Get-StepRecord -Result $disableWam -Name 'connect-graph').DurationMs } else { 'n/a' }))
            $rows += New-Claim -Claim 'A silent Graph WAM acquisition (no UI at all) is enough to map Graph''s msalruntime and create its RuntimeBroker Core' -Status $(if ($nativeStarted) { 'Observed' } else { 'Observed: differs' }) -Evidence ('graph-cancel-then-exo.json Steps[connect-graph-cancel].Snapshot.NativeModules: {0}; BrokerRuntimeState[Graph]: {1}' -f (Get-NativeSummary -Snapshot $cancelStep.Snapshot), $(if ($graphBrokerAfterCancel.Count -gt 0) { 'created=' + $graphBrokerAfterCancel[0].LazyCoreValueCreated + ', null=' + $graphBrokerAfterCancel[0].CoreIsNull } else { 'no Broker copy loaded' }))
            $rows += New-Claim -Claim 'Whether a cancelled picker alone (no token issued) also breaks EXO' -Status 'Not run' -Evidence 'Not exercisable while WAM holds a cached account for the Graph PowerShell app; removing it is a Windows account setting the harness never changes.'
        }
        else {
            $rows += New-Claim -Claim 'The Graph WAM picker was cancelled (Connect-MgGraph ended without a signed-in context)' -Status $(if ($cancelClass -in @('cancelled', 'other-exception', 'nonterminating-error') -and -not $signedIn) { 'Observed' } else { 'Observed: differs' }) -Evidence (Get-StepEvidence -ScenarioName 'graph-cancel-then-exo' -Step $cancelStep)
            $rows += New-Claim -Claim 'Graph''s msalruntime was mapped and its RuntimeBroker Core created before the picker appeared (a cancel is enough to start the native runtime)' -Status $(if ($nativeStarted) { 'Observed' } else { 'Observed: differs' }) -Evidence ('graph-cancel-then-exo.json Steps[connect-graph-cancel].Snapshot.NativeModules: {0}; BrokerRuntimeState[Graph]: {1}' -f (Get-NativeSummary -Snapshot $cancelStep.Snapshot), $(if ($graphBrokerAfterCancel.Count -gt 0) { 'created=' + $graphBrokerAfterCancel[0].LazyCoreValueCreated + ', null=' + $graphBrokerAfterCancel[0].CoreIsNull } else { 'no Broker copy loaded' }))
        }
        $exoBrokerAfter = @(Get-Prop -Object $cancelExo.Snapshot -Name 'BrokerRuntimeState' | Where-Object { $_ -and (Get-RowOwner -Row $_) -eq 'EXO' })
        $rows += New-Claim -Claim ('Connect-ExchangeOnline after that Graph step: {0}' -f $cancelExoClass) -Status 'Observed' -Evidence ('{0}; NativeModules: {1}; bare-name: {2}; EXO RuntimeBroker: {3}' -f (Get-StepEvidence -ScenarioName 'graph-cancel-then-exo' -Step $cancelExo), (Get-NativeSummary -Snapshot $cancelExo.Snapshot), (Get-BareNameSummary -Snapshot $cancelExo.Snapshot).Text, $(if ($exoBrokerAfter.Count -gt 0 -and $exoBrokerAfter[0].InitException) { $exoBrokerAfter[0].InitException.Properties.Status + ' "' + $exoBrokerAfter[0].InitException.Properties.Context + '"' } else { 'no init exception' }))
    }
    else { $rows += New-Claim -Claim 'Cancelled Graph prompt' -Status 'Not run' -Evidence '' }
    $lines += New-ClaimTable -Rows $rows

    # ---------- Finding 5 ----------
    $lines += '### Finding 5: is it about Graph, or about any WAM user (Az.Accounts)?'
    $lines += ''
    $rows = @()
    if ($azThenExo) {
        $azStep = Get-StepRecord -Result $azThenExo -Name 'connect-az'
        $azExo = Get-StepRecord -Result $azThenExo -Name 'connect-exo'
        $azExoBroker = @(Get-Prop -Object $azExo.Snapshot -Name 'BrokerRuntimeState' | Where-Object { $_ -and (Get-RowOwner -Row $_) -eq 'EXO' })
        $rows += New-Claim -Claim 'Connect-AzAccount (WAM) first' -Status 'Observed' -Evidence (Get-StepEvidence -ScenarioName 'az-connect-then-exo' -Step $azStep)
        $rows += New-Claim -Claim ('Connect-ExchangeOnline after Az: {0}' -f (Get-OutcomeClass -Step $azExo)) -Status 'Observed' -Evidence ('{0}; NativeModules: {1}; bare-name: {2}; EXO BrokerRuntimeState: {3}' -f (Get-StepEvidence -ScenarioName 'az-connect-then-exo' -Step $azExo), (Get-NativeSummary -Snapshot $azExo.Snapshot), (Get-BareNameSummary -Snapshot $azExo.Snapshot).Text, $(if ($azExoBroker.Count -gt 0 -and $azExoBroker[0].InitException) { $azExoBroker[0].InitException.Type + ' ' + $azExoBroker[0].InitException.Properties.Status } else { 'no init exception' }))
    }
    else { $rows += New-Claim -Claim 'Az.Accounts WAM sign-in followed by EXO' -Status 'Not run' -Evidence 'Precondition not met on this machine: az-connect-then-exo requires Az.Accounts with EnableLoginByWam = true (Get-AzConfig reported false; Az config was not changed).' }
    $lines += New-ClaimTable -Rows $rows

    # ---------- Finding 5b ----------
    $lines += '### Finding 5b: a Graph token from a non-WAM source (graph-accesstoken-then-exo)'
    $lines += ''
    $rows = @()
    $tokenRun = $Results['graph-accesstoken-then-exo']
    if ($tokenRun) {
        $tokenStep = Get-StepRecord -Result $tokenRun -Name 'connect-graph-accesstoken'
        $tokenExo = Get-StepRecord -Result $tokenRun -Name 'connect-exo'
        $tokenExoClass = Get-OutcomeClass -Step $tokenExo
        $graphBrokerAfterToken = @(Get-Prop -Object $tokenStep.Snapshot -Name 'BrokerRuntimeState' | Where-Object { $_ -and (Get-RowOwner -Row $_) -eq 'Graph' })
        $graphInteropAfterToken = @(Get-KeyAssemblyRows -Snapshot $tokenStep.Snapshot -Names @('Microsoft.Identity.Client.NativeInterop') | Where-Object { $_.Owner -eq 'Graph' })
        $exoBrokerAfterToken = @(Get-Prop -Object $tokenExo.Snapshot -Name 'BrokerRuntimeState' | Where-Object { $_ -and (Get-RowOwner -Row $_) -eq 'EXO' })
        $rows += New-Claim -Claim 'Prediction made before the run: handed a token, Graph never starts msalruntime, so EXO works afterwards' -Status $(if ($tokenExoClass -in @('signed-in', 'cancelled')) { 'Prediction: confirmed' } elseif ($tokenExoClass -eq 'not-run') { 'Prediction' } else { 'Prediction: refuted' }) -Evidence (Get-StepEvidence -ScenarioName 'graph-accesstoken-then-exo' -Step $tokenExo)
        $rows += New-Claim -Claim 'Connect-MgGraph -AccessToken connected without touching WAM: no msalruntime mapped, no Graph NativeInterop or RuntimeBroker loaded' -Status $(if ($tokenStep.Outcome -eq 'ok' -and @($tokenStep.Snapshot.NativeModules).Count -eq 0 -and $graphInteropAfterToken.Count -eq 0 -and $graphBrokerAfterToken.Count -eq 0) { 'Observed' } elseif ($tokenStep.Outcome -ne 'ok') { 'Observed: the token step failed' } else { 'Observed: differs' }) -Evidence ('{0}; Snapshot.NativeModules: {1}; Graph NativeInterop loaded: {2}; Graph Broker copies: {3}' -f (Get-StepEvidence -ScenarioName 'graph-accesstoken-then-exo' -Step $tokenStep), (Get-NativeSummary -Snapshot $tokenStep.Snapshot), $(if ($graphInteropAfterToken.Count -gt 0) { 'yes' } else { 'no' }), $graphBrokerAfterToken.Count)
        $rows += New-Claim -Claim ('Connect-ExchangeOnline afterwards: {0}' -f $tokenExoClass) -Status 'Observed' -Evidence ('{0}; NativeModules: {1}; bare-name: {2}; EXO RuntimeBroker: {3}' -f (Get-StepEvidence -ScenarioName 'graph-accesstoken-then-exo' -Step $tokenExo), (Get-NativeSummary -Snapshot $tokenExo.Snapshot), (Get-BareNameSummary -Snapshot $tokenExo.Snapshot).Text, $(if ($exoBrokerAfterToken.Count -gt 0) { 'created=' + $exoBrokerAfterToken[0].LazyCoreValueCreated + ', null=' + $exoBrokerAfterToken[0].CoreIsNull + ', init=' + $(if ($exoBrokerAfterToken[0].InitException) { $exoBrokerAfterToken[0].InitException.Properties.Status } else { 'none' }) } else { 'no Broker copy' }))
    }
    else { $rows += New-Claim -Claim 'Graph via -AccessToken from a non-WAM source, then EXO' -Status 'Not run' -Evidence '' }
    $lines += New-ClaimTable -Rows $rows

    # ---------- Finding 6 ----------
    # The isolated build is either a source build of PR #3789 (pr-* scenarios, -GraphModulePath) or, from 2.41.0,
    # the released module itself, in which case the standard scenarios are the evidence.
    $prConnect = $Results['pr-graph-connect-then-exo']
    $prReverse = $Results['pr-exo-then-graph']
    $prImport = $Results['pr-graph-import-then-exo']
    $prAny = $prConnect -or $prReverse -or $prImport
    $released = @($Results.Values | Where-Object { $_ -and -not (Get-Prop -Object $_.Requested -Name 'GraphModulePath') -and (Test-IsolatedGraph -Result $_) })
    if (-not $prAny -and $released.Count -gt 0) {
        $isoLabel = 'Microsoft.Graph.Authentication {0} (released build containing PR #3789)' -f $released[0].Requested.GraphVersion
        $isoConnect = $connectThenExo
        $isoReverse = $exoThenGraph
        $isoImport = $importThenExo
        $trio = @(@('graph-import-then-exo', $isoImport, 'connect-exo'), @('graph-connect-then-exo', $isoConnect, 'connect-exo'), @('exo-then-graph', $isoReverse, 'connect-graph'))
    }
    else {
        $isoLabel = 'PR #3789 build'
        $isoConnect = $prConnect
        $isoReverse = $prReverse
        $isoImport = $prImport
        $trio = @(@('pr-graph-import-then-exo', $isoImport, 'connect-exo'), @('pr-graph-connect-then-exo', $isoConnect, 'connect-exo'), @('pr-exo-then-graph', $isoReverse, 'connect-graph'))
    }
    $isoAny = $isoConnect -or $isoReverse -or $isoImport
    $lines += ('### Finding 6: {0}' -f $isoLabel)
    $lines += ''
    $rows = @()
    $prConnectClass = Get-OutcomeClass -Step (Get-StepRecord -Result $isoConnect -Name 'connect-exo')
    $prReverseClass = Get-OutcomeClass -Step (Get-StepRecord -Result $isoReverse -Name 'connect-graph')
    $prImportClass = Get-OutcomeClass -Step (Get-StepRecord -Result $isoImport -Name 'connect-exo')
    $notRunText = if ($released.Count -gt 0) { 'Not run on this Graph version yet.' } else { 'Not yet tested; see build-notes.md.' }
    $rows += New-Claim -Claim 'Prediction made before the PR build ran: Graph-then-EXO still fails after the PR, because the PR pins Graph''s P/Invokes to Graph''s copy (LoadUnmanagedDll override) while EXO''s stay bare-name in Default' -Status $(if ($isoConnect) { $(if ($prConnectClass -eq 'nre-runtimebroker') { 'Prediction: confirmed' } else { 'Prediction: refuted' }) } else { 'Prediction' }) -Evidence $(if ($isoConnect) { Get-StepEvidence -ScenarioName $trio[1][0] -Step (Get-StepRecord -Result $isoConnect -Name 'connect-exo') } else { $notRunText })
    if ($isoAny) {
        $rows += New-Claim -Claim 'Prediction made before the PR build ran: EXO-then-Graph is fixed by construction, because Graph''s Azure.Identity can no longer bind to EXO''s MSAL in Default' -Status $(if ($isoReverse) { $(if ($prReverseClass -in @('signed-in', 'cancelled')) { 'Prediction: confirmed' } elseif ($prReverseClass -eq 'withlogging-missingmethod') { 'Prediction: refuted' } else { 'Observed: differs (class {0})' -f $prReverseClass }) } else { 'Prediction' }) -Evidence $(if ($isoReverse) { Get-StepEvidence -ScenarioName $trio[2][0] -Step (Get-StepRecord -Result $isoReverse -Name 'connect-graph') } else { 'Not run' })
        foreach ($pair in $trio) {
            $name = $pair[0]
            $r = $pair[1]
            if (-not $r) { $rows += New-Claim -Claim $name -Status 'Not run' -Evidence ''; continue }
            $lastStep = Get-StepRecord -Result $r -Name $pair[2]
            $final = Get-FinalSnapshot -Result $r
            $graphInterop = @(Get-KeyAssemblyRows -Snapshot $final -Names @('Microsoft.Identity.Client.NativeInterop') | Where-Object { $_.Owner -eq 'Graph' })
            $exoBrokerState = @(Get-Prop -Object $final -Name 'BrokerRuntimeState' | Where-Object { $_ -and (Get-RowOwner -Row $_) -eq 'EXO' })
            $graphBrokerState = @(Get-Prop -Object $final -Name 'BrokerRuntimeState' | Where-Object { $_ -and (Get-RowOwner -Row $_) -eq 'Graph' })
            $rows += New-Claim -Claim ('{0}: last connect step class = {1}' -f $name, (Get-OutcomeClass -Step $lastStep)) -Status 'Observed' -Evidence (Get-StepEvidence -ScenarioName $name -Step $lastStep)
            $rows += New-Claim -Claim ('{0}: Graph''s NativeInterop load context' -f $name) -Status 'Observed' -Evidence ('{0}.json final snapshot: {1}' -f $name, $(if ($graphInterop.Count -gt 0) { $graphInterop[0].Context + ' (' + (Get-ShortLocation -Location $graphInterop[0].Location) + ')' } else { 'not loaded' }))
            $rows += New-Claim -Claim ('{0}: native mappings and bare-name resolution' -f $name) -Status 'Observed' -Evidence ('{0}.json final snapshot: NativeModules {1}; {2}' -f $name, (Get-NativeSummary -Snapshot $final), (Get-BareNameSummary -Snapshot $final).Text)
            $rows += New-Claim -Claim ('{0}: RuntimeBroker statics' -f $name) -Status 'Observed' -Evidence ('{0}.json final snapshot: Graph {1}; EXO {2}' -f $name, $(if ($graphBrokerState.Count -gt 0) { 'created=' + $graphBrokerState[0].LazyCoreValueCreated + ', null=' + $graphBrokerState[0].CoreIsNull + ', init=' + $(if ($graphBrokerState[0].InitException) { $graphBrokerState[0].InitException.Properties.Status } else { 'none' }) } else { 'no Broker copy' }), $(if ($exoBrokerState.Count -gt 0) { 'created=' + $exoBrokerState[0].LazyCoreValueCreated + ', null=' + $exoBrokerState[0].CoreIsNull + ', init=' + $(if ($exoBrokerState[0].InitException) { $exoBrokerState[0].InitException.Properties.Status + ' "' + $exoBrokerState[0].InitException.Properties.Context + '"' } else { 'none' }) } else { 'no Broker copy' }))
        }
    }
    elseif ($released.Count -gt 0) {
        $rows += New-Claim -Claim 'graph-import-then-exo, graph-connect-then-exo, exo-then-graph' -Status 'Not run' -Evidence $notRunText
    }
    else {
        $rows += New-Claim -Claim 'pr-graph-import-then-exo, pr-graph-connect-then-exo, pr-exo-then-graph' -Status 'Not run' -Evidence 'No build of the PR was available (no .NET SDK on this machine and no downloadable CI artifact; see build-notes.md).'
    }
    $lines += New-ClaimTable -Rows $rows

    # ---------- Implication ----------
    $lines += '### Implication for PR #3789'
    $lines += ''
    if ($isoAny) {
        $lines += ('Observed on {0}: Graph-then-EXO = {1}; EXO-then-Graph = {2}; Graph-import-then-EXO = {3}.' -f $isoLabel, $prConnectClass, $prReverseClass, $prImportClass)
        if ($prConnectClass -eq 'nre-runtimebroker') { $lines += 'The PR fixes EXO-then-Graph (if the row above shows a sign-in) and does not fix Graph-then-EXO. The fix for that direction has to come from MSAL''s NativeInterop (pin P/Invokes to the preloaded handle, or tolerate a second startup); -DisableWAM remains the workaround.' }
        elseif ($prConnectClass -in @('signed-in', 'cancelled')) {
            $isoFinal = Get-FinalSnapshot -Result $isoConnect
            $isoBare = Get-BareNameSummary -Snapshot $isoFinal
            $isoExoBroker = @(Get-Prop -Object $isoFinal -Name 'BrokerRuntimeState' | Where-Object { $_ -and (Get-RowOwner -Row $_) -eq 'EXO' })
            if ($isoBare.Owner -eq 'Graph' -and $isoExoBroker.Count -gt 0 -and -not $isoExoBroker[0].InitException) {
                $lines += 'Graph-then-EXO works on the isolated build, which refutes the prediction, though not because EXO reached a different copy: the bare name still resolves to Graph''s mapped msalruntime and EXO''s RuntimeBroker started cleanly against it, so the second startup was accepted rather than avoided. The isolation changed the managed side only; the native change is the runtime Graph ships (Finding 1, last row).'
            }
            else {
                $lines += 'Graph-then-EXO works on the isolated build, which refutes the prediction: pinning Graph''s copy was enough. Re-read the native rows above for why (most likely a second, unstarted mapping being the one EXO reached).'
            }
        }
        if ($prReverseClass -in @('signed-in', 'cancelled')) { $lines += 'EXO-then-Graph reached a Graph sign-in: the WithLogging failure is gone, as predicted.' }
        elseif ($prReverseClass -eq 'withlogging-missingmethod') { $lines += 'EXO-then-Graph still fails on WithLogging: the isolation did not stop Graph binding to EXO''s MSAL; check the Microsoft.Identity.Client placement row in Finding 3.' }
        elseif ($isoReverse) { $lines += ('EXO-then-Graph failed with a different class ({0}): the exception detail is in the exo-then-graph section above, and its native rows show whether a second msalruntime startup is what failed.' -f $prReverseClass) }
    }
    elseif ($importClass -eq 'nre-runtimebroker') {
        $lines += 'If Finding 1 landed on mechanism A, the PR''s removal of the AppDomain.AssemblyResolve handler on PS7 addresses Graph-then-EXO as well as EXO-then-Graph.'
    }
    elseif ($connectClass -eq 'nre-runtimebroker') {
        $lines += 'Prediction (untested until Finding 6 runs): the PR isolates managed code and pins only Graph''s own P/Invokes to Graph''s copy. The msalruntime that Graph loads is still the first module of that name in the process, EXO''s NativeInterop still P/Invokes by bare name, so EXO''s second startup should still be rejected. EXO-then-Graph should be fixed by construction (Graph''s Azure.Identity can no longer bind to EXO''s MSAL). If both hold, the fix for Graph-then-EXO belongs in MSAL''s NativeInterop (bind P/Invokes to the handle it preloaded, or tolerate a second startup); -DisableWAM remains the workaround.'
    }
    else {
        $lines += 'No implication can be stated because Finding 1 is unexplained.'
    }
    $lines += ''
    return $lines
}

function New-LoadOrderReport {
    param([string] $Path, [hashtable] $Runs)

    $ordered = @($script:Definitions.Order | Where-Object { $Runs.ContainsKey($_) })
    $results = @{}
    foreach ($name in $ordered) { $results[$name] = $Runs[$name].Result }

    $lines = @()
    $lines += '# Graph-then-EXO load-order diagnostic'
    $lines += ''
    $anyResult = $ordered | ForEach-Object { $results[$_] } | Where-Object { $_ } | Select-Object -First 1
    if ($anyResult) {
        $lines += ('Generated {0}. Host: PowerShell {1} ({2}), {3}, {4}, process {5}.' -f [DateTime]::Now.ToString('yyyy-MM-dd HH:mm'), $anyResult.Host.PSVersion, $anyResult.Host.PSEdition, $anyResult.Host.FrameworkDescription, $anyResult.Host.OSVersion, $anyResult.Host.ProcessArchitecture)
        $lines += ('Requested modules: Microsoft.Graph.Authentication {0}, ExchangeOnlineManagement {1}. Every scenario ran in its own fresh pwsh -NoProfile process.' -f $anyResult.Requested.GraphVersion, $anyResult.Requested.ExoVersion)
    }
    else {
        $lines += ('Generated {0}. No scenario produced results.' -f [DateTime]::Now.ToString('yyyy-MM-dd HH:mm'))
    }
    $lines += ''
    $lines += 'Snapshots were taken after every step: tracked managed assemblies with their load context, all load contexts, native msalruntime modules with the in-process bare-name resolution (Win32 GetModuleHandleW/LoadLibraryW and NativeLibrary.TryLoad), DllImport targets and DllImportResolver registrations of every loaded NativeInterop, the AppDomain.AssemblyResolve invocation list, RuntimeBroker statics, and module versions. Full detail is in results\<scenario>.json; host output is in results\<scenario>.transcript.txt. The tenant ID and account hint were scrubbed from both at write time. Status vocabulary: Observed, Inferred, Prediction, Not run.'
    $lines += ''

    $lines += '## Summary'
    $lines += ''
    $lines += '| Scenario | Child | Completed | Step outcomes | Last connect step class | msalruntime copies |'
    $lines += '|---|---|---|---|---|---|'
    foreach ($name in $ordered) {
        $r = $results[$name]
        if (-not $r) { $lines += ('| {0} | | no JSON | | | |' -f $name); continue }
        $outcomes = @($r.Steps | ForEach-Object { '{0}={1}' -f $_.Name, $_.Outcome }) -join ', '
        $lastConnect = Get-LastConnectStep -Result $r
        $lastClass = if ($lastConnect) { Get-OutcomeClass -Step $lastConnect } else { '' }
        $final = Get-FinalSnapshot -Result $r
        $lines += ('| {0} | {1} | {2} | {3} | {4} | {5} |' -f $name, (Get-Prop -Object $r -Name 'ScriptVersion'), $r.Completed, (ConvertTo-MarkdownCell -Text $outcomes), $lastClass, @($final.NativeModules).Count)
    }
    $notRun = @($script:Definitions.Order | Where-Object { -not $Runs.ContainsKey($_) })
    if ($notRun.Count -gt 0) {
        $lines += ''
        $lines += ('Defined but not run: {0}.' -f ($notRun -join ', '))
    }
    $lines += ''

    foreach ($name in $ordered) { $lines += New-ScenarioSection -Name $name -Result $results[$name] -ExitCode $Runs[$name].ExitCode }

    $lines += New-Interpretation -Results $results

    $params = @{
        LiteralPath = $Path
        Value       = ($lines -join [Environment]::NewLine)
        Encoding    = 'utf8'
    }
    Set-Content @params
}

function Get-ExistingRuns {
    # Rebuild the run table from whatever JSON is on disk (ReportOnly, or after running scenarios one at a time).
    $runs = @{}
    foreach ($name in $script:Definitions.Order) {
        $file = Join-Path $ResultsPath ('{0}.json' -f $name)
        if (-not (Test-Path -LiteralPath $file)) { continue }
        $result = Get-Content -LiteralPath $file -Raw | ConvertFrom-Json
        $runs[$name] = [pscustomobject]@{ Name = $name; ExitCode = $(if ($result.Completed) { 0 } else { -1 }); OutFile = $file; Result = $result }
    }
    return $runs
}

#endregion report helpers

#region main

if (-not (Test-Path -LiteralPath $ResultsPath)) { $null = New-Item -Path $ResultsPath -ItemType Directory -Force }

if ($ReportOnly) {
    $runs = Get-ExistingRuns
    if ($runs.Count -eq 0) { throw ('No JSON results found under {0}.' -f $ResultsPath) }
    New-LoadOrderReport -Path $script:ReportPath -Runs $runs
    Write-Host ('Report written: {0}' -f $script:ReportPath) -ForegroundColor Green
    return
}

if ($Scenario) {
    $unknown = @($Scenario | Where-Object { $script:Definitions.Order -notcontains $_ })
    if ($unknown.Count -gt 0) { throw ('Unknown scenario(s): {0}. Known: {1}' -f ($unknown -join ', '), ($script:Definitions.Order -join ', ')) }
}

# Preconditions decide silently unless the operator asked for the scenario by name.
$azWamChecked = $false
$azWam = $false
$selected = @()
foreach ($name in $script:Definitions.Order) {
    $definition = $script:Definitions.Scenarios[$name]
    $explicit = [bool] ($Scenario -and ($Scenario -contains $name))
    if ($Scenario -and -not $explicit) { continue }
    if ($definition.UsesPrBuild -and [string]::IsNullOrWhiteSpace($GraphModulePath)) {
        if ($explicit) { throw ('{0} needs -GraphModulePath pointing at a build of PR #3789.' -f $name) }
        continue
    }
    if ($definition.Precondition -eq 'AzWam') {
        if (-not $azWamChecked) { $azWam = Test-AzWamPrecondition; $azWamChecked = $true }
        if (-not $azWam) {
            if ($explicit) { throw ('{0} needs Az.Accounts with EnableLoginByWam = true (Get-AzConfig); the precondition is not met and Az config is never changed here.' -f $name) }
            continue
        }
    }
    if ($definition.Precondition -eq 'AzToken' -and -not (Test-AzTokenPrecondition)) {
        if ($explicit) { throw ('{0} needs Az.Accounts installed as the non-WAM token source.' -f $name) }
        continue
    }
    $selected += $name
}
if ($selected.Count -eq 0) { throw 'No scenario selected.' }

$needsIdentity = @($selected | Where-Object { $_ -notin @('probe-only', 'imports-only') }).Count -gt 0
if ($needsIdentity -and ([string]::IsNullOrWhiteSpace($TenantId) -or [string]::IsNullOrWhiteSpace($UserPrincipalName))) {
    throw 'TenantId and UserPrincipalName are required for every scenario except probe-only and imports-only.'
}
$needsPrBuild = @($selected | Where-Object { $script:Definitions.Scenarios[$_].UsesPrBuild }).Count -gt 0

$prereq = Test-Prerequisite -NeedsPrBuild $needsPrBuild
Write-Host ''

$runs = @{}
$index = 0
foreach ($name in $selected) {
    $index++
    $definition = $script:Definitions.Scenarios[$name]
    Write-Host ('>>> [{0}/{1}] {2}: {3}' -f $index, $selected.Count, $name, $definition.Instruction) -ForegroundColor Yellow
    if ($Pause) { $null = Read-Host -Prompt '    Press Enter to launch the scenario window' }

    if ($definition.Precondition -eq 'AzToken') {
        # Token in the environment block for the child only; cleared here the moment the child has exited.
        $tokenValue = Get-GraphTokenViaAz
        [System.Environment]::SetEnvironmentVariable('LOADORDER_GRAPH_TOKEN', $tokenValue)
        try { $run = Invoke-Scenario -Name $name -PwshPath $prereq.PwshPath }
        finally {
            [System.Environment]::SetEnvironmentVariable('LOADORDER_GRAPH_TOKEN', $null)
            $tokenValue = $null
        }
    }
    else {
        $run = Invoke-Scenario -Name $name -PwshPath $prereq.PwshPath
    }
    $runs[$name] = $run
    Show-StepOutcome -Run $run

    if ($name -eq 'probe-only') { Test-ProbeResult -Result $run.Result }
}

if (-not $SkipReport) {
    # Merge with earlier runs so report.md always covers everything on disk, not just this invocation.
    $allRuns = Get-ExistingRuns
    foreach ($key in $runs.Keys) { $allRuns[$key] = $runs[$key] }
    New-LoadOrderReport -Path $script:ReportPath -Runs $allRuns
    Write-Host ('Report written: {0}' -f $script:ReportPath) -ForegroundColor Green
}

#endregion main
