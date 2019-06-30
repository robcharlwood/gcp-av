resource "google_cloud_scheduler_job" "freshclam-job" {
  name        = "freshclam-job"
  region      = "${var.REGION}"
  description = "Job to kick of cloud function to update anti virus definitions"
  schedule    = "0 0 * * *" # every day at midnight

  pubsub_target {
    topic_name = "${var.pubsub_topic_id}"
    attributes = {
      update = true
    }
  }
}
