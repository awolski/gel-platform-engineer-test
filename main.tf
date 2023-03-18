provider "aws" {
  region = local.region
}

locals {
  region      = "eu-west-2"
  name_prefix = "${var.namespace}-${var.name}-${random_string.unique_id.id}"

  bucket_a_name  = "${local.name_prefix}-bucket-a"
  bucket_b_name  = "${local.name_prefix}-bucket-b"
  lambda_archive = "${path.module}/lambda/image_processor.zip"

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
  bucket = local.bucket_a_name

  tags = merge(local.tags, { Name = local.bucket_a_name })
}

# bucket notification
# iam policy granting bucket access to trigger Lambda
# ...

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
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/image_processor.py"
  output_path = local.lambda_archive
}

resource "aws_lambda_function" "test_lambda" {
  filename      = local.lambda_archive
  function_name = "image_processor"
  role          = aws_iam_role.lambda.arn
  handler       = "handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

################################################################################
# Bucket B
################################################################################

resource "aws_s3_bucket" "b" {
  bucket = local.bucket_b_name

  tags = merge(local.tags, { Name = local.bucket_b_name })
}

# ...


################################################################################
# Supporting Resources
################################################################################

# todo
# ...
