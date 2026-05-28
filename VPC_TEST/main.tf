module "roboshop" {
  source = "../VPC_Module"
  project = var.project
  environment = var.environment
  vpc_tags = var.vpc_tags
  isPeeringRequired = var.isPeeringRequired
}