# ADUserCreation PowerShell Module
# Main module file for creating Active Directory users with minimal input

#region Module Variables and Configuration
$script:ModuleDefaults = @{
    Domain = $env:USERDNSDOMAIN
    DefaultOU = "CN=Users,DC=$((Get-ADDomain).DistinguishedName -replace 'DC=','' -replace ',','.')"
    DefaultGroups = @('Domain Users')
    PasswordLength = 12
    AccountExpirationDays = 365
    ChangePasswordAtLogon = $true
    EnableAccount = $true
}

# Load classes
$ClassFiles = Get-ChildItem -Path "$PSScriptRoot\Classes\*.ps1" -ErrorAction SilentlyContinue
foreach ($Class in $ClassFiles) {
    try {
        . $Class.FullName
        Write-Verbose "Loaded class: $($Class.Name)"
    }
    catch {
        Write-Error "Failed to load class $($Class.Name): $($_.Exception.Message)"
    }
}

# Load private functions
$PrivateFunctions = Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue
foreach ($Function in $PrivateFunctions) {
    try {
        . $Function.FullName
        Write-Verbose "Loaded private function: $($Function.Name)"
    }
    catch {
        Write-Error "Failed to load private function $($Function.Name): $($_.Exception.Message)"
    }
}

# Load public functions
$PublicFunctions = Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -ErrorAction SilentlyContinue
foreach ($Function in $PublicFunctions) {
    try {
        . $Function.FullName
        Write-Verbose "Loaded public function: $($Function.Name)"
    }
    catch {
        Write-Error "Failed to load public function $($Function.Name): $($_.Exception.Message)"
    }
}
#endregion

#region Aliases
New-Alias -Name "Create-ADUser" -Value "New-ADUserSimple" -Force
New-Alias -Name "New-User" -Value "New-ADUserSimple" -Force
#endregion

#region Module Cleanup
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    # Clean up when module is removed
    Remove-Variable -Name ModuleDefaults -Scope Script -Force -ErrorAction SilentlyContinue
}
#endregion

# Export module members
Export-ModuleMember -Function @(
    'New-ADUserSimple',
    'Get-ADUserTemplate', 
    'Set-ADUserDefaults',
    'Test-ADUserExists',
    'New-ADUserBatch'
) -Alias @('Create-ADUser', 'New-User')
