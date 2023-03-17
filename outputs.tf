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
  value       = aws_s3_bucket.a.id
}
