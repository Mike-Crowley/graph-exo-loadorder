# Graph-then-EXO load-order diagnostic

Generated 2026-09-25 12:10. Host: PowerShell 7.6.6 (Core), .NET 10.0.12, Microsoft Windows NT 10.0.26200.0, process X64.
Requested modules: Microsoft.Graph.Authentication 2.40.0, ExchangeOnlineManagement 3.10.1. Every scenario ran in its own fresh pwsh -NoProfile process.

Snapshots were taken after every step: tracked managed assemblies with their load context, all load contexts, native msalruntime modules with the in-process bare-name resolution (Win32 GetModuleHandleW/LoadLibraryW and NativeLibrary.TryLoad), DllImport targets and DllImportResolver registrations of every loaded NativeInterop, the AppDomain.AssemblyResolve invocation list, RuntimeBroker statics, and module versions. Full detail is in results\<scenario>.json; host output is in results\<scenario>.transcript.txt. The tenant ID and account hint were scrubbed from both at write time. Status vocabulary: Observed, Inferred, Prediction, Not run.

## Summary

| Scenario | Child | Completed | Step outcomes | Last connect step class | msalruntime copies |
|---|---|---|---|---|---|
| probe-only | 2.1 | True | baseline=ok, import-probe-module=ok |  | 0 |
| exo-only | 1.0 | True | baseline=ok, import-exo=ok, connect-exo=ok | signed-in | 1 |
| graph-import-then-exo | 1.0 | True | baseline=ok, import-graph=ok, import-exo=ok, connect-exo=ok | signed-in | 1 |
| graph-connect-then-exo | 2.0 | True | baseline=ok, import-graph=ok, connect-graph=ok, import-exo=ok, connect-exo=exception | nre-runtimebroker | 2 |
| graph-cancel-then-exo | 2.0 | True | baseline=ok, import-graph=ok, connect-graph-cancel=ok, import-exo=ok, connect-exo=exception | nre-runtimebroker | 2 |
| graph-connect-then-exo-disablewam | 1.0 | True | baseline=ok, import-graph=ok, connect-graph=ok, import-exo=ok, connect-exo-disablewam=ok | signed-in | 1 |
| graph-accesstoken-then-exo | 2.1 | True | baseline=ok, import-graph=ok, connect-graph-accesstoken=ok, import-exo=ok, connect-exo=ok | signed-in | 1 |
| exo-then-graph | 1.0 | True | baseline=ok, import-exo=ok, connect-exo=ok, import-graph=ok, connect-graph=nonterminating-error | withlogging-missingmethod | 1 |

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
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 92 |  |

## exo-only

Steps: baseline -> import-exo -> connect-exo. Instruction given: One EXO prompt (WAM account picker). Sign in, or cancel; the stack is loaded before the prompt either way.

Child script version 1.0.

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
- EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll (first mapped after connect-exo; file version not set; base 0x7FF8C6790000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; not probed
- after import-exo: 0; not probed
- after connect-exo: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); TryLoad -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll)

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-exo: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-exo: System.Reflection.Assembly.LoadFromResolveHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 109 |  |

## graph-import-then-exo

Steps: baseline -> import-graph -> import-exo -> connect-exo. Instruction given: No Graph prompt. If an EXO prompt appears, sign in or cancel. If EXO throws before any prompt, that is the mechanism-A signal.

Child script version 1.0.

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
| Azure.Core | 1.51.1.0 | msgraph-load-context | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Azure.Core.dll |
| Microsoft.Exchange.Management.AdminApiProvider | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll |
| Microsoft.Exchange.Management.ExoPowershellGalleryModule | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll |
| Microsoft.Exchange.Management.RestApiClient | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.RestApiClient.dll |
| Microsoft.Graph.Authentication | 2.40.0.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Microsoft.Graph.Authentication.dll |
| Microsoft.Graph.Authentication.Core | 2.40.0.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Microsoft.Graph.Authentication.Core.dll |
| Microsoft.Identity.Client | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop | 0.19.4.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions | 8.19.2.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |

</details>

### Native msalruntime

Count in final snapshot: 1
- EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll (first mapped after connect-exo; file version not set; base 0x7FF8C6790000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; not probed
- after import-graph: 0; not probed
- after import-exo: 0; not probed
- after connect-exo: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); TryLoad -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll)

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-graph: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler
- after import-exo: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler
- after connect-exo: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 114 |  |
| msgraph-load-context | System.Runtime.Loader.AssemblyLoadContext | 2 |  |

## graph-connect-then-exo

