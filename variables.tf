variable "namespace" {
  description = "A short 3-4 letter abbreviation of the company name, to ensure globally unique IDs for things like S3 buckets"
  type        = string
  default     = "gel"
}

variable "name" {
  description = "A name for the collection of resources, to ensure globally unique IDs for resources"
  type        = string
  default     = "platform"
}
