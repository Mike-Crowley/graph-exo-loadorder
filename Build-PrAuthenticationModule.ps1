#Requires -Version 7.0
<#
.SYNOPSIS
Builds Microsoft.Graph.Authentication from the PR #3789 checkout under .\src, without the documentation steps.

.DESCRIPTION
The repository's own src/Authentication/Authentication/build-module.ps1 does two things: compile (dotnet publish
of Authentication.Core for three target frameworks, the Loader, and the cmdlet assembly) and lay the results out
as Dependencies\, Dependencies\Core and Dependencies\Desktop, which is the layout the psm1 and the
GraphAssemblyLoadContext expect. In between it regenerates help with platyPS (New-ExternalHelp) and several
markdown scripts. None of that touches the assemblies, and platyPS is not installed here, so this script
reproduces only the compile and layout halves, copying the checked-in help XML files instead.

A bare "dotnet build" is not enough because the psm1 depends on the Dependencies layout; this script produces it.

Requires a .NET SDK (8.0 or later) on PATH. It installs nothing: if the SDK is missing it stops and says so.

.PARAMETER SourceRoot
Root of the sparse clone (the folder that contains Repo.props and src\Authentication).

.PARAMETER OutputPath
Where the module is laid out. Import it by path: Import-Module <OutputPath>\Microsoft.Graph.Authentication.psd1
#>
[CmdletBinding()]
param(
    [string] $SourceRoot = (Join-Path $PSScriptRoot 'src'),

    [string] $OutputPath = (Join-Path $PSScriptRoot 'prbuild\Microsoft.Graph.Authentication'),

    [ValidateSet('Debug', 'Release')]
    [string] $Configuration = 'Release'
)

$ErrorActionPreference = 'Stop'

$netStandard = 'netstandard2.0'
$netApp = 'net6.0'
$netFx = 'net472'
$copyExtensions = @('.dll', '.pdb')

$dotnet = Get-Command -Name dotnet -CommandType Application -ErrorAction SilentlyContinue
if (-not $dotnet) { throw 'No .NET SDK found (dotnet is not on PATH). Install a .NET SDK 8.0 or later yourself, open a new shell, and rerun. This script never installs anything.' }
$sdks = @(& $dotnet.Source --list-sdks 2>&1 | Where-Object { $_ -match '^\d+\.\d+\.\d+' })
if ($sdks.Count -eq 0) { throw 'dotnet is on PATH but reports no SDKs (runtime only). Install a .NET SDK 8.0 or later yourself and rerun.' }
$newest = ($sdks | ForEach-Object { [version] ($_ -split '\s')[0] } | Sort-Object -Descending | Select-Object -First 1)
if ($newest -lt [version] '8.0') { throw ('Newest .NET SDK is {0}; 8.0 or later is needed (net6.0 and net472 targeting packs are restored from NuGet by newer SDKs).' -f $newest) }
Write-Host ('Using .NET SDK {0}' -f $newest) -ForegroundColor Cyan

$authRoot = Join-Path $SourceRoot 'src\Authentication'
$coreSrc = Join-Path $authRoot 'Authentication.Core'
$loaderSrc = Join-Path $authRoot 'Authentication.Loader'
$cmdletsSrc = Join-Path $authRoot 'Authentication'
foreach ($folder in $coreSrc, $loaderSrc, $cmdletsSrc) {
    if (-not (Test-Path -LiteralPath $folder)) { throw ('Source folder missing: {0}. Is the sparse checkout at src\Authentication present?' -f $folder) }
}

function Invoke-Publish {
    # One publish per target framework, mirroring build-module.ps1; the exit code is the only reliable failure signal.
    param([string] $Project, [string] $Framework)
    $arguments = @('publish', '-c', $Configuration, '--nologo')
    if ($Framework) { $arguments += @('-f', $Framework) }
    Push-Location $Project
    try {
        Write-Host ('dotnet {0}  [{1}]' -f ($arguments -join ' '), $Project) -ForegroundColor DarkGray
        & $dotnet.Source @arguments
        if ($LASTEXITCODE -ne 0) { throw ('dotnet publish failed (exit {0}) for {1} {2}' -f $LASTEXITCODE, $Project, $Framework) }
    }
    finally { Pop-Location }
}

Write-Host 'Cleaning bin/obj...' -ForegroundColor Green
foreach ($folder in $coreSrc, $loaderSrc, $cmdletsSrc) {
    Remove-Item -Path (Join-Path $folder 'bin'), (Join-Path $folder 'obj') -Recurse -Force -ErrorAction Ignore
}

Write-Host 'Compiling...' -ForegroundColor Green
Invoke-Publish -Project $coreSrc -Framework $netStandard
Invoke-Publish -Project $coreSrc -Framework $netApp
Invoke-Publish -Project $coreSrc -Framework $netFx
Invoke-Publish -Project $loaderSrc -Framework $netApp
Invoke-Publish -Project $cmdletsSrc

# Layout, copied from build-module.ps1 so the result matches what the release pipeline would produce.
$outDir = $OutputPath
$outDeps = Join-Path $outDir 'Dependencies'
$outCore = Join-Path $outDeps 'Core'
$outDesktop = Join-Path $outDeps 'Desktop'
if (Test-Path -LiteralPath $outDir) { Remove-Item -LiteralPath $outDir -Recurse -Force }
foreach ($folder in $outDir, $outDeps, $outCore, $outDesktop) { $null = New-Item -Path $folder -ItemType Directory -Force }

