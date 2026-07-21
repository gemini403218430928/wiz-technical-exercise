# vpc.tf

# Custom VPC Network
resource "google_compute_network" "vpc" {
  name                    = "wiz-vpc"
  description             = "Wiz Technical Exercise VPC Network deployed via GitHub Actions"
  auto_create_subnetworks = false
}

# Subnet for Private GKE Cluster
resource "google_compute_subnetwork" "gke_subnet" {
  name                     = "gke-subnet"
  ip_cidr_range            = "10.10.0.0/20"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true 

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services-ranges"
    ip_cidr_range = "10.30.0.0/20"
  }
}

# Subnet for MongoDB VM
resource "google_compute_subnetwork" "vm_subnet" {
  name                     = "vm-subnet"
  ip_cidr_range            = "10.0.1.0/24"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true 
}

# Cloud Router & NAT (Enables outbound internet for GKE container pulls)
resource "google_compute_router" "router" {
  name    = "wiz-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "wiz-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
# Demo trigger for Checkov scan
# Demo trigger for Checkov scan3
