# terraform/scc.tf
# Detective Control: Enable Security Command Center API

resource "google_project_service" "securitycenter_api" {
  project            = var.project_id
  service            = "securitycenter.googleapis.com"
  disable_on_destroy = false
}