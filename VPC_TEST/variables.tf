variable "environment" {
  type = string
  default = "dev"
}

variable "project" {
  type = string
  default = "roboshop"
}

variable "vpc_tags" {
  type = map(string)
  default = {}
}

variable "isPeeringRequired" {
  type = bool
  default = true
}