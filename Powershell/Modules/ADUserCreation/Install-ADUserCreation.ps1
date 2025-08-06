# Install-ADUserCreation.ps1
# Installation script for the ADUserCreation PowerShell module

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("CurrentUser", "AllUsers")]
    [string]$Scope = "CurrentUser",
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$Test
)

$ErrorActionPreference = "Stop"

Write-Host "=== ADUserCreation Module Installation ===" -ForegroundColor Cyan

# Define paths
$ModuleName = "ADUserCreation"
$SourcePath = Split-Path -Parent $PSScriptRoot

if ($Scope -eq "CurrentUser") {
    $TargetPath = Join-Path $env:USERPROFILE "Documents\PowerShell\Modules\$ModuleName"
    if (-not (Test-Path (Split-Path $TargetPath))) {
        $TargetPath = Join-Path $env:USERPROFILE "Documents\WindowsPowerShell\Modules\$ModuleName"
    }
}
else {
    $TargetPath = Join-Path $env:ProgramFiles "PowerShell\Modules\$ModuleName"
    if (-not (Test-Path (Split-Path $TargetPath))) {
        $TargetPath = Join-Path $env:ProgramFiles "WindowsPowerShell\Modules\$ModuleName"
    }
}

Write-Host "Source: $SourcePath" -ForegroundColor Yellow
Write-Host "Target: $TargetPath" -ForegroundColor Yellow
Write-Host "Scope: $Scope" -ForegroundColor Yellow

# Check prerequisites
Write-Host "`nChecking prerequisites..." -ForegroundColor Green

# Check PowerShell version
$psVersion = $PSVersionTable.PSVersion
Write-Host "PowerShell Version: $psVersion" -ForegroundColor White

if ($psVersion.Major -lt 5) {
    Write-Error "PowerShell 5.1 or later is required"
}

# Check for ActiveDirectory module
$adModule = Get-Module -Name ActiveDirectory -ListAvailable
if ($adModule) {
    Write-Host "✓ ActiveDirectory module found: $($adModule.Version)" -ForegroundColor Green
}
else {
    Write-Warning "ActiveDirectory module not found. Please install RSAT Tools."
    Write-Host "Download from: https://www.microsoft.com/en-us/download/details.aspx?id=45520" -ForegroundColor Yellow
}

# Check if module already exists
if (Test-Path $TargetPath) {
    if ($Force) {
        Write-Host "✓ Removing existing module (Force specified)" -ForegroundColor Yellow
        Remove-Item $TargetPath -Recurse -Force
    }
    else {
        Write-Error "Module already exists at $TargetPath. Use -Force to overwrite."
    }
}

# Check permissions
try {
    $targetDir = Split-Path $TargetPath
    if (-not (Test-Path $targetDir)) {
        New-Item -Path $targetDir -ItemType Directory -Force | Out-Null
    }
    
    # Test write permissions
    $testFile = Join-Path $targetDir "test_write.tmp"
    "test" | Out-File $testFile -ErrorAction Stop
    Remove-Item $testFile -ErrorAction SilentlyContinue
    
    Write-Host "✓ Write permissions verified" -ForegroundColor Green
}
catch {
    if ($Scope -eq "AllUsers") {
        Write-Error "Insufficient permissions for AllUsers scope. Run as Administrator or use -Scope CurrentUser"
    }
    else {
        Write-Error "Cannot write to module directory: $($_.Exception.Message)"
    }
}

# Install the module
Write-Host "`nInstalling module..." -ForegroundColor Green

try {
    # Create target directory
    New-Item -Path $TargetPath -ItemType Directory -Force | Out-Null
    
    # Copy all module files
    $filesToCopy = @(
        "*.psd1",
        "*.psm1", 
        "Public\*.ps1",
        "Private\*.ps1",
        "Classes\*.ps1",
        "Examples\*",
        "README.md"
    )
    
    foreach ($pattern in $filesToCopy) {
        $files = Get-ChildItem -Path $SourcePath -Filter $pattern -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            $relativePath = $file.FullName.Substring($SourcePath.Length + 1)
            $targetFile = Join-Path $TargetPath $relativePath
            $targetFileDir = Split-Path $targetFile
            
            if (-not (Test-Path $targetFileDir)) {
                New-Item -Path $targetFileDir -ItemType Directory -Force | Out-Null
            }
            
            Copy-Item $file.FullName $targetFile -Force
        }
    }
    
    Write-Host "✓ Module files copied successfully" -ForegroundColor Green
}
catch {
    Write-Error "Failed to copy module files: $($_.Exception.Message)"
}

# Test the installation
Write-Host "`nTesting installation..." -ForegroundColor Green

try {
    # Import the module
    Import-Module $TargetPath -Force
    
    # Verify commands are available
    $commands = Get-Command -Module $ModuleName
    Write-Host "✓ Module imported successfully" -ForegroundColor Green
    Write-Host "✓ Available commands: $($commands.Count)" -ForegroundColor Green
    
    foreach ($cmd in $commands) {
        Write-Host "  - $($cmd.Name)" -ForegroundColor White
    }
    
    # Run basic test if requested
    if ($Test) {
        Write-Host "`nRunning basic tests..." -ForegroundColor Green
        
        # Test configuration
        Set-ADUserDefaults -ShowCurrent
        
        # Test user details generation
        $testDetails = New-UserDetails -FirstName "Test" -LastName "Install"
        Write-Host "✓ Username generation test: $($testDetails.SamAccountName)" -ForegroundColor Green
        
        # Test password generation
        $null = New-SecurePassword -Length 10
        Write-Host "✓ Password generation test: 10 character password created" -ForegroundColor Green
    }
}
catch {
    Write-Error "Module test failed: $($_.Exception.Message)"
}

# Installation complete
Write-Host "`n=== Installation Complete ===" -ForegroundColor Cyan
Write-Host "Module installed to: $TargetPath" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Import the module: Import-Module $ModuleName" -ForegroundColor White
Write-Host "2. Configure defaults: Set-ADUserDefaults -ShowCurrent" -ForegroundColor White
Write-Host "3. Run the test script: .\Tests\Test-ADUserCreation.ps1" -ForegroundColor White
Write-Host "4. Try creating a user: New-ADUserSimple -FirstName 'Test' -LastName 'User' -WhatIf" -ForegroundColor White
Write-Host ""
Write-Host "Documentation: $TargetPath\README.md" -ForegroundColor Cyan
Write-Host "Examples: $TargetPath\Examples\" -ForegroundColor Cyan
