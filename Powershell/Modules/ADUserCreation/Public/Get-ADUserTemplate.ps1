function Get-ADUserTemplate {
    <#
    .SYNOPSIS
        Gets a template for AD user creation based on an existing user or department.
    
    .DESCRIPTION
        This function retrieves user templates that can be used as a basis for creating new users.
        It can copy settings from an existing user or provide department-specific templates.
    
    .PARAMETER TemplateUser
        An existing user to use as a template. The function will copy relevant properties.
    
    .PARAMETER Department
        A department name to get a department-specific template.
    
    .PARAMETER IncludeGroups
        Switch to include group memberships in the template.
    
    .EXAMPLE
        Get-ADUserTemplate -TemplateUser "john.doe"
        
        Gets a template based on john.doe's account settings.
    
    .EXAMPLE
        Get-ADUserTemplate -Department "IT" -IncludeGroups
        
        Gets a template for IT department users including typical group memberships.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "User")]
        [string]$TemplateUser,
        
        [Parameter(Mandatory = $false, ParameterSetName = "Department")]
        [string]$Department,
        
        [Parameter(Mandatory = $false)]
        [switch]$IncludeGroups
    )
    
    begin {
        Write-Verbose "Starting Get-ADUserTemplate function"
        
        # Import ActiveDirectory module
        try {
            Import-Module ActiveDirectory -ErrorAction Stop
        }
        catch {
            throw "Failed to import ActiveDirectory module: $($_.Exception.Message)"
        }
    }
    
    process {
        $template = @{
            OU = $script:ModuleDefaults.DefaultOU
            Groups = $script:ModuleDefaults.DefaultGroups
            AccountSettings = @{
                Enabled = $script:ModuleDefaults.EnableAccount
                ChangePasswordAtLogon = $script:ModuleDefaults.ChangePasswordAtLogon
                AccountExpirationDays = $script:ModuleDefaults.AccountExpirationDays
            }
        }
        
        if ($TemplateUser) {
            try {
                $user = Get-ADUser -Identity $TemplateUser -Properties * -ErrorAction Stop
                
                $template.OU = ($user.DistinguishedName -split ',', 2)[1]
                $template.Department = $user.Department
                $template.Company = $user.Company
                $template.Office = $user.Office
                $template.Manager = $user.Manager
                $template.Title = $user.Title
                $template.StreetAddress = $user.StreetAddress
                $template.City = $user.City
                $template.State = $user.State
                $template.PostalCode = $user.PostalCode
                $template.Country = $user.Country
                $template.OfficePhone = $user.OfficePhone
                
                if ($IncludeGroups) {
                    $userGroups = Get-ADPrincipalGroupMembership -Identity $TemplateUser | 
                                 Where-Object { $_.Name -ne "Domain Users" } | 
                                 Select-Object -ExpandProperty Name
                    $template.Groups = @($script:ModuleDefaults.DefaultGroups) + @($userGroups)
                }
                
                Write-Host "Template created based on user: $TemplateUser" -ForegroundColor Green
            }
            catch {
                Write-Error "Failed to get template from user '$TemplateUser': $($_.Exception.Message)"
                return
            }
        }
        elseif ($Department) {
            # Get department-specific settings
            $deptUsers = Get-ADUser -Filter "Department -eq '$Department'" -Properties Department, Title, Manager, MemberOf | Select-Object -First 5
            
            if ($deptUsers) {
                # Get most common OU for this department
                $commonOU = $deptUsers | Group-Object { ($_.DistinguishedName -split ',', 2)[1] } | 
                           Sort-Object Count -Descending | 
                           Select-Object -First 1 -ExpandProperty Name
                
                if ($commonOU) {
                    $template.OU = $commonOU
                }
                
                $template.Department = $Department
                
                # Get most common manager
                $commonManager = $deptUsers | Where-Object { $_.Manager } | 
                                Group-Object Manager | 
                                Sort-Object Count -Descending | 
                                Select-Object -First 1 -ExpandProperty Name
                
                if ($commonManager) {
                    $template.Manager = $commonManager
                }
                
                # Get common job titles
                $commonTitles = $deptUsers | Where-Object { $_.Title } | 
                               Group-Object Title | 
                               Sort-Object Count -Descending | 
                               Select-Object -First 3 -ExpandProperty Name
                
                if ($commonTitles) {
                    $template.CommonTitles = $commonTitles
                }
                
                if ($IncludeGroups) {
                    # Get common groups for this department
                    $allGroups = $deptUsers | ForEach-Object {
                        Get-ADPrincipalGroupMembership -Identity $_.SamAccountName | 
                        Where-Object { $_.Name -ne "Domain Users" } | 
                        Select-Object -ExpandProperty Name
                    }
                    
                    $commonGroups = $allGroups | Group-Object | 
                                   Where-Object { $_.Count -ge ($deptUsers.Count * 0.6) } | 
                                   Select-Object -ExpandProperty Name
                    
                    if ($commonGroups) {
                        $template.Groups = @($script:ModuleDefaults.DefaultGroups) + @($commonGroups)
                    }
                }
                
                Write-Host "Template created for department: $Department" -ForegroundColor Green
                Write-Host "Based on analysis of $($deptUsers.Count) existing users in this department" -ForegroundColor Yellow
            }
            else {
                Write-Warning "No existing users found in department: $Department"
                Write-Host "Using default template" -ForegroundColor Yellow
            }
        }
        
        return [PSCustomObject]$template
    }
    
    end {
        Write-Verbose "Completed Get-ADUserTemplate function"
    }
}
