# modules/vpc/outputs.tf

output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "IDs of the private subnets."
  value       = aws_subnet.private[*].id
}

output "private_subnet_ids_string" {
  description = "Comma-separated string of private subnet IDs for use in ECS task definitions."
  value       = join(",", aws_subnet.private[*].id)
}