Steps: baseline -> import-graph -> connect-graph -> import-exo -> connect-exo. Instruction given: Sign in at the Graph WAM prompt. EXO is then expected to throw the RuntimeBroker NullReferenceException before any prompt.

Child script version 2.0.

### Steps

| Step | Outcome | Exception type | Message (first line) |
|---|---|---|---|
| baseline | ok |  |  |
| import-graph | ok |  |  |
| connect-graph | ok |  |  |
| import-exo | ok |  |  |
| connect-exo | exception | System.NullReferenceException | Object reference not set to an instance of an object. |

Exception detail for connect-exo:

- FullyQualifiedErrorId: Object reference not set to an instance of an object.
- top of stack:

```text
at Microsoft.Identity.Client.Platforms.Features.RuntimeBroker.RuntimeBroker..ctor(CoreUIParent uiParent, ApplicationConfiguration appConfig, ILoggerAdapter logger)
at Microsoft.Identity.Client.Broker.BrokerExtension.<>c.<AddRuntimeSupport>b__3_0(CoreUIParent uiParent, ApplicationConfiguration appConfig, ILoggerAdapter logger)
at Microsoft.Identity.Client.PlatformsCommon.Shared.AbstractPlatformProxy.CreateBroker(ApplicationConfiguration appConfig, CoreUIParent uiParent)
at Microsoft.Identity.Client.Internal.Requests.InteractiveRequest.FetchTokensFromBrokerAsync(String brokerInstallUrl, CancellationToken cancellationToken)
at Microsoft.Identity.Client.Internal.Requests.InteractiveRequest.GetTokenResponseAsync(CancellationToken cancellationToken)
at Microsoft.Identity.Client.Internal.Requests.InteractiveRequest.ExecuteAsync(CancellationToken cancellationToken)
```

Host stream (transcript excerpt):

```text
PS>TerminatingError(Get-ConnectionContext): "One or more errors occurred. (Object reference not set to an instance of an object.)"
PS>TerminatingError(): "Object reference not set to an instance of an object."
>> TerminatingError(): "Object reference not set to an instance of an object."
```

### Final snapshot (after connect-exo)

| Assembly | Version | Context | Owner | Location |
|---|---|---|---|---|
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.19.2.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity | 1.18.0.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Azure.Identity.dll |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Azure.Core | 1.51.1.0 | msgraph-load-context | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Azure.Core.dll |
| Azure.Identity | 1.18.0.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Azure.Identity.dll |
| Azure.Identity.Broker | 1.4.0.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Azure.Identity.Broker.dll |
| Microsoft.Exchange.Management.AdminApiProvider | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll |
| Microsoft.Exchange.Management.ExoPowershellGalleryModule | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll |
| Microsoft.Exchange.Management.RestApiClient | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.RestApiClient.dll |
| Microsoft.Graph.Authentication | 2.40.0.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Microsoft.Graph.Authentication.dll |
| Microsoft.Graph.Authentication.Core | 2.40.0.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Microsoft.Graph.Authentication.Core.dll |
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Extensions.Msal | 4.83.1.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Microsoft.Identity.Client.Extensions.Msal.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.19.2.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.IdentityModel.Abstractions.dll |

</details>

### Native msalruntime

