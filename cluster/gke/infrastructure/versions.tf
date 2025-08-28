terraform {
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.5"
    }

    google = {
      source  = "hashicorp/google"
      version = "~> 6.49.2"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.5.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.4"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.13.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1.0"
    }
  }

  required_version = ">= 1.13.0"
}

provider "google" {
  project = var.project_id
}
