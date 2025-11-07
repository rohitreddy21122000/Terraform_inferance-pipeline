variable "env" {
  type = string
}

variable "rate_limit" {
  type    = number
  default = 2000
}

variable "api_id" {
  type    = string
  default = ""
}

variable "stage_name" {
  type    = string
  default = "$default"
}

variable "api_type" {
  type    = string
  default = "HTTP" # HTTP or REST
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "tags" {
  type    = map(string)
  default = {}
}
