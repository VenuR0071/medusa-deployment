# modules/rds/variables.tf

variable "project_name" {
  description = "Name prefix for resources."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "private_subnets" {
  description = "IDs of the private subnets."
  type        = list(string)
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

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage for the database (GB)."
  type        = number
}