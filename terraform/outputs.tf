
    output "alb_dns_name" {
      description = "The DNS name of the Application Load Balancer."
      value       = module.ecs_fargate.alb_dns_name
    }

    output "rds_endpoint" {
      description = "The endpoint of the RDS PostgreSQL instance."
      value       = module.rds.rds_endpoint
    }

    output "redis_endpoint" {
      description = "The endpoint of the ElastiCache Redis instance."
      value       = module.elasticache.redis_endpoint
    }

    output "ecr_repository_url" {
      description = "The URL of the ECR repository."
      value       = module.ecs_fargate.ecr_repository_url
    }

    output "s3_bucket_name" {
      description = "The name of the S3 bucket created for Medusa uploads."
      value       = module.s3_bucket.bucket_id
    }