Count in final snapshot: 2
- Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL (first mapped after connect-graph; file version not set; base 0x7FF84CC60000)
- EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll (first mapped after connect-exo; file version not set; base 0x7FF84C990000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-graph: 0; nothing mapped under that name
- after connect-graph: 1 (Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL), same handle: True, freed: True
- after import-exo: 1 (Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL), same handle: True, freed: True
- after connect-exo: 2 (Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL; EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL), same handle: True, freed: True

### DllImport targets in each loaded Microsoft.Identity.Client.NativeInterop (final snapshot)

| NativeInterop copy | Context | P/Invokes | Library names (count) |
|---|---|---|---|
| Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.Identity.Client.NativeInterop.dll | msgraph-load-context | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |
| EXO: ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll | Default | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |

### DllImportResolver registrations (final snapshot)

NativeLibrary field: s_nativeDllResolveMap; table exists: False; entries: none
- NativeInterop Graph (msgraph-load-context): resolver registered = False
- NativeInterop EXO (Default): resolver registered = False

### RuntimeBroker statics (final snapshot)

| Broker copy | Context | Lazy Core created | Core is null | s_initException |
|---|---|---|---|---|
| Graph | msgraph-load-context | True | False | (null) |
| EXO | Default | True | True | Microsoft.Identity.Client.NativeInterop.MsalRuntimeException, Status=ApiContractViolation, Context="Authenticator Factory has already been started" |

Per step (Lazy Core created / Core is null, per Broker copy):

- after baseline: no Broker assembly loaded
- after import-graph: no Broker assembly loaded
- after connect-graph: Graph: created=True, null=False
- after import-exo: Graph: created=True, null=False
- after connect-exo: Graph: created=True, null=False; EXO: created=True, null=True

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-graph: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler
- after connect-graph: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler
- after import-exo: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler
- after connect-exo: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 113 |  |
| msgraph-load-context | System.Runtime.Loader.AssemblyLoadContext | 9 |  |

## graph-cancel-then-exo

Steps: baseline -> import-graph -> connect-graph-cancel -> import-exo -> connect-exo. Instruction given: CANCEL the Graph WAM picker (close it without choosing an account). If an EXO prompt follows, sign in or cancel.

Child script version 2.0.

### Steps

| Step | Outcome | Exception type | Message (first line) |
|---|---|---|---|
| baseline | ok |  |  |
| import-graph | ok |  |  |
| connect-graph-cancel | ok |  |  |
| import-exo | ok |  |  |
| connect-exo | exception | System.NullReferenceException | Object reference not set to an instance of an object. |

Exception detail for connect-exo:

- FullyQualifiedErrorId: Object reference not set to an instance of an object.
- top of stack:

```text
at Microsoft.Identity.Client.Platforms.Features.RuntimeBroker.RuntimeBroker..ctor(CoreUIParent uiParent, ApplicationConfiguration appConfig, ILoggerAdapter logger)
at Microsoft.Identity.Client.Broker.BrokerExtension.<>c.<AddRuntimeSupport>b__3_0(CoreUIParent uiParent, ApplicationConfiguration appConfig, ILoggerAdapter logger)
at Microsoft.Identity.Client.PlatformsCommon.Shared.AbstractPlatformProxy.CreateBroker(ApplicationConfiguration appConfig, CoreUIParent uiParent)
at Microsoft.Identity.Client.Internal.Requests.InteractiveRequest.FetchTokensFromBrokerAsync(String brokerInstallUrl, CancellationToken cancellationToken)
at Microsoft.Identity.Client.Internal.Requests.InteractiveRequest.GetTokenResponseAsync(CancellationToken cancellationToken)
at Microsoft.Identity.Client.Internal.Requests.InteractiveRequest.ExecuteAsync(CancellationToken cancellationToken)
```

Host stream (transcript excerpt):

```text
PS>TerminatingError(Get-ConnectionContext): "One or more errors occurred. (Object reference not set to an instance of an object.)"
PS>TerminatingError(): "Object reference not set to an instance of an object."
>> TerminatingError(): "Object reference not set to an instance of an object."
```

### Final snapshot (after connect-exo)

| Assembly | Version | Context | Owner | Location |
|---|---|---|---|---|
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.19.2.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity | 1.18.0.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Azure.Identity.dll |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Azure.Core | 1.51.1.0 | msgraph-load-context | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Azure.Core.dll |
| Azure.Identity | 1.18.0.0 | msgraph-load-context | Graph | connect-graph-cancel | Microsoft.Graph.Authentication\2.40.0\Dependencies\Azure.Identity.dll |
| Azure.Identity.Broker | 1.4.0.0 | msgraph-load-context | Graph | connect-graph-cancel | Microsoft.Graph.Authentication\2.40.0\Dependencies\Azure.Identity.Broker.dll |
| Microsoft.Exchange.Management.AdminApiProvider | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll |
| Microsoft.Exchange.Management.ExoPowershellGalleryModule | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll |
| Microsoft.Exchange.Management.RestApiClient | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.RestApiClient.dll |
| Microsoft.Graph.Authentication | 2.40.0.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Microsoft.Graph.Authentication.dll |
| Microsoft.Graph.Authentication.Core | 2.40.0.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Microsoft.Graph.Authentication.Core.dll |
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | msgraph-load-context | Graph | connect-graph-cancel | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | msgraph-load-context | Graph | connect-graph-cancel | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Extensions.Msal | 4.83.1.0 | msgraph-load-context | Graph | connect-graph-cancel | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Microsoft.Identity.Client.Extensions.Msal.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.Identity.Client.NativeInterop (duplicate) | 0.19.4.0 | msgraph-load-context | Graph | connect-graph-cancel | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.19.2.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | msgraph-load-context | Graph | connect-graph-cancel | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.IdentityModel.Abstractions.dll |

</details>

### Native msalruntime

Count in final snapshot: 2
- Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL (first mapped after connect-graph-cancel; file version not set; base 0x7FF84CAB0000)
- EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll (first mapped after connect-exo; file version not set; base 0x7FF84C7E0000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; nothing mapped under that name
- after import-graph: 0; nothing mapped under that name
- after connect-graph-cancel: 1 (Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL), same handle: True, freed: True
- after import-exo: 1 (Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL), same handle: True, freed: True
- after connect-exo: 2 (Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL; EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL), same handle: True, freed: True

### DllImport targets in each loaded Microsoft.Identity.Client.NativeInterop (final snapshot)

| NativeInterop copy | Context | P/Invokes | Library names (count) |
|---|---|---|---|
| Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.Identity.Client.NativeInterop.dll | msgraph-load-context | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |
| EXO: ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll | Default | 269 | kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |

### DllImportResolver registrations (final snapshot)

NativeLibrary field: s_nativeDllResolveMap; table exists: False; entries: none
- NativeInterop Graph (msgraph-load-context): resolver registered = False
- NativeInterop EXO (Default): resolver registered = False

### RuntimeBroker statics (final snapshot)

| Broker copy | Context | Lazy Core created | Core is null | s_initException |
|---|---|---|---|---|
| Graph | msgraph-load-context | True | False | (null) |
| EXO | Default | True | True | Microsoft.Identity.Client.NativeInterop.MsalRuntimeException, Status=ApiContractViolation, Context="Authenticator Factory has already been started" |

Per step (Lazy Core created / Core is null, per Broker copy):

- after baseline: no Broker assembly loaded
- after import-graph: no Broker assembly loaded
- after connect-graph-cancel: Graph: created=True, null=False
- after import-exo: Graph: created=True, null=False
- after connect-exo: Graph: created=True, null=False; EXO: created=True, null=True

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-graph: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler
- after connect-graph-cancel: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler
- after import-exo: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler
- after connect-exo: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 113 |  |
| msgraph-load-context | System.Runtime.Loader.AssemblyLoadContext | 9 |  |

## graph-connect-then-exo-disablewam

Steps: baseline -> import-graph -> connect-graph -> import-exo -> connect-exo-disablewam. Instruction given: Sign in at the Graph WAM prompt. EXO then opens a browser sign-in (no WAM); sign in or cancel.

Child script version 1.0.

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
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop | 0.19.4.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.19.2.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity | 1.18.0.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Azure.Identity.dll |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Azure.Core | 1.51.1.0 | msgraph-load-context | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Azure.Core.dll |
| Azure.Identity | 1.18.0.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Azure.Identity.dll |
| Azure.Identity.Broker | 1.4.0.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Azure.Identity.Broker.dll |
| Microsoft.Exchange.Management.AdminApiProvider | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll |
| Microsoft.Exchange.Management.ExoPowershellGalleryModule | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll |
| Microsoft.Exchange.Management.RestApiClient | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.RestApiClient.dll |
| Microsoft.Graph.Authentication | 2.40.0.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Microsoft.Graph.Authentication.dll |
| Microsoft.Graph.Authentication.Core | 2.40.0.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Microsoft.Graph.Authentication.Core.dll |
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | Default | EXO | connect-exo-disablewam | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | Default | EXO | connect-exo-disablewam | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Broker (duplicate) | 4.83.1.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Extensions.Msal | 4.83.1.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Microsoft.Identity.Client.Extensions.Msal.dll |
| Microsoft.Identity.Client.NativeInterop | 0.19.4.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.19.2.0 | Default | EXO | connect-exo-disablewam | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.IdentityModel.Abstractions.dll |

</details>

### Native msalruntime

Count in final snapshot: 1
- Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL (first mapped after connect-graph; file version not set; base 0x7FF8CA6C0000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; not probed
- after import-graph: 0; not probed
- after connect-graph: 1 (Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL); TryLoad -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL)
- after import-exo: 1 (Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL); TryLoad -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL)
- after connect-exo-disablewam: 1 (Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL); TryLoad -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL)

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-graph: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler
- after connect-graph: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler
- after import-exo: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler
- after connect-exo-disablewam: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 116 |  |
| msgraph-load-context | System.Runtime.Loader.AssemblyLoadContext | 9 |  |

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
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop | 0.19.4.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions | 8.19.2.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity | 1.18.0.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Azure.Identity.dll |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Azure.Core | 1.51.1.0 | msgraph-load-context | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Azure.Core.dll |
| Azure.Identity | 1.18.0.0 | msgraph-load-context | Graph | connect-graph-accesstoken | Microsoft.Graph.Authentication\2.40.0\Dependencies\Azure.Identity.dll |
| Microsoft.Exchange.Management.AdminApiProvider | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll |
| Microsoft.Exchange.Management.ExoPowershellGalleryModule | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll |
| Microsoft.Exchange.Management.RestApiClient | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.RestApiClient.dll |
| Microsoft.Graph.Authentication | 2.40.0.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Microsoft.Graph.Authentication.dll |
| Microsoft.Graph.Authentication.Core | 2.40.0.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Microsoft.Graph.Authentication.Core.dll |
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client (duplicate) | 4.83.1.0 | msgraph-load-context | Graph | connect-graph-accesstoken | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Extensions.Msal | 4.83.1.0 | msgraph-load-context | Graph | connect-graph-accesstoken | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Microsoft.Identity.Client.Extensions.Msal.dll |
| Microsoft.Identity.Client.NativeInterop | 0.19.4.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions | 8.19.2.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |

