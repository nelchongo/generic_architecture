locals {
  tg_name = "${var.app_name}-tg"
  tg_secret_name = "${var.tags.env}/${local.tg_name}/tg-token"
}

#Secret manager for Twingate API Key
resource "aws_secretsmanager_secret" "app_tg_token" {
  count = 1
  name  = local.tg_secret_name
}

resource "aws_secretsmanager_secret_version" "app_tg_token_string" {
  count         = 1
  secret_id     = aws_secretsmanager_secret.app_tg_token[0].id
  secret_string = var.tg_api_token
  lifecycle {
    ignore_changes = [secret_string, ]
  }
}

#Network connector
resource "twingate_remote_network" "aws_network" {
  name = local.tg_name
  location = "AWS"
}

resource "twingate_connector" "aws_connector" {
  remote_network_id = twingate_remote_network.aws_network.id
}

resource "twingate_connector_tokens" "aws_connector_tokens" {
  connector_id = twingate_connector.aws_connector.id
}

data "aws_ami" "latest" {
  most_recent = true
  filter {
    name = "name"
    values = [
      "twingate/images/hvm-ssd/twingate-amd64-*",
    ]
  }
  owners = ["617935088040"]
}

#VPC Definition
module "app_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.app_name}-vpc"
  cidr = "10.0.0.0/16"

  azs                            = ["us-east-1a", "us-east-1b"]
  private_subnets                = ["10.0.1.0/24", "10.0.3.0/24"]
  public_subnets                 = ["10.0.2.0/24"]
  enable_classiclink_dns_support = true
  enable_dns_hostnames           = true
  enable_nat_gateway             = true
}

module "app_tg_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.17.0"
  vpc_id  = module.app_vpc.vpc_id
  name    = "${local.tg_name}-sg"
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-tcp", "all-udp", "all-icmp"]
}

# spin off a ec2 instance from Twingate AMI and configure tokens in user_data
module "app_ec2_tenant_connector" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.19.0"

  name = "${local.tg_name}-connector"
  user_data = <<-EOT
    #!/bin/bash
    set -e
    mkdir -p /etc/twingate/
    {
      echo TWINGATE_URL="https://${var.network}.twingate.com"
      echo TWINGATE_ACCESS_TOKEN="${twingate_connector_tokens.aws_connector_tokens.access_token}"
      echo TWINGATE_REFRESH_TOKEN="${twingate_connector_tokens.aws_connector_tokens.refresh_token}"
    } > /etc/twingate/connector.conf
    sudo systemctl enable --now twingate-connector
  EOT
  ami                    = data.aws_ami.latest.id
  instance_type          = "t3a.micro"
  vpc_security_group_ids = [module.app_tg_sg.this_security_group_id]
  subnet_id              = module.app_vpc.private_subnets[0]
}