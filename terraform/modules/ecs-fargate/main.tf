# modules/ecs-fargate/main.tf

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

resource "aws_ecr_repository" "medusa_backend" {
  name = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.ecr_repository_name
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_s3_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = var.s3_access_policy_arn
}


resource "aws_security_group" "ecs_fargate_tasks" {
  name_prefix = "${var.project_name}-ecs-fargate-tasks-sg-"
  description = "Security group for ECS Fargate tasks."
  vpc_id      = var.vpc_id

  # Allow inbound from ALB
  ingress {
    from_port       = var.medusa_server_port
    to_port         = var.medusa_server_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow traffic from ALB"
  }

  # Allow outbound to RDS, ElastiCache, and NAT Gateway
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allows outbound to internet (via NAT Gateway) and internal resources
  }

  tags = {
    Name = "${var.project_name}-ecs-fargate-tasks-sg"
  }
}

resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-sg-"
  description = "Security group for ALB."
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.alb_port
    to_port     = var.alb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow all inbound HTTP traffic
    description = "Allow HTTP access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

resource "aws_lb" "medusa_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnets

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_lb_target_group" "medusa_tg" {
  name        = "${var.project_name}-medusa-tg"
  port        = var.medusa_server_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.alb_health_check_path
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-medusa-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.medusa_alb.arn
  port              = var.alb_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.medusa_tg.arn
    type             = "forward"
  }
}

resource "aws_cloudwatch_log_group" "medusa_logs" {
  name              = "/ecs/${var.project_name}-medusa"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-medusa-logs"
  }
}

resource "aws_ecs_task_definition" "medusa_backend" {
  family                   = "${var.project_name}-medusa-backend"
  cpu                      = "1024" # 1 vCPU
  memory                   = "2048" # 2 GB RAM (Recommended 2GB+ for Medusa)
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn # Same for simplicity, can be separated

  container_definitions = jsonencode([
    {
      name        = "medusa-backend"
      image       = "${aws_ecr_repository.medusa_backend.repository_url}:latest" # Placeholder, updated by CD
      cpu         = 1024
      memory      = 2048
      essential   = true
      portMappings = [
        {
          containerPort = var.medusa_server_port
          hostPort      = var.medusa_server_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "PORT"
          value = "${var.medusa_server_port}"
        },
        {
          name  = "DATABASE_URL"
          value = "postgres://${var.db_username}:${var.db_password}@${var.rds_endpoint}:${var.rds_port}/${var.db_name}"
        },
        {
          name  = "REDIS_URL"
          value = "redis://${var.redis_endpoint}:${var.redis_port}"
        },
        {
          name  = "S3_URL"
          value = "https://${var.s3_bucket_name}.s3.${var.s3_bucket_region}.amazonaws.com"
        },
        {
          name  = "S3_ENDPOINT"
          value = "https://s3.${var.s3_bucket_region}.amazonaws.com"
        },
        {
          name  = "S3_BUCKET"
          value = var.s3_bucket_name
        },
        {
          name  = "S3_REGION"
          value = var.s3_bucket_region
        },
        # AWS Access Key ID and Secret Access Key will be picked up by the ECS task role
        # from the attached policy's permissions. No need to pass explicitly unless for specific scenarios.
        # {
        #   name  = "AWS_ACCESS_KEY_ID"
        #   value = "..." # Not recommended to hardcode or pass directly
        # },
        # {
        #   name  = "AWS_SECRET_ACCESS_KEY"
        #   value = "..." # Not recommended to hardcode or pass directly
        # },
        {
          name  = "STORE_CORS"
          value = var.store_cors
        },
        {
          name  = "ADMIN_CORS"
          value = var.admin_cors
        },
        {
          name  = "MEDUSA_WORKER_MODE"
          value = "server" # Or "worker" for a dedicated worker service
        },
        {
          name  = "DISABLE_MEDUSA_ADMIN"
          value = "false" # Set to "true" for a dedicated worker service if Admin is not needed there
        },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.medusa_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "medusa_backend_service" {
  name            = "${var.project_name}-medusa-backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.medusa_backend.arn
  desired_count   = 1 # Start with 1, scale as needed
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_fargate_tasks.id]
    assign_public_ip = false # Fargate tasks in private subnets, accessed via ALB
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.medusa_tg.arn
    container_name   = "medusa-backend"
    container_port   = var.medusa_server_port
  }

  depends_on = [
    aws_lb_listener.http
  ]

  tags = {
    Name = "${var.project_name}-medusa-backend-service"
  }
}