# Infrastructure
This MD file is used to explain some requirements, pre-requisites and variables

## Pre-requisite

### Twingate Pre-requisite
 1. Create Twingate Account
 2. Create Twingate Network
 3. Create Twingate API Token

### AWS Pre-requise
 1. Create hosted zone on Route 53
 2. Point DNS from hosted zone in hosted website (my case Domain.com)
 3. Create SSL certificates for Route 53

## Input Variables
|Variable	                          |Description                                                      |Required |Default value |
|-------------------------------------|-----------------------------------------------------------------|---------|--------------|
|app_name                             |This variable is for application name                            |`True`   | `NULL`       |
|tags                                 |This are tha applied tags for all the resources                  |`True`   | `NULL`       |  
|app_port                             |This port for accesing the application                           |`False`  | `8080`       |
|container_count                      |Number of containers inside the service                          |`False`  | `1`          |
|lb_is_public                         |Check if load balancer is public or not                          |`False`  | `False`       |
|lb_health_check_path                 |load balancer health check path                                  |`False`  | `/ping/`     |
|lb_certificate_arn                   |Load balancer ssl certificates check guides on how to create     |`True`   | `NULL`       |
|is_rds_available                     |RDS creation or not                                              |`False`  | `True`       |
|rds_instance_size                    |RDS instance size                                                |`False`  | `db.t3.micro`|
|rds_allocated_storage                |RDS instance allocated storage in GB                             |`False`  | `20`         |
|rds_storage_type                     |RDS instance storage type                                        |`False`  | `gp2`        |
|rds_storage_encrypted                |RDS instance storage encryption                                  |`False`  | `False`      |
|rds_enable_performance_insights      |RDS instance performance insight                                 |`False`  | `False`      |
|route_53_hosted_zone_id              |Route 53 hosted zone id                                          |`True`   | `NULL`       |
|twingate_available                   |Create or not twingate EC2 instance and network.                 |`False`  | `True`       |
|network                              |Twingate Network                                                 |`False`  | `futurumsoft`|
|tg_api_token                         |Twingate API Token                                               |`True`   | `NULL`       |
|nat_available                        |Create or not NAT inside the VPC                                 |`False`  | `True`       |

## Output Variables
|Variable	                          |Description                                                      |
|-------------------------------------|-----------------------------------------------------------------|
|app_name                             |This variable is for application name                            |
|app_dns                              |This variable is for application dns                             |
|ecs_execution_role_id                |ECS execution role id                                            |
|vpc_id                               |ID of the VPC                                                    |
|vpc_public_subnet                    |Public subnets of the VPC                                        |
|internal_lb_arn                      |Internal lb ARN                                                  |

##  Deployed Infrastructure Example
You can set it up in one VPC or in Multiple depending on the use case

<img src="./.generic_architecture.png" width="500" alt="accessibility text">