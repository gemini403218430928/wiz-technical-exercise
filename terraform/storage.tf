resource "google_storage_bucket" "backup_bucket" {
  name          = "wiz-db-backups-clgcporg10-185"
  location      = "US"
  force_destroy = true

  labels = {
    environment = "wiz-demo"
    managed_by  = "github-actions"
  }
}

resource "google_storage_bucket_iam_binding" "public_read" {
  bucket = google_storage_bucket.backup_bucket.name
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers",
  ]
}