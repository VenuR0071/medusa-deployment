
    variable "project_name" {
      description = "The name of the project."
      type        = string
    }

    variable "vpc_cidr_block" {
      description = "The CIDR block for the VPC."
      type        = string
    }

    variable "public_subnet_cidr_blocks" {
      description = "List of CIDR blocks for public subnets."
      type        = list(string)
    }

    variable "private_subnet_cidr_blocks" {
      description = "List of CIDR blocks for private subnets."
      type        = list(string)
    }

    variable "database_subnet_cidr_blocks" {
      description = "List of CIDR blocks for database subnets."
      type        = list(string)
    }

    variable "aws_region" {
      description = "The AWS region."
      type        = string
    }
    
