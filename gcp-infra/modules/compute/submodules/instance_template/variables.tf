variable "project_id" {
	type = string
}

variable "region" {
	type = string
}

variable "name_prefix" {
	type = string
}

variable "machine_type" {
	type = string
}

variable "subnetwork" {
	type = string
}

variable "source_image_project" {
	type = string
}

variable "source_image_family" {
	type = string
}

variable "disk_size_gb" {
	type = number
}

variable "network_tags" {
	type    = list(string)
	default = []
}

variable "metadata" {
	type    = map(string)
	default = {}
}

variable "assign_public_ip" {
	type = bool
}

variable "service_account_email" {
	type    = string
	default = null
}

variable "service_account_scopes" {
	type    = list(string)
	default = ["https://www.googleapis.com/auth/cloud-platform"]
}
