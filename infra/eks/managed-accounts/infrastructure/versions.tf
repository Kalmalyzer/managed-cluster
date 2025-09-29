terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14.1"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.5.0"
    }
  }

  required_version = ">= 1.13.0"
}

provider "aws" {
  region = var.region
}
