function New-ADUserSimple {
    <#
    .SYNOPSIS
        Creates a new Active Directory user with minimal required input.
    
    .DESCRIPTION
        This function creates a new Active Directory user by asking for minimal information
        and auto-generating other required fields based on organizational standards.
    
    .PARAMETER FirstName
        The user's first name. Required.
    
    .PARAMETER LastName
        The user's last name. Required.
    
    .PARAMETER JobTitle
        The user's job title. Optional.
    
    .PARAMETER Department
        The user's department. Optional.
    
    .PARAMETER Manager
        The user's manager (SamAccountName or DistinguishedName). Optional.
    
    .PARAMETER OU
        The Organizational Unit where the user will be created. 
        If not specified, uses the default OU from module configuration.
    
    .PARAMETER Password
        The password for the user account. If not specified, a secure password will be generated.
    
    .PARAMETER Groups
        Additional groups to add the user to beyond the default groups.
    
    .PARAMETER Interactive
        Switch to enable interactive mode where the function will prompt for missing information.
    
    .PARAMETER WhatIf
        Shows what would happen if the function runs without actually creating the user.
    
    .EXAMPLE
        New-ADUserSimple -FirstName "John" -LastName "Doe" -Interactive
        
        Creates a new user with interactive prompts for additional information.
    
    .EXAMPLE
        New-ADUserSimple -FirstName "Jane" -LastName "Smith" -JobTitle "Developer" -Department "IT"
        
        Creates a new user with specified job title and department.
    
    .EXAMPLE
        New-ADUserSimple -FirstName "Bob" -LastName "Johnson" -Manager "alice.manager" -Groups @("Developers", "RemoteUsers")
        
        Creates a new user with a specific manager and additional groups.
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FirstName,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$LastName,
        
        [Parameter(Mandatory = $false)]
        [string]$JobTitle,
        
        [Parameter(Mandatory = $false)]
        [string]$Department,
        
        [Parameter(Mandatory = $false)]
        [string]$Manager,
        
        [Parameter(Mandatory = $false)]
        [string]$OU,
        
        [Parameter(Mandatory = $false)]
        [SecureString]$Password,
        
        [Parameter(Mandatory = $false)]
        [string[]]$Groups = @(),
        
        [Parameter(Mandatory = $false)]
        [switch]$Interactive,
        
        [Parameter(Mandatory = $false)]
        [switch]$WhatIf
    )
    
    begin {
        Write-Verbose "Starting New-ADUserSimple function"
        
        # Check if ActiveDirectory module is available
        if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
            throw "ActiveDirectory module is not available. Please install RSAT tools."
        }
        
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
            # Interactive mode - collect additional information
            if ($Interactive) {
                Write-Host "`n=== AD User Creation - Interactive Mode ===" -ForegroundColor Cyan
                Write-Host "Creating user: $FirstName $LastName" -ForegroundColor Green
                
                if (-not $JobTitle) {
                    $JobTitle = Read-Host "Job Title (optional)"
                }
                
                if (-not $Department) {
                    $Department = Read-Host "Department (optional)"
                }
                
                if (-not $Manager) {
                    $Manager = Read-Host "Manager's username (optional)"
                }
                
                if (-not $OU) {
                    Write-Host "`nAvailable OUs:" -ForegroundColor Yellow
                    $availableOUs = Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName | Sort-Object Name
                    for ($i = 0; $i -lt $availableOUs.Count; $i++) {
                        Write-Host "  [$i] $($availableOUs[$i].Name)" -ForegroundColor White
                    }
                    
                    $ouChoice = Read-Host "`nSelect OU by number (or press Enter for default)"
                    if ($ouChoice -and $ouChoice -match '^\d+$' -and [int]$ouChoice -lt $availableOUs.Count) {
                        $OU = $availableOUs[[int]$ouChoice].DistinguishedName
                    }
                }
                
                # Ask for additional groups
                Write-Host "`nAvailable Groups:" -ForegroundColor Yellow
                $availableGroups = Get-ADGroup -Filter * | Where-Object { $_.GroupScope -eq "Global" -or $_.GroupScope -eq "Universal" } | 
                                 Select-Object Name | Sort-Object Name | Select-Object -First 20
                
                $availableGroups | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }
                
                $additionalGroups = Read-Host "`nAdditional groups (comma-separated, optional)"
                if ($additionalGroups) {
                    $Groups += $additionalGroups -split ',' | ForEach-Object { $_.Trim() }
                }
            }
            
            # Generate user details
            $userDetails = New-UserDetails -FirstName $FirstName -LastName $LastName -JobTitle $JobTitle -Department $Department
            
            # Validate username doesn't already exist
            if (Test-ADUserExists -SamAccountName $userDetails.SamAccountName) {
                throw "User '$($userDetails.SamAccountName)' already exists in Active Directory"
            }
            
            # Set OU if not provided
            if (-not $OU) {
                $OU = $script:ModuleDefaults.DefaultOU
            }
            
            # Generate password if not provided
            if (-not $Password) {
                $Password = New-SecurePassword -Length $script:ModuleDefaults.PasswordLength
                $passwordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
                Write-Host "`nGenerated password: $passwordText" -ForegroundColor Yellow
                Write-Host "Please save this password securely!" -ForegroundColor Red
            }
            
            # Prepare user creation parameters
            $userParams = @{
                SamAccountName          = $userDetails.SamAccountName
                UserPrincipalName       = $userDetails.UserPrincipalName
                Name                    = $userDetails.DisplayName
                DisplayName             = $userDetails.DisplayName
                GivenName               = $FirstName
                Surname                 = $LastName
                EmailAddress            = $userDetails.EmailAddress
                AccountPassword         = $Password
                Path                    = $OU
                Enabled                 = $script:ModuleDefaults.EnableAccount
                ChangePasswordAtLogon   = $script:ModuleDefaults.ChangePasswordAtLogon
            }
            
            # Add optional parameters
            if ($JobTitle) { $userParams.Title = $JobTitle }
            if ($Department) { $userParams.Department = $Department }
            if ($Manager) {
                try {
                    $managerUser = Get-ADUser -Identity $Manager -ErrorAction Stop
                    $userParams.Manager = $managerUser.DistinguishedName
                }
                catch {
                    Write-Warning "Manager '$Manager' not found. Skipping manager assignment."
                }
            }
            
            # Set account expiration
            if ($script:ModuleDefaults.AccountExpirationDays -gt 0) {
                $userParams.AccountExpirationDate = (Get-Date).AddDays($script:ModuleDefaults.AccountExpirationDays)
            }
            
            # Display what will be created
            Write-Host "`n=== User Creation Summary ===" -ForegroundColor Cyan
            Write-Host "Username: $($userDetails.SamAccountName)" -ForegroundColor Green
            Write-Host "Display Name: $($userDetails.DisplayName)" -ForegroundColor Green
            Write-Host "Email: $($userDetails.EmailAddress)" -ForegroundColor Green
            Write-Host "OU: $OU" -ForegroundColor Green
            if ($JobTitle) { Write-Host "Job Title: $JobTitle" -ForegroundColor Green }
            if ($Department) { Write-Host "Department: $Department" -ForegroundColor Green }
            if ($Manager) { Write-Host "Manager: $Manager" -ForegroundColor Green }
            
            # Combine default groups with additional groups
            $allGroups = $script:ModuleDefaults.DefaultGroups + $Groups | Select-Object -Unique
            Write-Host "Groups: $($allGroups -join ', ')" -ForegroundColor Green
            
            if ($WhatIf) {
                Write-Host "`n[WHATIF] Would create user with above parameters" -ForegroundColor Magenta
                return $userDetails
            }
            
            # Confirm creation in interactive mode
            if ($Interactive) {
                $confirm = Read-Host "`nProceed with user creation? (y/N)"
                if ($confirm -notmatch '^[Yy]') {
                    Write-Host "User creation cancelled." -ForegroundColor Yellow
                    return
                }
            }
            
            # Create the user
            Write-Host "`nCreating user..." -ForegroundColor Yellow
            
            if ($PSCmdlet.ShouldProcess($userDetails.SamAccountName, "Create AD User")) {
                $newUser = New-ADUser @userParams -PassThru
                Write-Host "User '$($userDetails.SamAccountName)' created successfully!" -ForegroundColor Green
                
                # Add user to groups
                foreach ($group in $allGroups) {
                    try {
                        Add-ADGroupMember -Identity $group -Members $newUser.SamAccountName -ErrorAction Stop
                        Write-Host "Added to group: $group" -ForegroundColor Green
                    }
                    catch {
                        Write-Warning "Failed to add user to group '$group': $($_.Exception.Message)"
                    }
                }
                
                # Return user object
                return Get-ADUser -Identity $newUser.SamAccountName -Properties *
            }
        }
        catch {
            Write-Error "Failed to create user: $($_.Exception.Message)"
            throw
        }
    }
    
    end {
        Write-Verbose "Completed New-ADUserSimple function"
    }
}
