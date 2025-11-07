variable "bucket_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "enable_versioning" {
  type    = bool
  default = true
}

variable "document_retention_days" {
  type    = number
  default = 90
}

variable "enable_intelligent_tiering" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
