
    variable "aws_region" {
      description = "The AWS region to deploy resources to."
      type        = string
      default     = "ap-south-1" # Set your default region here
    }

    variable "project_name" {
      description = "A unique name for your project, used as a prefix for resources."
      type        = string
      default     = "medusa-commerce" # Your desired project prefix
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
    variable "aws_access_key_id" {
  description = "AWS Access Key ID for AWS CLI/Terraform."
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key for AWS CLI/Terraform."
  type        = string
  sensitive   = true
}
