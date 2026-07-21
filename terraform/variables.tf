# variables.tf
variable "project_id" {
  type        = string
  description = "The GCP Project ID where resources will be deployed"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "Default GCP Region"
}

variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "Default GCP Zone"
}