# cloud storage buckets
resource "google_storage_bucket" "gcp-av-functions" {
  storage_class = "REGIONAL"
  name          = "gcp-av-functions"
  location      = "${var.REGION}"
  force_destroy = true
}

resource "google_storage_bucket" "gcp-av-definitions" {
  storage_class = "REGIONAL"
  name          = "gcp-av-definitions"
  location      = "${var.REGION}"
  force_destroy = true
}

resource "google_storage_bucket" "gcp-av-watch-bucket" {
  storage_class = "REGIONAL"
  name          = "gcp-av-upload"
  location      = "${var.REGION}"
  force_destroy = true
}
