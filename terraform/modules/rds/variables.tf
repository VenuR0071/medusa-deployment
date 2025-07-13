
    variable "project_name" {
      description = "The name of the project."
      type        = string
    }

    variable "vpc_id" {
      description = "The ID of the VPC."
      type        = string
    }

    variable "database_subnet_ids" {
      description = "List of database subnet IDs."
      type        = list(string)
    }

    variable "db_instance_type" {
      description = "The instance type for the RDS database."
      type        = string
    }

    variable "db_allocated_storage" {
      description = "The allocated storage in GB for the RDS database."
      type        = number
    }

    variable "db_engine_version" {
      description = "The engine version for the PostgreSQL database."
      type        = string
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

    variable "vpc_security_group_ids" {
      description = "List of security group IDs to associate with the RDS instance."
      type        = list(string)
    }
