# Lambda Management Deployment Script for Windows PowerShell
# This script automates the deployment process on Windows

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("deploy", "plan", "apply", "destroy", "init", "validate", "output", "help")]
    [string]$Command = "help",
    
    [Parameter(Mandatory=$false)]
    [switch]$AutoApprove
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$White = "White"

# Functions
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

# Check prerequisites
function Test-Prerequisites {
    Write-Status "Checking prerequisites..."
    
    # Check if Terraform is installed
    try {
        $terraformVersion = terraform version
        Write-Status "Terraform found: $($terraformVersion[0])"
    }
    catch {
        Write-Error "Terraform is not installed or not in PATH. Please install Terraform first."
        exit 1
    }
    
    # Check if AWS CLI is installed
    try {
        $awsVersion = aws --version
        Write-Status "AWS CLI found: $awsVersion"
    }
    catch {
        Write-Error "AWS CLI is not installed or not in PATH. Please install AWS CLI first."
        exit 1
    }
    
    # Check AWS credentials
    try {
        $identity = aws sts get-caller-identity | ConvertFrom-Json
        Write-Status "AWS credentials configured for account: $($identity.Account)"
    }
    catch {
        Write-Error "AWS credentials not configured. Please configure AWS credentials."
        exit 1
    }
    
    Write-Status "Prerequisites check passed!"
}

# Initialize Terraform
function Initialize-Terraform {
    Write-Status "Initializing Terraform..."
    
    try {
        terraform init
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Terraform initialized successfully!"
        }
        else {
            Write-Error "Terraform initialization failed!"
            exit 1
        }
    }
    catch {
        Write-Error "Terraform initialization failed: $($_.Exception.Message)"
        exit 1
    }
}

# Validate Terraform configuration
function Test-TerraformConfiguration {
    Write-Status "Validating Terraform configuration..."
    
    try {
        terraform validate
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Terraform configuration is valid!"
        }
        else {
            Write-Error "Terraform configuration validation failed!"
            exit 1
        }
    }
    catch {
        Write-Error "Terraform validation failed: $($_.Exception.Message)"
        exit 1
    }
}

# Plan Terraform deployment
function New-TerraformPlan {
    Write-Status "Creating Terraform plan..."
    
    try {
        terraform plan -out=tfplan
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Terraform plan created successfully!"
            Write-Warning "Please review the plan above before applying."
        }
        else {
            Write-Error "Terraform plan failed!"
            exit 1
        }
    }
    catch {
        Write-Error "Terraform plan failed: $($_.Exception.Message)"
        exit 1
    }
}

# Apply Terraform configuration
function Invoke-TerraformApply {
    param([bool]$AutoApprove = $false)
    
    Write-Status "Applying Terraform configuration..."
    
    # Ask for confirmation unless -AutoApprove is specified
    if (-not $AutoApprove) {
        $response = Read-Host "Do you want to apply this plan? (y/N)"
        if ($response -notmatch '^[Yy]') {
            Write-Warning "Deployment cancelled by user."
            exit 0
        }
    }
    
    try {
        terraform apply tfplan
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Terraform applied successfully!"
            Write-Status "Deployment completed!"
        }
        else {
            Write-Error "Terraform apply failed!"
            exit 1
        }
    }
    catch {
        Write-Error "Terraform apply failed: $($_.Exception.Message)"
        exit 1
    }
}

# Destroy infrastructure
function Remove-TerraformInfrastructure {
    Write-Warning "This will destroy all resources created by this Terraform configuration!"
    $response = Read-Host "Are you sure you want to destroy the infrastructure? (y/N)"
    
    if ($response -match '^[Yy]') {
        Write-Status "Destroying Terraform infrastructure..."
        
        try {
            terraform destroy
            if ($LASTEXITCODE -eq 0) {
                Write-Status "Infrastructure destroyed successfully!"
            }
            else {
                Write-Error "Terraform destroy failed!"
                exit 1
            }
        }
        catch {
            Write-Error "Terraform destroy failed: $($_.Exception.Message)"
            exit 1
        }
    }
    else {
        Write-Warning "Destroy cancelled by user."
    }
}

# Show help
function Show-Help {
    Write-Host "Lambda Management Deployment Script for Windows" -ForegroundColor $White
    Write-Host ""
    Write-Host "Usage: .\deploy.ps1 -Command <COMMAND> [-AutoApprove]" -ForegroundColor $White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor $White
    Write-Host "  deploy              Deploy the infrastructure (init, validate, plan, apply)" -ForegroundColor $White
    Write-Host "  plan               Create and show deployment plan" -ForegroundColor $White
    Write-Host "  apply              Apply the current plan" -ForegroundColor $White
    Write-Host "  destroy            Destroy the infrastructure" -ForegroundColor $White
    Write-Host "  init               Initialize Terraform" -ForegroundColor $White
    Write-Host "  validate           Validate Terraform configuration" -ForegroundColor $White
    Write-Host "  output             Show Terraform outputs" -ForegroundColor $White
    Write-Host "  help               Show this help message" -ForegroundColor $White
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor $White
    Write-Host "  -AutoApprove        Skip confirmation prompts" -ForegroundColor $White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor $White
    Write-Host "  .\deploy.ps1 -Command deploy                    # Full deployment with confirmation" -ForegroundColor $White
    Write-Host "  .\deploy.ps1 -Command deploy -AutoApprove       # Full deployment without confirmation" -ForegroundColor $White
    Write-Host "  .\deploy.ps1 -Command plan                      # Show what would be deployed" -ForegroundColor $White
    Write-Host "  .\deploy.ps1 -Command destroy                   # Destroy all resources" -ForegroundColor $White
}

# Show outputs
function Show-TerraformOutputs {
    Write-Status "Terraform outputs:"
    try {
        terraform output
    }
    catch {
        Write-Error "Failed to retrieve Terraform outputs: $($_.Exception.Message)"
    }
}

# Main script logic
switch ($Command) {
    "deploy" {
        Test-Prerequisites
        Initialize-Terraform
        Test-TerraformConfiguration
        New-TerraformPlan
        Invoke-TerraformApply -AutoApprove $AutoApprove
        Show-TerraformOutputs
    }
    "plan" {
        Test-Prerequisites
        Initialize-Terraform
        Test-TerraformConfiguration
        New-TerraformPlan
    }
    "apply" {
        Invoke-TerraformApply -AutoApprove $AutoApprove
        Show-TerraformOutputs
    }
    "destroy" {
        Remove-TerraformInfrastructure
    }
    "init" {
        Initialize-Terraform
    }
    "validate" {
        Test-TerraformConfiguration
    }
    "output" {
        Show-TerraformOutputs
    }
    "help" {
        Show-Help
    }
    default {
        Write-Error "Unknown command: $Command"
        Write-Host ""
        Show-Help
        exit 1
    }
}
