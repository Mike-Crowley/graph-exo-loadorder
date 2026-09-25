@{
    # Execution order. probe-only runs first because it validates the capture code
    # (the harness refuses to continue if the probe does not see LoadFromResolveHandler).
    # pr-* scenarios only run when -GraphModulePath points at a build of PR #3789;
    # az-connect-then-exo only runs when Az.Accounts is installed with EnableLoginByWam = true.
    Order     = @(
        'probe-only'
        'exo-only'
        'graph-import-then-exo'
        'graph-connect-then-exo'
        'graph-cancel-then-exo'
        'graph-connect-then-exo-disablewam'
        'graph-accesstoken-then-exo'
        'exo-then-graph'
        'az-connect-then-exo'
        'pr-graph-import-then-exo'
        'pr-graph-connect-then-exo'
        'pr-exo-then-graph'
    )

    # Steps are executed in order by Invoke-LoadOrderScenario.ps1; a snapshot follows every step.
    # 'baseline' is a no-op step so the process state before any import is captured too.
    Scenarios = @{
        'probe-only'                        = @{
            Steps       = @('baseline', 'import-probe-module')
            Instruction = 'Nothing to do: no modules, no prompts. Validates the snapshot code.'
            Expectation = 'After the probe module import, the AssemblyResolve list contains System.Reflection.Assembly.LoadFromResolveHandler.'
        }
        'exo-only'                          = @{
            Steps       = @('baseline', 'import-exo', 'connect-exo')
            Instruction = 'One EXO prompt (WAM account picker). Sign in, or cancel; the stack is loaded before the prompt either way.'
            Expectation = 'EXO identity assemblies land in Default from the netCore folder; one msalruntime, from EXO.'
        }
        'graph-import-then-exo'             = @{
            Steps       = @('baseline', 'import-graph', 'import-exo', 'connect-exo')
            Instruction = 'No Graph prompt. If an EXO prompt appears, sign in or cancel. If EXO throws before any prompt, that is the mechanism-A signal.'
            Expectation = 'A/B discriminator: an NRE here means a Graph connection is not required (A); a prompt here means it is (B).'
        }
        'graph-connect-then-exo'            = @{
            Steps       = @('baseline', 'import-graph', 'connect-graph', 'import-exo', 'connect-exo')
            Instruction = 'Sign in at the Graph WAM prompt. EXO is then expected to throw the RuntimeBroker NullReferenceException before any prompt.'
            Expectation = 'The reported failure.'
        }
        'graph-cancel-then-exo'             = @{
            Steps       = @('baseline', 'import-graph', 'connect-graph-cancel', 'import-exo', 'connect-exo')
            Instruction = 'CANCEL the Graph WAM picker (close it without choosing an account). If an EXO prompt follows, sign in or cancel.'
            Expectation = 'Shows whether Graph''s native runtime is started before the picker appears, and whether a cancelled Graph prompt is enough to break EXO.'
        }
        'graph-connect-then-exo-disablewam' = @{
            Steps       = @('baseline', 'import-graph', 'connect-graph', 'import-exo', 'connect-exo-disablewam')
            Instruction = 'Sign in at the Graph WAM prompt. EXO then opens a browser sign-in (no WAM); sign in or cancel.'
            Expectation = 'Reaches a sign-in: only the broker path is broken.'
        }
        'graph-accesstoken-then-exo'        = @{
            Steps        = @('baseline', 'import-graph', 'connect-graph-accesstoken', 'import-exo', 'connect-exo')
            Instruction  = 'First an Az browser sign-in in the harness (it fetches a Graph token without WAM), then an EXO WAM prompt in the window: sign in or cancel.'
            Expectation  = 'Prediction: EXO works, because Graph handed a token never starts msalruntime.'
            Precondition = 'AzToken'
        }
        'exo-then-graph'                    = @{
            Steps       = @('baseline', 'import-exo', 'connect-exo', 'import-graph', 'connect-graph')
            Instruction = 'Sign in at the EXO WAM prompt. Graph is then expected to fail with the WithLogging MissingMethodException before any prompt.'
            Expectation = 'Known failure, captured for completeness.'
        }
        'az-connect-then-exo'               = @{
            Steps        = @('baseline', 'connect-az', 'import-exo', 'connect-exo')
            Instruction  = 'Sign in at the Az WAM prompt. EXO follows; if it throws the same NullReferenceException the finding is about MSAL, not Graph.'
            Expectation  = 'A second, unrelated module reproducing the s_initException makes the finding about MSAL.'
            Precondition = 'AzWam'
        }
        'pr-graph-import-then-exo'          = @{
            Steps       = @('baseline', 'import-graph', 'import-exo', 'connect-exo')
            Instruction = 'PR build. No Graph prompt. Sign in or cancel at the EXO prompt.'
            Expectation = 'Control: should still reach a sign-in.'
            UsesPrBuild = $true
        }
        'pr-graph-connect-then-exo'         = @{
            Steps       = @('baseline', 'import-graph', 'connect-graph', 'import-exo', 'connect-exo')
            Instruction = 'PR build. Sign in at the Graph WAM prompt. Then EXO: the prediction is that it still throws the NullReferenceException.'
            Expectation = 'Tests the prediction that Graph-then-EXO survives the PR because EXO''s P/Invokes still bind by bare name.'
            UsesPrBuild = $true
        }
        'pr-exo-then-graph'                 = @{
            Steps       = @('baseline', 'import-exo', 'connect-exo', 'import-graph', 'connect-graph')
            Instruction = 'PR build. Sign in at the EXO WAM prompt. Then Graph: a prompt means WithLogging is fixed and the started-state is per mapped module.'
            Expectation = 'WithLogging failure should be gone; shows whether the already-started state is per mapped module or process-global.'
            UsesPrBuild = $true
        }
    }
}
