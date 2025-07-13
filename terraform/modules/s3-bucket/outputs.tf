
    output "bucket_id" {
      description = "The ID (name) of the S3 bucket."
      value       = aws_s3_bucket.main.id
    }

    output "bucket_region" {
      description = "The region of the S3 bucket."
      value       = aws_s3_bucket.main.region
    }
