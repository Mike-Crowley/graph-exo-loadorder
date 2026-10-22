# Graph-then-EXO load-order diagnostic

Generated 2026-10-21 20:55. Host: PowerShell 7.6.7 (Core), .NET 10.0.13, Microsoft Windows NT 10.0.26300.0, process X64.
Requested modules: Microsoft.Graph.Authentication 2.41.2, ExchangeOnlineManagement 3.10.1. Every scenario ran in its own fresh pwsh -NoProfile process.

Snapshots were taken after every step: tracked managed assemblies with their load context, all load contexts, native msalruntime modules with the in-process bare-name resolution (Win32 GetModuleHandleW/LoadLibraryW and NativeLibrary.TryLoad), DllImport targets and DllImportResolver registrations of every loaded NativeInterop, the AppDomain.AssemblyResolve invocation list, RuntimeBroker statics, and module versions. Full detail is in results\<scenario>.json; host output is in results\<scenario>.transcript.txt. The tenant ID and account hint were scrubbed from both at write time. Status vocabulary: Observed, Inferred, Prediction, Not run.

## Summary

| Scenario | Child | Completed | Step outcomes | Last connect step class | msalruntime copies |
|---|---|---|---|---|---|
| probe-only | 2.3 | True | baseline=ok, import-probe-module=ok |  | 0 |
| spo-only | 2.3 | True | baseline=ok, import-spo=ok, connect-spo=ok | signed-in | 1 |
| spo-then-exo | 2.3 | True | baseline=ok, import-spo=ok, connect-spo=ok, import-exo=ok, connect-exo=exception | other-exception | 1 |
| exo-then-spo | 2.3 | True | baseline=ok, import-exo=ok, connect-exo=ok, import-spo=ok, connect-spo=ok | signed-in | 1 |
| graph-then-spo | 2.3 | True | baseline=ok, import-graph=ok, connect-graph=ok, import-spo=ok, connect-spo=ok | signed-in | 2 |
| spo-then-graph | 2.3 | True | baseline=ok, import-spo=ok, connect-spo=ok, import-graph=ok, connect-graph=ok | signed-in | 2 |

Defined but not run: imports-only, exo-only, graph-import-then-exo, graph-connect-then-exo, graph-cancel-then-exo, graph-connect-then-exo-disablewam, graph-accesstoken-then-exo, exo-then-graph, az-connect-then-exo, pr-graph-import-then-exo, pr-graph-connect-then-exo, pr-exo-then-graph.

## probe-only

Steps: baseline -> import-probe-module. Instruction given: Nothing to do: no modules, no prompts. Validates the snapshot code.

Child script version 2.3.

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
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 101 |  |

## spo-only

Steps: baseline -> import-spo -> connect-spo. Instruction given: One SharePoint Online prompt (WAM through the patched interop). Sign in.

Child script version 2.3.

### Steps

| Step | Outcome | Exception type | Message (first line) |
|---|---|---|---|
| baseline | ok |  |  |
| import-spo | ok |  |  |
| connect-spo | ok |  |  |

### Final snapshot (after connect-spo)

| Assembly | Version | Context | Owner | Location |
|---|---|---|---|---|
| Microsoft.Identity.Client | 4.82.0.0 | Default | SPO | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker | 4.82.0.0 | Default | SPO | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop | 0.19.4.0 | Default | SPO | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions | 8.14.0.0 | Default | SPO | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity |  | (not loaded) |  | (none) |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Microsoft.Identity.Client | 4.82.0.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker | 4.82.0.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop | 0.19.4.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions | 8.14.0.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.Online.SharePoint.Client.Tenant | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.Client.Tenant.dll |
| Microsoft.Online.SharePoint.Migration | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.Migration.dll |
| Microsoft.Online.SharePoint.PowerShell | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.PowerShell.dll |
| Microsoft.Online.SharePoint.PowerShell.ResourceManager | 16.0.0.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.PowerShell.ResourceManager.dll |
| Microsoft.SharePoint.Client | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.SharePoint.Client.dll |
| Microsoft.SharePoint.Client.Publishing | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.SharePoint.Client.Publishing.dll |
| Microsoft.SharePoint.Client.Runtime | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.SharePoint.Client.Runtime.dll |

</details>

### Native msalruntime

