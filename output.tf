output "app_name" {
  value       = var.app_name
  description = "Application name"
}

output "app_dns" {
  value       = aws_route53_record.dns.name
  description = "Application DNS"
}

output "ecs_execution_role_id" {
  value       = aws_iam_role.execution.id
  description = "ECS Execution role id"
}