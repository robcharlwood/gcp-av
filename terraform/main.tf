provider "google" {
  version     = "~> 2.1"
  credentials = "${file(".keys/terraform_key.json")}"
  project     = "${var.PROJECT}"
  region      = "${var.REGION}"
  zone        = "${var.ZONE}"
}

module "s3" {
  source = "./s3"
  REGION = "${var.REGION}"
}

module "pubsub" {
  source = "./pubsub"
}

module "cloud-functions" {
  source                = "./cloud-functions"
  functions_bucket_name = "${module.s3.gcp-av-functions-bucket-name}"
  scan_bucket_name      = "${module.s3.gcp-av-scan-bucket-name}"
  pubsub_topic_name     = "${module.pubsub.gcp-av-pubsub-topic-name}"
  SLACK_WEBHOOK_URL     = "${var.SLACK_WEBHOOK_URL}"
}

module "scheduler" {
  source          = "./scheduler"
  REGION          = "${var.REGION}"
  pubsub_topic_id = "${module.pubsub.gcp-av-pubsub-topic-id}"
}