Count in final snapshot: 1
- SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL (first mapped after connect-spo; file version not set; base 0x7FFB28D10000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-spo: 0; nothing mapped under that name
- after connect-spo: 1 (SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); GetModuleHandleW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); LoadLibraryW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL), same handle: True, freed: True

### DllImport targets in each loaded Microsoft.Identity.Client.NativeInterop (final snapshot)

| NativeInterop copy | Context | P/Invokes | Library names (count) |
|---|---|---|---|
| SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.NativeInterop.dll | Default | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |

### DllImportResolver registrations (final snapshot)

NativeLibrary field: s_nativeDllResolveMap; table exists: False; entries: none
- NativeInterop SPO (Default): resolver registered = False

### RuntimeBroker statics (final snapshot)

| Broker copy | Context | Lazy Core created | Core is null | s_initException |
|---|---|---|---|---|
| SPO | Default | True | False | (null) |

Per step (Lazy Core created / Core is null, per Broker copy):

- after baseline: no Broker assembly loaded
- after import-spo: no Broker assembly loaded
- after connect-spo: SPO: created=True, null=False

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-spo: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-spo: System.Reflection.Assembly.LoadFromResolveHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 128 |  |

## spo-then-exo

Steps: baseline -> import-spo -> connect-spo -> import-exo -> connect-exo. Instruction given: SharePoint prompt first: sign in. Then EXO: a failure before any prompt is the point; if a prompt appears, sign in or cancel.

Child script version 2.3.

### Steps

| Step | Outcome | Exception type | Message (first line) |
|---|---|---|---|
| baseline | ok |  |  |
| import-spo | ok |  |  |
| connect-spo | ok |  |  |
| import-exo | ok |  |  |
| connect-exo | exception | System.IO.FileLoadException | Could not load file or assembly '~\OneDrive - Baseline Technologies\Documents\PowerShell\Modules\ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll'. The located assembly's manifest definition does not match the assembly reference. (0x80131040) |

Exception detail for connect-exo:

- FullyQualifiedErrorId: Could not load file or assembly '~\OneDrive - Baseline Technologies\Documents\PowerShell\Modules\ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll'. The located assembly's manifest definition does not match the assembly reference. (0x80131040)
- top of stack:

```text
at System.Runtime.Loader.AssemblyLoadContext.LoadFromAssemblyPath(String assemblyPath)
at System.Reflection.Assembly.LoadFromResolveHandler(Object sender, ResolveEventArgs args)
at System.Runtime.Loader.AssemblyLoadContext.InvokeResolveEvent(ResolveEventHandler eventHandler, RuntimeAssembly assembly, String name)
```

Host stream (transcript excerpt):

```text
PS>TerminatingError(Get-ConnectionContext): "Could not load file or assembly 'Microsoft.Identity.Client, Version=4.83.1.0, Culture=neutral, PublicKeyToken=0a613f4dd989e8ae'. The located assembly's manifest definition does not match the assembly reference. (0x80131040)"
PS>TerminatingError(): "Could not load file or assembly '~\OneDrive - Baseline Technologies\Documents\PowerShell\Modules\ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll'. The located assembly's manifest definition does not match the assembly reference. (0x80131040)"
>> TerminatingError(): "Could not load file or assembly '~\OneDrive - Baseline Technologies\Documents\PowerShell\Modules\ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll'. The located assembly's manifest definition does not match the assembly reference. (0x80131040)"
```

### Final snapshot (after connect-exo)

| Assembly | Version | Context | Owner | Location |
|---|---|---|---|---|
| Microsoft.Identity.Client | 4.82.0.0 | Default | SPO | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker | 4.82.0.0 | Default | SPO | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop | 0.19.4.0 | Default | SPO | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions | 8.14.0.0 | Default | SPO | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity |  | (not loaded) |  | (none) |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Microsoft.Exchange.Management.AdminApiProvider | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll |
| Microsoft.Exchange.Management.ExoPowershellGalleryModule | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll |
| Microsoft.Exchange.Management.RestApiClient | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.RestApiClient.dll |
| Microsoft.Identity.Client | 4.82.0.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker | 4.82.0.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop | 0.19.4.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions | 8.14.0.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.Online.SharePoint.Client.Tenant | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.Client.Tenant.dll |
| Microsoft.Online.SharePoint.Migration | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.Migration.dll |
| Microsoft.Online.SharePoint.PowerShell | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.PowerShell.dll |
| Microsoft.Online.SharePoint.PowerShell.ResourceManager | 16.0.0.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.PowerShell.ResourceManager.dll |
| Microsoft.SharePoint.Client | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.SharePoint.Client.dll |
| Microsoft.SharePoint.Client.Publishing | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.SharePoint.Client.Publishing.dll |
| Microsoft.SharePoint.Client.Runtime | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.SharePoint.Client.Runtime.dll |

