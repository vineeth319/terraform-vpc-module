module "roboshop" {
  #source = "../VPC_Module"
  source = "git::https://github.com/vineeth319/terraform-modules.git?ref=main"
  project = var.project
  environment = var.environment
  vpc_tags = var.vpc_tags
  isPeeringRequired = var.isPeeringRequired
}