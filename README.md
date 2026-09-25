# graph-exo-loadorder

A load-order diagnostic for `Microsoft.Graph.Authentication` and `ExchangeOnlineManagement` on PowerShell 7.
It runs each connect order in a fresh, visible `pwsh` process and snapshots the process after every step:
which load context each identity assembly landed in, which `msalruntime.dll` files are mapped and which one a
bare-name request resolves to, the `AppDomain.AssemblyResolve` invocation list, the P/Invoke targets and
`DllImportResolver` registrations of every loaded `Microsoft.Identity.Client.NativeInterop`, and the private
statics of MSAL's `RuntimeBroker` (the swallowed startup exception that turns into the well-known
`NullReferenceException`). The report it writes states every finding with an Observed / Inferred / Prediction
status and the JSON path behind it.

Background: [microsoftgraph/msgraph-sdk-powershell#3394](https://github.com/microsoftgraph/msgraph-sdk-powershell/issues/3394)
and [PR #3789](https://github.com/microsoftgraph/msgraph-sdk-powershell/pull/3789).

## Warning: a person must be at the keyboard

Every scenario except `probe-only` opens a Web Account Manager (WAM) picker or a browser sign-in, sometimes twice.
The harness prints one line before each scenario saying what to do at the prompt (sign in, or cancel). The child
process treats a cancelled prompt as an ordinary caught exception and still writes its snapshot; the harness waits
for the child and never kills it. Do not run this unattended.

## Prerequisites

- PowerShell 7 (tested on 7.6.6, .NET 10.0.12, Windows 11 x64). `pwsh` must be on PATH; the harness starts the
  child windows with it.
- `Microsoft.Graph.Authentication` 2.40.0 and `ExchangeOnlineManagement` 3.10.1 installed (exact versions; other
  versions via `-GraphVersion` and `-ExoVersion`). The harness never installs, updates or removes modules; if a
  version is missing it stops and says so.
- A tenant ID and an account that can sign in to Microsoft Graph and Exchange Online. Both values are passed to
  the child on its command line only; they are scrubbed from the JSON and the transcripts at write time and
  never appear in `report.md`.
- Optional: `Az.Accounts` with `EnableLoginByWam` set to true (`Get-AzConfig -EnableLoginByWam`) for
  `az-connect-then-exo`. The harness reads that setting and never changes it.
- Optional: a build of PR #3789 for the `pr-*` scenarios (`-GraphModulePath`). See `build-notes.md` and
  `Build-PrAuthenticationModule.ps1`; the build needs a .NET SDK 8.0 or later.

## How to run

```powershell
# everything whose preconditions are met, in the order of scenarios.psd1, then report.md
.\Test-GraphExoLoadOrder.ps1 -TenantId <tenant-guid> -UserPrincipalName <upn>

# one scenario at a time (no report), then rebuild the report from everything on disk
.\Test-GraphExoLoadOrder.ps1 -TenantId <tenant-guid> -UserPrincipalName <upn> -Scenario graph-connect-then-exo -SkipReport
.\Test-GraphExoLoadOrder.ps1 -ReportOnly

# the PR build scenarios
.\Test-GraphExoLoadOrder.ps1 -TenantId <tenant-guid> -UserPrincipalName <upn> -GraphModulePath .\prbuild\Microsoft.Graph.Authentication\Microsoft.Graph.Authentication.psd1 -Scenario pr-graph-connect-then-exo
```

`probe-only` runs first and must pass: it checks that the capture code sees
`System.Reflection.Assembly.LoadFromResolveHandler` in the `AssemblyResolve` list and that the Win32 probe compiled.
Add `-Pause` to wait for Enter before each scenario window opens.

## Files

| File | Role |
|---|---|
| `Test-GraphExoLoadOrder.ps1` | Harness: prerequisite checks, one fresh `pwsh -NoProfile -NoLogo` window per scenario via `Start-Process -Wait`, step outcomes after each, `report.md` at the end |
| `Invoke-LoadOrderScenario.ps1` | Child: runs one scenario in the current process, snapshots after every step, rewrites its JSON after every step so a crash still leaves the last state on disk |
| `scenarios.psd1` | Scenario definitions: steps, the instruction shown to the operator, the expectation, preconditions |
| `Build-PrAuthenticationModule.ps1` | Builds the Graph module from the PR #3789 checkout under `src\` (needs a .NET SDK) |
| `report.md`, `audit.md`, `build-notes.md` | Generated report; claim-by-claim evidence audit; what the PR build needs |
| `results\` | `<scenario>.json` and `<scenario>.transcript.txt` (git-ignored) |
| `reference\` | Fetched sources used for the interpretation: the PR diff, the pre-PR `ModuleInitializer.cs`, MSAL 4.83.1 `RuntimeBroker.cs` (git-ignored) |

## Scenarios and what each one discriminates

| Scenario | Steps | Discriminates |
|---|---|---|
| `probe-only` | baseline, import a trivial binary module | Validates the capture code; no sign-in |
| `exo-only` | import EXO, connect EXO | Baseline placement of EXO's identity stack and its `msalruntime` |
| `graph-import-then-exo` | import Graph, import EXO, connect EXO | Whether a Graph import alone breaks EXO (managed resolution) or a Graph connection is needed (native) |
| `graph-connect-then-exo` | import Graph, connect Graph, import EXO, connect EXO | The reported `RuntimeBroker` `NullReferenceException`, with native mappings, bare-name resolution, DllImport targets, resolver registrations and `RuntimeBroker` statics captured after the failure |
| `graph-cancel-then-exo` | import Graph, connect Graph (operator cancels), import EXO, connect EXO | Whether Graph's native runtime is started before its picker appears, and whether a cancelled prompt is enough to break EXO |
| `graph-connect-then-exo-disablewam` | as above, EXO with `-DisableWAM` | Whether bypassing the broker avoids the failure |
| `graph-accesstoken-then-exo` | connect Graph with `-AccessToken` (token fetched by the harness through Az.Accounts, browser sign-in), import EXO, connect EXO | Whether a Graph session that never starts msalruntime leaves EXO's WAM path working (a same-session workaround without `-DisableWAM`). The token travels in the child's environment block only and is scrubbed from everything the child writes |
| `exo-then-graph` | import EXO, connect EXO, import Graph, connect Graph | The reverse failure (`WithLogging` `MissingMethodException`) and the split `IIdentityLogger` identity behind it |
| `az-connect-then-exo` | connect Az (WAM), import EXO, connect EXO | Whether any WAM user, not just Graph, breaks EXO (only when Az uses WAM) |
| `pr-graph-import-then-exo`, `pr-graph-connect-then-exo`, `pr-exo-then-graph` | as their released-module counterparts, Graph from `-GraphModulePath` | Whether PR #3789 changes either direction |

## What a snapshot contains

Per step: outcome (ok, exception, non-terminating error) with the full exception chain and script stack; tracked
managed assemblies (`Microsoft.Identity*`, `Azure.Identity`, `Azure.Core`, `Microsoft.Graph*`, `Microsoft.Exchange*`,
`Microsoft.Kiota*`) with version, load context, owning module and location; every `AssemblyLoadContext` with
its `Resolving` handlers; `Process.Modules` entries named `msalruntime*`; the result of `NativeLibrary.TryLoad`
and of Win32 `GetModuleHandleW` / `LoadLibraryW` / `GetModuleFileNameW` for the bare name (probed only once a copy
is mapped, so the probe never maps one itself); the distinct `DllImportAttribute.Value` strings of every loaded
NativeInterop; the `NativeLibrary` resolver table and whether either NativeInterop has an entry; the
`AppDomain.AssemblyResolve` invocation list in order; `RuntimeBroker.s_lazyCore` / `s_initException` per loaded
Broker copy; module versions and paths.

## Rules the harness follows

Read-only towards the machine: no module installs, no profile or Az config changes, no system settings. The only
things it writes are the files under this folder. Splatting for calls with three or more parameters, no backtick
continuations, one pipeline per line.
