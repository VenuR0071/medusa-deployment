# main.tf

provider "aws" {
  region = var.aws_region
}

# --- Module Calls ---

module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
}

module "rds" {
  source = "./modules/rds"

  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  private_subnets   = module.vpc.private_subnets
  db_username       = var.db_username
  db_password       = var.db_password
  db_name           = var.db_name
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
}

module "elasticache" {
  source = "./modules/elasticache"

  project_name    = var.project_name
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  cache_node_type = var.redis_node_type
  num_cache_nodes = var.redis_num_nodes
}

module "s3_bucket" {
  source = "./modules/s3-bucket"

  project_name = var.project_name
}

module "ecs_fargate" {
  source = "./modules/ecs-fargate"

  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  public_subnets        = module.vpc.public_subnets
  private_subnets       = module.vpc.private_subnets
  ecr_repository_name   = var.ecr_repository_name
  medusa_server_port    = var.medusa_server_port
  alb_port              = var.alb_port
  alb_health_check_path = var.alb_health_check_path
  rds_endpoint          = module.rds.rds_endpoint
  rds_port              = module.rds.rds_port
  db_username           = var.db_username
  db_password           = var.db_password
  db_name               = var.db_name
  redis_endpoint        = module.elasticache.redis_endpoint
  redis_port            = module.elasticache.redis_port
  s3_bucket_name        = module.s3_bucket.bucket_id
  s3_bucket_region      = var.aws_region
  store_cors            = var.store_cors
  admin_cors            = var.admin_cors
}