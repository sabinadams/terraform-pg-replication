terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.5.1"
    }
  }
}