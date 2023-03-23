variable "name_prefix" {
  description = "Prefix to prepend to resource names"
  type        = string
}

variable "bucket_a_name" {
  description = "Name of the source bucket"
  type        = string
}

variable "bucket_b_name" {
  description = "Name of the target bucket"
  type        = string
}

variable "build_path" {
  description = "Path from where the package should be built"
  type        = string
}

variable "deployment_package_path" {
  description = "Path where the output deployment package should go"
  type        = string
}
