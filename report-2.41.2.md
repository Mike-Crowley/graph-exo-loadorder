# Graph-then-EXO load-order diagnostic

Generated 2026-10-19 10:13. Host: PowerShell 7.6.7 (Core), .NET 10.0.13, Microsoft Windows NT 10.0.26300.0, process X64.
Requested modules: Microsoft.Graph.Authentication 2.41.2, ExchangeOnlineManagement 3.10.1. Every scenario ran in its own fresh pwsh -NoProfile process.

Snapshots were taken after every step: tracked managed assemblies with their load context, all load contexts, native msalruntime modules with the in-process bare-name resolution (Win32 GetModuleHandleW/LoadLibraryW and NativeLibrary.TryLoad), DllImport targets and DllImportResolver registrations of every loaded NativeInterop, the AppDomain.AssemblyResolve invocation list, RuntimeBroker statics, and module versions. Full detail is in results\<scenario>.json; host output is in results\<scenario>.transcript.txt. The tenant ID and account hint were scrubbed from both at write time. Status vocabulary: Observed, Inferred, Prediction, Not run.

## Summary

| Scenario | Child | Completed | Step outcomes | Last connect step class | msalruntime copies |
|---|---|---|---|---|---|
| probe-only | 2.1 | True | baseline=ok, import-probe-module=ok |  | 0 |
| imports-only | 2.1 | True | baseline=ok, import-graph=ok, import-exo=ok |  | 0 |
| exo-only | 2.1 | True | baseline=ok, import-exo=ok, connect-exo=ok | signed-in | 1 |
| graph-import-then-exo | 2.1 | True | baseline=ok, import-graph=ok, import-exo=ok, connect-exo=ok | signed-in | 1 |
| graph-connect-then-exo | 2.1 | True | baseline=ok, import-graph=ok, connect-graph=ok, import-exo=ok, connect-exo=ok | signed-in | 2 |
| graph-cancel-then-exo | 2.1 | True | baseline=ok, import-graph=ok, connect-graph-cancel=ok, import-exo=ok, connect-exo=ok | signed-in | 2 |
| graph-connect-then-exo-disablewam | 2.1 | True | baseline=ok, import-graph=ok, connect-graph=ok, import-exo=ok, connect-exo-disablewam=ok | signed-in | 1 |
| graph-accesstoken-then-exo | 2.1 | True | baseline=ok, import-graph=ok, connect-graph-accesstoken=ok, import-exo=ok, connect-exo=ok | signed-in | 1 |
| exo-then-graph | 2.1 | True | baseline=ok, import-exo=ok, connect-exo=ok, import-graph=ok, connect-graph=ok | signed-in | 2 |

Defined but not run: az-connect-then-exo, pr-graph-import-then-exo, pr-graph-connect-then-exo, pr-exo-then-graph.

## probe-only

Steps: baseline -> import-probe-module. Instruction given: Nothing to do: no modules, no prompts. Validates the snapshot code.

Child script version 2.1.

### Steps

| Step | Outcome | Exception type | Message (first line) |
|---|---|---|---|
| baseline | ok |  |  |
| import-probe-module | ok |  |  |

### Final snapshot (after import-probe-module)

| Assembly | Version | Context | Owner | Location |
|---|---|---|---|---|
| Microsoft.Identity.Client |  | (not loaded) |  | (none) |
| Microsoft.Identity.Client.Broker |  | (not loaded) |  | (none) |
| Microsoft.Identity.Client.NativeInterop |  | (not loaded) |  | (none) |
| Microsoft.IdentityModel.Abstractions |  | (not loaded) |  | (none) |
| Azure.Identity |  | (not loaded) |  | (none) |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Microsoft.PowerShell.ThreadJob | 2.2.0.0 | Default | other | import-probe-module | Microsoft.PowerShell.ThreadJob\Microsoft.PowerShell.ThreadJob.dll |

</details>

### Native msalruntime

Count in final snapshot: 0

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-probe-module: 0; nothing mapped under that name

### DllImportResolver registrations (final snapshot)

NativeLibrary field: s_nativeDllResolveMap; table exists: False; entries: none

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-probe-module: System.Reflection.Assembly.LoadFromResolveHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 99 |  |

## imports-only

Steps: baseline -> import-graph -> import-exo. Instruction given: Nothing to do: no prompts. Captures where each module's identity stack lands before any sign-in.

Child script version 2.1.

### Steps

| Step | Outcome | Exception type | Message (first line) |
|---|---|---|---|
| baseline | ok |  |  |
| import-graph | ok |  |  |
| import-exo | ok |  |  |

### Final snapshot (after import-exo)

