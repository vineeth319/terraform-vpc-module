# terraform-aws-vpc

A reusable Terraform module for provisioning a production-ready AWS VPC with:

* Public subnets
* Private subnets
* Database subnets
* Internet Gateway
* NAT Gateway
* Route tables
* Optional VPC peering support and is only can connect with default VPC

---

# Features

* Configurable VPC CIDR block
* Public, private, and database subnet tiers
* Multi-AZ subnet deployment
* Internet Gateway for public subnets
* NAT Gateway with Elastic IP for outbound internet access
* Dedicated route tables for each subnet tier
* Optional VPC peering support
* Flexible tagging support for all resources
* Consistent naming convention

---

# Usage

```hcl
module "vpc" {
  source = "git::https://github.com/vineeth319/terraform-modules.git?ref=main"

  project     = "roboshop"
  environment = "dev"

  vpc_cidr = "10.0.0.0/16"

  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24"]
  database_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24"]

  is_peering_required = false
}
```

---

# Architecture

## Public Subnets

* Internet accessible
* Associated with Internet Gateway
* Suitable for:

  * Bastion hosts
  * Load balancers
  * Frontend applications

## Private Subnets

* Outbound internet access through NAT Gateway
* No direct inbound internet access
* Suitable for:

  * Backend services
  * Application servers

## Database Subnets

* Isolated subnet tier
* Outbound internet access through NAT Gateway
* Suitable for:

  * RDS
  * Databases
  * Stateful workloads

---

# Resources Created

| Name                                 | Type     |
| ------------------------------------ | -------- |
| aws_vpc.roboshop                         | Resource |
| aws_internet_gateway.gw            | Resource |
| aws_subnet.public                    | Resource |
| aws_subnet.private                   | Resource |
| aws_subnet.database                  | Resource |
| aws_eip.nat                          | Resource |
| aws_nat_gateway.roboshop_nat                 | Resource |
| aws_route_table.public               | Resource |
| aws_route_table.private              | Resource |
| aws_route_table.database             | Resource |
| aws_route.public                     | Resource |
| aws_route.private                    | Resource |
| aws_route.database                   | Resource |
| aws_route_table_association.public   | Resource |
| aws_route_table_association.private  | Resource |
| aws_route_table_association.database | Resource |

---

# Inputs

| Name                      | Description                                         | Type         | Default                            | Required |
| ------------------------- | --------------------------------------------------- | ------------ | ---------------------------------- | -------- |
| project                   | Project name used for naming and tagging resources  | string       | n/a                                | yes      |
| environment               | Deployment environment (`dev`, `qa`, `uat`, `prod`) | string       | n/a                                | yes      |
| cidr_block                 | CIDR block for the VPC                              | string       | `10.0.0.0/16`                      | no       |
| public_subnet_cidrs       | CIDR blocks for public subnets                      | list(string) | `["10.0.1.0/24", "10.0.2.0/24"]`   | no       |
| private_subnet_cidrs      | CIDR blocks for private subnets                     | list(string) | `["10.0.11.0/24", "10.0.12.0/24"]` | no       |
| database_subnet_cidrs     | CIDR blocks for database subnets                    | list(string) | `["10.0.21.0/24", "10.0.22.0/24"]` | no       |
| vpc_tags                  | Additional VPC tags                                 | map(string)  | `{}`                               | no       |
| igw_tags                  | Additional Internet Gateway tags                    | map(string)  | `{}`                               | no       |
| public_subnet_tags        | Additional public subnet tags                       | map(string)  | `{}`                               | no       |
| private_subnet_tags       | Additional private subnet tags                      | map(string)  | `{}`                               | no       |
| database_subnet_tags      | Additional database subnet tags                     | map(string)  | `{}`                               | no       |
| public_route_table_tags   | Additional public route table tags                  | map(string)  | `{}`                               | no       |
| private_route_table_tags  | Additional private route table tags                 | map(string)  | `{}`                               | no       |
| database_route_table_tags | Additional database route table tags                | map(string)  | `{}`                               | no       |
| eip_tags                  | Additional Elastic IP tags                          | map(string)  | `{}`                               | no       |
| nat_gateway_tags          | Additional NAT Gateway tags                         | map(string)  | `{}`                               | no       |
| is_peering_required       | Enables VPC peering resources                       | bool         | `false`                            | no       |

---

# Outputs

| Name                | Description             |
| ------------------- | ----------------------- |
| vpc_id              | ID of the VPC           |
| public_subnet_ids   | IDs of public subnets   |
| private_subnet_ids  | IDs of private subnets  |
| database_subnet_ids | IDs of database subnets |

---

# Naming Convention

Resources follow the naming format:

```text
{project}-{environment}-{tier}-{availability-zone}
```

## Example

```text
roboshop-dev-public-us-east-1a
roboshop-dev-private-us-east-1b
roboshop-dev-database-us-east-1a
```

---

# Example Folder Structure

```text
terraform-aws-vpc/
├── main.tf
├── variables.tf
├── outputs.tf
├── locals.tf
├── versions.tf
└── README.md
```

---

# Notes

* This module currently provisions a single NAT Gateway.
* Suitable for:

  * Development
  * QA
  * Mid-scale environments

For highly available production environments, consider:

* One NAT Gateway per Availability Zone
* Dedicated route tables per AZ
* Separate network ACL strategy
* Flow logs and monitoring

---