Write-Host 'Laying out the module...' -ForegroundColor Green
$prefix = 'Microsoft.Graph.Authentication'
Copy-Item -Path (Join-Path $cmdletsSrc "$prefix.format.ps1xml") -Destination $outDir
Copy-Item -Path (Join-Path $cmdletsSrc "$prefix.psm1") -Destination $outDir
Copy-Item -Path (Join-Path $cmdletsSrc "$prefix.psd1") -Destination $outDir
Copy-Item -Path (Join-Path $cmdletsSrc 'StartupScripts') -Filter '*.ps1' -Recurse -Destination $outDir
# Checked-in help instead of regenerating it with platyPS.
foreach ($help in "$prefix.dll-Help.xml", "$prefix-Help.xml") {
    $helpPath = Join-Path $cmdletsSrc $help
    if (Test-Path -LiteralPath $helpPath) { Copy-Item -Path $helpPath -Destination $outDir }
}
Copy-Item -Path (Join-Path $cmdletsSrc 'custom') -Recurse -Destination $outDir

# Shared with the cmdlet assembly and the generated service modules, so it must stay in the module root (Default context).
$sharedAssemblies = @('Newtonsoft.Json')
# The engine assembly must NOT be in the module root, otherwise PowerShell would load it into Default.
$coreAssemblies = @('Microsoft.Graph.Authentication.Core')

$deps = [System.Collections.Generic.HashSet[string]]::new()
$standardPublish = Join-Path $coreSrc "bin\$Configuration\$netStandard\publish"
$appPublish = Join-Path $coreSrc "bin\$Configuration\$netApp\publish"
$fxPublish = Join-Path $coreSrc "bin\$Configuration\$netFx\publish"
$loaderPublish = Join-Path $loaderSrc "bin\$Configuration\$netApp\publish"
$cmdletPublish = Join-Path $cmdletsSrc "bin\$Configuration\$netStandard\publish"

foreach ($file in Get-ChildItem -Path $standardPublish -File) {
    if ($file.Extension -notin $copyExtensions) { continue }
    if ($coreAssemblies -contains $file.BaseName -or $sharedAssemblies -contains $file.BaseName) { continue }
    [void] $deps.Add($file.Name)
    Copy-Item -Path $file.FullName -Destination $outDeps
}
foreach ($file in Get-ChildItem -Path $appPublish -File) {
    if ($sharedAssemblies -contains $file.BaseName) { continue }
    [void] $deps.Add($file.Name)
    Copy-Item -Path $file.FullName -Destination $outCore
}
foreach ($file in Get-ChildItem -Path $fxPublish -File) {
    if ($sharedAssemblies -contains $file.BaseName) { continue }
    [void] $deps.Add($file.Name)
    Copy-Item -Path $file.FullName -Destination $outDesktop
}
foreach ($file in Get-ChildItem -Path $loaderPublish -File) {
    if ($file.BaseName -ne 'Microsoft.Graph.Authentication.Loader' -or $file.Extension -notin $copyExtensions) { continue }
    [void] $deps.Add($file.Name)
    Copy-Item -Path $file.FullName -Destination $outCore
}
foreach ($file in Get-ChildItem -Path $standardPublish -File) {
    if ($sharedAssemblies -notcontains $file.BaseName -or $file.Extension -notin $copyExtensions) { continue }
    [void] $deps.Add($file.Name)
    Copy-Item -Path $file.FullName -Destination $outDir
}
foreach ($file in Get-ChildItem -Path $cmdletPublish -File) {
    if ($deps.Contains($file.Name) -or $file.Extension -notin $copyExtensions) { continue }
    Copy-Item -Path $file.FullName -Destination $outDir
}

# Native runtimes folder: the netstandard publish may put msalruntime under runtimes\<rid>\native; the ALC's
# LoadUnmanagedDll probes that folder first, then Dependencies itself, so copy whatever exists.
$runtimes = Join-Path $standardPublish 'runtimes'
if (Test-Path -LiteralPath $runtimes) { Copy-Item -Path $runtimes -Destination $outDeps -Recurse }

$manifest = Import-PowerShellDataFile -Path (Join-Path $outDir "$prefix.psd1")
if ($manifest.ContainsKey('NestedModules') -or $manifest.ContainsKey('RequiredAssemblies')) {
    Write-Error 'The module manifest must not declare NestedModules or RequiredAssemblies; the .psm1 loads the assemblies after initializing the AssemblyLoadContext.'
}
foreach ($required in @('Dependencies\Core\Microsoft.Graph.Authentication.Loader.dll', 'Dependencies\Core\Microsoft.Graph.Authentication.Core.dll', "$prefix.dll", "$prefix.psm1")) {
    if (-not (Test-Path -LiteralPath (Join-Path $outDir $required))) { throw ('Build layout is missing {0}' -f $required) }
}
Write-Host ('Module laid out at {0} (ModuleVersion {1}). Import it by path.' -f $outDir, $manifest.ModuleVersion) -ForegroundColor Green
