terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.49.2"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.5.0"
    }
  }

  required_version = ">= 1.13.0"
}

provider "google" {
  project = var.project_id
}
