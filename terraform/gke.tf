# gke.tf

resource "google_container_cluster" "primary" {
  name                     = "wiz-gke-cluster"
  location                 = var.region
  network                  = google_compute_network.vpc.id
  subnetwork               = google_compute_subnetwork.gke_subnet.id 
  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-ranges"
    services_secondary_range_name = "services-ranges"
  }

  # Configures private node pool deployment
  private_cluster_config {
    enable_private_nodes    = true 
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "wiz-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}