| Assembly | Version | Context | Owner | Location |
|---|---|---|---|---|
| Microsoft.Identity.Client |  | (not loaded) |  | (none) |
| Microsoft.Identity.Client.Broker |  | (not loaded) |  | (none) |
| Microsoft.Identity.Client.NativeInterop |  | (not loaded) |  | (none) |
| Microsoft.IdentityModel.Abstractions |  | (not loaded) |  | (none) |
| Azure.Identity |  | (not loaded) |  | (none) |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Microsoft.Exchange.Management.AdminApiProvider | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll |
| Microsoft.Exchange.Management.ExoPowershellGalleryModule | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll |
| Microsoft.Exchange.Management.RestApiClient | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.RestApiClient.dll |
| Microsoft.Graph.Authentication | 2.41.2.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Microsoft.Graph.Authentication.dll |
| Microsoft.Graph.Authentication.Core | 2.41.2.0 | Microsoft.Graph.Authentication | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Core.dll |
| Microsoft.Graph.Authentication.Loader | 2.38.1.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Loader.dll |

</details>

### Native msalruntime

Count in final snapshot: 0

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-graph: 0; nothing mapped under that name
- after import-exo: 0; nothing mapped under that name

### DllImportResolver registrations (final snapshot)

NativeLibrary field: s_nativeDllResolveMap; table exists: False; entries: none

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-graph: System.Reflection.Assembly.LoadFromResolveHandler
- after import-exo: System.Reflection.Assembly.LoadFromResolveHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 114 |  |
| Microsoft.Graph.Authentication | Microsoft.Graph.PowerShell.Authentication.Loader.GraphAssemblyLoadContext | 1 |  |

## exo-only

Steps: baseline -> import-exo -> connect-exo. Instruction given: One EXO prompt (WAM account picker). Sign in, or cancel; the stack is loaded before the prompt either way.

Child script version 2.1.

### Steps

| Step | Outcome | Exception type | Message (first line) |
|---|---|---|---|
| baseline | ok |  |  |
| import-exo | ok |  |  |
| connect-exo | ok |  |  |

### Final snapshot (after connect-exo)

| Assembly | Version | Context | Owner | Location |
|---|---|---|---|---|
| Microsoft.Identity.Client | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop | 0.19.4.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions | 8.19.2.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity |  | (not loaded) |  | (none) |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Microsoft.Exchange.Management.AdminApiProvider | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll |
| Microsoft.Exchange.Management.ExoPowershellGalleryModule | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll |
| Microsoft.Exchange.Management.RestApiClient | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.RestApiClient.dll |
| Microsoft.Identity.Client | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop | 0.19.4.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions | 8.19.2.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |

</details>

### Native msalruntime

