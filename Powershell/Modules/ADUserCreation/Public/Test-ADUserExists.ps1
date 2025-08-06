function Test-ADUserExists {
    <#
    .SYNOPSIS
        Tests if an AD user already exists.
    
    .DESCRIPTION
        This function checks if a user account already exists in Active Directory
        by SamAccountName, UserPrincipalName, or email address.
    
    .PARAMETER SamAccountName
        The SamAccountName to check.
    
    .PARAMETER UserPrincipalName
        The UserPrincipalName to check.
    
    .PARAMETER EmailAddress
        The email address to check.
    
    .PARAMETER FirstName
        First name for automatic username generation and checking.
    
    .PARAMETER LastName
        Last name for automatic username generation and checking.
    
    .EXAMPLE
        Test-ADUserExists -SamAccountName "john.doe"
        
        Tests if user john.doe exists.
    
    .EXAMPLE
        Test-ADUserExists -FirstName "John" -LastName "Doe"
        
        Tests if user exists using generated username from first and last name.
    
    .EXAMPLE
        Test-ADUserExists -EmailAddress "john.doe@company.com"
        
        Tests if a user exists with the specified email address.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "SamAccountName")]
        [string]$SamAccountName,
        
        [Parameter(Mandatory = $false, ParameterSetName = "UPN")]
        [string]$UserPrincipalName,
        
        [Parameter(Mandatory = $false, ParameterSetName = "Email")]
        [string]$EmailAddress,
        
        [Parameter(Mandatory = $true, ParameterSetName = "Name")]
        [string]$FirstName,
        
        [Parameter(Mandatory = $true, ParameterSetName = "Name")]
        [string]$LastName
    )
    
    begin {
        Write-Verbose "Starting Test-ADUserExists function"
        
        # Import ActiveDirectory module
        try {
            Import-Module ActiveDirectory -ErrorAction Stop
        }
        catch {
            throw "Failed to import ActiveDirectory module: $($_.Exception.Message)"
        }
    }
    
    process {
        try {
            $exists = $false
            $foundUser = $null
            
            switch ($PSCmdlet.ParameterSetName) {
                "SamAccountName" {
                    try {
                        $foundUser = Get-ADUser -Identity $SamAccountName -ErrorAction Stop
                        $exists = $true
                    }
                    catch {
                        $exists = $false
                    }
                }
                
                "UPN" {
                    try {
                        $foundUser = Get-ADUser -Filter "UserPrincipalName -eq '$UserPrincipalName'" -ErrorAction Stop
                        $exists = $null -ne $foundUser
                    }
                    catch {
                        $exists = $false
                    }
                }
                
                "Email" {
                    try {
                        $foundUser = Get-ADUser -Filter "mail -eq '$EmailAddress'" -ErrorAction Stop
                        $exists = $null -ne $foundUser
                    }
                    catch {
                        $exists = $false
                    }
                }
                
                "Name" {
                    # Generate potential usernames and check each
                    $potentialUsernames = Get-PotentialUsernames -FirstName $FirstName -LastName $LastName
                    
                    foreach ($username in $potentialUsernames) {
                        try {
                            $foundUser = Get-ADUser -Identity $username -ErrorAction Stop
                            if ($foundUser) {
                                $exists = $true
                                $SamAccountName = $username
                                break
                            }
                        }
                        catch {
                            # User doesn't exist, continue checking
                        }
                    }
                }
            }
            
            $result = [PSCustomObject]@{
                Exists = $exists
                SamAccountName = if ($foundUser) { $foundUser.SamAccountName } else { $SamAccountName }
                DistinguishedName = if ($foundUser) { $foundUser.DistinguishedName } else { $null }
                Enabled = if ($foundUser) { $foundUser.Enabled } else { $null }
                UserPrincipalName = if ($foundUser) { $foundUser.UserPrincipalName } else { $null }
            }
            
            return $result
        }
        catch {
            Write-Error "Error checking if user exists: $($_.Exception.Message)"
            return $false
        }
    }
    
    end {
        Write-Verbose "Completed Test-ADUserExists function"
    }
}