</details>

### Native msalruntime

Count in final snapshot: 1
- SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL (first mapped after connect-spo; file version not set; base 0x7FFB4AE50000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-spo: 0; nothing mapped under that name
- after connect-spo: 1 (SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); GetModuleHandleW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); LoadLibraryW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL), same handle: True, freed: True
- after import-exo: 1 (SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); GetModuleHandleW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); LoadLibraryW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL), same handle: True, freed: True
- after connect-exo: 1 (SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); GetModuleHandleW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); LoadLibraryW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL), same handle: True, freed: True

### DllImport targets in each loaded Microsoft.Identity.Client.NativeInterop (final snapshot)

| NativeInterop copy | Context | P/Invokes | Library names (count) |
|---|---|---|---|
| SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.NativeInterop.dll | Default | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |

### DllImportResolver registrations (final snapshot)

NativeLibrary field: s_nativeDllResolveMap; table exists: False; entries: none
- NativeInterop SPO (Default): resolver registered = False

### RuntimeBroker statics (final snapshot)

| Broker copy | Context | Lazy Core created | Core is null | s_initException |
|---|---|---|---|---|
| SPO | Default | True | False | (null) |

Per step (Lazy Core created / Core is null, per Broker copy):

- after baseline: no Broker assembly loaded
- after import-spo: no Broker assembly loaded
- after connect-spo: SPO: created=True, null=False
- after import-exo: SPO: created=True, null=False
- after connect-exo: SPO: created=True, null=False

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-spo: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-spo: System.Reflection.Assembly.LoadFromResolveHandler
- after import-exo: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-exo: System.Reflection.Assembly.LoadFromResolveHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 137 |  |

## exo-then-spo

Steps: baseline -> import-exo -> connect-exo -> import-spo -> connect-spo. Instruction given: EXO prompt first: sign in. Then SharePoint: sign in if it prompts.

Child script version 2.3.

### Steps

| Step | Outcome | Exception type | Message (first line) |
|---|---|---|---|
| baseline | ok |  |  |
| import-exo | ok |  |  |
| connect-exo | ok |  |  |
| import-spo | ok |  |  |
| connect-spo | ok |  |  |

### Final snapshot (after connect-spo)

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
| Microsoft.Online.SharePoint.Client.Tenant | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.Client.Tenant.dll |
| Microsoft.Online.SharePoint.Migration | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.Migration.dll |
| Microsoft.Online.SharePoint.PowerShell | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.PowerShell.dll |
| Microsoft.Online.SharePoint.PowerShell.ResourceManager | 16.0.0.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.PowerShell.ResourceManager.dll |
| Microsoft.SharePoint.Client | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.SharePoint.Client.dll |
| Microsoft.SharePoint.Client.Publishing | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.SharePoint.Client.Publishing.dll |
| Microsoft.SharePoint.Client.Runtime | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.SharePoint.Client.Runtime.dll |

</details>

### Native msalruntime

