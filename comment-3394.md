Follow-up with a harness. Rig: PowerShell 7.6.6, Microsoft.Graph.Authentication 2.40.0, ExchangeOnlineManagement 3.10.1, one fresh pwsh per scenario, a load-state snapshot after every step. Scenarios: exo-only, graph-import-then-exo, graph-connect-then-exo, graph-cancel-then-exo, graph-connect-then-exo-disablewam, exo-then-graph.

Observed for Graph-then-EXO:

- Importing Graph without connecting leaves EXO working. A Graph WAM sign-in first breaks it, even a silent one that shows no picker.
- After the failure two msalruntime.dll files are mapped (Graph's from Dependencies\, EXO's from netCore\runtimes\win-x64\native\), and GetModuleHandleW and LoadLibraryW for "msalruntime.dll" both return Graph's.
- Both NativeInterop copies declare all 269 P/Invokes against bare names ("msalruntime" on x64); neither has a DllImportResolver registered.
- EXO's RuntimeBroker, read by reflection after the failure, has a null lazy Core and s_initException = MsalRuntimeException, Status ApiContractViolation, Context "Authenticator Factory has already been started". Graph's copy in the same process has a live Core. The NullReferenceException is the constructor dereferencing that null Core.
- EXO's managed stack sits entirely in Default from netCore; Graph's AssemblyResolve handler answered none of its requests. Managed isolation is not the fault here.

Meaning: EXO's wrapper reaches the native runtime Graph already started, because bare-name P/Invokes bind to the first module of that name in the process. #3789 fixes EXO-then-Graph by construction. For Graph-then-EXO my prediction (untested, no build yet) is that it survives, since EXO's P/Invokes stay bare-name; that fix belongs in NativeInterop (pin P/Invokes to the preloaded handle, or tolerate a second startup). Workaround today: connect EXO first, or use -DisableWAM.

Harness, JSON and transcripts: <REPO_URL>
