# ---------------------------------------------------------------------------------------------------------------------
# AWS PROVIDER FOR TF CLOUD
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = "~>1.4.6"
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.1.0"
    }
  }
}


provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS PROVIDER USING TF CLI
# ---------------------------------------------------------------------------------------------------------------------

# provider "aws" {
#   profile = "default-ecs"
#   version = "~> 2.25"
#   region  = "${var.aws_region}"
# }

# terraform {
#   required_version = "~>0.12"
#   backend "remote" {
#     organization = "aws-isv"

#     workspaces {
#       name = "petclinic-fargate"
#     }
#   }
# }