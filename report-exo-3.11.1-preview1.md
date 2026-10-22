# Graph-then-EXO load-order diagnostic

Generated 2026-10-22 15:48. Host: PowerShell 7.6.7 (Core), .NET 10.0.13, Microsoft Windows NT 10.0.26300.0, process X64.
Requested modules: Microsoft.Graph.Authentication 2.41.2, ExchangeOnlineManagement 3.11.1. Every scenario ran in its own fresh pwsh -NoProfile process.

Snapshots were taken after every step: tracked managed assemblies with their load context, all load contexts, native msalruntime modules with the in-process bare-name resolution (Win32 GetModuleHandleW/LoadLibraryW and NativeLibrary.TryLoad), DllImport targets and DllImportResolver registrations of every loaded NativeInterop, the AppDomain.AssemblyResolve invocation list, RuntimeBroker statics, and module versions. Full detail is in results\<scenario>.json; host output is in results\<scenario>.transcript.txt. The tenant ID and account hint were scrubbed from both at write time. Status vocabulary: Observed, Inferred, Prediction, Not run.

## Summary

| Scenario | Child | Completed | Step outcomes | Last connect step class | msalruntime copies |
|---|---|---|---|---|---|
| graph-connect-then-exo | 2.3 | True | baseline=ok, import-graph=ok, connect-graph=ok, import-exo=ok, connect-exo=ok | signed-in | 2 |
| exo-then-graph | 2.3 | True | baseline=ok, import-exo=ok, connect-exo=ok, import-graph=ok, connect-graph=ok | signed-in | 2 |

Defined but not run: probe-only, imports-only, exo-only, graph-import-then-exo, graph-cancel-then-exo, graph-connect-then-exo-disablewam, graph-accesstoken-then-exo, spo-only, spo-then-exo, exo-then-spo, graph-then-spo, spo-then-graph, az-connect-then-exo, pr-graph-import-then-exo, pr-graph-connect-then-exo, pr-exo-then-graph.

## graph-connect-then-exo

Steps: baseline -> import-graph -> connect-graph -> import-exo -> connect-exo. Instruction given: Sign in at the Graph WAM prompt. EXO is then expected to throw the RuntimeBroker NullReferenceException before any prompt.

Child script version 2.3.

### Steps

| Step | Outcome | Exception type | Message (first line) |
|---|---|---|---|
| baseline | ok |  |  |
| import-graph | ok |  |  |
| connect-graph | ok |  |  |
| import-exo | ok |  |  |
| connect-exo | ok |  |  |

### Final snapshot (after connect-exo)

| Assembly | Version | Context | Owner | Location |
|---|---|---|---|---|
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Default | EXO | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.85.2.0 | Default | EXO | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Default | EXO | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.22.0.0 | Default | EXO | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Azure.Core | 1.51.1.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Azure.Core.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |
| Azure.Identity.Broker | 1.4.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.Broker.dll |
| Microsoft.Exchange.Management.AdminApiProvider | 15.0.0.0 | Default | EXO | import-exo | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll |
| Microsoft.Exchange.Management.ExoPowershellGalleryModule | 15.0.0.0 | Default | EXO | import-exo | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll |
| Microsoft.Exchange.Management.RestApiClient | 15.0.0.0 | Default | EXO | import-exo | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Exchange.Management.RestApiClient.dll |
| Microsoft.Graph.Authentication | 2.41.2.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Microsoft.Graph.Authentication.dll |
| Microsoft.Graph.Authentication.Core | 2.41.2.0 | Microsoft.Graph.Authentication | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Core.dll |
| Microsoft.Graph.Authentication.Loader | 2.38.1.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Loader.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Default | EXO | connect-exo | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.85.2.0 | Default | EXO | connect-exo | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Extensions.Msal | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.Extensions.Msal.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Default | EXO | connect-exo | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.22.0.0 | Default | EXO | connect-exo | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.IdentityModel.Abstractions.dll |

</details>

### Native msalruntime

