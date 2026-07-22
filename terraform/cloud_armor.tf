# terraform/cloud_armor.tf
# Preventative Control: Google Cloud Armor WAF Policy

resource "google_compute_security_policy" "block_bad_actors" {
  name        = "block-bad-actors"
  description = "WAF policy attached to GKE Ingress to block or rate-limit traffic"
  project     = var.project_id

  # Rule 900: Block Log4j2 CVE-2021-44228 (Satisfies Checkov CKV_GCP_86)
  rule {
    action   = "deny(403)"
    priority = "900"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('cve-canary')"
      }
    }
    description = "Block Log4j2 CVE-2021-44228 vulnerabilities"
  }

  # Rule 1000: Deny rule for specific IP range (can be modified live during demo)
  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["192.0.2.1/32"] # Placeholder IP to demonstrate live blocking
      }
    }
    description = "Demonstration rule to block malicious traffic"
  }

  # Default Rule: Allow all other traffic
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow rule"
  }
}

output "cloud_armor_policy_name" {
  description = "Name of the Cloud Armor security policy"
  value       = google_compute_security_policy.block_bad_actors.name
}