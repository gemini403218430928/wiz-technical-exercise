# providers.tf
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Add the GCS Remote Backend configuration here
  backend "gcs" {
    bucket = "wiz-tf-state-clgcporg10-185" # Must match the bucket created in Step 1
    prefix = "terraform/state"                 # Path inside the bucket where the state file lives
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}