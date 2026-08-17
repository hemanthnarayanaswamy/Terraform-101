variable "project_id" {
  description = "This is the field for project_id"
  type        = string
  default     = "kkgcplabs01-041"
}

variable "region" {
  description = "GCP region in US"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "GCP machine type (2 vCPU from E2 or N2)"
  type        = string
  default     = "e2-standard-2"
}

variable "disk_type" {
  description = "Disk type: pd-standard, pd-balanced, or pd-ssd"
  type        = string
  default     = "pd-standard"
}

variable "image" {
  description = "Boot disk image"
  type        = string
  default     = "debian-cloud/debian-12" # Allowed OS (not premium)
}
