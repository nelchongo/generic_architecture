resource "aws_ecr_repository" "repo" {
  name = var.app_name
  tags = var.tags
}