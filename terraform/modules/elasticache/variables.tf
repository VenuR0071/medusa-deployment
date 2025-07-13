
    variable "project_name" {
      description = "The name of the project."
      type        = string
    }

    variable "vpc_id" {
      description = "The ID of the VPC."
      type        = string
    }

    variable "private_subnet_ids" {
      description = "List of private subnet IDs."
      type        = list(string)
    }

    variable "redis_node_type" {
      description = "The node type for the ElastiCache Redis cluster."
      type        = string
    }

    variable "vpc_security_group_ids" {
      description = "List of security group IDs to associate with the Redis cluster."
      type        = list(string)
    }
   

