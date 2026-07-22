# audit_logs.tf
# Enable Data Access Audit Logging for GCS and Compute Engine

# 1. Audit Logging for Google Cloud Storage
resource "google_project_iam_audit_config" "gcs_audit" {
  project = var.project_id
  service = "storage.googleapis.com"

  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

# 2. Audit Logging for Compute Engine
resource "google_project_iam_audit_config" "compute_audit" {
  project = var.project_id
  service = "compute.googleapis.com"

  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}