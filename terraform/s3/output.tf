output "gcp-av-functions-bucket-self_link" {
  value       = "${google_storage_bucket.gcp-av-functions.self_link}"
  description = "The URI of the created functions bucket."
}

output "gcp-av-functions-bucket-url" {
  value       = "${google_storage_bucket.gcp-av-functions.url}"
  description = "The base URL of the functions bucket, in the format gs://<bucket-name>."
}

output "gcp-av-functions-bucket-name" {
  value       = "${google_storage_bucket.gcp-av-functions.name}"
  description = "The name of the functions bucket."
}




output "gcp-av-scan-bucket-self_link" {
  value       = "${google_storage_bucket.gcp-av-watch-bucket.self_link}"
  description = "The URI of the created scan bucket."
}

output "gcp-av-scan-bucket-url" {
  value       = "${google_storage_bucket.gcp-av-watch-bucket.url}"
  description = "The base URL of the scan bucket, in the format gs://<bucket-name>."
}

output "gcp-av-scan-bucket-name" {
  value       = "${google_storage_bucket.gcp-av-watch-bucket.name}"
  description = "The name of the bucket to scan."
}
