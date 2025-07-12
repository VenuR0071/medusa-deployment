# modules/rds/main.tf

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-rds-sg-"
  description = "Allow inbound traffic to RDS from ECS Fargate tasks."
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432 # PostgreSQL default port
    to_port         = 5432
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
    Name = "${var.project_name}-rds-sg"
  }
}

resource "aws_db_instance" "medusa_db" {
  allocated_storage    = var.db_allocated_storage
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  identifier           = "${var.project_name}-medusa-db"
  username             = var.db_username
  password             = var.db_password
  db_name              = var.db_name
  multi_az             = false # Set to true for higher availability in production
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible  = false # Database should not be publicly accessible
  storage_encrypted    = true
  parameter_group_name = "default.postgres${split(".", var.engine_version)[0]}" # Use correct parameter group for your version

  tags = {
    Name = "${var.project_name}-medusa-db"
  }
}

# Data source to fetch ECS Fargate tasks security group created in ecs-fargate module
data "aws_security_group" "ecs_fargate_tasks" {
  count = length(var.private_subnets) > 0 ? 1 : 0 # Only fetch if private subnets exist
  name = "${var.project_name}-ecs-fargate-tasks-sg"
  vpc_id = var.vpc_id
}