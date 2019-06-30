output "gcp-av-pubsub-topic-name" {
  value       = "${google_pubsub_topic.gcp-av-freshclam.name}"
  description = "The name of the Google pubsub topic to subscribe to"
}

output "gcp-av-pubsub-topic-id" {
  value       = "${google_pubsub_topic.gcp-av-freshclam.id}"
  description = "The ID of the Google pubsub topic to subscribe to"
}
