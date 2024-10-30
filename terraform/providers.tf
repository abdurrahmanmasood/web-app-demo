terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }

  backend "gcs" {
    bucket = "terraform-state-file-graceful-fact"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}