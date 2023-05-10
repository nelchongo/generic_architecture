provider "twingate" {
  api_token = var.tg_api_token != "" ? var.tg_api_token : aws_secretsmanager_secret_version.app_tg_token_string[0].secret_string
  network   = var.network
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.8.0"
    }

    twingate = {
      source  = "Twingate/twingate"
      version = ">= 1.0.0"
    }
  }

  required_version = ">= 1.0.3"
}