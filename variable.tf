#General Variables
variable "app_name" {
  type = string
  description = "Application name"
  validation {
    condition = (var.app_name != null || var.app_name != "") && length(regexall("^[a-z0-9]+$", var.app_name)) > 0
    error_message = "The app_name cannot be null, please insert a value" 
  }
}

variable "tags" {
  type = object({
    env        = string
    app_name   = string
  })
  description = "Mandatory tags"
}

variable "app_port" {
  type        = number
  description = "TCP port number where the application is listening at."
  validation {
    condition     = var.app_port >= 0 && var.app_port <= 65535
    error_message = "The application port must be a number in the range of 0-65535."
  }
}

variable "containers_count" {
  type    = number
  default = 1
  description = "Number of containers for ECS Services"
}

#Load Balancer Variables
variable "lb_health_check_path" {
    type = string
    default = "/ping/"
}

variable "lb_certificate_arn" {
    type = string
    validation {
        condition     = (var.lb_certificate_arn != null || var.lb_certificate_arn != "")
        error_message = "The lb certificates can't be null or empty"
    }
}

#RDS Variables
variable "rds_instance_size" {
  type        = string
  description = "RDS instance size"
  default     = "db.t3.micro" #Free tier
}

variable "rds_allocated_storage" {
  type        = number
  description = "Size of  the allocated storage for RDS data in Gigabytes."
  default     = 20
}

variable "rds_storage_type" {
  type        = string
  description = "RDS Storage type"
  default     = "gp2"
}

variable "rds_storage_encrypted" {
  type        = bool
  description = "Wheter to encrypt the RDS data storage or not."
  default     = false
}

variable "rds_enable_performance_insights" {
  type        = bool
  description = "Wheter to enable RDS Performance insights or not."
  default     = false
}

variable "route_53_hosted_zone_id" {
    type       = string
    description = "Hosted zone id"
    validation {
        condition     = (var.route_53_hosted_zone_id != null || var.route_53_hosted_zone_id != "")
        error_message = "The hosted zone id can't be null or empty"
    }
}

#Twingate Variables
variable "network" {
  type = string
  default = "futurumsoft"
  description = "Twingate network for the application"
}

variable "tg_api_token" {
  type = string
  description = "Twingate application token"
  validation {
    condition = var.tg_api_token != null
    error_message = "Twingate token can not be null, please insert a token" 
  }
}