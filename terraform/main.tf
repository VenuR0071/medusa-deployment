terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "venur0071-medusa" # <-- REPLACE with your S3 bucket name
    key            = "medusa-commerce/terraform.tfstate"
    region         = "ap-south-1" # <-- REPLACE with your chosen AWS region
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

    # --- VPC Module ---
    module "vpc" {
      source = "./modules/vpc"
      project_name = var.project_name
      vpc_cidr_block = "10.0.0.0/16"
      public_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
      private_subnet_cidr_blocks = ["10.0.11.0/24", "10.0.12.0/24"]
      database_subnet_cidr_blocks = ["10.0.21.0/24", "10.0.22.0/24"]
      aws_region = var.aws_region
    }

    # --- RDS Module (PostgreSQL) ---
    module "rds" {
      source = "./modules/rds"
      project_name = var.project_name
      vpc_id = module.vpc.vpc_id
      database_subnet_ids = module.vpc.database_subnet_ids
      db_instance_type = "db.t3.micro" # Or db.t4g.micro for Graviton
      db_allocated_storage = 20
      db_engine_version = "14" # Confirm a recent PostgreSQL version
      db_username = var.db_username
      db_password = var.db_password
      vpc_security_group_ids = [module.vpc.db_security_group_id]
    }

    # --- ElastiCache Module (Redis) ---
    module "elasticache" {
      source = "./modules/elasticache"
      project_name = var.project_name
      vpc_id = module.vpc.vpc_id
      private_subnet_ids = module.vpc.private_subnet_ids
      redis_node_type = "cache.t3.micro" # Or cache.t4g.micro for Graviton
      vpc_security_group_ids = [module.vpc.redis_security_group_id]
    }

    # --- S3 Bucket Module for Medusa Uploads ---
    module "s3_bucket" {
      source = "./modules/s3-bucket"
      project_name = var.project_name
      aws_region = var.aws_region
    }

    # --- ECS Fargate Module ---
    module "ecs_fargate" {
      source = "./modules/ecs-fargate"
      project_name = var.project_name
      vpc_id = module.vpc.vpc_id
      public_subnet_ids = module.vpc.public_subnet_ids
      private_subnet_ids = module.vpc.private_subnet_ids
      app_security_group_id = module.vpc.app_security_group_id
      alb_sg_id = module.vpc.alb_security_group_id
      db_endpoint = module.rds.rds_endpoint
      redis_endpoint = module.elasticache.redis_endpoint
      s3_bucket_name = module.s3_bucket.bucket_id
      s3_region = module.s3_bucket.bucket_region
      store_cors = var.store_cors
      admin_cors = var.admin_cors
      auth_cors = var.auth_cors # NEW for Medusa v2
      db_username = var.db_username
      db_password = var.db_password
    }
