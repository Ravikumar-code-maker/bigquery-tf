terraform {
  backend "gcs" {
    bucket  = "terraform-state-dev1"
    prefix  = "bigquery/vm/state"
  }
}
