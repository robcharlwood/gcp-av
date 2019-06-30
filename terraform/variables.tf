variable "PROJECT" {
  description = "Your Google Cloud Platform Project"
  type        = "string"
}

variable "REGION" {
  description = "Region of your Google Cloud Platform Project"
  type        = "string"
}

variable "ZONE" {
  description = "Zone of your Google Cloud Platform Project"
  type        = "string"
}

variable "SLACK_WEBHOOK_URL" {
  description = "Slack webhook to send notifications to."
  type        = "string"
}
