#
# Module manifest for module 'ADUserCreation'
#

@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'ADUserCreation.psm1'
    
    # Version number of this module.
    ModuleVersion = '1.0.0'
    
    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')
    
    # ID used to uniquely identify this module
    GUID = 'f8c2a3d4-e5b6-4c7d-8e9f-0a1b2c3d4e5f'
    
    # Author of this module
    Author = 'Your Name'
    
    # Company or vendor of this module
    CompanyName = 'Your Organization'
    
    # Copyright statement for this module
    Copyright = '(c) 2025. All rights reserved.'
    
    # Description of the functionality provided by this module
    Description = 'PowerShell module for creating Active Directory users with minimal input requirements'
    
    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'
    
    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @('ActiveDirectory')
    
    # Functions to export from this module
    FunctionsToExport = @(
        'New-ADUserSimple',
        'Get-ADUserTemplate',
        'Set-ADUserDefaults',
        'Test-ADUserExists',
        'New-ADUserBatch'
    )
    
    # Cmdlets to export from this module
    CmdletsToExport = @()
    
    # Variables to export from this module
    VariablesToExport = @()
    
    # Aliases to export from this module
    AliasesToExport = @('Create-ADUser', 'New-User')
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{
        PSData = @{
            # Tags applied to this module
            Tags = @('ActiveDirectory', 'UserManagement', 'Administration')
            
            # A URL to the license for this module.
            LicenseUri = ''
            
            # A URL to the main website for this project.
            ProjectUri = ''
            
            # A URL to an icon representing this module.
            IconUri = ''
            
            # ReleaseNotes of this module
            ReleaseNotes = 'Initial release of ADUserCreation module'
        }
    }
}
