# Team B - ECS Only Infrastructure

## 📋 Overview
Team B uses a **containerized-only** infrastructure approach with AWS ECS Fargate for serverless container deployment. No EC2 instances are managed directly.

## 🐳 What Gets Deployed

### Infrastructure Components:
- **ECS Fargate Cluster** - Serverless container platform
- **ECS Service** - Manages 2 Apache HTTPD containers
- **Security Group** - Allows all inbound/outbound traffic
- **IAM Roles** - ECS execution and task permissions
- **CloudWatch Logs** - Container logging and monitoring

### Container Specifications:
- **Image**: `httpd:latest` (Apache Web Server)
- **CPU**: 512 units per task
- **Memory**: 1024 MiB per task
- **Desired Count**: 2 running instances
- **Port**: 80 (HTTP)
- **Public IP**: Enabled
- **Container Insights**: Enabled for monitoring

## 🚀 Deployment Commands

```bash
# Navigate to Team B directory
cd Teams/B

# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply

# View outputs
terraform output
```

## 🔧 Configuration Differences from Team A

| Aspect | Team A | Team B |
|--------|--------|--------|
| **Compute** | EC2 + ECS | ECS Only |
| **Web Server** | NGINX | Apache HTTPD |
| **CPU** | 256 units | 512 units |
| **Memory** | 512 MiB | 1024 MiB |
| **Instances** | 1 | 2 |
| **Environment** | Development | Production |
| **Monitoring** | Disabled | Enabled |

## 🎯 Use Cases
- **Microservices Architecture** - Perfect for containerized applications
- **Auto-scaling Workloads** - ECS handles scaling automatically
- **Cost Optimization** - Pay only for container runtime
- **CI/CD Integration** - Easy container deployments
- **High Availability** - Multiple container instances

## 🔍 Monitoring & Logs
- **CloudWatch Logs**: `/ecs/team-b-task`
- **Container Insights**: Enabled for performance monitoring
- **Service Metrics**: Available in CloudWatch

## 🔒 Security
- Uses the same security group module as Team A
- All inbound/outbound traffic allowed (customize as needed)
- IAM roles follow least-privilege principle for ECS tasks

## 💡 Customization
Modify variables in `variables.tf` or create `terraform.tfvars`:

```hcl
ecs_container_image = "your-custom-image:tag"
ecs_desired_count   = 3
ecs_cpu            = "1024"
ecs_memory         = "2048"
```

----------------- # Split

Each ECS Task now runs 2 containers:

Both containers run in the same task (shared network/storage)
Each container has different images and configurations
Both containers are logged separately in CloudWatch
With desired_count = 2, you'll have 2 tasks × 2 containers = 4 running containers total
🎯 Customization Options:
You can easily change the second container image by updating the ecs_container_definitions variable in your Team B variables.tf. For example, to use a different Node.js version:


{  name      = "node-app-v2"  image     = "uya0/node-example-1:different-tag"  # Different version  # ... rest of config}
🚀 Deploy the Updated Configuration:

cd Teams/Bterraform initterraform plan  # Review the changesterraform apply
📊 Result:
2 ECS tasks (desired_count = 2)
2 containers per task (node-app-v1 and node-app-v2)
Total: 4 running containers with different images
Separate logging for each container type