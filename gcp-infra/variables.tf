variable "organization_id" {
	description = "GCP organization ID where the folder can be created."
	type        = string
	default     = null

	validation {
		condition     = !var.create_folder || var.organization_id != null
		error_message = "organization_id is required when create_folder = true."
	}

	validation {
		condition     = !(var.create_project && !var.create_folder && var.folder_id == null) || var.organization_id != null
		error_message = "When create_project = true and create_folder = false, set folder_id or organization_id."
	}
}

variable "folder_name" {
	description = "Folder display name to create under the organization."
	type        = string
	default     = "terraform-infra"
}

variable "create_folder" {
	description = "Whether to create a new folder under the organization."
	type        = bool
	default     = false
}

variable "folder_id" {
	description = "Existing folder ID to use when create_folder is false."
	type        = string
	default     = null
}

variable "project_id" {
	description = "Project ID used for all resources."
	type        = string
}

variable "project_name" {
	description = "Project display name when create_project is true."
	type        = string
	default     = "terraform-infra-project"
}

variable "create_project" {
	description = "Whether to create the project in the selected folder."
	type        = bool
	default     = false
}

variable "billing_account" {
	description = "Billing account ID required when create_project is true."
	type        = string
	default     = null
}

variable "region" {
	description = "Default GCP region."
	type        = string
	default     = "europe-west1"
}

variable "zone" {
	description = "Default GCP zone."
	type        = string
	default     = "europe-west1-b"
}

variable "enable_apis" {
	description = "APIs to enable in the target project."
	type        = list(string)
	default = [
		"compute.googleapis.com",
		"storage.googleapis.com"
	]
}

variable "create_state_bucket" {
	description = "Whether to create a GCS bucket for Terraform remote state."
	type        = bool
	default     = true
}

variable "state_bucket_name" {
	description = "Name of the GCS bucket used for Terraform state. Must be globally unique."
	type        = string
	default     = null
}

variable "state_bucket_location" {
	description = "Location for the Terraform state bucket."
	type        = string
	default     = "EU"
}

variable "state_bucket_prefix" {
	description = "Prefix/path inside the state bucket for this stack state file."
	type        = string
	default     = "gcp-infra/state"
}

variable "hub_vpc_key" {
	description = "VPC key used as HUB for local peering."
	type        = string
	default     = "hub"

	validation {
		condition     = contains(keys(var.vpcs), var.hub_vpc_key)
		error_message = "hub_vpc_key must reference an existing key in vpcs."
	}
}

variable "spoke_vpc_key" {
	description = "VPC key used as SPOKE for local peering."
	type        = string
	default     = "spoke-a"

	validation {
		condition     = contains(keys(var.vpcs), var.spoke_vpc_key)
		error_message = "spoke_vpc_key must reference an existing key in vpcs."
	}

	validation {
		condition     = var.spoke_vpc_key != var.hub_vpc_key
		error_message = "spoke_vpc_key must be different from hub_vpc_key."
	}
}

variable "network_supernet_cidr" {
	description = "Global address pool used for dynamic VPC allocation."
	type        = string
	default     = "10.0.0.0/8"
}

variable "vpc_newbits" {
	description = "Additional CIDR bits to allocate each VPC from network_supernet_cidr."
	type        = number
	default     = 8
}

variable "subnet_newbits" {
	description = "Additional CIDR bits to allocate subnets from each VPC CIDR."
	type        = number
	default     = 8
}

variable "public_subnet_netnum" {
	description = "Subnet index used by cidrsubnet for public subnet allocation."
	type        = number
	default     = 1
}

variable "private_subnet_netnum" {
	description = "Subnet index used by cidrsubnet for private subnet allocation."
	type        = number
	default     = 2
}

variable "vpcs" {
	description = "Map of VPC definitions. CIDR and subnet fields can be omitted for dynamic allocation."
	type = map(object({
		vpc_index                 = optional(number)
		cidr_block                = optional(string)
		subnet_type               = optional(string)
		subnet_name               = optional(string)
		subnet_cidr               = optional(string)
		public_subnet_cidr        = optional(string)
		private_subnet_cidr       = optional(string)
		public_subnet_name        = optional(string)
		private_subnet_name       = optional(string)
		public_ingress_cidrs      = optional(list(string), ["0.0.0.0/0"])
		public_ingress_tcp_ports  = optional(list(number), [22])
		enable_private_googleapis = optional(bool, true)
	}))

	validation {
		condition = alltrue([
			for vpc in values(var.vpcs) : try(vpc.vpc_index, null) == null || try(vpc.vpc_index, -1) >= 0
		])
		error_message = "vpcs[*].vpc_index must be >= 0 when provided."
	}
}

variable "instances" {
	description = "Map of compute instances to create. subnet_type must be public or private."
	type = map(object({
		vpc_key                = string
		subnet_type            = string
		zone                   = optional(string)
		machine_type           = optional(string, "e2-micro")
		image                  = optional(string, "debian-cloud/debian-12")
		assign_public_ip       = optional(bool, true)
		disk_size_gb           = optional(number, 20)
		network_tags           = optional(list(string), [])
		metadata               = optional(map(string), {})
		ssh_public_key_path    = optional(string)
		ssh_username           = optional(string, "ubuntu")
		service_account_email  = optional(string)
		service_account_scopes = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"])
	}))

	validation {
		condition = alltrue([
			for instance in values(var.instances) : contains(["public", "private"], lower(instance.subnet_type))
		])
		error_message = "Each instance subnet_type must be either 'public' or 'private'."
	}

	validation {
		condition = alltrue([
			for instance in values(var.instances) : contains(keys(try(instance.metadata, {})), "ssh-keys") || try(instance.ssh_public_key_path, null) != null
		])
		error_message = "Each instance must provide ssh_public_key_path or metadata['ssh-keys']."
	}
}
