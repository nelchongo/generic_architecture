locals {
  rds_name = "${var.app_name}-rds"
  rds_secret_name = "${var.tags.env}/${local.rds_name}/postgres"
}

#Secret Manager
resource "random_password" "rds_password" {
  count = var.is_rds_available ? 1 : 0
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "rds_pass" {
  count = var.is_rds_available ? 1 : 0
  name  = local.rds_secret_name
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  count = var.is_rds_available ? 1 : 0
  secret_id     = aws_secretsmanager_secret.rds_pass[0].id
  secret_string = random_password.rds_password[0].result
}

#Networking
resource "aws_db_subnet_group" "main" {
  count = var.is_rds_available ? 1 : 0
  name       = "${local.rds_name}-${var.tags.env}-rds-subnet-group"
  subnet_ids = module.app_vpc.private_subnets
  tags       = var.tags
}

resource "aws_security_group" "rds" {
  count = var.is_rds_available ? 1 : 0
  name        = "${local.rds_name}-${var.tags.env}-rds-sg"
  description = "Application database - ${var.app_name}"
  vpc_id      = module.app_vpc.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "allow_egress_rds" {
  count = var.is_rds_available ? 1 : 0
  description       = "Allow all outgoing traffic"
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.rds[0].id
}

resource "aws_security_group_rule" "allow_dbaccess_from_instances_to_rds" {
  count = var.is_rds_available ? 1 : 0
  description              = "Allow database access from application instances"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.instances.id
  security_group_id        = aws_security_group.rds[0].id
}

resource "aws_security_group_rule" "allow_dbaccess_from_given_sg" {
  count = var.is_rds_available ? 1 : 0
  description              = "Allow database access from each security group"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.app_tg_sg.this_security_group_id
  security_group_id        = aws_security_group.rds[0].id
}

#Roles
resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.is_rds_available ? 1 : 0
  name                = "${local.rds_name}-rds-monitoring"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]

  assume_role_policy  = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Sid = ""
            Effect = "Allow"
            Principal = {
                Service = "monitoring.rds.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
    ]
  })

  tags = var.tags
}

#RDS
data "aws_availability_zones" "current" {
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

resource "aws_db_instance" "this" {
  count = var.is_rds_available ? 1 : 0
  identifier        = local.rds_name
  engine            = "postgres"
  engine_version    = "13.7"
  instance_class    = var.rds_instance_size
  allocated_storage = var.rds_allocated_storage
  storage_type      = var.rds_storage_type
  iops              = null
  storage_encrypted = var.rds_storage_encrypted

  username = "postgres"
  password = aws_secretsmanager_secret_version.rds_secret_version[0].secret_string
  port     = 5432

  vpc_security_group_ids       = [aws_security_group.rds[0].id]
  db_subnet_group_name         = aws_db_subnet_group.main[0].name
  parameter_group_name         = "default.postgres13"
  option_group_name            = "default:postgres-13"
  performance_insights_enabled = var.rds_enable_performance_insights

  availability_zone   = data.aws_availability_zones.current.names[0]
  multi_az            = false
  publicly_accessible = false

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  maintenance_window          = "tue:04:00-tue:05:00"
  backup_window               = null
  backup_retention_period     = 30
  deletion_protection         = false
  skip_final_snapshot         = true
  monitoring_interval         = 0
  monitoring_role_arn         = null
  apply_immediately           = true
  tags                        = var.tags
}
