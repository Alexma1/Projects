# 🚀 Multi-Team Infrastructure with Terraform Modules

This repository provides a modular Terraform infrastructure setup supporting different team architectures - from traditional EC2 deployments to modern containerized ECS solutions.

## 📁 Project Structure

```
custom_module_environment/
├── Modules/                    # Reusable infrastructure modules
│   ├── EC2/                   # EC2 instance module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ECS/                   # ECS Fargate module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── sg/                    # Security Group module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── Teams/                     # Team-specific configurations
    ├── A/                     # Team A: Hybrid (EC2 + ECS)
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    └── B/                     # Team B: ECS-Only
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

## 🏗️ Available Modules

### 🔒 Security Group Module (`Modules/sg/`)
- **Purpose**: Creates AWS security groups with configurable rules
- **Default**: Allows all inbound and outbound traffic
- **Customizable**: Tags, VPC, rules

### 🖥️ EC2 Module (`Modules/EC2/`)
- **Purpose**: Deploys EC2 instances with latest Amazon Linux 2
- **Features**: Auto-discovery of subnets and AMI, SSH key support
- **Networking**: Uses provided security groups and VPC

### 🐳 ECS Module (`Modules/ECS/`)
- **Purpose**: Deploys containerized applications on AWS Fargate
- **Features**: Multi-container support, CloudWatch logging, IAM roles
- **Flexibility**: Supports single or multiple container definitions

## 👥 Team Configurations

### 🔵 Team A - Hybrid Infrastructure
**Location**: `Teams/A/`

**Architecture**:
- ✅ EC2 Instance (Amazon Linux 2, t3.micro)
- ✅ ECS Fargate Cluster (NGINX container)
- ✅ Shared Security Group
- ✅ Development environment setup

**Use Cases**:
- Legacy application migration
- Hybrid cloud strategies
- Development and testing
- Learning both EC2 and ECS

### 🟢 Team B - Container-Only Infrastructure  
**Location**: `Teams/B/`

**Architecture**:
- ✅ ECS Fargate Cluster Only
- ✅ Multi-container setup (Node.js + NGINX proxy)
- ✅ Production-grade configuration
- ✅ Container Insights enabled

**Use Cases**:
- Microservices architecture
- Cloud-native applications
- Production workloads
- Cost-optimized deployments

## 🚀 Quick Start Guide

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0 installed
- Git (for module sources)

### 🔵 Deploy Team A (Hybrid Infrastructure)

```bash
# Navigate to Team A directory
cd Teams/A

# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy infrastructure
terraform apply

# View important outputs
terraform output
```

**What gets created**:
- 1x Security Group (allows all traffic)
- 1x EC2 Instance (t3.micro, Amazon Linux 2)
- 1x ECS Cluster with NGINX container
- CloudWatch Log Groups
- IAM Roles for ECS

### 🟢 Deploy Team B (ECS-Only Infrastructure)

```bash
# Navigate to Team B directory  
cd Teams/B

# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy infrastructure
terraform apply

# View important outputs
terraform output
```

**What gets created**:
- 1x Security Group (allows all traffic)
- 1x ECS Cluster with 2 containers:
  - Node.js app (`uya0/node-example-1:node-deploy`) on port 3000
  - NGINX reverse proxy on port 80
- CloudWatch Log Groups with Container Insights
- IAM Roles for ECS

## 🔧 Configuration Options

### Team A Customization

Edit `Teams/A/variables.tf` or create `Teams/A/terraform.tfvars`:

```hcl
# EC2 Configuration
instance_type = "t3.small"
key_name      = "your-ssh-key"

# ECS Configuration
ecs_container_image = "your-custom-image:tag"
ecs_desired_count   = 2

# Networking
vpc_id            = "vpc-your-vpc-id"
availability_zone = "us-east-1b"
```

### Team B Customization

Edit `Teams/B/variables.tf` or create `Teams/B/terraform.tfvars`:

```hcl
# ECS Configuration
ecs_desired_count = 2  # Number of tasks (each with 2 containers)
ecs_cpu          = "1024"
ecs_memory       = "2048"

