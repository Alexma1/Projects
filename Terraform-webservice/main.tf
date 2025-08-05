terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source               = "../../modules/vpc"
  cidr_block           = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnets
  private_subnet_cidrs = var.private_subnets
}

module "security_groups" {
  source = "../../modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

module "rds" {
  source            = "../../modules/rds"
  subnet_ids        = module.vpc.private_subnet_ids
  vpc_security_group= module.security_groups.sg_db_id
  db_username       = var.db_username
  db_password       = var.db_password
  allocated_storage = var.db_allocated_storage
  engine            = var.db_engine
  instance_class    = var.db_instance_class
}

module "s3" {
  source      = "../../modules/s3"
  bucket_name = "${var.zone_name}-assets"
}

module "route53" {
  source       = "../../modules/route53"
  record_name  = var.record_name
  alb_dns_name = module.alb.alb_web_dns
  alb_zone_id  = module.alb.alb_web_zone_id
  zone_name    = var.zone_name
}