variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "environment" {
  type    = string
  default = "qa"
}

variable "tags" {
  type = map(string)
  default = {}
}
