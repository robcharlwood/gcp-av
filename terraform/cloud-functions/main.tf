resource "google_storage_bucket_object" "gcp-av-update-function-zip" {
  name   = "freshclam_function.zip"
  bucket = "${var.functions_bucket_name}"
  source = "./build/freshclam_function.zip"
}

resource "google_storage_bucket_object" "gcp-av-scan-function-zip" {
  name   = "clamscan_func.zip"
  bucket = "${var.functions_bucket_name}"
  source = "./build/clamscan_function.zip"
}

resource "google_cloudfunctions_function" "gcp-av-update-function" {
  name        = "freshclam"
  description = "Updates the virus definitions in the relevant cloud storage bucket"
  runtime     = "python37"

  available_memory_mb   = 1024
  source_archive_bucket = "${var.functions_bucket_name}"
  source_archive_object = "${google_storage_bucket_object.gcp-av-update-function-zip.name}"
  timeout               = 300
  entry_point           = "update_virus_definitions"
  max_instances         = 1

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = "${var.pubsub_topic_name}"
  }
}

resource "google_cloudfunctions_function" "gcp-av-scan-function" {
  name        = "clamscan"
  description = "Scans files uploaded to GCS buckets for viruses using clamav"
  runtime     = "python37"

  available_memory_mb   = 2048
  source_archive_bucket = "${var.functions_bucket_name}"
  source_archive_object = "${google_storage_bucket_object.gcp-av-scan-function-zip.name}"
  timeout               = 300
  entry_point           = "scan"
  max_instances         = 10

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = "${var.scan_bucket_name}"
  }
}
