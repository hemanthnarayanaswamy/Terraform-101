resource "google_project_service" "storage" {
  project = var.project_id
  service = "storage.googleapis.com"

  disable_on_destroy = false
}

resource "google_storage_bucket" "learning" {
  name     = var.bucket_name
  location = var.bucket_location

  uniform_bucket_level_access = true
  force_destroy               = false

  labels = {
    environment = var.environment
    managed_by  = "terraform"
    module      = "module-2"
  }

  depends_on = [google_project_service.storage]
}
