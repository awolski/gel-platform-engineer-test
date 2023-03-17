provider "aws" {
  region = local.region
}

locals {
  region      = "eu-west-2"
  name_prefix = "${var.namespace}-${var.name}-${random_string.unique_id.id}"

  bucket_a_name = "${local.name_prefix}-bucket-a"
  bucket_b_name = "${local.name_prefix}-bucket-b"

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

# todo
# ...


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
