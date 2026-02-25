# -----------------------------
# Enable Required APIs
# -----------------------------
resource "google_project_service" "compute_api" {
  service  = "compute.googleapis.com"
}

resource "google_project_service" "bigquery_api" {
  service = "bigquery.googleapis.com"
}

resource "google_project_service" "iam_api" {
  service = "iam.googleapis.com"
}
