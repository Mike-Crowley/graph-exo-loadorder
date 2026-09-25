# Build notes for the PR #3789 test build (Task 3)

Status: stopped at the SDK check, as the spec requires. Nothing was installed.

## What is in place

- `src\` holds a sparse, blob-filtered clone of microsoftgraph/msgraph-sdk-powershell checked out at
  `aed9bcde1a72bc0b482c3e610dc34949d44950dd` (the merge commit of PR #3789), limited to `src/Authentication`
  plus the root files (`Repo.props` is imported by the Core and Loader projects). About 4 MB of git objects.
- `Build-PrAuthenticationModule.ps1` reproduces the compile and layout halves of the repository's
  `src/Authentication/Authentication/build-module.ps1` and writes the module to
  `prbuild\Microsoft.Graph.Authentication\`. It skips the help regeneration (`generate-doc-files.ps1`,
  `import-examples.ps1`, `update-markdown.ps1`, `New-ExternalHelp` from platyPS) because that step does not
  affect the assemblies and platyPS is not installed here. The checked-in help XML files are copied instead.
  The script is untested for the same reason the build is blocked: it needs the SDK.
- The harness already accepts `-GraphModulePath` and defines `pr-graph-import-then-exo`,
  `pr-graph-connect-then-exo` and `pr-exo-then-graph`; the child imports the manifest by path for those.

## What the build needs

| Need | Detail |
|---|---|
| .NET SDK | None is installed (`dotnet --list-sdks`: "No .NET SDKs were found"). Any 8.0 or later x64 SDK works; the `net6.0` targeting pack (`Microsoft.NETCore.App.Ref` 6.0.x) and the `net472` reference assemblies are restored from NuGet by newer SDKs. `winget install Microsoft.DotNet.SDK.10` (or `.SDK.8`) is the usual route; open a new shell afterwards. |
| NuGet access | Restore pulls Azure.Identity 1.18.0, Azure.Identity.Broker 1.4.0, Microsoft.Identity.Client 4.83.1 (+ Broker, Extensions.Msal), Microsoft.Graph.Core 4.0.1, System.Text.Json 10.0.3, Microsoft.Bcl.AsyncInterfaces 10.0.3, Newtonsoft.Json 13.0.3, PowerShellStandard.Library 5.1.1, Microsoft.Win32.Registry 5.0.0. |
| Targets | Authentication.Core: netstandard2.0, net6.0, net472. Loader: net6.0. Cmdlet assembly: netstandard2.0. |

## Why the CI artifact route is closed

- The repository has no GitHub Actions build workflow (only `docker.yml`, `metadatachanges.yml`,
  `project-auto-add.yml`). The merge commit's Actions runs are Dependabot updates and the NuGet dependency
  submission; none produce a module artifact.
- Module builds run on Azure DevOps ("PowerShell V2 Build" at microsoftgraph.visualstudio.com). The PR approval
  comment refers to test build #3791 (`ramsess/test-isolation`, a re-run of #3789 with MSAL 4.90.0); its ADO
  build 244405 failed after 3 hours, and its PR was closed unmerged. There is no downloadable artifact of the
  merged code.

So the only route is the SDK route above.

## How to resume Task 3

```powershell
# 1. after installing an SDK (new shell)
.\Build-PrAuthenticationModule.ps1

# 2. run the three PR scenarios against the built module (one visible window each, sign-ins as prompted)
$params = @{
    TenantId          = '<tenant-id>'
    UserPrincipalName = '<upn>'
    GraphModulePath   = '.\prbuild\Microsoft.Graph.Authentication\Microsoft.Graph.Authentication.psd1'
    Scenario          = 'pr-graph-import-then-exo', 'pr-graph-connect-then-exo', 'pr-exo-then-graph'
}
.\Test-GraphExoLoadOrder.ps1 @params
```

If a CI artifact ever becomes available instead, drop its contents in `prbuild\Microsoft.Graph.Authentication\`
so that `Microsoft.Graph.Authentication.psd1` sits directly in that folder, and run step 2 only.

## Notes for when it builds

- Both the csproj `Version` and the manifest `ModuleVersion` in the tree read 2.38.1 (the source tree lags the
  released 2.40.0 label); neither matters here because the module is imported by path, never by name.
- The PR's psm1 requires the manifest to have no `NestedModules` or `RequiredAssemblies`; the build script fails
  if either is present, matching `build-module.ps1`.
- Expect the ALC to be named `Microsoft.Graph.Authentication` (type `GraphAssemblyLoadContext`) and Graph's
  NativeInterop and msalruntime to be resolved from `Dependencies\` (or `Dependencies\runtimes\win-x64\native\`)
  through `LoadUnmanagedDll`. The snapshot records both.
