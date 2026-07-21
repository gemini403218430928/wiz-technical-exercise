# gcs.tf

# Database Backup Storage Bucket
resource "google_storage_bucket" "backup_bucket" {
  name                     = "wiz-db-backups-${var.project_id}"
  location                 = var.region
  force_destroy            = true
  public_access_prevention = "inherited" # Permits public access
}

# Intentional Misconfiguration: Publicly readable and listable bucket
resource "google_storage_bucket_iam_binding" "public_read" {
  bucket = google_storage_bucket.backup_bucket.name
  role   = "roles/storage.objectViewer" 

  members = [
    "allUsers" 
  ]
}