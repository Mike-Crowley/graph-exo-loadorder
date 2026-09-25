I built a small harness for this: one fresh pwsh per scenario, a load-state snapshot after every step. PowerShell 7.6.6, Microsoft.Graph.Authentication 2.40.0, ExchangeOnlineManagement 3.10.1, seven scenarios.

Observed, Graph-then-EXO:

- Importing Graph alone is fine. Any Graph WAM sign-in first breaks EXO, even a silent one with no picker.
- After the failure two msalruntime.dll files are mapped (Graph's from Dependencies\, EXO's from netCore\runtimes\win-x64\native\); a bare-name lookup returns Graph's.
- Both NativeInterop copies declare all 269 P/Invokes by bare name ("msalruntime" on x64); neither registers a DllImportResolver.
- EXO's RuntimeBroker after the failure (read by reflection): lazy Core null, s_initException MsalRuntimeException, ApiContractViolation, "Authenticator Factory has already been started"; Graph's copy has a live Core. The NRE is that null being dereferenced.
- EXO's managed stack sits in Default from netCore; Graph's AssemblyResolve handler answered none of its requests. This direction is native.

EXO-then-Graph still fails (WithLogging MissingMethodException), so neither order works. Two same-session combinations connected: Graph, then Connect-ExchangeOnline -DisableWAM; or Graph via -AccessToken (token from Az.Accounts), then EXO as normal, because Graph never starts msalruntime.

Predictions, no build yet: #3789 fixes EXO-then-Graph by construction; Graph-then-EXO survives it, since EXO's bare-name P/Invokes still find Graph's started copy. Untested fixes: NativeInterop pins P/Invokes to its preloaded handle or tolerates a second startup; Graph uses a Graph-only file name; EXO gets its own load context or DllImportResolver. Related: #3576.

Ask: can the NativeInterop part be routed to the MSAL owners, or should I file it in MSAL.NET?

Harness and report: https://github.com/Mike-Crowley/graph-exo-loadorder
