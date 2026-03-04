module "object_storage_bucket" {
	source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
	version = "~> 12.3"
	count  = var.create_state_bucket ? 1 : 0

	name       = coalesce(var.state_bucket_name, "${var.project_id}-tfstate")
	project_id = var.project_id
	location   = var.state_bucket_location
	force_destroy            = false
	versioning               = true
	public_access_prevention = "enforced"
	bucket_policy_only       = true

	labels = {
		purpose     = "terraform-state"
		environment = "shared"
	}

	depends_on = [
		google_project.project,
		google_project_service.required
	]
}
