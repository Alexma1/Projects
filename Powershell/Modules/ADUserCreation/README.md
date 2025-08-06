# ADUserCreation PowerShell Module

A comprehensive PowerShell module for creating Active Directory users with minimal input requirements. This module simplifies AD user creation by automating username generation, password creation, and applying organizational standards.

## Features

- **Minimal Input Required**: Only first name and last name are mandatory
- **Automatic Username Generation**: Smart username generation with uniqueness validation
- **Secure Password Generation**: Automatic creation of complex passwords
- **Interactive Mode**: Guided user creation with prompts
- **Batch User Creation**: Support for CSV files and user arrays
- **Template System**: Copy settings from existing users or departments
- **Comprehensive Validation**: Checks for existing users, groups, OUs, and managers
- **Flexible Configuration**: Customizable defaults for your organization
- **Error Handling**: Robust error handling with detailed reporting

## Requirements

- Windows PowerShell 5.1 or PowerShell Core 6+
- Active Directory PowerShell Module (RSAT Tools)
- Appropriate Active Directory permissions for user creation

## Installation

1. Copy the module to your PowerShell modules directory:
   ```powershell
   $ModulePath = "$env:USERPROFILE\Documents\PowerShell\Modules\ADUserCreation"
   # Copy the ADUserCreation folder to this location
   ```

2. Import the module:
   ```powershell
   Import-Module ADUserCreation
   ```

3. Verify installation:
   ```powershell
   Get-Module ADUserCreation
   Get-Command -Module ADUserCreation
   ```

## Quick Start

### Create a Single User (Interactive)
```powershell
New-ADUserSimple -FirstName "John" -LastName "Doe" -Interactive
```

### Create a User with Details
```powershell
New-ADUserSimple -FirstName "Jane" -LastName "Smith" -JobTitle "Developer" -Department "IT"
```

### Batch Create from CSV
```powershell
New-ADUserBatch -CsvPath "C:\temp\newusers.csv"
```

## Functions

### New-ADUserSimple
Creates a new Active Directory user with minimal required input.

**Parameters:**
- `FirstName` (Required): User's first name
- `LastName` (Required): User's last name
- `JobTitle` (Optional): Job title
- `Department` (Optional): Department name
- `Manager` (Optional): Manager's SamAccountName
- `OU` (Optional): Target Organizational Unit
- `Password` (Optional): Custom password (SecureString)
- `Groups` (Optional): Additional groups beyond defaults
- `Interactive` (Switch): Enable interactive prompts
- `WhatIf` (Switch): Test run without creating users

### Get-ADUserTemplate
Gets templates for user creation based on existing users or departments.

**Parameters:**
- `TemplateUser` (Optional): Existing user to copy settings from
- `Department` (Optional): Department to create template for
- `IncludeGroups` (Switch): Include group memberships in template

### Set-ADUserDefaults
Configures default settings for the module.

**Parameters:**
- `DefaultOU` (Optional): Default Organizational Unit
- `DefaultGroups` (Optional): Default groups for new users
- `PasswordLength` (Optional): Default password length
- `AccountExpirationDays` (Optional): Days until account expires
- `ChangePasswordAtLogon` (Optional): Force password change
- `EnableAccount` (Optional): Enable accounts by default
- `ShowCurrent` (Switch): Display current settings

### Test-ADUserExists
Tests if a user already exists in Active Directory.

**Parameters:**
- `SamAccountName` (Optional): Username to check
- `UserPrincipalName` (Optional): UPN to check
- `EmailAddress` (Optional): Email address to check
- `FirstName` & `LastName` (Optional): Generate usernames and check

### New-ADUserBatch
Creates multiple users from CSV file or user array.

**Parameters:**
- `CsvPath` (Optional): Path to CSV file
- `Users` (Optional): Array of user objects
- `Template` (Optional): Template to apply defaults
- `WhatIf` (Switch): Test run
- `ContinueOnError` (Switch): Continue on individual failures

## Configuration

