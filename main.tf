provider "aws" {
  region = local.region
}

locals {
  region      = "eu-west-2"
  name_prefix = "${var.namespace}-${var.name}-${random_string.unique_id.id}"

  tags = {
    Namespace = var.namespace
    Name      = var.name
    UniqueID  = random_string.unique_id.id
  }
}

resource "random_string" "unique_id" {
  length  = 12
  special = false
}

################################################################################
# Bucket A
################################################################################

# bucket
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

# bucket
# ...


################################################################################
# Supporting Resources
################################################################################

# todo
# ...
