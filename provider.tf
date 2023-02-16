terraform {

  required_providers {
    aws = {
      version = ">= 2.7.0"
      source  = "hashicorp/aws"
    }
  }

  # Comment in to use a remote backend
  # Make sure to put in the approriate parameters
  # backend "s3" {
  #   bucket         = ""
  #   key            = "terraform.tfstate"
  #   dynamodb_table = ""

  #   region = ""
  # }
}


provider "aws" {
  region = "us-east-1"
  profile = "terraform"
}