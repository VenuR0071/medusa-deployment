# modules/rds/outputs.tf

output "rds_endpoint" {
  description = "The DNS address of the RDS instance."
  value       = aws_db_instance.medusa_db.address
  sensitive   = true
}

output "rds_port" {
  description = "The port of the RDS instance."
  value       = aws_db_instance.medusa_db.port
}

output "rds_security_group_id" {
  description = "The security group ID of the RDS instance."
  value       = aws_security_group.rds.id
}