### View Current Defaults
```powershell
Set-ADUserDefaults -ShowCurrent
```

### Customize Defaults
```powershell
# Set default OU and password length
Set-ADUserDefaults -DefaultOU "OU=NewUsers,DC=company,DC=com" -PasswordLength 16

# Set default groups
Set-ADUserDefaults -DefaultGroups @("Domain Users", "All Staff", "Email Users")

# Set account policies
Set-ADUserDefaults -AccountExpirationDays 365 -ChangePasswordAtLogon $true
```

## Username Generation

The module automatically generates usernames using these patterns (in order of preference):

1. `firstname.lastname`
2. `f.lastname`
3. `firstname.l`
4. `flastname`
5. `firstnamel`
6. `fl`

If all patterns are taken, numbers are appended (e.g., `john.doe1`, `john.doe2`).

## Security Features

- **Secure Password Generation**: Meets AD complexity requirements
- **SecureString Handling**: Passwords handled securely in memory
- **Account Policies**: Configurable expiration and password policies
- **Validation**: Comprehensive checks before user creation
- **Audit Trail**: Detailed logging and error reporting

## CSV File Format

For batch user creation, use this CSV format:

```csv
FirstName,LastName,JobTitle,Department,Manager,OU,Groups
John,Doe,Developer,IT,alice.manager,,Developers;RemoteUsers
Jane,Smith,Manager,HR,bob.director,"OU=HR,DC=company,DC=com",HR Managers;All Staff
```

**Required Columns:**
- FirstName
- LastName

**Optional Columns:**
- JobTitle
- Department
- Manager (SamAccountName)
- OU (Distinguished Name)
- Groups (semicolon-separated)

## Error Handling

The module includes comprehensive error handling:

- Username uniqueness validation
- Group existence validation
- OU existence validation
- Manager existence validation
- Password complexity validation
- Active Directory connectivity checks

## Examples

### Interactive User Creation
```powershell
# Interactive mode with prompts
New-ADUserSimple -FirstName "Alice" -LastName "Wonder" -Interactive
```

### Template-Based Creation
```powershell
# Get template from existing user
$template = Get-ADUserTemplate -TemplateUser "john.doe" -IncludeGroups

# Create new user with template
New-ADUserSimple -FirstName "New" -LastName "Employee" -Template $template
```

### Batch Processing
```powershell
# Create multiple users from CSV
$results = New-ADUserBatch -CsvPath "C:\temp\newusers.csv" -ContinueOnError

# Review results
$results | Where-Object Status -eq "Error" | Format-Table FirstName, LastName, Error
```

### Validation
```powershell
# Check if user exists before creation
$userCheck = Test-ADUserExists -FirstName "John" -LastName "Doe"
if (-not $userCheck.Exists) {
    New-ADUserSimple -FirstName "John" -LastName "Doe"
}
```

## Troubleshooting

### Common Issues

1. **"ActiveDirectory module not found"**
   - Install RSAT Tools for your Windows version
   - Import the module: `Import-Module ActiveDirectory`

2. **"Access denied" errors**
   - Ensure you have appropriate AD permissions
   - Check OU permissions for user creation

3. **"Group not found" warnings**
   - Verify group names exist in AD
   - Check spelling and case sensitivity

4. **Username generation issues**
   - Check for naming conflicts
   - Review domain naming policies

### Debug Mode
```powershell
# Enable verbose output
New-ADUserSimple -FirstName "Test" -LastName "User" -Verbose

# Use WhatIf to test without creating
New-ADUserSimple -FirstName "Test" -LastName "User" -WhatIf
```

## Contributing

This module was created for internal use but can be customized for your organization's needs. Consider these customization points:

- Username generation patterns
- Default groups and OUs
- Password policies
- Email domain handling
- Department-specific templates

## License

This module is provided as-is for educational and organizational use.

## Version History

- **v1.0.0**: Initial release with core functionality
  - User creation with minimal inputs
  - Interactive mode
  - Batch processing
  - Template system
  - Configuration management
