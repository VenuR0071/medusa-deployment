# modules/elasticache/outputs.tf

output "redis_endpoint" {
  description = "The DNS address of the ElastiCache Redis cluster."
  value       = aws_elasticache_cluster.medusa_redis.cache_nodes[0].address
  sensitive   = true
}

output "redis_port" {
  description = "The port of the ElastiCache Redis cluster."
  value       = aws_elasticache_cluster.medusa_redis.port
}

output "redis_security_group_id" {
  description = "The security group ID of the ElastiCache Redis cluster."
  value       = aws_security_group.elasticache.id
}