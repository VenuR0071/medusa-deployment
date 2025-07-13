
    output "redis_endpoint" {
      description = "The primary endpoint address of the ElastiCache Redis cluster."
      value       = aws_elasticache_replication_group.main.primary_endpoint_address
    }
 
