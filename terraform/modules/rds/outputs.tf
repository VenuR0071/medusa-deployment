
    output "rds_endpoint" {
      description = "The endpoint address of the RDS instance."
      value       = aws_db_instance.main.address
    }
