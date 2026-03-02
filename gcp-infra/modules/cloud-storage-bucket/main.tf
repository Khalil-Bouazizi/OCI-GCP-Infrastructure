module "state_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 12.3"

  name       = var.name
  project_id = var.project_id
  location   = var.location

  force_destroy            = var.force_destroy
  versioning               = true
  public_access_prevention = "enforced"
  bucket_policy_only       = true

  iam_members = var.iam_members
  labels      = var.labels
}