
    # Add these two variable blocks to terraform/modules/ecs-fargate/variables.tf
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
    variable "project_name" {
      description = "The name of the project."
      type        = string
    }

    variable "vpc_id" {
      description = "The ID of the VPC."
      type        = string
    }

    variable "public_subnet_ids" {
      description = "List of public subnet IDs."
      type        = list(string)
    }

    variable "private_subnet_ids" {
      description = "List of private subnet IDs."
      type        = list(string)
    }

    variable "app_security_group_id" {
      description = "The ID of the application security group."
      type        = string
    }

    variable "alb_sg_id" {
      description = "The ID of the ALB security group."
      type        = string
    }

    variable "db_endpoint" {
      description = "The endpoint of the RDS PostgreSQL instance."
      type        = string
    }

    variable "redis_endpoint" {
      description = "The endpoint of the ElastiCache Redis instance."
      type        = string
    }

    variable "s3_bucket_name" {
      description = "The name of the S3 bucket for uploads."
      type        = string
    }

    variable "s3_region" {
      description = "The region of the S3 bucket."
      type        = string
    }

    variable "store_cors" {
      description = "Comma-separated list of allowed origins for store API CORS."
      type        = string
    }

    variable "admin_cors" {
      description = "Comma-separated list of allowed origins for admin API CORS."
      type        = string
    }

    variable "auth_cors" { # NEW for Medusa v2
      description = "Comma-separated list of allowed origins for authentication API CORS."
      type        = string
    }

