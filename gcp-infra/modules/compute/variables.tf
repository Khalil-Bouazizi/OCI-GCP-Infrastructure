variable "project_id" {
	description = "Project ID where compute instances are created."
	type        = string
}

variable "instances" {
	description = "Map of compute instances to create."
	type = map(object({
		zone                 = string
		machine_type         = string
		subnetwork           = string
		source_image_project = string
		source_image_family  = string
		assign_public_ip     = bool
		disk_size_gb         = optional(number)
		network_tags         = optional(list(string), [])
		metadata             = optional(map(string), {})
		service_account_email  = optional(string)
		service_account_scopes = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"])
	}))
}