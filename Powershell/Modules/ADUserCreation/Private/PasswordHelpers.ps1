function New-SecurePassword {
    <#
    .SYNOPSIS
        Generates a secure password.
    
    .DESCRIPTION
        This private function generates a secure password with specified length
        that meets Active Directory complexity requirements.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(8, 128)]
        [int]$Length = 12
    )
    
    # Character sets for password generation
    $uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $lowercase = 'abcdefghijklmnopqrstuvwxyz'
    $numbers = '0123456789'
    $symbols = '!@#$%^&*()_+-=[]{}|;:,.<>?'
    
    # Ensure at least one character from each set
    $password = @()
    $password += Get-Random -InputObject $uppercase.ToCharArray()
    $password += Get-Random -InputObject $lowercase.ToCharArray()
    $password += Get-Random -InputObject $numbers.ToCharArray()
    $password += Get-Random -InputObject $symbols.ToCharArray()
    
    # Fill remaining length with random characters from all sets
    $allChars = $uppercase + $lowercase + $numbers + $symbols
    for ($i = $password.Count; $i -lt $Length; $i++) {
        $password += Get-Random -InputObject $allChars.ToCharArray()
    }
    
    # Shuffle the password array
    $shuffledPassword = $password | Get-Random -Count $password.Count
    
    # Convert to SecureString
    $passwordString = -join $shuffledPassword
    $securePassword = ConvertTo-SecureString -String $passwordString -AsPlainText -Force
    
    return $securePassword
}

function Test-PasswordComplexity {
    <#
    .SYNOPSIS
        Tests if a password meets complexity requirements.
    
    .DESCRIPTION
        This private function tests if a password meets Active Directory
        complexity requirements.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [SecureString]$Password
    )
    
    # Convert SecureString to plain text for validation (temporarily)
    $passwordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
    
    $requirements = @{
        MinLength = $passwordText.Length -ge 8
        HasUppercase = $passwordText -cmatch '[A-Z]'
        HasLowercase = $passwordText -cmatch '[a-z]'
        HasNumber = $passwordText -match '\d'
        HasSymbol = $passwordText -match '[^a-zA-Z0-9]'
    }
    
    # Clear the plain text password from memory
    $passwordText = $null
    
    $passedCount = ($requirements.Values | Where-Object { $_ }).Count
    $isComplex = $passedCount -ge 3 -and $requirements.MinLength
    
    return [PSCustomObject]@{
        IsComplex = $isComplex
        Requirements = $requirements
        PassedCount = $passedCount
    }
}
