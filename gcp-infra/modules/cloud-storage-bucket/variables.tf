variable "name" {
	description = "State bucket name (must be globally unique)."
	type        = string
}

variable "project_id" {
	description = "Project ID where the bucket is created."
	type        = string
}

variable "location" {
	description = "Bucket location/region."
	type        = string
}

variable "force_destroy" {
	description = "Allow bucket destroy even if objects exist. Keep false for state buckets."
	type        = bool
	default     = false
}

variable "iam_members" {
	description = "Optional IAM members on the bucket."
	type = list(object({
		role   = string
		member = string
	}))
	default = []
}

variable "labels" {
	description = "Optional labels applied to the bucket."
	type        = map(string)
	default     = {}
}