</details>

### Native msalruntime

Count in final snapshot: 1
- EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll (first mapped after connect-exo; file version not set; base 0x7FF84DA90000)

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
- after import-graph: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler
- after connect-graph-accesstoken: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler
- after import-exo: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler
- after connect-exo: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 115 |  |
| msgraph-load-context | System.Runtime.Loader.AssemblyLoadContext | 5 |  |

## exo-then-graph

Steps: baseline -> import-exo -> connect-exo -> import-graph -> connect-graph. Instruction given: Sign in at the EXO WAM prompt. Graph is then expected to fail with the WithLogging MissingMethodException before any prompt.

Child script version 1.0.

### Steps

| Step | Outcome | Exception type | Message (first line) |
|---|---|---|---|
| baseline | ok |  |  |
| import-exo | ok |  |  |
| connect-exo | ok |  |  |
| import-graph | ok |  |  |
| connect-graph | nonterminating-error | Azure.Identity.AuthenticationFailedException | InteractiveBrowserCredential authentication failed: Method not found: '!0 Microsoft.Identity.Client.BaseAbstractApplicationBuilder`1.WithLogging(Microsoft.IdentityModel.Abstractions.IIdentityLogger, Boolean)'. |

Error stream detail for connect-graph:

- Azure.Identity.AuthenticationFailedException: InteractiveBrowserCredential authentication failed: Method not found: '!0 Microsoft.Identity.Client.BaseAbstractApplicationBuilder`1.WithLogging(Microsoft.IdentityModel.Abstractions.IIdentityLogger, Boolean)'.
  - inner: System.MissingMethodException: Method not found: '!0 Microsoft.Identity.Client.BaseAbstractApplicationBuilder`1.WithLogging(Microsoft.IdentityModel.Abstractions.IIdentityLogger, Boolean)'.

