# Configure the Google Cloud tfstate file location
terraform {
  backend "gcs" {
    bucket      = "gcp-av-terraform"
    credentials = ".keys/terraform_key.json"
  }
}