Count in final snapshot: 1
- EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll (first mapped after connect-exo; file version not set; base 0x7FFB32950000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-exo: 0; nothing mapped under that name
- after connect-exo: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True
- after import-spo: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True
- after connect-spo: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True

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
- after import-spo: EXO: created=True, null=False
- after connect-spo: EXO: created=True, null=False

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-exo: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-exo: System.Reflection.Assembly.LoadFromResolveHandler
- after import-spo: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-spo: System.Reflection.Assembly.LoadFromResolveHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 135 |  |

## graph-then-spo

Steps: baseline -> import-graph -> connect-graph -> import-spo -> connect-spo. Instruction given: Graph signs in (silently if WAM holds the account). Then SharePoint: sign in if it prompts.

Child script version 2.3.

### Steps

| Step | Outcome | Exception type | Message (first line) |
|---|---|---|---|
| baseline | ok |  |  |
| import-graph | ok |  |  |
| connect-graph | ok |  |  |
| import-spo | ok |  |  |
| connect-spo | ok |  |  |

### Final snapshot (after connect-spo)

| Assembly | Version | Context | Owner | Location |
|---|---|---|---|---|
| Microsoft.Identity.Client (duplicate) | 4.82.0.0 | Default | SPO | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.82.0.0 | Default | SPO | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | Default | SPO | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.14.0.0 | Default | SPO | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Azure.Core | 1.51.1.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Azure.Core.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |
| Azure.Identity.Broker | 1.4.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.Broker.dll |
| Microsoft.Graph.Authentication | 2.41.2.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Microsoft.Graph.Authentication.dll |
| Microsoft.Graph.Authentication.Core | 2.41.2.0 | Microsoft.Graph.Authentication | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Core.dll |
| Microsoft.Graph.Authentication.Loader | 2.38.1.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Loader.dll |
| Microsoft.Identity.Client (duplicate) | 4.82.0.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.82.0.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Extensions.Msal | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.Extensions.Msal.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.14.0.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.Online.SharePoint.Client.Tenant | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.Client.Tenant.dll |
| Microsoft.Online.SharePoint.Migration | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.Migration.dll |
| Microsoft.Online.SharePoint.PowerShell | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.PowerShell.dll |
| Microsoft.Online.SharePoint.PowerShell.ResourceManager | 16.0.0.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.PowerShell.ResourceManager.dll |
| Microsoft.SharePoint.Client | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.SharePoint.Client.dll |
| Microsoft.SharePoint.Client.Publishing | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.SharePoint.Client.Publishing.dll |
| Microsoft.SharePoint.Client.Runtime | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.SharePoint.Client.Runtime.dll |

</details>

### Native msalruntime

Count in final snapshot: 2
- Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll (first mapped after connect-graph; file version not set; base 0x7FFB31D30000)
- SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL (first mapped after connect-spo; file version not set; base 0x7FFB285C0000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-graph: 0; nothing mapped under that name
- after connect-graph: 1 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True
- after import-spo: 1 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True
- after connect-spo: 2 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll; SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True

### DllImport targets in each loaded Microsoft.Identity.Client.NativeInterop (final snapshot)

| NativeInterop copy | Context | P/Invokes | Library names (count) |
|---|---|---|---|
| Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll | Microsoft.Graph.Authentication | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |
| SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.NativeInterop.dll | Default | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |

### DllImportResolver registrations (final snapshot)

NativeLibrary field: s_nativeDllResolveMap; table exists: False; entries: none
- NativeInterop Graph (Microsoft.Graph.Authentication): resolver registered = False
- NativeInterop SPO (Default): resolver registered = False

### RuntimeBroker statics (final snapshot)

| Broker copy | Context | Lazy Core created | Core is null | s_initException |
|---|---|---|---|---|
| Graph | Microsoft.Graph.Authentication | True | False | (null) |
| SPO | Default | True | False | (null) |

Per step (Lazy Core created / Core is null, per Broker copy):

- after baseline: no Broker assembly loaded
- after import-graph: no Broker assembly loaded
- after connect-graph: Graph: created=True, null=False
- after import-spo: Graph: created=True, null=False
- after connect-spo: Graph: created=True, null=False; SPO: created=True, null=False

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-graph: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-graph: System.Reflection.Assembly.LoadFromResolveHandler
- after import-spo: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-spo: System.Reflection.Assembly.LoadFromResolveHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 138 |  |
| Microsoft.Graph.Authentication | Microsoft.Graph.PowerShell.Authentication.Loader.GraphAssemblyLoadContext | 10 |  |

## spo-then-graph

Steps: baseline -> import-spo -> connect-spo -> import-graph -> connect-graph. Instruction given: SharePoint prompt first: sign in. Then Graph signs in (silently if WAM holds the account).

Child script version 2.3.

### Steps

| Step | Outcome | Exception type | Message (first line) |
|---|---|---|---|
| baseline | ok |  |  |
| import-spo | ok |  |  |
| connect-spo | ok |  |  |
| import-graph | ok |  |  |
| connect-graph | ok |  |  |

### Final snapshot (after connect-graph)

| Assembly | Version | Context | Owner | Location |
|---|---|---|---|---|
| Microsoft.Identity.Client (duplicate) | 4.82.0.0 | Default | SPO | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.82.0.0 | Default | SPO | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | Default | SPO | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.14.0.0 | Default | SPO | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Azure.Core | 1.51.1.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Azure.Core.dll |
| Azure.Identity | 1.18.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.dll |
| Azure.Identity.Broker | 1.4.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Azure.Identity.Broker.dll |
| Microsoft.Graph.Authentication | 2.41.2.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Microsoft.Graph.Authentication.dll |
| Microsoft.Graph.Authentication.Core | 2.41.2.0 | Microsoft.Graph.Authentication | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Core.dll |
| Microsoft.Graph.Authentication.Loader | 2.38.1.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Graph.Authentication.Loader.dll |
| Microsoft.Identity.Client (duplicate) | 4.82.0.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.82.0.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Extensions.Msal | 4.90.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Core\Microsoft.Identity.Client.Extensions.Msal.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.20.6.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.14.0.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | Microsoft.Graph.Authentication | Graph | connect-graph | Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.Online.SharePoint.Client.Tenant | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.Client.Tenant.dll |
| Microsoft.Online.SharePoint.Migration | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.Migration.dll |
| Microsoft.Online.SharePoint.PowerShell | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.PowerShell.dll |
| Microsoft.Online.SharePoint.PowerShell.ResourceManager | 16.0.0.0 | Default | SPO | connect-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Online.SharePoint.PowerShell.ResourceManager.dll |
| Microsoft.SharePoint.Client | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.SharePoint.Client.dll |
| Microsoft.SharePoint.Client.Publishing | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.SharePoint.Client.Publishing.dll |
| Microsoft.SharePoint.Client.Runtime | 16.0.0.0 | Default | SPO | import-spo | Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.SharePoint.Client.Runtime.dll |

</details>

### Native msalruntime

Count in final snapshot: 2
- SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL (first mapped after connect-spo; file version not set; base 0x7FFB31D50000)
- Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll (first mapped after connect-graph; file version not set; base 0x7FFB285A0000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-spo: 0; nothing mapped under that name
- after connect-spo: 1 (SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); GetModuleHandleW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); LoadLibraryW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL), same handle: True, freed: True
- after import-graph: 1 (SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); GetModuleHandleW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); LoadLibraryW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL), same handle: True, freed: True
- after connect-graph: 2 (SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL; Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); LoadLibraryW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL), same handle: True, freed: True

