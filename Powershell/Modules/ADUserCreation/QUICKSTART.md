# ADUserCreation Module - Quick Start Guide

## Overview

The ADUserCreation PowerShell module simplifies Active Directory user creation by requiring only minimal input (first name and last name) and automating all other aspects like username generation, password creation, and group assignment.

## Key Features

- ✅ **Minimal Input**: Only first and last name required
- ✅ **Smart Username Generation**: Automatically creates unique usernames
- ✅ **Secure Password Generation**: Creates complex passwords automatically
- ✅ **Interactive Mode**: Guided user creation with prompts
- ✅ **Batch Processing**: Create multiple users from CSV files
- ✅ **Template System**: Copy settings from existing users/departments
- ✅ **Comprehensive Validation**: Checks all inputs before creation
- ✅ **Error Handling**: Robust error handling with detailed feedback

## Installation

1. **Copy the module to your PowerShell modules directory**
2. **Run the installation script** (optional but recommended):
   ```powershell
   .\Install-ADUserCreation.ps1 -Test
   ```
3. **Import the module**:
   ```powershell
   Import-Module ADUserCreation
   ```

## Basic Usage

### Single User Creation (Interactive)
```powershell
New-ADUserSimple -FirstName "John" -LastName "Doe" -Interactive
```

### Single User with Details
```powershell
New-ADUserSimple -FirstName "Jane" -LastName "Smith" -JobTitle "Developer" -Department "IT"
```

### Batch Creation from CSV
```powershell
New-ADUserBatch -CsvPath "C:\temp\newusers.csv"
```

## Module Functions

| Function | Purpose |
|----------|---------|
| `New-ADUserSimple` | Create a single AD user with minimal input |
| `New-ADUserBatch` | Create multiple users from CSV or array |
| `Get-ADUserTemplate` | Get templates based on existing users/departments |
| `Set-ADUserDefaults` | Configure module defaults |
| `Test-ADUserExists` | Check if a user already exists |

## CSV File Format

Create a CSV file with these columns (only FirstName and LastName are required):

```csv
FirstName,LastName,JobTitle,Department,Manager,OU,Groups
John,Doe,Developer,IT,alice.manager,,Developers;RemoteUsers
Jane,Smith,Manager,HR,bob.director,"OU=HR,DC=company,DC=com",HR Managers
```

## Configuration

### View Current Settings
```powershell
Set-ADUserDefaults -ShowCurrent
```

### Customize for Your Organization
```powershell
# Set default OU and groups
Set-ADUserDefaults -DefaultOU "OU=NewUsers,DC=company,DC=com" -DefaultGroups @("Domain Users", "All Staff")

# Set password policy
Set-ADUserDefaults -PasswordLength 16 -AccountExpirationDays 365
```

## Safety Features

- **WhatIf Support**: Test operations without making changes
- **Input Validation**: Comprehensive checks before creation
- **Unique Username Generation**: Prevents conflicts
- **Secure Password Handling**: Uses SecureString throughout
- **Error Continuation**: Batch operations can continue on individual failures

## Examples

### Template-Based Creation
```powershell
# Get template from existing user
$template = Get-ADUserTemplate -TemplateUser "john.doe" -IncludeGroups

# Create new user using template
New-ADUserSimple -FirstName "New" -LastName "Employee" -Template $template
```

### Batch with Error Handling
```powershell
$results = New-ADUserBatch -CsvPath "newusers.csv" -ContinueOnError
$results | Where-Object Status -eq "Error" | Format-Table FirstName, LastName, Error
```

### Test Mode
```powershell
# Test what would happen without creating users
New-ADUserSimple -FirstName "Test" -LastName "User" -WhatIf
New-ADUserBatch -CsvPath "newusers.csv" -WhatIf
```

## Testing

Run the included test script to validate functionality:
```powershell
.\Tests\Test-ADUserCreation.ps1 -WhatIf:$true
```

## Requirements

- Windows PowerShell 5.1+ or PowerShell Core 6+
- Active Directory PowerShell Module (RSAT Tools)
- Appropriate AD permissions for user creation

## File Structure

```
ADUserCreation/
├── ADUserCreation.psd1          # Module manifest
├── ADUserCreation.psm1          # Main module file
├── README.md                    # Detailed documentation
├── Install-ADUserCreation.ps1   # Installation script
├── Public/                      # Public functions
│   ├── New-ADUserSimple.ps1
│   ├── New-ADUserBatch.ps1
│   ├── Get-ADUserTemplate.ps1
│   ├── Set-ADUserDefaults.ps1
│   └── Test-ADUserExists.ps1
├── Private/                     # Private helper functions
│   ├── UserHelpers.ps1
│   └── PasswordHelpers.ps1
├── Examples/                    # Usage examples and samples
│   ├── Usage-Examples.md
│   └── sample_users.csv
└── Tests/                       # Test scripts
    └── Test-ADUserCreation.ps1
```

## Support

- Check the `README.md` for detailed documentation
- Review `Examples/Usage-Examples.md` for more examples
- Run tests with `Tests/Test-ADUserCreation.ps1`
- Use `-Verbose` and `-WhatIf` for troubleshooting

This module provides a complete solution for AD user creation with minimal complexity and maximum safety!
