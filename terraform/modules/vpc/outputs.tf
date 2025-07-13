
    output "vpc_id" {
      description = "The ID of the VPC."
      value       = aws_vpc.main.id
    }

    output "public_subnet_ids" {
      description = "List of IDs of public subnets."
      value       = aws_subnet.public[*].id
    }

    output "private_subnet_ids" {
      description = "List of IDs of private subnets."
      value       = aws_subnet.private[*].id
    }

    output "database_subnet_ids" {
      description = "List of IDs of database subnets."
      value       = aws_subnet.database[*].id
    }

    output "app_security_group_id" {
      description = "The ID of the application security group."
      value       = aws_security_group.app.id
    }

    output "db_security_group_id" {
      description = "The ID of the database security group."
      value       = aws_security_group.db.id
    }

    output "redis_security_group_id" {
      description = "The ID of the Redis security group."
      value       = aws_security_group.redis.id
    }

    output "alb_security_group_id" {
      description = "The ID of the ALB security group."
      value       = aws_security_group.alb.id
    }

