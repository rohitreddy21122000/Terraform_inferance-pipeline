variable "env" { type = string }
variable "lambda_arns" { 
  type = list(string) 
  default = [] 
}