output "lambda_arn" {
  value = aws_lambda_function.fn.arn
}

output "lambda_name" {
  value = aws_lambda_function.fn.function_name
}
