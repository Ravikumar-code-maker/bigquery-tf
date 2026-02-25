# bigquery-tf
provider/provider.tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
📁 main.tf (Updated with Enhanced BigQuery Table)
# -----------------------------
# Enable Required APIs
# -----------------------------
resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"
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
  display_name = "VM BigQuery Service Account"
}

resource "google_project_iam_member" "bigquery_editor" {
  role   = "roles/bigquery.dataEditor"
  member = "serviceAccount:${google_service_account.vm_sa.email}"
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

  time_partitioning {
    type  = "DAY"
    field = "created_at"
  }

  clustering = ["country", "status"]

  schema = jsonencode([
    {
      name = "id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "first_name"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "last_name"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "email"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "phone"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "age"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "country"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "status"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "is_active"
      type = "BOOLEAN"
      mode = "NULLABLE"
    },
    {
      name = "purchase_amount"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "updated_at"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    }
  ])
}

# -----------------------------
# Compute Engine VM
# -----------------------------
resource "google_compute_instance" "vm" {
  name         = "bigquery-vm"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  depends_on = [
    google_project_service.compute_api,
    google_project_service.bigquery_api
  ]
}
📁 variables.tf
variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "dataset_id" {
  type    = string
  default = "sales_dataset"
}

variable "table_id" {
  type    = string
  default = "customers"
}
🚀 Deployment Steps
1️⃣ Create the GCS bucket (once)
2️⃣ Update bucket name in backend.tf
3️⃣ Run:
terraform init -reconfigure
terraform plan
terraform apply
✅ What You Now Have

✔ Remote Terraform state in GCS
✔ Versioned state (safe rollback)
✔ Partitioned BigQuery table
✔ Clustered columns for performance
✔ Expanded production-ready schema
✔ VM with BigQuery access

If you want next-level production setup, I can provide:

🔐 State locking using DynamoDB equivalent (GCS locking method)

🔒 Private VM (no public IP)

🏗️ Modular Terraform structure

🌍 Multi-environment setup (dev/stage/prod)

📊 BigQuery views & scheduled queries

🔄 CI/CD pipeline for Terraform

Tell me your target environment (enterprise / learning / production).

🪣 Create GCS Bucket for Remote State (One-Time) were config this bfore code or after

Good question 👍 — this is very important in Terraform.

✅ Answer:

You must create the GCS bucket FIRST (before configuring the backend).

🔎 Why?

Terraform backend initialization happens during:

terraform init

If the GCS bucket does not already exist, Terraform will fail with:

Error: Failed to get existing workspaces
Bucket doesn't exist

Terraform cannot create the backend bucket using the same configuration that uses it.

🏗️ Correct Order (Best Practice)
✅ Step 1 — Create the GCS bucket (Bootstrap Step)

Create a separate temporary folder like:

bootstrap/
 └── main.tf
bootstrap/main.tf
provider "google" {
  project = "your-project-id"
  region  = "us-central1"
}

resource "google_storage_bucket" "tf_state" {
  name                        = "your-terraform-state-bucket"
  location                    = "US"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

Run:

cd bootstrap
terraform init
terraform apply

Now the bucket exists ✅

✅ Step 2 — Configure Backend in Main Project

Now in your main project:

📁 provider/backend.tf

terraform {
  backend "gcs" {
    bucket  = "your-terraform-state-bucket"
    prefix  = "bigquery/vm/state"
  }
}

Then run:

terraform init -reconfigure

Now Terraform will store state in GCS successfully.

🧠 Production Tip

In real enterprise setups:

Bootstrap bucket is created once

Then used for:

dev state

staging state

prod state (different prefixes)

Example:

prefix = "dev/state"
prefix = "prod/state"
🔥 Summary
Step	Action
1	Create GCS bucket (separate bootstrap config)
2	Add backend block
3	Run terraform init -reconfigure
4	Deploy infrastructure

If you want, I can show you:

🔐 Fully secure enterprise backend setup

🌍 Multi-environment remote state structure

🏗️ Proper production Terraform folder architecture

🚀 CI/CD setup with remote backend

Just tell me your goal (learning / real production / enterprise).
