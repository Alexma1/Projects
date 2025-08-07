function New-UserDetails {
    <#
    .SYNOPSIS
        Generates user details for AD user creation.
    
    .DESCRIPTION
        This private function generates standardized user details including
        SamAccountName, UserPrincipalName, DisplayName, and EmailAddress
        based on the provided first and last names.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FirstName,
        
        [Parameter(Mandatory = $true)]
        [string]$LastName,
        
        [Parameter(Mandatory = $false)]
        [string]$JobTitle,
        
        [Parameter(Mandatory = $false)]
        [string]$Department
    )
    
    # Clean names (remove special characters, extra spaces)
    $cleanFirstName = ($FirstName -replace '[^a-zA-Z]', '').Trim()
    $cleanLastName = ($LastName -replace '[^a-zA-Z]', '').Trim()
    
    # Generate SamAccountName
    $samAccountName = New-SamAccountName -FirstName $cleanFirstName -LastName $cleanLastName
    
    # Generate other details
    $displayName = "$FirstName $LastName"
    $userPrincipalName = "$samAccountName@$($script:ModuleDefaults.Domain)"
    $emailAddress = "$samAccountName@$($script:ModuleDefaults.Domain -replace '\..*$', '.com')"
    
    return [PSCustomObject]@{
        SamAccountName = $samAccountName
        UserPrincipalName = $userPrincipalName
        DisplayName = $displayName
        EmailAddress = $emailAddress
        FirstName = $cleanFirstName
        LastName = $cleanLastName
        JobTitle = $JobTitle
        Department = $Department
    }
}

function New-SamAccountName {
    <#
    .SYNOPSIS
        Creates a unique SamAccountName.
    
    .DESCRIPTION
        This private function creates a SamAccountName using various patterns
        and ensures it's unique in Active Directory.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FirstName,
        
        [Parameter(Mandatory = $true)]
        [string]$LastName
    )
    
    # Get potential usernames in order of preference
    $potentialUsernames = Get-PotentialUsernames -FirstName $FirstName -LastName $LastName
    
    # Find the first available username
    foreach ($username in $potentialUsernames) {
        $userExists = Test-ADUserExists -SamAccountName $username
        if (-not $userExists.Exists) {
            return $username.ToLower()
        }
    }
    
    # If all standard patterns are taken, add numbers
    $baseUsername = "$($FirstName.Substring(0, [Math]::Min(1, $FirstName.Length)))$LastName".ToLower()
    $counter = 1
    
    do {
        $numberedUsername = "$baseUsername$counter"
        $userExists = Test-ADUserExists -SamAccountName $numberedUsername
        $counter++
    } while ($userExists.Exists -and $counter -lt 1000)
    
    if ($counter -ge 1000) {
        throw "Unable to generate unique username for $FirstName $LastName"
    }
    
    return $numberedUsername
}

function Get-PotentialUsernames {
    <#
    .SYNOPSIS
        Gets potential username patterns.
    
    .DESCRIPTION
        This private function returns an array of potential usernames
        in order of preference.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FirstName,
        
        [Parameter(Mandatory = $true)]
        [string]$LastName
    )
    
    $patterns = @()
    
    # Ensure we have valid lengths
    $firstInitial = if ($FirstName.Length -gt 0) { $FirstName.Substring(0, 1) } else { "x" }
    $lastInitial = if ($LastName.Length -gt 0) { $LastName.Substring(0, 1) } else { "x" }
    
    # Pattern 1: firstname.lastname (most preferred)
    $patterns += "$FirstName.$LastName"
    
    # Pattern 2: firstinitial.lastname
    $patterns += "$firstInitial.$LastName"
    
    # Pattern 3: firstname.lastinitial
    $patterns += "$FirstName.$lastInitial"
    
    # Pattern 4: firstinitiallastname
    $patterns += "$firstInitial$LastName"
    
    # Pattern 5: firstnamelastinitial
    $patterns += "$FirstName$lastInitial"
    
    # Pattern 6: firstinitiallastinitial
    $patterns += "$firstInitial$lastInitial"
    
    # Convert to lowercase and remove any that are too short or too long
    $patterns = $patterns | ForEach-Object { 
        $_.ToLower() 
    } | Where-Object { 
        $_.Length -ge 3 -and $_.Length -le 20 
    } | Select-Object -Unique
    
    return $patterns
}
