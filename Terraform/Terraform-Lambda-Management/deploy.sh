#!/bin/bash

# Deployment script for Lambda Management Terraform project
# This script automates the deployment process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please configure AWS credentials."
        exit 1
    fi
    
    print_status "Prerequisites check passed!"
}

# Initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    terraform init
    
    if [ $? -eq 0 ]; then
        print_status "Terraform initialized successfully!"
    else
        print_error "Terraform initialization failed!"
        exit 1
    fi
}

# Validate Terraform configuration
validate_terraform() {
    print_status "Validating Terraform configuration..."
    terraform validate
    
    if [ $? -eq 0 ]; then
        print_status "Terraform configuration is valid!"
    else
        print_error "Terraform configuration validation failed!"
        exit 1
    fi
}

# Plan Terraform deployment
plan_terraform() {
    print_status "Creating Terraform plan..."
    terraform plan -out=tfplan
    
    if [ $? -eq 0 ]; then
        print_status "Terraform plan created successfully!"
        print_warning "Please review the plan above before applying."
    else
        print_error "Terraform plan failed!"
        exit 1
    fi
}

# Apply Terraform configuration
apply_terraform() {
    print_status "Applying Terraform configuration..."
    
    # Ask for confirmation unless --auto-approve is passed
    if [[ "$1" != "--auto-approve" ]]; then
        read -p "Do you want to apply this plan? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_warning "Deployment cancelled by user."
            exit 0
        fi
    fi
    
    terraform apply tfplan
    
    if [ $? -eq 0 ]; then
        print_status "Terraform applied successfully!"
        print_status "Deployment completed!"
    else
        print_error "Terraform apply failed!"
        exit 1
    fi
}

# Destroy infrastructure
destroy_terraform() {
    print_warning "This will destroy all resources created by this Terraform configuration!"
    read -p "Are you sure you want to destroy the infrastructure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Destroying Terraform infrastructure..."
        terraform destroy
        
        if [ $? -eq 0 ]; then
            print_status "Infrastructure destroyed successfully!"
        else
            print_error "Terraform destroy failed!"
            exit 1
        fi
    else
        print_warning "Destroy cancelled by user."
    fi
}

# Show help
show_help() {
    echo "Lambda Management Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  deploy              Deploy the infrastructure (init, validate, plan, apply)"
    echo "  deploy --auto-approve Deploy without confirmation prompt"
    echo "  plan               Create and show deployment plan"
    echo "  apply              Apply the current plan"
    echo "  destroy            Destroy the infrastructure"
    echo "  init               Initialize Terraform"
    echo "  validate           Validate Terraform configuration"
    echo "  output             Show Terraform outputs"
    echo "  help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy                    # Full deployment with confirmation"
    echo "  $0 deploy --auto-approve     # Full deployment without confirmation"
    echo "  $0 plan                      # Show what would be deployed"
    echo "  $0 destroy                   # Destroy all resources"
}

# Show outputs
show_outputs() {
    print_status "Terraform outputs:"
    terraform output
}

# Main script logic
case "$1" in
    "deploy")
        check_prerequisites
        init_terraform
        validate_terraform
        plan_terraform
        apply_terraform "$2"
        show_outputs
        ;;
    "plan")
        check_prerequisites
        init_terraform
        validate_terraform
        plan_terraform
        ;;
    "apply")
        apply_terraform "$2"
        show_outputs
        ;;
    "destroy")
        destroy_terraform
        ;;
    "init")
        init_terraform
        ;;
    "validate")
        validate_terraform
        ;;
    "output")
        show_outputs
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    "")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
