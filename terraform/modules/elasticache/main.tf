
    resource "aws_elasticache_subnet_group" "main" {
      name       = "${var.project_name}-redis-subnet-group"
      subnet_ids = var.private_subnet_ids
 
      tags = {
        Name = "${var.project_name}-redis-subnet-group"
      }
    }



    resource "aws_elasticache_replication_group" "main" {
      replication_group_id          = "${var.project_name}-medusa-redis-rg"
      description                   = "Medusa Redis replication group"
      engine                        = "redis"
      engine_version                = "6.x" # Match cluster engine version
      node_type                     = var.redis_node_type
      num_cache_clusters            = 1 # Number of shards (clusters in replication group)
      parameter_group_name          = "default.redis6.x"
      port                          = 6379
      subnet_group_name             = aws_elasticache_subnet_group.main.name
      security_group_ids            = var.vpc_security_group_ids
      automatic_failover_enabled    = false # Set to true for multi-AZ in production
      snapshot_retention_limit      = 0 # Disable snapshots for non-critical data
      snapshot_window               = "00:00-01:00" # Dummy value if snapshot_retention_limit is 0
      tags = {
        Name = "${var.project_name}-medusa-redis-rg"
      }
    }