### DllImport targets in each loaded Microsoft.Identity.Client.NativeInterop (final snapshot)

| NativeInterop copy | Context | P/Invokes | Library names (count) |
|---|---|---|---|
| SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\Microsoft.Identity.Client.NativeInterop.dll | Default | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |
| Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\Microsoft.Identity.Client.NativeInterop.dll | Microsoft.Graph.Authentication | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |

### DllImportResolver registrations (final snapshot)

NativeLibrary field: s_nativeDllResolveMap; table exists: False; entries: none
- NativeInterop SPO (Default): resolver registered = False
- NativeInterop Graph (Microsoft.Graph.Authentication): resolver registered = False

### RuntimeBroker statics (final snapshot)

| Broker copy | Context | Lazy Core created | Core is null | s_initException |
|---|---|---|---|---|
| SPO | Default | True | False | (null) |
| Graph | Microsoft.Graph.Authentication | True | False | (null) |

Per step (Lazy Core created / Core is null, per Broker copy):

- after baseline: no Broker assembly loaded
- after import-spo: no Broker assembly loaded
- after connect-spo: SPO: created=True, null=False
- after import-graph: SPO: created=True, null=False
- after connect-graph: SPO: created=True, null=False; Graph: created=True, null=False

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-spo: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-spo: System.Reflection.Assembly.LoadFromResolveHandler
- after import-graph: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-graph: System.Reflection.Assembly.LoadFromResolveHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 138 |  |
| Microsoft.Graph.Authentication | Microsoft.Graph.PowerShell.Authentication.Loader.GraphAssemblyLoadContext | 10 |  |

## Interpretation

Findings follow the decision rules fixed before the run. Every claim carries a status: Observed (a value in results\*.json or a transcript line, cited), Inferred (derived from observed values plus source or metadata that was read offline, with the basis named), Prediction (not yet tested), or Not run. Anything that fits neither mechanism is reported as unexplained.

### Finding 1: which mechanism

