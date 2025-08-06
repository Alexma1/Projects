# ADUserCreation Module Test Script
# This script tests the functionality of the ADUserCreation module

param(
    [bool]$WhatIf = $true,  # Default to WhatIf mode for safety
    [switch]$SkipADTests = $false  # Skip tests that require AD connectivity
)

Write-Host "=== ADUserCreation Module Test Script ===" -ForegroundColor Cyan
Write-Host "WhatIf Mode: $WhatIf" -ForegroundColor Yellow

# Test 1: Module Import
Write-Host "`n1. Testing Module Import..." -ForegroundColor Green
try {
    $modulePath = Split-Path -Parent $PSScriptRoot
    Import-Module $modulePath -Force
    Write-Host "✓ Module imported successfully" -ForegroundColor Green
    
    $commands = Get-Command -Module ADUserCreation
    Write-Host "✓ Available commands: $($commands.Name -join ', ')" -ForegroundColor Green
}
catch {
    Write-Host "✗ Failed to import module: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Configuration Functions
Write-Host "`n2. Testing Configuration Functions..." -ForegroundColor Green
try {
    # Test showing current defaults
    Write-Host "Current defaults:" -ForegroundColor Yellow
    Set-ADUserDefaults -ShowCurrent
    
    # Test setting new defaults (in memory only)
    Set-ADUserDefaults -PasswordLength 14 -AccountExpirationDays 180
    Write-Host "✓ Configuration functions work" -ForegroundColor Green
}
catch {
    Write-Host "✗ Configuration test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Username Generation (Private Functions)
Write-Host "`n3. Testing Username Generation..." -ForegroundColor Green
try {
    # Test the New-UserDetails function directly
    $userDetails = New-UserDetails -FirstName "John" -LastName "Doe" -JobTitle "Developer" -Department "IT"
    
    Write-Host "Generated user details:" -ForegroundColor Yellow
    Write-Host "  SamAccountName: $($userDetails.SamAccountName)" -ForegroundColor White
    Write-Host "  UserPrincipalName: $($userDetails.UserPrincipalName)" -ForegroundColor White
    Write-Host "  DisplayName: $($userDetails.DisplayName)" -ForegroundColor White
    Write-Host "  EmailAddress: $($userDetails.EmailAddress)" -ForegroundColor White
    
    Write-Host "✓ Username generation works" -ForegroundColor Green
}
catch {
    Write-Host "✗ Username generation test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Password Generation
Write-Host "`n4. Testing Password Generation..." -ForegroundColor Green
try {
    $password = New-SecurePassword -Length 12
    
    # Convert to plain text temporarily for validation
    $passwordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
    
    Write-Host "Generated password length: $($passwordText.Length)" -ForegroundColor Yellow
    Write-Host "Password complexity test:" -ForegroundColor Yellow
    
    $complexity = Test-PasswordComplexity -Password $password
    Write-Host "  Is Complex: $($complexity.IsComplex)" -ForegroundColor White
    Write-Host "  Min Length: $($complexity.Requirements.MinLength)" -ForegroundColor White
    Write-Host "  Has Uppercase: $($complexity.Requirements.HasUppercase)" -ForegroundColor White
    Write-Host "  Has Lowercase: $($complexity.Requirements.HasLowercase)" -ForegroundColor White
    Write-Host "  Has Number: $($complexity.Requirements.HasNumber)" -ForegroundColor White
    Write-Host "  Has Symbol: $($complexity.Requirements.HasSymbol)" -ForegroundColor White
    
    # Clear password from memory
    $passwordText = $null
    
    Write-Host "✓ Password generation works" -ForegroundColor Green
}
catch {
    Write-Host "✗ Password generation test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: User Creation (WhatIf mode)
Write-Host "`n5. Testing User Creation (WhatIf mode)..." -ForegroundColor Green
try {
    $result = New-ADUserSimple -FirstName "Test" -LastName "User" -JobTitle "Tester" -Department "QA" -WhatIf
    
    if ($result) {
        Write-Host "✓ User creation test completed (WhatIf mode)" -ForegroundColor Green
    }
    else {
        Write-Host "⚠ User creation returned null (expected in WhatIf mode)" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "✗ User creation test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Batch Processing (Array mode)
Write-Host "`n6. Testing Batch User Creation..." -ForegroundColor Green
try {
    $testUsers = @(
        @{FirstName="Alice"; LastName="Test"; JobTitle="Analyst"; Department="Finance"},
        @{FirstName="Bob"; LastName="Test"; JobTitle="Manager"; Department="Sales"},
        @{FirstName="Charlie"; LastName="Test"; JobTitle="Developer"; Department="IT"}
    )
    
    $results = New-ADUserBatch -Users $testUsers -WhatIf:$WhatIf
    
    Write-Host "Batch processing results:" -ForegroundColor Yellow
    $results | Format-Table FirstName, LastName, SamAccountName, Status -AutoSize
    
    Write-Host "✓ Batch processing test completed" -ForegroundColor Green
}
catch {
    Write-Host "✗ Batch processing test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 7: CSV Processing (if sample file exists)
Write-Host "`n7. Testing CSV Processing..." -ForegroundColor Green
try {
    $csvPath = Join-Path (Split-Path -Parent $PSScriptRoot) "Examples\sample_users.csv"
    
    if (Test-Path $csvPath) {
        Write-Host "Testing with sample CSV file..." -ForegroundColor Yellow
        $results = New-ADUserBatch -CsvPath $csvPath -WhatIf:$WhatIf
        
        Write-Host "CSV processing results:" -ForegroundColor Yellow
        $results | Format-Table FirstName, LastName, SamAccountName, Status -AutoSize
        
        Write-Host "✓ CSV processing test completed" -ForegroundColor Green
    }
    else {
        Write-Host "⚠ Sample CSV file not found at $csvPath" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "✗ CSV processing test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 8: Active Directory Connectivity Tests (Optional)
if (-not $SkipADTests) {
    Write-Host "`n8. Testing Active Directory Connectivity..." -ForegroundColor Green
    try {
        # Test if ActiveDirectory module is available
        if (Get-Module -Name ActiveDirectory -ListAvailable) {
            Import-Module ActiveDirectory -ErrorAction Stop
            
            # Test basic AD connectivity
            $domain = Get-ADDomain -ErrorAction Stop
            Write-Host "✓ Connected to domain: $($domain.DNSRoot)" -ForegroundColor Green
            
            # Test user existence check
            $existsResult = Test-ADUserExists -FirstName "NonExistent" -LastName "User"
            Write-Host "✓ User existence check works: $($existsResult.Exists)" -ForegroundColor Green
            
            # Test OU enumeration
            try {
                $ous = Get-ADOrganizationalUnit -Filter * | Select-Object -First 5
                Write-Host "✓ Can enumerate OUs: $($ous.Count) found" -ForegroundColor Green
            }
            catch {
                Write-Host "⚠ Limited OU access: $($_.Exception.Message)" -ForegroundColor Yellow
            }
            
            # Test group enumeration
            try {
                $groups = Get-ADGroup -Filter * | Select-Object -First 5
                Write-Host "✓ Can enumerate groups: $($groups.Count) found" -ForegroundColor Green
            }
            catch {
                Write-Host "⚠ Limited group access: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "⚠ ActiveDirectory module not available" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "⚠ AD connectivity test skipped: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}
else {
    Write-Host "`n8. Skipping Active Directory Tests (-SkipADTests specified)" -ForegroundColor Yellow
}

# Test Summary
Write-Host "`n=== Test Summary ===" -ForegroundColor Cyan
Write-Host "All basic module tests completed." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Review the test output above for any issues" -ForegroundColor White
Write-Host "2. Test in a safe AD environment with -WhatIf:`$false" -ForegroundColor White
Write-Host "3. Customize the module defaults for your organization" -ForegroundColor White
Write-Host "4. Create your own CSV file with real user data" -ForegroundColor White
Write-Host ""
Write-Host "Example usage:" -ForegroundColor Yellow
Write-Host "  New-ADUserSimple -FirstName 'John' -LastName 'Doe' -Interactive" -ForegroundColor White
Write-Host "  New-ADUserBatch -CsvPath 'C:\temp\newusers.csv'" -ForegroundColor White
