
    output "alb_dns_name" {
      description = "The DNS name of the Application Load Balancer."
      value       = aws_lb.medusa_backend.dns_name
    }

    output "ecr_repository_url" {
      description = "The URL of the ECR repository for the Medusa backend image."
      value       = aws_ecr_repository.medusa_backend.repository_url
    }

    output "task_definition_arn" {
      description = "The ARN of the ECS task definition."
      value       = aws_ecs_task_definition.medusa_backend.arn
    }