| Claim | Status | Evidence |
|---|---|---|
| exo-only: EXO alone signs in; its identity stack lands in Default from netCore with one msalruntime (EXO's) | Not run |  |
| Importing Graph without connecting leaves EXO working (graph-import-then-exo reaches a sign-in) | Not run | graph-import-then-exo.json: step not recorded |
| A Graph WAM sign-in first makes Connect-ExchangeOnline throw the RuntimeBroker NullReferenceException | Not run |  |

Unexplained. connect-exo classes were not-run (import) and not-run (connect); this does not match either predicted pattern. See the raw step tables and exception details above.

### Finding 2: can Graph's AssemblyResolve handler run before LoadFromResolveHandler?

| Claim | Status | Evidence |
|---|---|---|
| Handler order | Not run | No import-graph step was recorded. |

### Finding 3: the other two directions on the released modules

| Claim | Status | Evidence |
|---|---|---|
| -DisableWAM behaviour | Not run |  |
| EXO-then-Graph behaviour | Not run |  |

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
| Prediction made before the PR build ran: Graph-then-EXO still fails after the PR, because the PR pins Graph's P/Invokes to Graph's copy (LoadUnmanagedDll override) while EXO's stay bare-name in Default | Prediction | Not run on this Graph version yet. |
| graph-import-then-exo, graph-connect-then-exo, exo-then-graph | Not run | Not run on this Graph version yet. |

### Finding 7: a third module (SharePoint Online, patched for PowerShell 7)

| Claim | Status | Evidence |
|---|---|---|
| spo-only: Baseline: where SPO's MSAL 4.82.0, Broker, NativeInterop 0.19.4 and msalruntime land, and whether the connect works on PowerShell 7 at all. | Prediction | Recorded before the run in scenarios.psd1. Outcome: connect-spo=signed-in |
| spo-only: connect-spo | Observed | spo-only.json Steps[connect-spo]: Outcome=ok; Notes.Connected=True |
| spo-only: MSAL, Broker and NativeInterop copies in the final snapshot | Observed | spo-only.json final Snapshot.Assemblies: Microsoft.Identity.Client 4.82.0.0 [SPO/Default]; Microsoft.Identity.Client.Broker 4.82.0.0 [SPO/Default]; Microsoft.Identity.Client.NativeInterop 0.19.4.0 [SPO/Default] |
| spo-only: native mappings, bare-name resolution, RuntimeBroker statics | Observed | spo-only.json final snapshot: NativeModules 1 (SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); GetModuleHandleW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); LoadLibraryW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL), same handle: True, freed: True; Broker copies: SPO [Default]: created=True, null=False, init=none |
| spo-then-exo: Prediction: a managed clash, EXO asking for MSAL 4.83.1 with 4.82.0 (.NET Framework build) already in Default; no native second start, because both modules would share the one NativeInterop 0.19.4 copy already in Default. | Prediction | Recorded before the run in scenarios.psd1. Outcome: connect-spo=signed-in; connect-exo=other-exception |
| spo-then-exo: connect-spo | Observed | spo-then-exo.json Steps[connect-spo]: Outcome=ok; Notes.Connected=True |
| spo-then-exo: connect-exo | Observed | spo-then-exo.json Steps[connect-exo]: Outcome=exception; Exception.TypeFullName=System.IO.FileLoadException |
| spo-then-exo: MSAL, Broker and NativeInterop copies in the final snapshot | Observed | spo-then-exo.json final Snapshot.Assemblies: Microsoft.Identity.Client 4.82.0.0 [SPO/Default]; Microsoft.Identity.Client.Broker 4.82.0.0 [SPO/Default]; Microsoft.Identity.Client.NativeInterop 0.19.4.0 [SPO/Default] |
| spo-then-exo: native mappings, bare-name resolution, RuntimeBroker statics | Observed | spo-then-exo.json final snapshot: NativeModules 1 (SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); GetModuleHandleW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); LoadLibraryW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL), same handle: True, freed: True; Broker copies: SPO [Default]: created=True, null=False, init=none |
| exo-then-spo: Prediction: SPO's 4.82.0 reference binds upward to EXO's 4.83.1 already in Default and the connect works on one shared NativeInterop and msalruntime. | Prediction | Recorded before the run in scenarios.psd1. Outcome: connect-exo=signed-in; connect-spo=signed-in |
| exo-then-spo: connect-exo | Observed | exo-then-spo.json Steps[connect-exo]: Outcome=ok; Notes.Connected=True |
| exo-then-spo: connect-spo | Observed | exo-then-spo.json Steps[connect-spo]: Outcome=ok; Notes.Connected=True |
| exo-then-spo: MSAL, Broker and NativeInterop copies in the final snapshot | Observed | exo-then-spo.json final Snapshot.Assemblies: Microsoft.Identity.Client 4.83.1.0 [EXO/Default]; Microsoft.Identity.Client.Broker 4.83.1.0 [EXO/Default]; Microsoft.Identity.Client.NativeInterop 0.19.4.0 [EXO/Default] |
| exo-then-spo: native mappings, bare-name resolution, RuntimeBroker statics | Observed | exo-then-spo.json final snapshot: NativeModules 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); LoadLibraryW -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll), same handle: True, freed: True; Broker copies: EXO [Default]: created=True, null=False, init=none |
| graph-then-spo: Prediction: SPO's bare-name P/Invokes land on Graph's msalruntime; with Graph 2.41.x (runtime shipped with NativeInterop 0.20.6) the second start is accepted, as it was for EXO. | Prediction | Recorded before the run in scenarios.psd1. Outcome: connect-graph=signed-in; connect-spo=signed-in |
| graph-then-spo: connect-graph | Observed | graph-then-spo.json Steps[connect-graph]: Outcome=ok; Notes.SignedIn=True |
| graph-then-spo: connect-spo | Observed | graph-then-spo.json Steps[connect-spo]: Outcome=ok; Notes.Connected=True |
| graph-then-spo: MSAL, Broker and NativeInterop copies in the final snapshot | Observed | graph-then-spo.json final Snapshot.Assemblies: Microsoft.Identity.Client 4.82.0.0 [SPO/Default]; Microsoft.Identity.Client 4.90.0.0 [Graph/Microsoft.Graph.Authentication]; Microsoft.Identity.Client.Broker 4.82.0.0 [SPO/Default]; Microsoft.Identity.Client.Broker 4.90.0.0 [Graph/Microsoft.Graph.Authentication]; Microsoft.Identity.Client.NativeInterop 0.19.4.0 [SPO/Default]; Microsoft.Identity.Client.NativeInterop 0.20.6.0 [Graph/Microsoft.Graph.Authentication] |
| graph-then-spo: native mappings, bare-name resolution, RuntimeBroker statics | Observed | graph-then-spo.json final snapshot: NativeModules 2 (Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll; SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll), same handle: True, freed: True; Broker copies: Graph [Microsoft.Graph.Authentication]: created=True, null=False, init=none; SPO [Default]: created=True, null=False, init=none |
| spo-then-graph: Prediction: Graph 2.41.x pins its own msalruntime through LoadUnmanagedDll and connects; two started runtimes in the process. | Prediction | Recorded before the run in scenarios.psd1. Outcome: connect-spo=signed-in; connect-graph=signed-in |
| spo-then-graph: connect-spo | Observed | spo-then-graph.json Steps[connect-spo]: Outcome=ok; Notes.Connected=True |
| spo-then-graph: connect-graph | Observed | spo-then-graph.json Steps[connect-graph]: Outcome=ok; Notes.SignedIn=True |
| spo-then-graph: MSAL, Broker and NativeInterop copies in the final snapshot | Observed | spo-then-graph.json final Snapshot.Assemblies: Microsoft.Identity.Client 4.82.0.0 [SPO/Default]; Microsoft.Identity.Client 4.90.0.0 [Graph/Microsoft.Graph.Authentication]; Microsoft.Identity.Client.Broker 4.82.0.0 [SPO/Default]; Microsoft.Identity.Client.Broker 4.90.0.0 [Graph/Microsoft.Graph.Authentication]; Microsoft.Identity.Client.NativeInterop 0.19.4.0 [SPO/Default]; Microsoft.Identity.Client.NativeInterop 0.20.6.0 [Graph/Microsoft.Graph.Authentication] |
| spo-then-graph: native mappings, bare-name resolution, RuntimeBroker statics | Observed | spo-then-graph.json final snapshot: NativeModules 2 (SPO: Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL; Graph: Microsoft.Graph.Authentication\2.41.2\Dependencies\msalruntime.dll); GetModuleHandleW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL); LoadLibraryW -> SPO (Microsoft.Online.SharePoint.PowerShell\16.0.27709.12000\msalruntime.DLL), same handle: True, freed: True; Broker copies: SPO [Default]: created=True, null=False, init=none; Graph [Microsoft.Graph.Authentication]: created=True, null=False, init=none |

### Implication for PR #3789

No implication can be stated because Finding 1 is unexplained.

