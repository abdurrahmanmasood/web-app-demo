terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }

  backend "gcs" {
    bucket = "terraform-state-file-wired-torus123"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}