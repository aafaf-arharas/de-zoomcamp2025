variable "credentials" {
  description = "My credentials"
  default     = "./keys/my-creds.json"
}

variable "project" {
  description = "Project"
  default     = "poetic-hawk-445716-c1"
}

variable "region" {
  description = "region"
  default     = "us-central1"
}

variable "location" {
  description = "Project location"
  default     = "US"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset name"
  default     = "ny_rides_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket name"
  default     = "poetic-hawk-445716-c1-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}