
    resource "aws_db_subnet_group" "main" {
      name       = "${var.project_name}-db-subnet-group"
      subnet_ids = var.database_subnet_ids

      tags = {
        Name = "${var.project_name}-db-subnet-group"
      }
    }

    resource "aws_db_instance" "main" {
      allocated_storage    = var.db_allocated_storage
      engine               = "postgres"
      engine_version       = var.db_engine_version
      instance_class       = var.db_instance_type
      identifier           = "${var.project_name}-medusa-db"
      name                 = "${var.project_name}-medusa-db"
      username             = var.db_username
      password             = var.db_password
      db_subnet_group_name = aws_db_subnet_group.main.name
      vpc_security_group_ids = var.vpc_security_group_ids
      skip_final_snapshot = true # Set to false in production
      publicly_accessible = false
      storage_type = "gp2" # General Purpose SSD
      multi_az = false # Set to true for high availability in production
      port = 5432
      final_snapshot_identifier = "${var.project_name}-final-snapshot" # Required if skip_final_snapshot is false
      deletion_protection = false # Set to true in production
    }

