# iam.tf

# Service Account attached to the VM
resource "google_service_account" "vm_sa" {
  account_id   = "wiz-vm-sa"
  display_name = "Overly Permissive VM Service Account"
}

# Intentional Misconfiguration: Granting full Compute Admin privileges to the VM identity
resource "google_project_iam_member" "vm_sa_compute_admin" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}

# Granting VM access to write to Cloud Storage
resource "google_project_iam_member" "vm_sa_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}