# modules/ecs-fargate/variables.tf

variable "project_name" {
  description = "Name prefix for resources."
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "public_subnets" {
  description = "IDs of the public subnets."
  type        = list(string)
}

variable "private_subnets" {
  description = "IDs of the private subnets."
  type        = list(string)
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository for Medusa."
  type        = string
}

variable "medusa_server_port" {
  description = "Port Medusa server listens on inside the container."
  type        = number
}

variable "alb_port" {
  description = "Port the ALB listens on for HTTP traffic."
  type        = number
}

variable "alb_health_check_path" {
  description = "Path for ALB health checks."
  type        = string
}

variable "rds_endpoint" {
  description = "RDS PostgreSQL endpoint."
  type        = string
  sensitive   = true
}

variable "rds_port" {
  description = "RDS PostgreSQL port."
  type        = number
}

variable "db_username" {
  description = "Username for the PostgreSQL database."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the PostgreSQL database."
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Name of the PostgreSQL database."
  type        = string
}

variable "redis_endpoint" {
  description = "ElastiCache Redis endpoint."
  type        = string
  sensitive   = true
}

variable "redis_port" {
  description = "ElastiCache Redis port."
  type        = number
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for uploads."
  type        = string
}

variable "s3_bucket_region" {
  description = "Region of the S3 bucket."
  type        = string
}

variable "s3_access_policy_arn" {
  description = "ARN of the S3 access policy for ECS tasks."
  type        = string
}

variable "store_cors" {
  description = "CORS origin for the storefront (e.g., 'http://localhost:8000,*')."
  type        = string
}

variable "admin_cors" {
  description = "CORS origin for the admin (e.g., 'http://localhost:7000,*')."
  type        = string
}