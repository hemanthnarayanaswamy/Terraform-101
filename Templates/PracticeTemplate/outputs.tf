output "bucket_name" {
  description = "The name of the Cloud Storage bucket."
  value       = google_storage_bucket.learning.name
}

output "bucket_url" {
  description = "The gsutil-style URL of the Cloud Storage bucket."
  value       = "gs://${google_storage_bucket.learning.name}"
}
