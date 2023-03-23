output "iam_role_name" {
  description = "Name of the Lambda IAM Role"
  value       = aws_iam_role.lambda.name
}

output "iam_policy_name" {
  description = "Name of the Lambda IAM Policy"
  value       = aws_iam_policy.lambda.name
}

output "lambda_name" {
  description = "Name of the image processor lambda"
  value       = aws_lambda_function.lambda.id
}
