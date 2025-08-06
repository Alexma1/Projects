function Set-ADUserDefaults {
    <#
    .SYNOPSIS
        Sets default values for AD user creation.
    
    .DESCRIPTION
        This function allows you to configure default settings that will be used
        when creating new AD users with this module.
    
    .PARAMETER DefaultOU
        The default Organizational Unit for new users.
    
    .PARAMETER DefaultGroups
        Array of default groups to add new users to.
    
    .PARAMETER PasswordLength
        Default password length for generated passwords.
    
    .PARAMETER AccountExpirationDays
        Number of days until account expires (0 for no expiration).
    
    .PARAMETER ChangePasswordAtLogon
        Whether users must change password at first logon.
    
    .PARAMETER EnableAccount
        Whether accounts are enabled by default.
    
    .PARAMETER ShowCurrent
        Switch to display current default settings.
    
    .EXAMPLE
        Set-ADUserDefaults -ShowCurrent
        
        Displays current default settings.
    
    .EXAMPLE
        Set-ADUserDefaults -DefaultOU "OU=NewUsers,DC=company,DC=com" -PasswordLength 16
        
        Sets a new default OU and password length.
    
    .EXAMPLE
        Set-ADUserDefaults -DefaultGroups @("Domain Users", "All Staff", "Email Users")
        
        Sets default groups for new users.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$DefaultOU,
        
        [Parameter(Mandatory = $false)]
        [string[]]$DefaultGroups,
        
        [Parameter(Mandatory = $false)]
        [ValidateRange(8, 128)]
        [int]$PasswordLength,
        
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 3650)]
        [int]$AccountExpirationDays,
        
        [Parameter(Mandatory = $false)]
        [bool]$ChangePasswordAtLogon,
        
        [Parameter(Mandatory = $false)]
        [bool]$EnableAccount,
        
        [Parameter(Mandatory = $false)]
        [switch]$ShowCurrent
    )
    
    begin {
        Write-Verbose "Starting Set-ADUserDefaults function"
    }
    
    process {
        if ($ShowCurrent) {
            Write-Host "`n=== Current AD User Creation Defaults ===" -ForegroundColor Cyan
            Write-Host "Default OU: $($script:ModuleDefaults.DefaultOU)" -ForegroundColor Green
            Write-Host "Default Groups: $($script:ModuleDefaults.DefaultGroups -join ', ')" -ForegroundColor Green
            Write-Host "Password Length: $($script:ModuleDefaults.PasswordLength)" -ForegroundColor Green
            Write-Host "Account Expiration Days: $($script:ModuleDefaults.AccountExpirationDays)" -ForegroundColor Green
            Write-Host "Change Password at Logon: $($script:ModuleDefaults.ChangePasswordAtLogon)" -ForegroundColor Green
            Write-Host "Enable Account: $($script:ModuleDefaults.EnableAccount)" -ForegroundColor Green
            Write-Host "Domain: $($script:ModuleDefaults.Domain)" -ForegroundColor Green
            return
        }
        
        $updated = @()
        
        if ($PSBoundParameters.ContainsKey('DefaultOU')) {
            # Validate OU exists
            try {
                Get-ADOrganizationalUnit -Identity $DefaultOU -ErrorAction Stop | Out-Null
                $script:ModuleDefaults.DefaultOU = $DefaultOU
                $updated += "Default OU"
            }
            catch {
                Write-Error "Invalid OU: $DefaultOU. Error: $($_.Exception.Message)"
                return
            }
        }
        
        if ($PSBoundParameters.ContainsKey('DefaultGroups')) {
            # Validate groups exist
            $validGroups = @()
            foreach ($group in $DefaultGroups) {
                try {
                    Get-ADGroup -Identity $group -ErrorAction Stop | Out-Null
                    $validGroups += $group
                }
                catch {
                    Write-Warning "Group '$group' not found and will be skipped"
                }
            }
            
            if ($validGroups.Count -gt 0) {
                $script:ModuleDefaults.DefaultGroups = $validGroups
                $updated += "Default Groups"
            }
        }
        
        if ($PSBoundParameters.ContainsKey('PasswordLength')) {
            $script:ModuleDefaults.PasswordLength = $PasswordLength
            $updated += "Password Length"
        }
        
        if ($PSBoundParameters.ContainsKey('AccountExpirationDays')) {
            $script:ModuleDefaults.AccountExpirationDays = $AccountExpirationDays
            $updated += "Account Expiration Days"
        }
        
        if ($PSBoundParameters.ContainsKey('ChangePasswordAtLogon')) {
            $script:ModuleDefaults.ChangePasswordAtLogon = $ChangePasswordAtLogon
            $updated += "Change Password at Logon"
        }
        
        if ($PSBoundParameters.ContainsKey('EnableAccount')) {
            $script:ModuleDefaults.EnableAccount = $EnableAccount
            $updated += "Enable Account"
        }
        
        if ($updated.Count -gt 0) {
            Write-Host "`nUpdated settings: $($updated -join ', ')" -ForegroundColor Green
            Write-Host "Use 'Set-ADUserDefaults -ShowCurrent' to view all current settings" -ForegroundColor Yellow
        }
        else {
            Write-Host "No settings were updated" -ForegroundColor Yellow
        }
    }
    
    end {
        Write-Verbose "Completed Set-ADUserDefaults function"
    }
}
