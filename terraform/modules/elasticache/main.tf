# modules/elasticache/main.tf

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-elasticache-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "${var.project_name}-elasticache-subnet-group"
  }
}

resource "aws_security_group" "elasticache" {
  name_prefix = "${var.project_name}-elasticache-sg-"
  description = "Allow inbound traffic to ElastiCache from ECS Fargate tasks."
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379 # Redis default port
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [data.aws_security_group.ecs_fargate_tasks.id] # Allow from ECS tasks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-elasticache-sg"
  }
}

resource "aws_elasticache_cluster" "medusa_redis" {
  cluster_id           = "${var.project_name}-medusa-redis"
  engine               = "redis"
  node_type            = var.cache_node_type
  num_cache_nodes      = var.num_cache_nodes
  port                 = 6379
  parameter_group_name = "default.redis6.x" # Adjust based on desired Redis version
  engine_version       = "6.x"
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.elasticache.id]

  tags = {
    Name = "${var.project_name}-medusa-redis"
  }
}

# Data source to fetch ECS Fargate tasks security group created in ecs-fargate module
data "aws_security_group" "ecs_fargate_tasks" {
  count = length(var.private_subnets) > 0 ? 1 : 0 # Only fetch if private subnets exist
  name = "${var.project_name}-ecs-fargate-tasks-sg"
  vpc_id = var.vpc_id
}