# Container Images
ecs_container_definitions = [
  {
    name  = "your-app"
    image = "your-registry/your-app:latest"
    # ... other container config
  }
]
```

## 📊 Resource Overview

### Team A Resources:
| Resource Type | Count | Purpose |
|---------------|-------|---------|
| Security Groups | 1 | Network security |
| EC2 Instances | 1 | Traditional compute |
| ECS Clusters | 1 | Container orchestration |
| ECS Services | 1 | Container management |
| CloudWatch Log Groups | 2 | Logging |
| IAM Roles | 2 | ECS permissions |

### Team B Resources:
| Resource Type | Count | Purpose |
|---------------|-------|---------|
| Security Groups | 1 | Network security |
| ECS Clusters | 1 | Container orchestration |
| ECS Services | 1 | Container management |
| ECS Tasks | 1 | Container runtime |
| Containers per Task | 2 | App + Proxy |
| CloudWatch Log Groups | 1 | Centralized logging |
| IAM Roles | 2 | ECS permissions |

## 🌐 Accessing Your Applications

### Team A Access:
```bash
# Get outputs
terraform output

# SSH to EC2 instance
ssh -i your-key.pem ec2-user@<ec2_public_ip>

# Access ECS service via public IP
curl http://<ecs_task_public_ip>
```

### Team B Access:
```bash
# Get outputs  
terraform output

# Access application via NGINX proxy
curl http://<ecs_task_public_ip>
# Traffic flows: Internet → NGINX:80 → Node.js:3000
```

## 🔍 Monitoring & Logging

### CloudWatch Logs:
- **Team A**: `/ecs/team-a-task`
- **Team B**: `/ecs/team-b-task` (with Container Insights)

### Viewing Logs:
```bash
# Team A logs
aws logs tail /ecs/team-a-task --follow

# Team B logs (separate streams)
aws logs tail /ecs/team-b-task --follow --log-stream-prefix node-app
aws logs tail /ecs/team-b-task --follow --log-stream-prefix nginx-proxy
```

## 🧹 Cleanup

### Destroy Team A Infrastructure:
```bash
cd Teams/A
terraform destroy
```

### Destroy Team B Infrastructure:
```bash
cd Teams/B
terraform destroy
```

## 🔒 Security Considerations

⚠️ **Important**: The default security groups allow ALL traffic (0.0.0.0/0). For production use:

1. Restrict inbound rules to specific ports/sources
2. Implement least-privilege access
3. Use AWS Systems Manager Session Manager for EC2 access
4. Enable VPC Flow Logs
5. Configure AWS Config rules

### Example Production Security Group:
```hcl
# In your sg module variables
ingress_rules = [
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]
```

## 🎯 Use Case Examples

### Development Workflow (Team A):
1. **Deploy infrastructure**: `terraform apply`
2. **SSH to EC2**: Test applications directly
3. **Deploy to ECS**: Containerized testing
4. **Iterate**: Modify and redeploy

### Production Deployment (Team B):
1. **Deploy ECS cluster**: `terraform apply`
2. **Monitor containers**: CloudWatch + Container Insights
3. **Scale horizontally**: Increase `desired_count`
4. **Update applications**: New container images

## 🔄 CI/CD Integration

### GitHub Actions Example:
```yaml
name: Deploy Infrastructure
on:
  push:
    branches: [main]

jobs:
  deploy-team-a:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
      - name: Deploy Team A
        run: |
          cd Teams/A
          terraform init
          terraform apply -auto-approve
```

## 📚 Additional Resources

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Fargate Pricing](https://aws.amazon.com/fargate/pricing/)
- [Container Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)

---

**Need Help?** Check the individual team README files in `Teams/A/README.md` and `Teams/B/README.md` for detailed configurations.