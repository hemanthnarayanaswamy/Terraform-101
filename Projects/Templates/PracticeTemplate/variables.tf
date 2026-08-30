variable "project_id" {
  description = "The GCP project ID where Terraform will create resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID: 6-30 characters, lowercase letters, numbers, and hyphens, starting with a letter and ending with a letter or number."
  }
}

variable "region" {
  description = "The default GCP region for provider operations."
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Short environment name used for labels."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, staging, prod."
  }
}

variable "bucket_name" {
  description = "Globally unique Cloud Storage bucket name. Use lowercase letters, numbers, and hyphens."
  type        = string

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63 && can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3-63 characters and use only lowercase letters, numbers, and hyphens. It must start and end with a letter or number."
  }
}

variable "bucket_location" {
  description = "Cloud Storage bucket location."
  type        = string
  default     = "US"
}
