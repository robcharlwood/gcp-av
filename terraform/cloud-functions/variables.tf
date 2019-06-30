variable "functions_bucket_name" {
  description = "Name of the functions bucket"
  type        = "string"
}

variable "pubsub_topic_name" {
  description = "Name of the pubsub topic"
  type        = "string"
}

variable "scan_bucket_name" {
  description = "Name of the GCS bucket to scan"
  type        = "string"
}
