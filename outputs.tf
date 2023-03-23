output "name_prefix" {
  description = "The name_prefix used for all resources"
  value       = local.name_prefix
}

output "bucket_a_id" {
  description = "Name of bucket A"
  value       = aws_s3_bucket.a.id
}

output "bucket_b_id" {
  description = "Name of bucket B"
  value       = aws_s3_bucket.b.id
}

output "iam_role_name" {
  description = "Name of the Lambda IAM Role"
  value       = module.image_processor.iam_role_name
}

output "iam_policy_name" {
  description = "Name of the Lambda IAM Policy"
  value       = module.image_processor.iam_policy_name
}

output "lambda_name" {
  description = "Name of the image processor lambda"
  value       = module.image_processor.lambda_name
}
