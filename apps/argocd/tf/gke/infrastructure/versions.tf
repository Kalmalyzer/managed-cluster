terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.49.2"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.13.1"
    }
  }

  required_version = ">= 1.13.0"
}

provider "google" {
  project = var.project_id
}
