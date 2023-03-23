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

  users = ["a", "b"]

  bucket_permissions = {
    bucket_a = {
      bucket_arn  = aws_s3_bucket.a.arn
      permissions = ["s3:GetObject", "s3:ListBucket", "s3:PutObject"]
      user_arn    = aws_iam_user.user["a"].arn
    },
    bucket_b = {
      bucket_arn  = aws_s3_bucket.b.arn
      permissions = ["s3:GetObject", "s3:ListBucket"]
      user_arn    = aws_iam_user.user["b"].arn
    }
  }

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

module "image_processor" {
  source = "./modules/gel-aws-lambda-image-processor"

  name_prefix             = local.name_prefix
  bucket_a_name           = aws_s3_bucket.a.id
  bucket_b_name           = aws_s3_bucket.b.id
  build_path              = "${path.module}/lib"
  deployment_package_path = "${path.module}/build"
}

################################################################################
# Users
################################################################################

resource "aws_iam_user" "user" {
  for_each = toset(local.users)
  name     = "${local.name_prefix}-user-${each.key}"
}

################################################################################
# Bucket permissions
################################################################################

resource "aws_s3_bucket_policy" "bucket_a" {
  bucket = aws_s3_bucket.a.id
  policy = data.aws_iam_policy_document.bucket_policy["bucket_a"].json
}

resource "aws_s3_bucket_policy" "bucket_b" {
  bucket = aws_s3_bucket.b.id
  policy = data.aws_iam_policy_document.bucket_policy["bucket_b"].json
}

data "aws_iam_policy_document" "bucket_policy" {
  for_each = local.bucket_permissions

  statement {
    principals {
      type        = "AWS"
      identifiers = [each.value.user_arn]
    }
    actions = each.value.permissions

    resources = [
      each.value.bucket_arn,
      "${each.value.bucket_arn}/*"
    ]
  }
}
