# modules/elasticache/variables.tf

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

variable "cache_node_type" {
  description = "Redis cache node type."
  type        = string
}

variable "num_cache_nodes" {
  description = "Number of Redis cache nodes."
  type        = number
}