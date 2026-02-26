module "instance_template" {
	source = "terraform-google-modules/vm/google//modules/instance_template"

	project_id   = var.project_id
	region       = var.region
	name_prefix  = var.name_prefix
	machine_type = var.machine_type
	subnetwork   = var.subnetwork
	source_image_project = var.source_image_project # Project where the source image comes from
	source_image_family  = var.source_image_family # OS type
	disk_size_gb         = tostring(var.disk_size_gb)
	tags                 = var.network_tags
	metadata             = var.metadata
	access_config        = var.assign_public_ip ? [{ network_tier = "STANDARD" }] : []
	service_account      = var.service_account_email == null ? null : {
		email  = var.service_account_email
		scopes = toset(var.service_account_scopes)
	}
}
