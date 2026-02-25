terrafrom {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "harshicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
