
    resource "aws_s3_bucket" "main" {
      bucket = "${var.project_name}-medusa-uploads-${var.aws_region}-${random_string.suffix.result}" # Unique bucket name

      tags = {
        Name = "${var.project_name}-medusa-uploads"
      }
    }

    resource "random_string" "suffix" {
      length  = 6
      special = false
      upper   = false
      numeric = true
    }



    resource "aws_s3_bucket_versioning" "main_versioning" {
      bucket = aws_s3_bucket.main.id
      versioning_configuration {
        status = "Enabled"
      }
    }
