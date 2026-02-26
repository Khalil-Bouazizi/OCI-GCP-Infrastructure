module "compute_instance" {
	source = "terraform-google-modules/vm/google//modules/compute_instance"

	project_id         = var.project_id
	zone               = var.zone
	hostname           = var.hostname
	instance_template  = var.instance_template
	add_hostname_suffix = false
	num_instances      = 1
}
