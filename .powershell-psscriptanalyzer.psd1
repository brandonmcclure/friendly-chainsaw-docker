#Documentation: https://github.com/PowerShell/PSScriptAnalyzer/blob/master/docs/markdown/Invoke-ScriptAnalyzer.md#-settings
@{
    #CustomRulePath='path\to\CustomRuleModule.psm1'
    #RecurseCustomRulePath='path\of\customrules'
    #Severity = @(
    #    'Error'
    #    'Warning'
    #)
    #IncludeDefaultRules=${true}
    ExcludeRules = @(
        'PSUseDeclaredVarsMoreThanAssignment',
		'PSAvoidTrailingWhitespace',
		'PSAvoidDefaultValueSwitchParameter',
		'PSUseShouldProcessForStateChangingFunctions',
		'PSUseDeclaredVarsMoreThanAssignments'
    )
    #IncludeRules = @(
    #    'PSAvoidUsingWriteHost',
    #    'MyCustomRuleName'
    #)
}