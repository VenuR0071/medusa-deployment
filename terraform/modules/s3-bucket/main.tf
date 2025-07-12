# modules/s3-bucket/main.tf

resource "aws_s3_bucket" "medusa_uploads" {
  bucket = "${var.project_name}-medusa-uploads-${random_string.suffix.result}" # Unique bucket name

  tags = {
    Name = "${var.project_name}-medusa-uploads"
  }
}

resource "aws_s3_bucket_acl" "medusa_uploads_acl" {
  bucket = aws_s3_bucket.medusa_uploads.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "medusa_uploads_public_access" {
  bucket = aws_s3_bucket.medusa_uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

# IAM Policy for S3 access from Medusa ECS Task
resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.project_name}-medusa-s3-access-policy"
  description = "Policy for Medusa ECS tasks to access S3 bucket."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ],
        Resource = [
          aws_s3_bucket.medusa_uploads.arn,
          "${aws_s3_bucket.medusa_uploads.arn}/*",
        ],
      },
    ],
  })
}

output "s3_access_policy_arn" {
  value = aws_iam_policy.s3_access_policy.arn
}