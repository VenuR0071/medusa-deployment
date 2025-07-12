# variables.tf

variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "ap-south-1" # Chennai, India
}

variable "project_name" {
  description = "Name prefix for all resources."
  type        = string
  default     = "medusa-commerce"
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# RDS Variables
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
  default     = "medusadb"
}

variable "db_engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "14.7"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the database (GB)."
  type        = number
  default     = 20
}

# ElastiCache (Redis) Variables
variable "redis_node_type" {
  description = "Redis cache node type."
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_nodes" {
  description = "Number of Redis cache nodes."
  type        = number
  default     = 1
}

# ECS Fargate Variables
variable "ecr_repository_name" {
  description = "Name of the ECR repository for Medusa."
  type        = string
  default     = "medusa-backend"
}

variable "medusa_server_port" {
  description = "Port Medusa server listens on inside the container."
  type        = number
  default     = 9000
}

variable "alb_port" {
  description = "Port the ALB listens on for HTTP traffic."
  type        = number
  default     = 80
}

variable "alb_health_check_path" {
  description = "Path for ALB health checks."
  type        = string
  default     = "/health" # Medusa's default health check endpoint
}

variable "store_cors" {
  description = "CORS origin for the storefront (e.g., 'http://localhost:8000,*')."
  type        = string
}

variable "admin_cors" {
  description = "CORS origin for the admin (e.g., 'http://localhost:7000,*')."
  type        = string
}