### Final snapshot (after connect-graph)

| Assembly | Version | Context | Owner | Location |
|---|---|---|---|---|
| Microsoft.Identity.Client | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker | 4.83.1.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.NativeInterop | 0.19.4.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.19.2.0 | Default | EXO | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.IdentityModel.Abstractions.dll |
| Azure.Identity | 1.18.0.0 | msgraph-load-context | Graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Azure.Identity.dll |

<details><summary>All tracked assemblies in the final snapshot</summary>

| Assembly | Version | Context | Owner | First seen | Location |
|---|---|---|---|---|---|
| Azure.Core | 1.51.1.0 | msgraph-load-context | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Azure.Core.dll |
| Azure.Identity | 1.18.0.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Azure.Identity.dll |
| Azure.Identity.Broker | 1.4.0.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Azure.Identity.Broker.dll |
| Microsoft.Exchange.Management.AdminApiProvider | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.AdminApiProvider.dll |
| Microsoft.Exchange.Management.ExoPowershellGalleryModule | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.ExoPowershellGalleryModule.dll |
| Microsoft.Exchange.Management.RestApiClient | 15.0.0.0 | Default | EXO | import-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Exchange.Management.RestApiClient.dll |
| Microsoft.Graph.Authentication | 2.40.0.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Microsoft.Graph.Authentication.dll |
| Microsoft.Graph.Authentication.Core | 2.40.0.0 | Default | Graph | import-graph | Microsoft.Graph.Authentication\2.40.0\Microsoft.Graph.Authentication.Core.dll |
| Microsoft.Identity.Client | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.dll |
| Microsoft.Identity.Client.Broker | 4.83.1.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.Broker.dll |
| Microsoft.Identity.Client.Extensions.Msal | 4.83.1.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Core\Microsoft.Identity.Client.Extensions.Msal.dll |
| Microsoft.Identity.Client.NativeInterop | 0.19.4.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.Identity.Client.NativeInterop.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.19.2.0 | Default | EXO | connect-exo | ExchangeOnlineManagement\3.10.1\netCore\Microsoft.IdentityModel.Abstractions.dll |
| Microsoft.IdentityModel.Abstractions (duplicate) | 8.18.0.0 | msgraph-load-context | Graph | connect-graph | Microsoft.Graph.Authentication\2.40.0\Dependencies\Microsoft.IdentityModel.Abstractions.dll |

