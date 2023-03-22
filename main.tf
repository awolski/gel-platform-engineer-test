provider "aws" {
  region = local.region
}

locals {
  region      = "eu-west-2"
  name_prefix = "${var.namespace}-${var.name}-${random_string.unique_id.id}"

  bucket_a_name   = "${local.name_prefix}-bucket-a"
  bucket_b_name   = "${local.name_prefix}-bucket-b"
  iam_role_name   = "${local.name_prefix}-lambda-role"
  iam_policy_name = "${local.name_prefix}-lambda-policy"
  lambda_name     = "${local.name_prefix}-lambda"

  tags = {
    Namespace = var.namespace
    Name      = var.name
    UniqueID  = random_string.unique_id.id
  }
}

resource "random_string" "unique_id" {
  length  = 12
  special = false
  upper   = false
}

################################################################################
# Bucket A
################################################################################

resource "aws_s3_bucket" "a" {
  bucket        = local.bucket_a_name
  force_destroy = true

  tags = merge(local.tags, { Name = local.bucket_a_name })
}

################################################################################
# Bucket B
################################################################################

resource "aws_s3_bucket" "b" {
  bucket        = local.bucket_b_name
  force_destroy = true

  tags = merge(local.tags, { Name = local.bucket_b_name })
}

################################################################################
# Lambda
################################################################################

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = local.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "lambda" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = ["${aws_s3_bucket.a.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject"
    ]

    resources = ["${aws_s3_bucket.b.arn}/*"]
  }
}

resource "aws_iam_policy" "lambda" {
  name        = local.iam_policy_name
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

resource "local_file" "lambda_function" {
  content = templatefile("${path.module}/templates/image_processor.py.tftpl", {
    target_bucket = aws_s3_bucket.b.id
  })
  filename = "${path.module}/lib/image_processor.py"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lib"
  output_path = "${path.module}/build/image_processor.zip"

  depends_on = [
    local_file.lambda_function
  ]
}

resource "aws_lambda_function" "lambda" {
  filename         = data.archive_file.lambda.output_path
  function_name    = local.lambda_name
  role             = aws_iam_role.lambda.arn
  handler          = "image_processor.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "python3.9"
  timeout          = 10
  memory_size      = 256
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.a.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.a.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpg"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
