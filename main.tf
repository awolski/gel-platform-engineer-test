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

module "image_processor" {
  source = "./modules/gel-aws-lambda-image-processor"

  name_prefix             = local.name_prefix
  bucket_a_name           = aws_s3_bucket.a.id
  bucket_b_name           = aws_s3_bucket.b.id
  build_path              = "${path.module}/lib"
  deployment_package_path = "${path.module}/build"
}
