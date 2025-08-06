function New-ADUserBatch {
    <#
    .SYNOPSIS
        Creates multiple AD users from a CSV file or array of user objects.
    
    .DESCRIPTION
        This function allows bulk creation of AD users from a CSV file or an array of user objects.
        Each user is created using the same logic as New-ADUserSimple.
    
    .PARAMETER CsvPath
        Path to a CSV file containing user information.
    
    .PARAMETER Users
        Array of user objects with properties for user creation.
    
    .PARAMETER Template
        A template object to use for default values.
    
    .PARAMETER WhatIf
        Shows what would happen without actually creating users.
    
    .PARAMETER ContinueOnError
        Continue processing other users if one fails.
    
    .EXAMPLE
        New-ADUserBatch -CsvPath "C:\temp\newusers.csv"
        
        Creates users from a CSV file.
    
    .EXAMPLE
        $users = @(
            @{FirstName="John"; LastName="Doe"; JobTitle="Developer"; Department="IT"},
            @{FirstName="Jane"; LastName="Smith"; JobTitle="Manager"; Department="HR"}
        )
        New-ADUserBatch -Users $users
        
        Creates users from an array of user objects.
    
    .NOTES
        CSV file should contain columns: FirstName, LastName, JobTitle, Department, Manager, OU, Groups
        Groups should be semicolon-separated if multiple groups per user.
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "CSV")]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [string]$CsvPath,
        
        [Parameter(Mandatory = $true, ParameterSetName = "Array")]
        [array]$Users,
        
        [Parameter(Mandatory = $false)]
        [PSCustomObject]$Template,
        
        [Parameter(Mandatory = $false)]
        [switch]$WhatIf,
        
        [Parameter(Mandatory = $false)]
        [switch]$ContinueOnError
    )
    
    begin {
        Write-Verbose "Starting New-ADUserBatch function"
        
        # Import ActiveDirectory module
        try {
            Import-Module ActiveDirectory -ErrorAction Stop
        }
        catch {
            throw "Failed to import ActiveDirectory module: $($_.Exception.Message)"
        }
        
        $results = @()
        $successCount = 0
        $errorCount = 0
    }
    
    process {
        # Load users from CSV or use provided array
        if ($PSCmdlet.ParameterSetName -eq "CSV") {
            try {
                $Users = Import-Csv -Path $CsvPath
                Write-Host "Loaded $($Users.Count) users from CSV file: $CsvPath" -ForegroundColor Green
            }
            catch {
                Write-Error "Failed to import CSV file: $($_.Exception.Message)"
                return
            }
        }
        
        Write-Host "`n=== Batch User Creation ===" -ForegroundColor Cyan
        Write-Host "Processing $($Users.Count) users..." -ForegroundColor Yellow
        
        if ($WhatIf) {
            Write-Host "[WHATIF] This is a test run - no users will be created" -ForegroundColor Magenta
        }
        
        foreach ($user in $Users) {
            try {
                Write-Host "`nProcessing: $($user.FirstName) $($user.LastName)" -ForegroundColor Yellow
                
                # Validate required fields
                if (-not $user.FirstName -or -not $user.LastName) {
                    throw "FirstName and LastName are required for each user"
                }
                
                # Prepare parameters for New-ADUserSimple
                $userParams = @{
                    FirstName = $user.FirstName
                    LastName = $user.LastName
                    WhatIf = $WhatIf
                }
                
                # Add optional parameters
                if ($user.JobTitle) { $userParams.JobTitle = $user.JobTitle }
                if ($user.Department) { $userParams.Department = $user.Department }
                if ($user.Manager) { $userParams.Manager = $user.Manager }
                if ($user.OU) { $userParams.OU = $user.OU }
                
                # Handle groups (semicolon-separated)
                if ($user.Groups) {
                    $userParams.Groups = $user.Groups -split ';' | ForEach-Object { $_.Trim() }
                }
                
                # Apply template defaults if provided
                if ($Template) {
                    if (-not $userParams.ContainsKey('OU') -and $Template.OU) {
                        $userParams.OU = $Template.OU
                    }
                    if (-not $userParams.ContainsKey('Department') -and $Template.Department) {
                        $userParams.Department = $Template.Department
                    }
                    if (-not $userParams.ContainsKey('Manager') -and $Template.Manager) {
                        $userParams.Manager = $Template.Manager
                    }
                    if ($Template.Groups -and -not $userParams.ContainsKey('Groups')) {
                        $userParams.Groups = $Template.Groups
                    }
                }
                
                # Create the user
                $result = New-ADUserSimple @userParams
                
                if ($result) {
                    $successCount++
                    $results += [PSCustomObject]@{
                        FirstName = $user.FirstName
                        LastName = $user.LastName
                        SamAccountName = $result.SamAccountName
                        Status = "Success"
                        Error = $null
                    }
                    
                    if (-not $WhatIf) {
                        Write-Host "✓ Created: $($result.SamAccountName)" -ForegroundColor Green
                    }
                    else {
                        Write-Host "✓ Would create: $($result.SamAccountName)" -ForegroundColor Green
                    }
                }
            }
            catch {
                $errorCount++
                $errorMessage = $_.Exception.Message
                
                Write-Error "Failed to create user $($user.FirstName) $($user.LastName): $errorMessage"
                
                $results += [PSCustomObject]@{
                    FirstName = $user.FirstName
                    LastName = $user.LastName
                    SamAccountName = $null
                    Status = "Error"
                    Error = $errorMessage
                }
                
                if (-not $ContinueOnError) {
                    Write-Host "Stopping batch process due to error. Use -ContinueOnError to skip failed users." -ForegroundColor Red
                    break
                }
            }
        }
        
        # Summary
        Write-Host "`n=== Batch Creation Summary ===" -ForegroundColor Cyan
        Write-Host "Total users processed: $($Users.Count)" -ForegroundColor White
        Write-Host "Successful: $successCount" -ForegroundColor Green
        Write-Host "Failed: $errorCount" -ForegroundColor Red
        
        if ($errorCount -gt 0) {
            Write-Host "`nFailed users:" -ForegroundColor Red
            $results | Where-Object { $_.Status -eq "Error" } | ForEach-Object {
                Write-Host "  - $($_.FirstName) $($_.LastName): $($_.Error)" -ForegroundColor Red
            }
        }
        
        return $results
    }
    
    end {
        Write-Verbose "Completed New-ADUserBatch function"
    }
}
