# scc.tf
# Detective Control: Security Command Center API & Finding Export Setup

# 1. Enable Security Command Center API
resource "google_project_service" "securitycenter_api" {
  project            = var.project_id
  service            = "securitycenter.googleapis.com"
  disable_on_destroy = false
}

# 2. Pub/Sub Topic for Security Command Center Findings (Optional Export)
resource "google_pubsub_topic" "scc_findings_topic" {
  name    = "wiz-scc-findings-topic"
  project = var.project_id

  depends_on = [
    google_project_service.securitycenter_api
  ]
}