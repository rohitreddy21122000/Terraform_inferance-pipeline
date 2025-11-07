output "web_acl_arn" { value = aws_wafv2_web_acl.web_acl.arn }
output "association_arn" { value = try(aws_wafv2_web_acl_association.api_gateway_association[0].id, "") }
