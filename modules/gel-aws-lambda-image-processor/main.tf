locals {
  iam_role_name   = "${var.name_prefix}-lambda-role"
  iam_policy_name = "${var.name_prefix}-lambda-policy"
  lambda_name     = "${var.name_prefix}-lambda"
}

data "aws_s3_bucket" "bucket_a" {
  bucket = var.bucket_a_name
}

data "aws_s3_bucket" "bucket_b" {
  bucket = var.bucket_b_name
}

################################################################################
# IAM
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

    resources = ["${data.aws_s3_bucket.bucket_a.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject"
    ]

    resources = ["${data.aws_s3_bucket.bucket_b.arn}/*"]
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
  content = templatefile("${path.module}/image_processor.py.tftpl", {
    target_bucket = var.bucket_b_name
  })
  filename = "${var.build_path}/image_processor.py"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = var.build_path
  output_path = "${var.deployment_package_path}/image_processor.zip"

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
  source_arn    = data.aws_s3_bucket.bucket_a.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bucket_a_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpg"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
