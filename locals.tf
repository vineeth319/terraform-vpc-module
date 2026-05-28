locals {
  az_names = slice(data.aws_availability_zones.azs.names, 0, 2)
  name     = "${var.project}-${var.environment}"
  common_tags = {
    "project"     = var.project
    "Terraform"   = "true"
    "environment" = var.environment
  }
}
