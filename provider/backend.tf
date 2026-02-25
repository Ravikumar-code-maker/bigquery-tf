terraform {
  backend "gcs" {
    bucket  = "terraform-sate"
    prefix  = "bigquery/vm/state"
  }
}
