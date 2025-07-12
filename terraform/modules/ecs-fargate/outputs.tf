# modules/ecs-fargate/outputs.tf

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.medusa_alb.dns_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository."
  value       = aws_ecr_repository.medusa_backend.repository_url
}