</details>

### Native msalruntime

Count in final snapshot: 1
- EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll (first mapped after connect-exo; file version not set; base 0x7FF8CA6C0000)

Per step (count, then the bare-name resolution result):

- after baseline: 0; not probed
- after import-exo: 0; not probed
- after connect-exo: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); TryLoad -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll)
- after import-graph: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); TryLoad -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll)
- after connect-graph: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); TryLoad -> EXO (ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll)

### AppDomain.AssemblyResolve handlers (invocation order)

Source: System.Runtime.Loader.AssemblyLoadContext.AssemblyResolve (static field)

- after baseline: System.Reflection.Assembly.LoadFromResolveHandler
- after import-exo: System.Reflection.Assembly.LoadFromResolveHandler
- after connect-exo: System.Reflection.Assembly.LoadFromResolveHandler
- after import-graph: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler
- after connect-graph: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler

### Load contexts (final snapshot)

| Name | Type | Assemblies | Resolving handlers |
|---|---|---|---|
| Default | System.Runtime.Loader.DefaultAssemblyLoadContext | 114 |  |
| msgraph-load-context | System.Runtime.Loader.AssemblyLoadContext | 6 |  |

## Interpretation

Findings follow the decision rules fixed before the run. Every claim carries a status: Observed (a value in results\*.json or a transcript line, cited), Inferred (derived from observed values plus source or metadata that was read offline, with the basis named), Prediction (not yet tested), or Not run. Anything that fits neither mechanism is reported as unexplained.

### Finding 1: which mechanism

