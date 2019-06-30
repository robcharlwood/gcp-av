variable "REGION" {
  description = "Region of your Google Cloud Platform Project"
  type        = "string"
}

variable "pubsub_topic_id" {
  description = "PubSub topic ID for scheduler"
  type        = "string"
}
