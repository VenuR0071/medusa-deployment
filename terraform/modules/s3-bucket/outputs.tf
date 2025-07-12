# modules/s3-bucket/outputs.tf

output "bucket_id" {
  description = "The ID of the S3 bucket."
  value       = aws_s3_bucket.medusa_uploads.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.medusa_uploads.arn
}

output "s3_policy_arn" {
  value = aws_iam_policy.s3_access_policy.arn
}