Count in final snapshot: 1
- EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll (first mapped after connect-exo; file version not set; base 0x7FFAF4D30000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-exo: 0; nothing mapped under that name
- after connect-exo: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True

### DllImport targets in each loaded Microsoft.Identity.Client.NativeInterop (final snapshot)

| NativeInterop copy | Context | P/Invokes | Library names (count) |
|---|---|---|---|
| EXO: ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll | Default | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |

### DllImportResolver registrations (final snapshot)

NativeLibrary field: s_nativeDllResolveMap; table exists: False; entries: none
- NativeInterop EXO (Default): resolver registered = False

### RuntimeBroker statics (final snapshot)

| Broker copy | Context | Lazy Core created | Core is null | s_initException |
|---|---|---|---|---|
| EXO | Default | True | False | (null) |

Per step (Lazy Core created / Core is null, per Broker copy):

- after baseline: no Broker assembly loaded
- after import-exo: no Broker assembly loaded
- after connect-exo: EXO: created=True, null=False

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-exo: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-exo: System.Reflection.Assembly.LoadFromResolveHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 115 |  |

## graph-import-then-exo

Steps: baseline -> import-graph -> import-exo -> connect-exo. Instruction given: No Graph prompt. If an EXO prompt appears, sign in or cancel. If EXO throws before any prompt, that is the mechanism-A signal.

Child script version 2.1.

### Steps

| Step | Outcome | Exception type | Message (first line) |
|---|---|---|---|
| baseline | ok |  |  |
| import-graph | ok |  |  |
| import-exo | ok |  |  |
| connect-exo | ok |  |  |

### Final snapshot (after connect-exo)

| Assembly | Version | Context | Owner | Location |
|---|---|---|---|---|
| Microsoft.Identity.Client | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop | 0.19.4.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions | 8.19.2.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity |  | (not loaded) |  | (none) |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Microsoft.Exchange.Management.AdminApiProvider | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll |
| Microsoft.Exchange.Management.ExoPowershellGalleryModule | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll |
| Microsoft.Exchange.Management.RestApiClient | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.RestApiClient.dll |
| Microsoft.Graph.Authentication | 2.41.2.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Microsoft.Graph.Authentication.dll |
| Microsoft.Graph.Authentication.Core | 2.41.2.0 | Microsoft.Graph.Authentication | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Core.dll |
| Microsoft.Graph.Authentication.Loader | 2.38.1.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Loader.dll |
| Microsoft.Identity.Client | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop | 0.19.4.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions | 8.19.2.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |

</details>

### Native msalruntime

Count in final snapshot: 1
- EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll (first mapped after connect-exo; file version not set; base 0x7FFAF4D30000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-graph: 0; nothing mapped under that name
- after import-exo: 0; nothing mapped under that name
- after connect-exo: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True

### DllImport targets in each loaded Microsoft.Identity.Client.NativeInterop (final snapshot)

| NativeInterop copy | Context | P/Invokes | Library names (count) |
|---|---|---|---|
| EXO: ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll | Default | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |

### DllImportResolver registrations (final snapshot)

NativeLibrary field: s_nativeDllResolveMap; table exists: False; entries: none
- NativeInterop EXO (Default): resolver registered = False

### RuntimeBroker statics (final snapshot)

| Broker copy | Context | Lazy Core created | Core is null | s_initException |
|---|---|---|---|---|
| EXO | Default | True | False | (null) |

Per step (Lazy Core created / Core is null, per Broker copy):

- after baseline: no Broker assembly loaded
- after import-graph: no Broker assembly loaded
- after import-exo: no Broker assembly loaded
- after connect-exo: EXO: created=True, null=False

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-graph: System.Reflection.Assembly.LoadFromResolveHandler
- after import-exo: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-exo: System.Reflection.Assembly.LoadFromResolveHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 121 |  |
| Microsoft.Graph.Authentication | Microsoft.Graph.PowerShell.Authentication.Loader.GraphAssemblyLoadContext | 1 |  |

## graph-connect-then-exo

Steps: baseline -> import-graph -> connect-graph -> import-exo -> connect-exo. Instruction given: Sign in at the Graph WAM prompt. EXO is then expected to throw the RuntimeBroker NullReferenceException before any prompt.

Child script version 2.1.

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
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.19.2.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Azure.Core | 1.51.1.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Azure.Core.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |
| Azure.Identity.Broker | 1.4.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.Broker.dll |
| Microsoft.Exchange.Management.AdminApiProvider | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll |
| Microsoft.Exchange.Management.ExoPowershellGalleryModule | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll |
| Microsoft.Exchange.Management.RestApiClient | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.RestApiClient.dll |
| Microsoft.Graph.Authentication | 2.41.2.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Microsoft.Graph.Authentication.dll |
| Microsoft.Graph.Authentication.Core | 2.41.2.0 | Microsoft.Graph.Authentication | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Core.dll |
| Microsoft.Graph.Authentication.Loader | 2.38.1.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Loader.dll |
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Extensions.Msal | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.Extensions.Msal.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.19.2.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.IdentityModel.Abstractions.dll |

</details>

### Native msalruntime

Count in final snapshot: 2
- Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll (first mapped after connect-graph; file version not set; base 0x7FFAF4D10000)
- EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll (first mapped after connect-exo; file version not set; base 0x7FFAF2770000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-graph: 0; nothing mapped under that name
- after connect-graph: 1 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True
- after import-exo: 1 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True
- after connect-exo: 2 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll; EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True

### DllImport targets in each loaded Microsoft.Identity.Client.NativeInterop (final snapshot)

| NativeInterop copy | Context | P/Invokes | Library names (count) |
|---|---|---|---|
| Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll | Microsoft.Graph.Authentication | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |
| EXO: ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll | Default | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |

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
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 125 |  |
| Microsoft.Graph.Authentication | Microsoft.Graph.PowerShell.Authentication.Loader.GraphAssemblyLoadContext | 10 |  |

## graph-cancel-then-exo

Steps: baseline -> import-graph -> connect-graph-cancel -> import-exo -> connect-exo. Instruction given: CANCEL the Graph WAM picker (close it without choosing an account). If an EXO prompt follows, sign in or cancel.

Child script version 2.1.

### Steps

| Step | Outcome | Exception type | Message (first line) |
|---|---|---|---|
| baseline | ok |  |  |
| import-graph | ok |  |  |
| connect-graph-cancel | ok |  |  |
| import-exo | ok |  |  |
| connect-exo | ok |  |  |

### Final snapshot (after connect-exo)

| Assembly | Version | Context | Owner | Location |
|---|---|---|---|---|
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.19.2.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Azure.Core | 1.51.1.0 | Microsoft.Graph.Authentication | Graph | connect-graph-cancel | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Azure.Core.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph-cancel | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |
| Azure.Identity.Broker | 1.4.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph-cancel | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.Broker.dll |
| Microsoft.Exchange.Management.AdminApiProvider | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll |
| Microsoft.Exchange.Management.ExoPowershellGalleryModule | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll |
| Microsoft.Exchange.Management.RestApiClient | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.RestApiClient.dll |
| Microsoft.Graph.Authentication | 2.41.2.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Microsoft.Graph.Authentication.dll |
| Microsoft.Graph.Authentication.Core | 2.41.2.0 | Microsoft.Graph.Authentication | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Core.dll |
| Microsoft.Graph.Authentication.Loader | 2.38.1.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Loader.dll |
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph-cancel | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph-cancel | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Extensions.Msal | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph-cancel | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.Extensions.Msal.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Microsoft.Graph.Authentication | Graph | connect-graph-cancel | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.19.2.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph-cancel | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.IdentityModel.Abstractions.dll |

</details>

### Native msalruntime

Count in final snapshot: 2
- Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll (first mapped after connect-graph-cancel; file version not set; base 0x7FFAF4D10000)
- EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll (first mapped after connect-exo; file version not set; base 0x7FFAF5900000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-graph: 0; nothing mapped under that name
- after connect-graph-cancel: 1 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True
- after import-exo: 1 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True
- after connect-exo: 2 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll; EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True

### DllImport targets in each loaded Microsoft.Identity.Client.NativeInterop (final snapshot)

| NativeInterop copy | Context | P/Invokes | Library names (count) |
|---|---|---|---|
| Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll | Microsoft.Graph.Authentication | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |
| EXO: ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll | Default | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |

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
- after connect-graph-cancel: Graph: created=True, null=False
- after import-exo: Graph: created=True, null=False
- after connect-exo: Graph: created=True, null=False; EXO: created=True, null=False

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-graph: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-graph-cancel: System.Reflection.Assembly.LoadFromResolveHandler
- after import-exo: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-exo: System.Reflection.Assembly.LoadFromResolveHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 125 |  |
| Microsoft.Graph.Authentication | Microsoft.Graph.PowerShell.Authentication.Loader.GraphAssemblyLoadContext | 10 |  |

## graph-connect-then-exo-disablewam

Steps: baseline -> import-graph -> connect-graph -> import-exo -> connect-exo-disablewam. Instruction given: Sign in at the Graph WAM prompt. EXO then opens a browser sign-in (no WAM); sign in or cancel.

Child script version 2.1.

### Steps

| Step | Outcome | Exception type | Message (first line) |
|---|---|---|---|
| baseline | ok |  |  |
| import-graph | ok |  |  |
| connect-graph | ok |  |  |
| import-exo | ok |  |  |
| connect-exo-disablewam | ok |  |  |

### Final snapshot (after connect-exo-disablewam)

| Assembly | Version | Context | Owner | Location |
|---|---|---|---|---|
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop | 0.20.6.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.19.2.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Azure.Core | 1.51.1.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Azure.Core.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |
| Azure.Identity.Broker | 1.4.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.Broker.dll |
| Microsoft.Exchange.Management.AdminApiProvider | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll |
| Microsoft.Exchange.Management.ExoPowershellGalleryModule | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll |
| Microsoft.Exchange.Management.RestApiClient | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.RestApiClient.dll |
| Microsoft.Graph.Authentication | 2.41.2.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Microsoft.Graph.Authentication.dll |
| Microsoft.Graph.Authentication.Core | 2.41.2.0 | Microsoft.Graph.Authentication | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Core.dll |
| Microsoft.Graph.Authentication.Loader | 2.38.1.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Loader.dll |
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | Default | EXO | connect-exo-disablewam | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | Default | EXO | connect-exo-disablewam | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Extensions.Msal | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.Extensions.Msal.dll |
| Microsoft.Identity.Client.NativeInterop | 0.20.6.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.19.2.0 | Default | EXO | connect-exo-disablewam | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.IdentityModel.Abstractions.dll |

</details>

### Native msalruntime

Count in final snapshot: 1
- Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll (first mapped after connect-graph; file version not set; base 0x7FFAF58E0000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-graph: 0; nothing mapped under that name
- after connect-graph: 1 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True
- after import-exo: 1 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True
- after connect-exo-disablewam: 1 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True

### DllImport targets in each loaded Microsoft.Identity.Client.NativeInterop (final snapshot)

| NativeInterop copy | Context | P/Invokes | Library names (count) |
|---|---|---|---|
| Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll | Microsoft.Graph.Authentication | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |

### DllImportResolver registrations (final snapshot)

NativeLibrary field: s_nativeDllResolveMap; table exists: False; entries: none
- NativeInterop Graph (Microsoft.Graph.Authentication): resolver registered = False

### RuntimeBroker statics (final snapshot)

| Broker copy | Context | Lazy Core created | Core is null | s_initException |
|---|---|---|---|---|
| Graph | Microsoft.Graph.Authentication | True | False | (null) |
| EXO | Default | False |  | (null) |

Per step (Lazy Core created / Core is null, per Broker copy):

- after baseline: no Broker assembly loaded
- after import-graph: no Broker assembly loaded
- after connect-graph: Graph: created=True, null=False
- after import-exo: Graph: created=True, null=False
- after connect-exo-disablewam: Graph: created=True, null=False; EXO: created=False, null=

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-graph: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-graph: System.Reflection.Assembly.LoadFromResolveHandler
- after import-exo: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-exo-disablewam: System.Reflection.Assembly.LoadFromResolveHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 126 |  |
| Microsoft.Graph.Authentication | Microsoft.Graph.PowerShell.Authentication.Loader.GraphAssemblyLoadContext | 10 |  |

## graph-accesstoken-then-exo

Steps: baseline -> import-graph -> connect-graph-accesstoken -> import-exo -> connect-exo. Instruction given: First an Az browser sign-in in the harness (it fetches a Graph token without WAM), then an EXO WAM prompt in the window: sign in or cancel.

Child script version 2.1.

### Steps

| Step | Outcome | Exception type | Message (first line) |
|---|---|---|---|
| baseline | ok |  |  |
| import-graph | ok |  |  |
| connect-graph-accesstoken | ok |  |  |
| import-exo | ok |  |  |
| connect-exo | ok |  |  |

### Final snapshot (after connect-exo)

| Assembly | Version | Context | Owner | Location |
|---|---|---|---|---|
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop | 0.19.4.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions | 8.19.2.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Azure.Core | 1.51.1.0 | Microsoft.Graph.Authentication | Graph | connect-graph-accesstoken | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Azure.Core.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph-accesstoken | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |
| Microsoft.Exchange.Management.AdminApiProvider | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll |
| Microsoft.Exchange.Management.ExoPowershellGalleryModule | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll |
| Microsoft.Exchange.Management.RestApiClient | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.RestApiClient.dll |
| Microsoft.Graph.Authentication | 2.41.2.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Microsoft.Graph.Authentication.dll |
| Microsoft.Graph.Authentication.Core | 2.41.2.0 | Microsoft.Graph.Authentication | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Core.dll |
| Microsoft.Graph.Authentication.Loader | 2.38.1.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Loader.dll |
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph-accesstoken | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Extensions.Msal | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph-accesstoken | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.Extensions.Msal.dll |
| Microsoft.Identity.Client.NativeInterop | 0.19.4.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions | 8.19.2.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |

</details>

### Native msalruntime

Count in final snapshot: 1
- EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll (first mapped after connect-exo; file version not set; base 0x7FFAF4D30000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-graph: 0; nothing mapped under that name
- after connect-graph-accesstoken: 0; nothing mapped under that name
- after import-exo: 0; nothing mapped under that name
- after connect-exo: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True

### DllImport targets in each loaded Microsoft.Identity.Client.NativeInterop (final snapshot)

| NativeInterop copy | Context | P/Invokes | Library names (count) |
|---|---|---|---|
| EXO: ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll | Default | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |

### DllImportResolver registrations (final snapshot)

NativeLibrary field: s_nativeDllResolveMap; table exists: False; entries: none
- NativeInterop EXO (Default): resolver registered = False

### RuntimeBroker statics (final snapshot)

| Broker copy | Context | Lazy Core created | Core is null | s_initException |
|---|---|---|---|---|
| EXO | Default | True | False | (null) |

Per step (Lazy Core created / Core is null, per Broker copy):

- after baseline: no Broker assembly loaded
- after import-graph: no Broker assembly loaded
- after connect-graph-accesstoken: no Broker assembly loaded
- after import-exo: no Broker assembly loaded
- after connect-exo: EXO: created=True, null=False

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-graph: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-graph-accesstoken: System.Reflection.Assembly.LoadFromResolveHandler
- after import-exo: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-exo: System.Reflection.Assembly.LoadFromResolveHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 122 |  |
| Microsoft.Graph.Authentication | Microsoft.Graph.PowerShell.Authentication.Loader.GraphAssemblyLoadContext | 6 |  |

## exo-then-graph

Steps: baseline -> import-exo -> connect-exo -> import-graph -> connect-graph. Instruction given: Sign in at the EXO WAM prompt. On Graph 2.40.0 Connect-MgGraph then fails before any prompt (WithLogging MissingMethodException); on 2.41.0 or later a Graph prompt is expected: sign in, or cancel.

Child script version 2.1.

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
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.19.2.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Azure.Core | 1.51.1.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Azure.Core.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |
| Azure.Identity.Broker | 1.4.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.Broker.dll |
| Microsoft.Exchange.Management.AdminApiProvider | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll |
| Microsoft.Exchange.Management.ExoPowershellGalleryModule | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll |
| Microsoft.Exchange.Management.RestApiClient | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.RestApiClient.dll |
| Microsoft.Graph.Authentication | 2.41.2.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Microsoft.Graph.Authentication.dll |
| Microsoft.Graph.Authentication.Core | 2.41.2.0 | Microsoft.Graph.Authentication | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Core.dll |
| Microsoft.Graph.Authentication.Loader | 2.38.1.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Loader.dll |
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Extensions.Msal | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.Extensions.Msal.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.19.2.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.IdentityModel.Abstractions.dll |

</details>

### Native msalruntime

Count in final snapshot: 2
- EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll (first mapped after connect-exo; file version not set; base 0x7FFB6ECD0000)
- Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll (first mapped after connect-graph; file version not set; base 0x7FFAF58E0000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-exo: 0; nothing mapped under that name
- after connect-exo: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True
- after import-graph: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True
- after connect-graph: 2 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll; Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True

### DllImport targets in each loaded Microsoft.Identity.Client.NativeInterop (final snapshot)

| NativeInterop copy | Context | P/Invokes | Library names (count) |
|---|---|---|---|
| EXO: ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll | Default | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |
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
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 125 |  |
| Microsoft.Graph.Authentication | Microsoft.Graph.PowerShell.Authentication.Loader.GraphAssemblyLoadContext | 10 |  |

## Interpretation

Findings follow the decision rules fixed before the run. Every claim carries a status: Observed (a value in results\*.json or a transcript line, cited), Inferred (derived from observed values plus source or metadata that was read offline, with the basis named), Prediction (not yet tested), or Not run. Anything that fits neither mechanism is reported as unexplained.

### Finding 1: which mechanism

| Claim | Status | Evidence |
|---|---|---|
| exo-only: EXO alone signs in; its identity stack lands in Default from netCore with one msalruntime (EXO's) | Observed | exo-only.json Steps[connect-exo]: Outcome=ok; Notes.Connected=True; final NativeModules: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll) |
| Importing Graph without connecting leaves EXO working (graph-import-then-exo reaches a sign-in) | Observed | graph-import-then-exo.json Steps[connect-exo]: Outcome=ok; Notes.Connected=True |
| A Graph WAM sign-in first makes Connect-ExchangeOnline throw the RuntimeBroker NullReferenceException | Observed: contradicted | graph-connect-then-exo.json Steps[connect-exo]: Outcome=ok; Notes.Connected=True; stack frame RuntimeBroker..ctor present: False |
| Graph's msalruntime is mapped during Connect-MgGraph, not at import | Observed | graph-connect-then-exo.json Steps[import-graph].Snapshot.NativeModules: 0; Steps[connect-graph]: 1 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll) |
| EXO's msalruntime is mapped during Connect-ExchangeOnline, not at import | Observed | graph-connect-then-exo.json Steps[import-exo].Snapshot.NativeModules: 1 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); Steps[connect-exo]: 2 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll; EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); exo-only.json Steps[import-exo]: 0; Steps[connect-exo]: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll) |
| After Connect-ExchangeOnline two msalruntime.dll files are mapped, one from each module | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot.NativeModules: 2 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll; EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll) |
| A bare-name request for msalruntime.dll in that process resolves to Graph's copy | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot: Win32 GetModuleHandleW/LoadLibraryW: GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True |
| EXO's NativeInterop declares its runtime P/Invokes against the bare name "msalruntime" (no path) | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot.DllImportTargets[EXO]: 269 P/Invokes; library names: kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |
| No DllImportResolver is registered for either NativeInterop copy, so nothing pins its P/Invokes to the handle it preloaded | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot.DllImportResolvers: field s_nativeDllResolveMap; table exists False; entries: none; NativeInterop HasResolver: Graph=False, EXO=False |
| EXO's NativeInterop mapped its own msalruntime by full path (a kernel32 LoadLibrary preload from runtimes\win-x64\native) | Inferred | Basis: offline metadata of NativeInterop 0.19.4 (P/Invoke kernel32!LoadLibrary; string literals "runtimes", "win-x64\native\msalruntime.dll", "PATH") plus the observation that the second mapping appears exactly at connect-exo. The preload call itself was not traced. |
| EXO's P/Invokes therefore executed against Graph's already-started runtime rather than its own mapped copy | Inferred | Basis: the observed bare-name resolution, the observed bare-name DllImport targets, and the observed absence of a resolver. Binding was not traced with a debugger. |
| EXO's RuntimeBroker copy started: lazy Core created and live, no s_initException, so the runtime its P/Invokes reached accepted a second startup | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot.BrokerRuntimeState[EXO]: LazyCoreValueCreated=True; CoreIsNull=False; InitException.Type=null; Status=(none); Context="(none)" |
| Graph's RuntimeBroker copy in the same process has a live Core and no init exception | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot.BrokerRuntimeState[Graph]: LazyCoreValueCreated=True; CoreIsNull=False; InitException=null |
| Why the second startup is accepted on this build: the runtime Graph maps comes from a newer NativeInterop package than the one EXO carries (and than the 0.19.4 both shipped when the failure was recorded); whether the change is in msalruntime itself or in how MSAL starts it was not traced | Inferred | graph-connect-then-exo.json Steps[connect-exo].Snapshot.Assemblies[Microsoft.Identity.Client.NativeInterop]: EXO=0.19.4.0 (Default), Graph=0.20.6.0 (Microsoft.Graph.Authentication); NativeModules FileVersion: none (msalruntime.dll carries no version resource) |

No failure to explain on this build: Connect-ExchangeOnline signed in after a Graph WAM sign-in. The native picture is the one that failed on 2.40.0 (2 msalruntime copies; bare name -> Graph; EXO's P/Invokes bare-name; no resolver), so EXO's second startup went against Graph's mapped copy and was accepted. The difference is on the native side, in the runtime each module ships (NativeInterop EXO 0.19.4.0 vs Graph 0.20.6.0), not in managed resolution.

### Finding 2: can Graph's AssemblyResolve handler run before LoadFromResolveHandler?

| Claim | Status | Evidence |
|---|---|---|
| LoadFromResolveHandler is registered at baseline, before any module import | Observed | graph-connect-then-exo.json Steps[baseline].Snapshot.AssemblyResolveHandlers.Handlers: System.Reflection.Assembly.LoadFromResolveHandler |
| No Graph AssemblyResolve handler is registered: from 2.41.0 Graph resolves its dependencies inside GraphAssemblyLoadContext instead of hooking AppDomain.AssemblyResolve | Observed | graph-connect-then-exo.json Steps[import-graph].Snapshot.AssemblyResolveHandlers.Handlers: System.Reflection.Assembly.LoadFromResolveHandler |
| The runtime invokes AssemblyResolve handlers in registration order and stops at the first non-null result | Inferred | Basis: .NET runtime source, System.Runtime.Loader.AssemblyLoadContext.InvokeResolveEvent (foreach over Delegate.EnumerateInvocationList, return first non-null). Documented behavior, not observed in this process. |
| EXO's identity assemblies resolved from netCore into Default in every scenario; none came from Graph's folder | Observed | final snapshots: exo-only: 4 EXO identity assemblies in Default; graph-import-then-exo: 4 EXO identity assemblies in Default; graph-connect-then-exo: 4 EXO identity assemblies in Default; graph-connect-then-exo-disablewam: 3 EXO identity assemblies in Default; exo-then-graph: 4 EXO identity assemblies in Default |
| Mechanism A cannot occur for EXO's own dependencies: LoadFromResolveHandler answers first for any file beside a LoadFrom-loaded requester in Default, and all of EXO's live in netCore beside the requesters | Inferred | Basis: the four rows above (by construction). |

### Finding 3: the other two directions on the released modules

| Claim | Status | Evidence |
|---|---|---|
| With -DisableWAM after a Graph sign-in, EXO signs in; its Broker assembly loads but its NativeInterop never does, and only Graph's msalruntime is mapped | Observed | graph-connect-then-exo-disablewam.json Steps[connect-exo-disablewam]: Outcome=ok; Notes.Connected=True; EXO Broker loaded: yes (Default); EXO NativeInterop loaded: no; NativeModules: 1 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll) |
| With the broker bypassed the RuntimeBroker constructor never runs, so nothing touches the native runtime a second time | Inferred | Basis: the row above (no NativeInterop, no second mapping) and MSAL's broker path being the only consumer of NativeInterop. |
| Prediction made before any isolated build ran: EXO first, then Connect-MgGraph no longer fails on WithLogging and reaches a Graph prompt, because Graph's Azure.Identity can no longer bind to EXO's MSAL in Default | Prediction: confirmed | exo-then-graph.json Steps[connect-graph]: Outcome=ok; Notes.SignedIn=True |
| Microsoft.Identity.Client is loaded twice in that process: EXO's in Default and Graph's in Microsoft.Graph.Authentication | Observed | exo-then-graph.json Steps[connect-graph].Snapshot.Assemblies: Microsoft.IdentityModel.Abstractions 8.19.2.0 in Default (EXO); Microsoft.IdentityModel.Abstractions 8.18.0.0 in Microsoft.Graph.Authentication (Graph); Microsoft.Identity.Client 4.83.1.0 in Default (EXO); Microsoft.Identity.Client 4.90.0.0 in Microsoft.Graph.Authentication (Graph) |
| EXO then Graph on the native side: msalruntime copies mapped, bare-name resolution, and each RuntimeBroker's startup state (a live Graph Core beside a live EXO Core means the already-started state is per mapped module; a Graph init exception means it is process-global) | Observed | exo-then-graph.json final snapshot: NativeModules 2 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll; Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True; Graph broker: created=True, null=False, init=none; EXO broker: created=True, null=False, init=none |

### Finding 4: is a completed Graph sign-in required, or just the picker?

| Claim | Status | Evidence |
|---|---|---|
| The Graph WAM picker was cancelled (Connect-MgGraph ended without a signed-in context) | Observed: differs | graph-cancel-then-exo.json Steps[connect-graph-cancel]: Outcome=ok; Notes.SignedIn=True |
| Graph's msalruntime was mapped and its RuntimeBroker Core created before the picker appeared (a cancel is enough to start the native runtime) | Observed | graph-cancel-then-exo.json Steps[connect-graph-cancel].Snapshot.NativeModules: 1 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); BrokerRuntimeState[Graph]: created=True, null=False |
| Connect-ExchangeOnline after that Graph step: signed-in | Observed | graph-cancel-then-exo.json Steps[connect-exo]: Outcome=ok; Notes.Connected=True; NativeModules: 2 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll; EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); bare-name: GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True; EXO RuntimeBroker: no init exception |

### Finding 5: is it about Graph, or about any WAM user (Az.Accounts)?

| Claim | Status | Evidence |
|---|---|---|
| Az.Accounts WAM sign-in followed by EXO | Not run | Precondition not met on this machine: az-connect-then-exo requires Az.Accounts with EnableLoginByWam = true (Get-AzConfig reported false; Az config was not changed). |

### Finding 5b: a Graph token from a non-WAM source (graph-accesstoken-then-exo)

| Claim | Status | Evidence |
|---|---|---|
| Prediction made before the run: handed a token, Graph never starts msalruntime, so EXO works afterwards | Prediction: confirmed | graph-accesstoken-then-exo.json Steps[connect-exo]: Outcome=ok; Notes.Connected=True |
| Connect-MgGraph -AccessToken connected without touching WAM: no msalruntime mapped, no Graph NativeInterop or RuntimeBroker loaded | Observed | graph-accesstoken-then-exo.json Steps[connect-graph-accesstoken]: Outcome=ok; Notes.SignedIn=True; Snapshot.NativeModules: 0; Graph NativeInterop loaded: no; Graph Broker copies: 0 |
| Connect-ExchangeOnline afterwards: signed-in | Observed | graph-accesstoken-then-exo.json Steps[connect-exo]: Outcome=ok; Notes.Connected=True; NativeModules: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); bare-name: GetModuleHandleW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True; EXO RuntimeBroker: created=True, null=False, init=none |

### Finding 6: Microsoft.Graph.Authentication 2.41.2 (released build containing PR #3789)

| Claim | Status | Evidence |
|---|---|---|
| Prediction made before the PR build ran: Graph-then-EXO still fails after the PR, because the PR pins Graph's P/Invokes to Graph's copy (LoadUnmanagedDll override) while EXO's stay bare-name in Default | Prediction: refuted | graph-connect-then-exo.json Steps[connect-exo]: Outcome=ok; Notes.Connected=True |
| Prediction made before the PR build ran: EXO-then-Graph is fixed by construction, because Graph's Azure.Identity can no longer bind to EXO's MSAL in Default | Prediction: confirmed | exo-then-graph.json Steps[connect-graph]: Outcome=ok; Notes.SignedIn=True |
| graph-import-then-exo: last connect step class = signed-in | Observed | graph-import-then-exo.json Steps[connect-exo]: Outcome=ok; Notes.Connected=True |
| graph-import-then-exo: Graph's NativeInterop load context | Observed | graph-import-then-exo.json final snapshot: not loaded |
| graph-import-then-exo: native mappings and bare-name resolution | Observed | graph-import-then-exo.json final snapshot: NativeModules 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True |
| graph-import-then-exo: RuntimeBroker statics | Observed | graph-import-then-exo.json final snapshot: Graph no Broker copy; EXO created=True, null=False, init=none |
| graph-connect-then-exo: last connect step class = signed-in | Observed | graph-connect-then-exo.json Steps[connect-exo]: Outcome=ok; Notes.Connected=True |
| graph-connect-then-exo: Graph's NativeInterop load context | Observed | graph-connect-then-exo.json final snapshot: Microsoft.Graph.Authentication (Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll) |
| graph-connect-then-exo: native mappings and bare-name resolution | Observed | graph-connect-then-exo.json final snapshot: NativeModules 2 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll; EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True |
| graph-connect-then-exo: RuntimeBroker statics | Observed | graph-connect-then-exo.json final snapshot: Graph created=True, null=False, init=none; EXO created=True, null=False, init=none |
| exo-then-graph: last connect step class = signed-in | Observed | exo-then-graph.json Steps[connect-graph]: Outcome=ok; Notes.SignedIn=True |
| exo-then-graph: Graph's NativeInterop load context | Observed | exo-then-graph.json final snapshot: Microsoft.Graph.Authentication (Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll) |
| exo-then-graph: native mappings and bare-name resolution | Observed | exo-then-graph.json final snapshot: NativeModules 2 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll; Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True |
| exo-then-graph: RuntimeBroker statics | Observed | exo-then-graph.json final snapshot: Graph created=True, null=False, init=none; EXO created=True, null=False, init=none |

### Implication for PR #3789

Observed on Microsoft.Graph.Authentication 2.41.2 (released build containing PR #3789): Graph-then-EXO = signed-in; EXO-then-Graph = signed-in; Graph-import-then-EXO = signed-in.
Graph-then-EXO works on the isolated build, which refutes the prediction, though not because EXO reached a different copy: the bare name still resolves to Graph's mapped msalruntime and EXO's RuntimeBroker started cleanly against it, so the second startup was accepted rather than avoided. The isolation changed the managed side only; the native change is the runtime Graph ships (Finding 1, last row).
EXO-then-Graph reached a Graph sign-in: the WithLogging failure is gone, as predicted.

