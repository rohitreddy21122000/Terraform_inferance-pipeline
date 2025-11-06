variable "name" {
  type    = string
  default = "tech-extract-text"
}

variable "env" {
  type    = string
  default = "qa"
}

variable "runtime" {
  type    = string
  default = "nodejs18.x"
}

variable "handler" {
  type    = string
  default = "index.handler"
}

variable "memory_size" {
  type    = number
  default = 512
}

variable "timeout" {
  type    = number
  default = 30
}