Count in final snapshot: 2
- Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll (first mapped after connect-graph; file version not set; base 0x7FF880270000)
- EXO: ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll (first mapped after connect-exo; file version not set; base 0x7FF86A410000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-graph: 0; nothing mapped under that name
- after connect-graph: 1 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True
- after import-exo: 1 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True
- after connect-exo: 2 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll; EXO: ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True

### DllImport targets in each loaded Microsoft.Identity.Client.NativeInterop (final snapshot)

| NativeInterop copy | Context | P/Invokes | Library names (count) |
|---|---|---|---|
| Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll | Microsoft.Graph.Authentication | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |
| EXO: ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Identity.Client.NativeInterop.dll | Default | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |

### DllImportResolver registrations (final snapshot)

NativeLibrary field: s_nativeDllResolveMap; table exists: False; entries: none
- NativeInterop Graph (Microsoft.Graph.Authentication): resolver registered = False
- NativeInterop EXO (Default): resolver registered = False

### RuntimeBroker statics (final snapshot)

| Broker copy | Context | Lazy Core created | Core is null | s_initException |
|---|---|---|---|---|
| Graph | Microsoft.Graph.Authentication | True | False | (null) |
| EXO | Default | True | False | (null) |

Per step (Lazy Core created / Core is null, per Broker copy):

- after baseline: no Broker assembly loaded
- after import-graph: no Broker assembly loaded
- after connect-graph: Graph: created=True, null=False
- after import-exo: Graph: created=True, null=False
- after connect-exo: Graph: created=True, null=False; EXO: created=True, null=False

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-graph: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-graph: System.Reflection.Assembly.LoadFromResolveHandler
- after import-exo: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-exo: System.Reflection.Assembly.LoadFromResolveHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 129 |  |
| Microsoft.Graph.Authentication | Microsoft.Graph.PowerShell.Authentication.Loader.GraphAssemblyLoadContext | 10 |  |

## exo-then-graph

Steps: baseline -> import-exo -> connect-exo -> import-graph -> connect-graph. Instruction given: Sign in at the EXO WAM prompt. On Graph 2.40.0 Connect-MgGraph then fails before any prompt (WithLogging MissingMethodException); on 2.41.0 or later a Graph prompt is expected: sign in, or cancel.

Child script version 2.3.

### Steps

| Step | Outcome | Exception type | Message (first line) |
|---|---|---|---|
| baseline | ok |  |  |
| import-exo | ok |  |  |
| connect-exo | ok |  |  |
| import-graph | ok |  |  |
| connect-graph | ok |  |  |

### Final snapshot (after connect-graph)

| Assembly | Version | Context | Owner | Location |
|---|---|---|---|---|
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Default | EXO | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.85.2.0 | Default | EXO | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Default | EXO | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.22.0.0 | Default | EXO | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Azure.Core | 1.51.1.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Azure.Core.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |
| Azure.Identity.Broker | 1.4.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.Broker.dll |
| Microsoft.Exchange.Management.AdminApiProvider | 15.0.0.0 | Default | EXO | import-exo | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll |
| Microsoft.Exchange.Management.ExoPowershellGalleryModule | 15.0.0.0 | Default | EXO | import-exo | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll |
| Microsoft.Exchange.Management.RestApiClient | 15.0.0.0 | Default | EXO | import-exo | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Exchange.Management.RestApiClient.dll |
| Microsoft.Graph.Authentication | 2.41.2.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Microsoft.Graph.Authentication.dll |
| Microsoft.Graph.Authentication.Core | 2.41.2.0 | Microsoft.Graph.Authentication | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Core.dll |
| Microsoft.Graph.Authentication.Loader | 2.38.1.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Loader.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Default | EXO | connect-exo | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.85.2.0 | Default | EXO | connect-exo | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Extensions.Msal | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.Extensions.Msal.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Default | EXO | connect-exo | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.22.0.0 | Default | EXO | connect-exo | ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.IdentityModel.Abstractions.dll |

</details>

### Native msalruntime

Count in final snapshot: 2
- EXO: ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll (first mapped after connect-exo; file version not set; base 0x7FF86A410000)
- Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll (first mapped after connect-graph; file version not set; base 0x7FF880270000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-exo: 0; nothing mapped under that name
- after connect-exo: 1 (EXO: ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> EXO (~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True
- after import-graph: 1 (EXO: ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> EXO (~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True
- after connect-graph: 2 (EXO: ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll; Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> EXO (~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True

### DllImport targets in each loaded Microsoft.Identity.Client.NativeInterop (final snapshot)

| NativeInterop copy | Context | P/Invokes | Library names (count) |
|---|---|---|---|
| EXO: ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\Microsoft.Identity.Client.NativeInterop.dll | Default | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |
| Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll | Microsoft.Graph.Authentication | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |

### DllImportResolver registrations (final snapshot)

NativeLibrary field: s_nativeDllResolveMap; table exists: False; entries: none
- NativeInterop EXO (Default): resolver registered = False
- NativeInterop Graph (Microsoft.Graph.Authentication): resolver registered = False

### RuntimeBroker statics (final snapshot)

| Broker copy | Context | Lazy Core created | Core is null | s_initException |
|---|---|---|---|---|
| EXO | Default | True | False | (null) |
| Graph | Microsoft.Graph.Authentication | True | False | (null) |

Per step (Lazy Core created / Core is null, per Broker copy):

- after baseline: no Broker assembly loaded
- after import-exo: no Broker assembly loaded
- after connect-exo: EXO: created=True, null=False
- after import-graph: EXO: created=True, null=False
- after connect-graph: EXO: created=True, null=False; Graph: created=True, null=False

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-exo: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-exo: System.Reflection.Assembly.LoadFromResolveHandler
- after import-graph: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-graph: System.Reflection.Assembly.LoadFromResolveHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 129 |  |
| Microsoft.Graph.Authentication | Microsoft.Graph.PowerShell.Authentication.Loader.GraphAssemblyLoadContext | 10 |  |

## Interpretation

Findings follow the decision rules fixed before the run. Every claim carries a status: Observed (a value in results\*.json or a transcript line, cited), Inferred (derived from observed values plus source or metadata that was read offline, with the basis named), Prediction (not yet tested), or Not run. Anything that fits neither mechanism is reported as unexplained.

### Finding 1: which mechanism

| Claim | Status | Evidence |
|---|---|---|
| exo-only: EXO alone signs in; its identity stack lands in Default from netCore with one msalruntime (EXO's) | Not run |  |
| Importing Graph without connecting leaves EXO working (graph-import-then-exo reaches a sign-in) | Not run | graph-import-then-exo.json: step not recorded |
| A Graph WAM sign-in first makes Connect-ExchangeOnline throw the RuntimeBroker NullReferenceException | Observed: contradicted | graph-connect-then-exo.json Steps[connect-exo]: Outcome=ok; Notes.Connected=True; stack frame RuntimeBroker..ctor present: False |
| Graph's msalruntime is mapped during Connect-MgGraph, not at import | Observed | graph-connect-then-exo.json Steps[import-graph].Snapshot.NativeModules: 0; Steps[connect-graph]: 1 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll) |
| EXO's msalruntime is mapped during Connect-ExchangeOnline, not at import | Observed | graph-connect-then-exo.json Steps[import-exo].Snapshot.NativeModules: 1 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); Steps[connect-exo]: 2 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll; EXO: ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll) |
| After Connect-ExchangeOnline two msalruntime.dll files are mapped, one from each module | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot.NativeModules: 2 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll; EXO: ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll) |
| A bare-name request for msalruntime.dll in that process resolves to Graph's copy | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot: Win32 GetModuleHandleW/LoadLibraryW: GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True |
| EXO's NativeInterop declares its runtime P/Invokes against the bare name "msalruntime" (no path) | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot.DllImportTargets[EXO]: 269 P/Invokes; library names: kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |
| No DllImportResolver is registered for either NativeInterop copy, so nothing pins its P/Invokes to the handle it preloaded | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot.DllImportResolvers: field s_nativeDllResolveMap; table exists False; entries: none; NativeInterop HasResolver: Graph=False, EXO=False |
| EXO's NativeInterop mapped its own msalruntime by full path (a kernel32 LoadLibrary preload from runtimes\win-x64\native) | Inferred | Basis: offline metadata of NativeInterop 0.19.4 (P/Invoke kernel32!LoadLibrary; string literals "runtimes", "win-x64\native\msalruntime.dll", "PATH") plus the observation that the second mapping appears exactly at connect-exo. The preload call itself was not traced. |
| EXO's P/Invokes therefore executed against Graph's already-started runtime rather than its own mapped copy | Inferred | Basis: the observed bare-name resolution, the observed bare-name DllImport targets, and the observed absence of a resolver. Binding was not traced with a debugger. |
| EXO's RuntimeBroker copy started: lazy Core created and live, no s_initException, so the runtime its P/Invokes reached accepted a second startup | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot.BrokerRuntimeState[EXO]: LazyCoreValueCreated=True; CoreIsNull=False; InitException.Type=null; Status=(none); Context="(none)" |
| Graph's RuntimeBroker copy in the same process has a live Core and no init exception | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot.BrokerRuntimeState[Graph]: LazyCoreValueCreated=True; CoreIsNull=False; InitException=null |
| Why the second startup is accepted on this build: the runtime Graph maps comes from a newer NativeInterop package than the one EXO carries (and than the 0.19.4 both shipped when the failure was recorded); whether the change is in msalruntime itself or in how MSAL starts it was not traced | Inferred | graph-connect-then-exo.json Steps[connect-exo].Snapshot.Assemblies[Microsoft.Identity.Client.NativeInterop]: EXO=0.20.6.0 (Default), Graph=0.20.6.0 (Microsoft.Graph.Authentication); NativeModules FileVersion: none (msalruntime.dll carries no version resource) |

Unexplained. connect-exo classes were not-run (import) and signed-in (connect); this does not match either predicted pattern. See the raw step tables and exception details above.

### Finding 2: can Graph's AssemblyResolve handler run before LoadFromResolveHandler?

| Claim | Status | Evidence |
|---|---|---|
| LoadFromResolveHandler is registered at baseline, before any module import | Observed | graph-connect-then-exo.json Steps[baseline].Snapshot.AssemblyResolveHandlers.Handlers: System.Reflection.Assembly.LoadFromResolveHandler |
| No Graph AssemblyResolve handler is registered: from 2.41.0 Graph resolves its dependencies inside GraphAssemblyLoadContext instead of hooking AppDomain.AssemblyResolve | Observed | graph-connect-then-exo.json Steps[import-graph].Snapshot.AssemblyResolveHandlers.Handlers: System.Reflection.Assembly.LoadFromResolveHandler |
| The runtime invokes AssemblyResolve handlers in registration order and stops at the first non-null result | Inferred | Basis: .NET runtime source, System.Runtime.Loader.AssemblyLoadContext.InvokeResolveEvent (foreach over Delegate.EnumerateInvocationList, return first non-null). Documented behavior, not observed in this process. |
| EXO's identity assemblies resolved from netCore into Default in every scenario; none came from Graph's folder | Observed | final snapshots: graph-connect-then-exo: 4 EXO identity assemblies in Default; exo-then-graph: 4 EXO identity assemblies in Default |
| Mechanism A cannot occur for EXO's own dependencies: LoadFromResolveHandler answers first for any file beside a LoadFrom-loaded requester in Default, and all of EXO's live in netCore beside the requesters | Inferred | Basis: the four rows above (by construction). |

### Finding 3: the other two directions on the released modules

| Claim | Status | Evidence |
|---|---|---|
| -DisableWAM behaviour | Not run |  |
| Prediction made before any isolated build ran: EXO first, then Connect-MgGraph no longer fails on WithLogging and reaches a Graph prompt, because Graph's Azure.Identity can no longer bind to EXO's MSAL in Default | Prediction: confirmed | exo-then-graph.json Steps[connect-graph]: Outcome=ok; Notes.SignedIn=True |
| Microsoft.Identity.Client is loaded twice in that process: EXO's in Default and Graph's in Microsoft.Graph.Authentication | Observed | exo-then-graph.json Steps[connect-graph].Snapshot.Assemblies: Microsoft.IdentityModel.Abstractions 8.22.0.0 in Default (EXO); Microsoft.IdentityModel.Abstractions 8.18.0.0 in Microsoft.Graph.Authentication (Graph); Microsoft.Identity.Client 4.90.0.0 in Default (EXO); Microsoft.Identity.Client 4.90.0.0 in Microsoft.Graph.Authentication (Graph) |
| EXO then Graph on the native side: msalruntime copies mapped, bare-name resolution, and each RuntimeBroker's startup state (a live Graph Core beside a live EXO Core means the already-started state is per mapped module; a Graph init exception means it is process-global) | Observed | exo-then-graph.json final snapshot: NativeModules 2 (EXO: ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll; Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> EXO (~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True; Graph broker: created=True, null=False, init=none; EXO broker: created=True, null=False, init=none |

### Finding 4: is a completed Graph sign-in required, or just the picker?

| Claim | Status | Evidence |
|---|---|---|
| Cancelled Graph prompt | Not run |  |

### Finding 5: is it about Graph, or about any WAM user (Az.Accounts)?

| Claim | Status | Evidence |
|---|---|---|
| Az.Accounts WAM sign-in followed by EXO | Not run | Precondition not met on this machine: az-connect-then-exo requires Az.Accounts with EnableLoginByWam = true (Get-AzConfig reported false; Az config was not changed). |

### Finding 5b: a Graph token from a non-WAM source (graph-accesstoken-then-exo)

| Claim | Status | Evidence |
|---|---|---|
| Graph via -AccessToken from a non-WAM source, then EXO | Not run |  |

### Finding 6: Microsoft.Graph.Authentication 2.41.2 (released build containing PR #3789)

| Claim | Status | Evidence |
|---|---|---|
| Prediction made before the PR build ran: Graph-then-EXO still fails after the PR, because the PR pins Graph's P/Invokes to Graph's copy (LoadUnmanagedDll override) while EXO's stay bare-name in Default | Prediction: refuted | graph-connect-then-exo.json Steps[connect-exo]: Outcome=ok; Notes.Connected=True |
| Prediction made before the PR build ran: EXO-then-Graph is fixed by construction, because Graph's Azure.Identity can no longer bind to EXO's MSAL in Default | Prediction: confirmed | exo-then-graph.json Steps[connect-graph]: Outcome=ok; Notes.SignedIn=True |
| graph-import-then-exo | Not run |  |
| graph-connect-then-exo: last connect step class = signed-in | Observed | graph-connect-then-exo.json Steps[connect-exo]: Outcome=ok; Notes.Connected=True |
| graph-connect-then-exo: Graph's NativeInterop load context | Observed | graph-connect-then-exo.json final snapshot: Microsoft.Graph.Authentication (Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll) |
| graph-connect-then-exo: native mappings and bare-name resolution | Observed | graph-connect-then-exo.json final snapshot: NativeModules 2 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll; EXO: ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True |
| graph-connect-then-exo: RuntimeBroker statics | Observed | graph-connect-then-exo.json final snapshot: Graph created=True, null=False, init=none; EXO created=True, null=False, init=none |
| exo-then-graph: last connect step class = signed-in | Observed | exo-then-graph.json Steps[connect-graph]: Outcome=ok; Notes.SignedIn=True |
| exo-then-graph: Graph's NativeInterop load context | Observed | exo-then-graph.json final snapshot: Microsoft.Graph.Authentication (Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll) |
| exo-then-graph: native mappings and bare-name resolution | Observed | exo-then-graph.json final snapshot: NativeModules 2 (EXO: ~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll; Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> EXO (~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (~\AppData\Local\Temp\exo-preview\3.11.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True |
| exo-then-graph: RuntimeBroker statics | Observed | exo-then-graph.json final snapshot: Graph created=True, null=False, init=none; EXO created=True, null=False, init=none |

### Finding 7: a third module (SharePoint Online, patched for PowerShell 7)

| Claim | Status | Evidence |
|---|---|---|
| spo-only, spo-then-exo, exo-then-spo, graph-then-spo, spo-then-graph | Not run | spo-* scenarios need -SpoModulePath and -SpoAdminUrl. |

### Implication for PR #3789

Observed on Microsoft.Graph.Authentication 2.41.2 (released build containing PR #3789): Graph-then-EXO = signed-in; EXO-then-Graph = signed-in; Graph-import-then-EXO = not-run.
Graph-then-EXO works on the isolated build, which refutes the prediction, though not because EXO reached a different copy: the bare name still resolves to Graph's mapped msalruntime and EXO's RuntimeBroker started cleanly against it, so the second startup was accepted rather than avoided. The isolation changed the managed side only; the native change is the runtime Graph ships (Finding 1, last row).
EXO-then-Graph reached a Graph sign-in: the WithLogging failure is gone, as predicted.

