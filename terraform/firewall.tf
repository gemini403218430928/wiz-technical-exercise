# firewall.tf

# Intentional Misconfiguration: SSH (port 22) exposed to 0.0.0.0/0
resource "google_compute_firewall" "allow_public_ssh" {
  name    = "allow-public-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"] 
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["mongo-vm"]
}

# Restricted Access: Allow Mongo port (27017) ONLY from GKE Pod Secondary CIDR
resource "google_compute_firewall" "allow_mongo_from_gke" {
  name    = "allow-mongo-from-gke"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["27017"] 
  }

  source_ranges = [google_compute_subnetwork.gke_subnet.secondary_ip_range[0].ip_cidr_range] 
  target_tags   = ["mongo-vm"]
}