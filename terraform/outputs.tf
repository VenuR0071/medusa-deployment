# outputs.tf

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.ecs_fargate.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint."
  value       = module.rds.rds_endpoint
  sensitive   = true
}

output "redis_endpoint" {
  description = "ElastiCache Redis endpoint."
  value       = module.elasticache.redis_endpoint
  sensitive   = true
}

output "ecr_repository_url" {
  description = "URL of the ECR repository."
  value       = module.ecs_fargate.ecr_repository_url
}