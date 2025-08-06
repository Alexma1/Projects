# ADUserCreation Module - Usage Examples

## Basic Usage

### Create a single user interactively
```powershell
Import-Module ADUserCreation
New-ADUserSimple -FirstName "John" -LastName "Doe" -Interactive
```

### Create a user with specific details
```powershell
New-ADUserSimple -FirstName "Jane" -LastName "Smith" -JobTitle "Developer" -Department "IT" -Groups @("Developers", "RemoteUsers")
```

### Create a user with a specific manager
```powershell
New-ADUserSimple -FirstName "Bob" -LastName "Johnson" -Manager "alice.manager" -JobTitle "Sales Rep" -Department "Sales"
```

## Template Usage

### Get a template based on an existing user
```powershell
$template = Get-ADUserTemplate -TemplateUser "john.doe" -IncludeGroups
```

### Get a department template
```powershell
$template = Get-ADUserTemplate -Department "IT" -IncludeGroups
```

### Use template to create new user
```powershell
New-ADUserSimple -FirstName "New" -LastName "User" -Template $template
```

## Batch User Creation

### Create users from CSV file
```powershell
New-ADUserBatch -CsvPath "C:\temp\newusers.csv" -ContinueOnError
```

### Create users from array with template
```powershell
$users = @(
    @{FirstName="Alice"; LastName="Cooper"; JobTitle="Analyst"; Department="Finance"},
    @{FirstName="Bob"; LastName="Dylan"; JobTitle="Manager"; Department="Sales"}
)

$template = Get-ADUserTemplate -Department "Sales"
New-ADUserBatch -Users $users -Template $template
```

## Configuration

### View current defaults
```powershell
Set-ADUserDefaults -ShowCurrent
```

### Set new defaults
```powershell
Set-ADUserDefaults -DefaultOU "OU=NewHires,DC=company,DC=com" -PasswordLength 16 -AccountExpirationDays 90
```

### Set default groups
```powershell
Set-ADUserDefaults -DefaultGroups @("Domain Users", "All Staff", "Email Users")
```

## User Validation

### Check if user exists
```powershell
Test-ADUserExists -SamAccountName "john.doe"
Test-ADUserExists -FirstName "John" -LastName "Doe"
Test-ADUserExists -EmailAddress "john.doe@company.com"
```

## Advanced Examples

### Create user with custom OU and specific groups
```powershell
New-ADUserSimple -FirstName "Sarah" -LastName "Connor" `
                 -JobTitle "Security Specialist" `
                 -Department "Security" `
                 -OU "OU=Security,OU=Users,DC=company,DC=com" `
                 -Groups @("Security Team", "VPN Users", "Privileged Users") `
                 -Manager "kyle.reese"
```

### Test run (WhatIf)
```powershell
New-ADUserSimple -FirstName "Test" -LastName "User" -WhatIf
New-ADUserBatch -CsvPath "C:\temp\users.csv" -WhatIf
```

### Batch creation with template and error handling
```powershell
$template = Get-ADUserTemplate -Department "IT" -IncludeGroups
$results = New-ADUserBatch -CsvPath "C:\temp\newdevs.csv" -Template $template -ContinueOnError

# Review results
$results | Where-Object Status -eq "Error" | Format-Table FirstName, LastName, Error -AutoSize
$results | Where-Object Status -eq "Success" | Format-Table FirstName, LastName, SamAccountName -AutoSize
```

## CSV File Format

Your CSV file should have the following columns (only FirstName and LastName are required):

- **FirstName** (Required): User's first name
- **LastName** (Required): User's last name  
- **JobTitle** (Optional): Job title
- **Department** (Optional): Department name
- **Manager** (Optional): Manager's SamAccountName
- **OU** (Optional): Target Organizational Unit (DN format)
- **Groups** (Optional): Semicolon-separated list of groups

Example CSV content:
```csv
FirstName,LastName,JobTitle,Department,Manager,OU,Groups
John,Doe,Developer,IT,alice.manager,,Developers;RemoteUsers
Jane,Smith,Manager,HR,bob.director,"OU=HR,DC=company,DC=com",HR Managers
```

## Error Handling

The module includes comprehensive error handling:

- Username uniqueness validation
- Group existence validation
- OU existence validation
- Manager existence validation
- Password complexity validation
- Active Directory connectivity checks

Use the `-ContinueOnError` switch with batch operations to process all users even if some fail.

## Security Features

- Automatic secure password generation
- Passwords are handled as SecureString objects
- Account expiration settings
- Change password at logon enforcement
- Group membership validation
