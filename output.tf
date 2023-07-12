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

output "vpc_id" {
  value       = module.app_vpc.vpc_id
  description = "VPC id"
}

output "vpc_public_subnet" {
  value       = module.app_vpc.public_subnets
  description = "VPC public subnet"
}

output "internal_lb_arn"{
  value       = aws_lb.lb.arn
  description = "internal lb ARN"
}