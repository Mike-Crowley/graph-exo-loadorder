Harness follow-up: one fresh pwsh per scenario, a snapshot after every step. PowerShell 7.6.6, Microsoft.Graph.Authentication 2.40.0, ExchangeOnlineManagement 3.10.1. Scenarios: exo-only, graph-import-then-exo, graph-connect-then-exo, graph-cancel-then-exo, graph-connect-then-exo-disablewam, exo-then-graph.

Observed for Graph-then-EXO:

- Importing Graph alone leaves EXO working; any Graph WAM sign-in first breaks it, even a silent one with no picker.
- After the failure two msalruntime.dll files are mapped (Graph's from Dependencies\, EXO's from netCore\runtimes\win-x64\native\); GetModuleHandleW and LoadLibraryW for that name both return Graph's.
- Both NativeInterop copies declare all 269 P/Invokes by bare name ("msalruntime" on x64); neither registers a DllImportResolver.
- EXO's RuntimeBroker after the failure (read by reflection): lazy Core null; s_initException is MsalRuntimeException, ApiContractViolation, "Authenticator Factory has already been started". Graph's copy has a live Core; the NullReferenceException is the constructor dereferencing the null one.
- EXO's managed stack sits in Default from netCore; Graph's AssemblyResolve handler answered none of its requests. This direction is native.

EXO-then-Graph still fails here (WithLogging MissingMethodException), so neither order works on these versions; the only same-session combination that connected was Graph, then Connect-ExchangeOnline -DisableWAM.

Predictions (no build yet): #3789 fixes EXO-then-Graph by construction; Graph-then-EXO survives it, since EXO's bare-name P/Invokes still find Graph's started copy. Untested fixes: NativeInterop pins P/Invokes to its preloaded handle or tolerates a second startup; Graph uses a Graph-only file name; EXO gets its own load context or a DllImportResolver. Related: #3576.

Ask: can the NativeInterop part be routed to the MSAL owners from here, or should I file it in MSAL.NET?

Harness and report: <REPO_URL>
