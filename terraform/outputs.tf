# outputs.tf

output "mongo_vm_public_ip" {
  value       = google_compute_instance.mongo_vm.network_interface[0].access_config[0].nat_ip
  description = "Public IP of MongoDB VM (Exposed via SSH)"
}

output "mongo_vm_private_ip" {
  value       = google_compute_instance.mongo_vm.network_interface[0].network_ip
  description = "Internal IP of MongoDB VM (Needed by GKE application environment variable)"
}

output "gcs_backup_bucket_url" {
  value       = "https://storage.googleapis.com/${google_storage_bucket.backup_bucket.name}"
  description = "Public GCS Bucket URL"
}

output "gke_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "Private GKE Cluster Name"
}