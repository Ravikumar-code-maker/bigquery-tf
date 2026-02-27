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

# -----------------------------
# Service Account
# -----------------------------
resource "google_service_account" "vm_sa" {
  account_id   = "vm-bigquery-sa"
  display_name = "VM BIGQUERY SERVICE ACCOUNT"
}
resource "google_project_iam_member" "bigquery_editor" {
  role    = "role/bigquery.dataEditor"
  memeber = "serviceAccount:${google_service_account.vm_sa.email}"
}

# -----------------------------
# BigQuery Dataset
# -----------------------------
resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = var.dataset_id
  location                    = var.region
  delete_contents_on_destroy  = true
}

# -----------------------------
# BigQuery Table (Extended Schema)
# -----------------------------

resource "google_bigquery_table" "table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = var.table_id
  deletion_protection = false

  schema = jsonencode([ 
    {
     name  = "id"
     type  = "STRING"
     mode  = "REQUIRED"
    },
    {
    name  = "name"
    type  = "STRING"
    mode  = "NULLABLE"
   },
   {
   name  = "email"
   type  = "STRING"
   mode  = "NULLABLE"
   },
   {
   name  = "age"
   type  = "INTEGER"
   mode  = "NULLABLE"
   },
   {
   name  = "created_at"
   typen = "TIMESTAMP"
   mode  = "NULLABLE"
   },
   {
   name  = "is_active"
   type  = "BOOLEAN"
   mode  = "NULLABLE"
   }
])

time_partitioning {
  type  = "DAY"
  filed = "created_at"
}

clustering = ["name", "email"]

depends_on = [
  google_project_service.bigquery_api
]
}