| Claim | Status | Evidence |
|---|---|---|
| exo-only: EXO alone signs in; its identity stack lands in Default from netCore with one msalruntime (EXO's) | Observed | exo-only.json Steps[connect-exo]: Outcome=ok; Notes.Connected=True; final NativeModules: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll) |
| Importing Graph without connecting leaves EXO working (graph-import-then-exo reaches a sign-in) | Observed | graph-import-then-exo.json Steps[connect-exo]: Outcome=ok; Notes.Connected=True |
| A Graph WAM sign-in first makes Connect-ExchangeOnline throw the RuntimeBroker NullReferenceException | Observed | graph-connect-then-exo.json Steps[connect-exo]: Outcome=exception; Exception.TypeFullName=System.NullReferenceException; stack frame RuntimeBroker..ctor present: True |
| Graph's msalruntime is mapped during Connect-MgGraph, not at import | Observed | graph-connect-then-exo.json Steps[import-graph].Snapshot.NativeModules: 0; Steps[connect-graph]: 1 (Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL) |
| EXO's msalruntime is mapped during Connect-ExchangeOnline, not at import | Observed | graph-connect-then-exo.json Steps[import-exo].Snapshot.NativeModules: 1 (Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL); Steps[connect-exo]: 2 (Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL; EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); exo-only.json Steps[import-exo]: 0; Steps[connect-exo]: 1 (EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll) |
| After the failure two msalruntime.dll files are mapped, one from each module | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot.NativeModules: 2 (Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL; EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll) |
| A bare-name request for msalruntime.dll in that process resolves to Graph's copy | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot: Win32 GetModuleHandleW/LoadLibraryW: GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL), same handle: True, freed: True |
| EXO's NativeInterop declares its runtime P/Invokes against the bare name "msalruntime" (no path) | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot.DllImportTargets[EXO]: 269 P/Invokes; library names: kernel32 (1), libc (4), msalruntime (67), msalruntime_arm (65), msalruntime_arm64 (67), msalruntime_x86 (65) |
| No DllImportResolver is registered for either NativeInterop copy, so nothing pins its P/Invokes to the handle it preloaded | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot.DllImportResolvers: field s_nativeDllResolveMap; table exists False; entries: none; NativeInterop HasResolver: Graph=False, EXO=False |
| EXO's NativeInterop mapped its own msalruntime by full path (a kernel32 LoadLibrary preload from runtimes\win-x64\native) | Inferred | Basis: offline metadata of NativeInterop 0.19.4 (P/Invoke kernel32!LoadLibrary; string literals "runtimes", "win-x64\native\msalruntime.dll", "PATH") plus the observation that the second mapping appears exactly at connect-exo. The preload call itself was not traced. |
| EXO's P/Invokes therefore executed against Graph's already-started runtime rather than its own mapped copy | Inferred | Basis: the observed bare-name resolution, the observed bare-name DllImport targets, the observed absence of a resolver, and the observed init-exception Context below (a copy that was never started cannot report itself as already started). Binding was not traced with a debugger. |
| EXO's RuntimeBroker copy: lazy Core created but null; s_initException = MsalRuntimeException with Status ApiContractViolation and Context "Authenticator Factory has already been started" | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot.BrokerRuntimeState[EXO]: LazyCoreValueCreated=True; CoreIsNull=True; InitException.Type=Microsoft.Identity.Client.NativeInterop.MsalRuntimeException; Status=ApiContractViolation; Context="Authenticator Factory has already been started" |
| Graph's RuntimeBroker copy in the same process has a live Core and no init exception | Observed | graph-connect-then-exo.json Steps[connect-exo].Snapshot.BrokerRuntimeState[Graph]: LazyCoreValueCreated=True; CoreIsNull=False; InitException=null |
| The NullReferenceException is the null-Core dereference in RuntimeBroker's constructor (s_lazyCore.Value under PiiLoggingEnabled); a DLL load failure would surface as MsalClientException wam_runtime_init_failed instead | Inferred | Basis: MSAL 4.83.1 source (src/client/Microsoft.Identity.Client.Broker/RuntimeBroker.cs: the lazy factory catches only MsalRuntimeException with ApiContractViolation and returns null; every other exception is rethrown as wam_runtime_init_failed) plus the observed null Core. The release build carries no line numbers, so the exact statement is not in the stack. |

Mechanism B (native, process-level). graph-import-then-exo reached a sign-in while graph-connect-then-exo threw the NRE, so Graph's native runtime being started first is the precondition. Both modules hold a private managed MSAL stack (Graph in msgraph-load-context, EXO in Default); the collision is in the one msalruntime.dll a bare-name P/Invoke can reach. The native runtime loaded fine and rejected EXO's second startup as a contract violation.

The "Error Acquiring Token" host text quoted in the issue thread did not appear in this transcript; the failure surfaced as a terminating error from Get-ConnectionContext wrapping the same NullReferenceException stack.

### Finding 2: can Graph's AssemblyResolve handler run before LoadFromResolveHandler?

| Claim | Status | Evidence |
|---|---|---|
| LoadFromResolveHandler is registered at baseline, before any module import | Observed | graph-connect-then-exo.json Steps[baseline].Snapshot.AssemblyResolveHandlers.Handlers: System.Reflection.Assembly.LoadFromResolveHandler |
| Graph's ModuleInitializer.ResolvingHandler is appended after it (3 registrations, one per import of the cmdlet assembly) | Observed | graph-connect-then-exo.json Steps[import-graph].Snapshot.AssemblyResolveHandlers.Handlers: System.Reflection.Assembly.LoadFromResolveHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler -> Microsoft.Graph.PowerShell.Authentication.ModuleInitializer.ResolvingHandler |
| The runtime invokes AssemblyResolve handlers in registration order and stops at the first non-null result | Inferred | Basis: .NET runtime source, System.Runtime.Loader.AssemblyLoadContext.InvokeResolveEvent (foreach over Delegate.EnumerateInvocationList, return first non-null). Documented behavior, not observed in this process. |
| EXO's identity assemblies resolved from netCore into Default in every scenario; none came from Graph's folder | Observed | final snapshots: exo-only: 4 EXO identity assemblies in Default; graph-import-then-exo: 4 EXO identity assemblies in Default; graph-connect-then-exo: 4 EXO identity assemblies in Default; graph-connect-then-exo-disablewam: 3 EXO identity assemblies in Default; exo-then-graph: 4 EXO identity assemblies in Default |
| Mechanism A cannot occur for EXO's own dependencies: LoadFromResolveHandler answers first for any file beside a LoadFrom-loaded requester in Default, and all of EXO's live in netCore beside the requesters | Inferred | Basis: the four rows above (by construction). |

### Finding 3: the other two directions on the released modules

| Claim | Status | Evidence |
|---|---|---|
| With -DisableWAM after a Graph sign-in, EXO signs in; its Broker assembly loads but its NativeInterop never does, and only Graph's msalruntime is mapped | Observed | graph-connect-then-exo-disablewam.json Steps[connect-exo-disablewam]: Outcome=ok; Notes.Connected=True; EXO Broker loaded: yes (Default); EXO NativeInterop loaded: no; NativeModules: 1 (Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL) |
| With the broker bypassed the RuntimeBroker constructor never runs, so nothing touches the native runtime a second time | Inferred | Basis: the row above (no NativeInterop, no second mapping) and MSAL's broker path being the only consumer of NativeInterop. |
| EXO first, then Connect-MgGraph fails with MissingMethodException on BaseAbstractApplicationBuilder.WithLogging(IIdentityLogger, Boolean) | Observed | exo-then-graph.json Steps[connect-graph]: Outcome=nonterminating-error; ErrorStreamEntries[0]=Azure.Identity.AuthenticationFailedException; Notes.SignedIn=False |
| In that process Microsoft.IdentityModel.Abstractions is loaded twice (EXO's in Default, Graph's in msgraph-load-context) while Microsoft.Identity.Client is EXO's copy in Default only | Observed | exo-then-graph.json Steps[connect-graph].Snapshot.Assemblies: Microsoft.IdentityModel.Abstractions 8.19.2.0 in Default (EXO); Microsoft.IdentityModel.Abstractions 8.18.0.0 in msgraph-load-context (Graph); Microsoft.Identity.Client 4.83.1.0 in Default (EXO) |
| The MissingMethodException is the split IIdentityLogger identity: Graph's Azure.Identity binds to EXO's MSAL in Default, whose WithLogging is typed to Default's Abstractions, while Azure.Identity passes the IIdentityLogger from Graph's context | Inferred | Basis: the placement row above plus the method signature in the error text. Type identity per context was not dumped. |

### Finding 4: is a completed Graph sign-in required, or just the picker?

| Claim | Status | Evidence |
|---|---|---|
| The Graph picker did not appear: WAM completed the sign-in silently in 508 ms, so the cancel condition could not be exercised on this machine | Observed | graph-cancel-then-exo.json Steps[connect-graph-cancel]: Outcome=ok; Notes.SignedIn=True; DurationMs=508 (an earlier picker interaction in graph-connect-then-exo-disablewam took 8546 ms) |
| A silent Graph WAM acquisition (no UI at all) is enough to map Graph's msalruntime and create its RuntimeBroker Core | Observed | graph-cancel-then-exo.json Steps[connect-graph-cancel].Snapshot.NativeModules: 1 (Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL); BrokerRuntimeState[Graph]: created=True, null=False |
| Whether a cancelled picker alone (no token issued) also breaks EXO | Not run | Not exercisable while WAM holds a cached account for the Graph PowerShell app; removing it is a Windows account setting the harness never changes. |
| Connect-ExchangeOnline after that Graph step: nre-runtimebroker | Observed | graph-cancel-then-exo.json Steps[connect-exo]: Outcome=exception; Exception.TypeFullName=System.NullReferenceException; NativeModules: 2 (Graph: Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL; EXO: ExchangeOnlineManagement\3.10.1\netCore\runtimes\win-x64\native\msalruntime.dll); bare-name: GetModuleHandleW -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL); LoadLibraryW -> Graph (Microsoft.Graph.Authentication\2.40.0\Dependencies\msalruntime.DLL), same handle: True, freed: True; EXO RuntimeBroker: ApiContractViolation "Authenticator Factory has already been started" |

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

### Finding 6: PR #3789 build

| Claim | Status | Evidence |
|---|---|---|
| Prediction made before the PR build ran: Graph-then-EXO still fails after the PR, because the PR pins Graph's P/Invokes to Graph's copy (LoadUnmanagedDll override) while EXO's stay bare-name in Default | Prediction | Not yet tested; see build-notes.md. |
| pr-graph-import-then-exo, pr-graph-connect-then-exo, pr-exo-then-graph | Not run | No build of the PR was available (no .NET SDK on this machine and no downloadable CI artifact; see build-notes.md). |

### Implication for PR #3789

Prediction (untested until Finding 6 runs): the PR isolates managed code and pins only Graph's own P/Invokes to Graph's copy. The msalruntime that Graph loads is still the first module of that name in the process, EXO's NativeInterop still P/Invokes by bare name, so EXO's second startup should still be rejected. EXO-then-Graph should be fixed by construction (Graph's Azure.Identity can no longer bind to EXO's MSAL). If both hold, the fix for Graph-then-EXO belongs in MSAL's NativeInterop (bind P/Invokes to the handle it preloaded, or tolerate a second startup); -DisableWAM remains the workaround.

