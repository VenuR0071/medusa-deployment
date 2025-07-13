
    resource "aws_ecr_repository" "medusa_backend" {
      name                 = "medusa-backend" # This name should match your GitHub Action's ECR_REPOSITORY
      image_tag_mutability = "MUTABLE" # Or IMMUTABLE if you want strict tag immutability
      image_scanning_configuration {
        scan_on_push = true
      }

      tags = {
        Name = "${var.project_name}-ecr-medusa-backend"
      }
    }

    resource "aws_ecs_cluster" "main" {
      name = "${var.project_name}-cluster"

      tags = {
        Name = "${var.project_name}-cluster"
      }
    }

    resource "aws_cloudwatch_log_group" "medusa_backend" {
      name              = "/ecs/medusa-backend"
      retention_in_days = 7 # Adjust as needed

      tags = {
        Name = "${var.project_name}-backend-logs"
      }
    }
    # Add this block:
locals {
  full_database_url = "postgresql://${var.db_username}:${var.db_password}@${var.db_endpoint}:5432/medusadb"
}

    resource "aws_iam_role" "ecs_task_execution_role" {
      name = "${var.project_name}-ecsTaskExecutionRole"

      assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Action = "sts:AssumeRole",
            Effect = "Allow",
            Principal = {
              Service = "ecs-tasks.amazonaws.com"
            }
          }
        ]
      })

      tags = {
        Name = "${var.project_name}-ecs-exec-role"
      }
    }

    resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
      role       = aws_iam_role.ecs_task_execution_role.name
      policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    }

    # IAM Role for Medusa application (for S3 access)
    resource "aws_iam_role" "medusa_app_role" {
      name = "${var.project_name}-medusaAppRole"

      assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Action = "sts:AssumeRole",
            Effect = "Allow",
            Principal = {
              Service = "ecs-tasks.amazonaws.com"
            }
          }
        ]
      })

      tags = {
        Name = "${var.project_name}-medusa-app-role"
      }
    }

    resource "aws_iam_policy" "s3_access_policy" {
      name        = "${var.project_name}-MedusaS3AccessPolicy"
      description = "IAM policy for Medusa backend to access S3 bucket"

      policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Effect   = "Allow",
            Action   = [
              "s3:GetObject",
              "s3:PutObject",
              "s3:DeleteObject",
              "s3:ListBucket"
            ],
            Resource = [
              "arn:aws:s3:::${var.s3_bucket_name}",
              "arn:aws:s3:::${var.s3_bucket_name}/*"
            ]
          }
        ]
      })
    }

    resource "aws_iam_role_policy_attachment" "medusa_s3_policy_attachment" {
      role       = aws_iam_role.medusa_app_role.name
      policy_arn = aws_iam_policy.s3_access_policy.arn
    }


    resource "aws_ecs_task_definition" "medusa_backend" {
      family                   = "${var.project_name}-medusa-backend-task"
      cpu                      = "1024" # 1 vCPU
      memory                   = "2048" # 2GB RAM
      network_mode             = "awsvpc"
      requires_compatibilities = ["FARGATE"]
      execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
      task_role_arn            = aws_iam_role.medusa_app_role.arn # Assign custom role for S3 access
      container_definitions    = jsonencode([
        {
          name      = "medusa-backend", # This name MUST match ECS_CONTAINER_NAME in GitHub Action
          image     = "${aws_ecr_repository.medusa_backend.repository_url}:latest", # Placeholder for initial run
          cpu       = 1024,
          memory    = 2048,
          essential = true,

          # ADD THIS LINE TEMPORARILY FOR MIGRATIONS:
          portMappings = [
            {
              containerPort = 9000,
              hostPort      = 9000,
              protocol      = "tcp"
            }
          ],
          logConfiguration = {
            logDriver = "awslogs",
            options   = {
              "awslogs-group"         = aws_cloudwatch_log_group.medusa_backend.name,
              "awslogs-region"        = var.s3_region,
              "awslogs-stream-prefix" = "ecs"
            }
          },
          environment = [
            {
              name  = "DATABASE_URL",
              value = "postgresql://${var.db_username}:${var.db_password}@${var.db_endpoint}:5432/medusadb"
            },
            {
              name  = "REDIS_URL",
              value = "redis://${var.redis_endpoint}:6379"
            },
            {
              name  = "S3_BUCKET",
              value = var.s3_bucket_name
            },
            {
              name  = "S3_REGION",
              value = var.s3_region
            },
            {
              name  = "STORE_CORS",
              value = var.store_cors
            },
            {
              name  = "ADMIN_CORS",
              value = var.admin_cors
            },
            {
              name  = "AUTH_CORS", # NEW for Medusa v2
              value = var.auth_cors
            },
            {
              name  = "JWT_SECRET",
              value = "supersecret-jwt-key" # CHANGE IN PRODUCTION! Use AWS Secrets Manager.
            },
            {
              name  = "COOKIE_SECRET",
              value = "supersecret-cookie-key" # CHANGE IN PRODUCTION! Use AWS Secrets Manager.
            },
            {
              name  = "NODE_ENV",
              value = "production"
            }
          ]
        }
      ])
    }

    resource "aws_lb" "medusa_backend" {
      name               = "${var.project_name}-alb"
      internal           = false
      load_balancer_type = "application"
      security_groups    = [var.alb_sg_id]
      subnets            = var.public_subnet_ids # ALB is typically in public subnets

      tags = {
        Name = "${var.project_name}-alb"
      }
    }

    resource "aws_lb_target_group" "medusa_backend" {
      name        = "${var.project_name}-tg"
      port        = 9000
      protocol    = "HTTP"
      vpc_id      = var.vpc_id
      target_type = "ip" # Required for Fargate

      health_check {
        path                = "/health" # Medusa's health check endpoint
        protocol            = "HTTP"
        matcher             = "200"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }

      tags = {
        Name = "${var.project_name}-tg"
      }
    }

    resource "aws_lb_listener" "http" {
      load_balancer_arn = aws_lb.medusa_backend.arn
      port              = 80
      protocol          = "HTTP"

      default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.medusa_backend.arn
      }
    }

    resource "aws_ecs_service" "medusa_backend" {
      name            = "${var.project_name}-medusa-backend-service"
      cluster         = aws_ecs_cluster.main.id
      task_definition = aws_ecs_task_definition.medusa_backend.arn
      desired_count   = 1 # Start with 1, scale up as needed
      launch_type     = "FARGATE"

      network_configuration {
        subnets          = var.private_subnet_ids # ECS tasks typically run in private subnets
        security_groups  = [var.app_security_group_id]
        assign_public_ip = false # Tasks in private subnets should not have public IPs
      }

      load_balancer {
        target_group_arn = aws_lb_target_group.medusa_backend.arn
        container_name   = "medusa-backend" # MUST match the container name in task definition
        container_port   = 9000
      }

      # Force a new deployment on task definition changes (important for CI/CD)
      force_new_deployment = true

      # Migrations step (pre-deployment hook)
      # This can be integrated as a separate task run, or as part of a pre-hook
      # For simplicity, we'll rely on the GitHub Action to run `predeploy` first.

      tags = {
        Name = "${var.project_name}-medusa-backend-service"
      }
    }
 
