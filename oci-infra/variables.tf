# variables are like rules : Defines WHAT VALUES are expected and their TYPE - read values from .tvars file.

variable "tenancy_ocid" {
  description = "OCID of the tenancy root compartment."
  type        = string
}

variable "compartment_name" {
  description = "Name of the root-level compartment to create."
  type        = string
  default     = "oci-infra-test"
}

variable "compartment_description" {
  description = "Description for the created compartment."
  type        = string
  default     = "Terraform-managed compartment for OCI infrastructure testing"
}

variable "compartment_enable_delete" {
  description = "Allow compartment deletion via Terraform destroy."
  type        = bool
  default     = false
}

variable "compartment_freeform_tags" {
  description = "Freeform tags to set on the compartment."
  type        = map(string)
  default     = {}
}

variable "compartment_defined_tags" {
  description = "Defined tags to set on the compartment."
  type        = map(string)
  default     = {}
}

variable "vcns" {
  description = "Map of VCN definitions. Each VCN creates one public and one private subnet with IGW, NAT, route tables, and security lists."
  type = map(object({
    cidr_block               = string
    dns_label                = string # enable DNS hostname resolution within your network - When dns_label is defined, OCI automatically creates a private DNS zone for the VCN, allowing instances to communicate using hostnames rather than hard-coded IPs
    public_subnet_cidr       = string
    private_subnet_cidr      = string
    public_subnet_dns_label  = string
    private_subnet_dns_label = string
    public_ingress_cidrs     = optional(list(string), ["0.0.0.0/0"])
    public_ingress_tcp_ports = optional(list(number), [22])
    freeform_tags            = optional(map(string), {})
    defined_tags             = optional(map(string), {})
  }))
}

variable "instances" {
  description = "Map of compute instances to create. subnet_type must be public or private."
  type = map(object({
    vcn_key                 = string 
    subnet_type             = string
    availability_domain     = optional(string)
    image_ocid              = string
    ssh_authorized_keys     = list(string)
    shape                   = optional(string, "VM.Standard.E2.1.Micro")
    assign_public_ip        = optional(bool, true)
    boot_volume_size_in_gbs = optional(number)
    fault_domain            = optional(string)
    metadata                = optional(map(string), {})
    freeform_tags           = optional(map(string), {})
    defined_tags            = optional(map(string), {})
  }))

  validation {
    condition = alltrue([
      for instance in values(var.instances) : contains(["public", "private"], lower(instance.subnet_type))
    ])
    error_message = "Each instance subnet_type must be either 'public' or 'private'."
  }
}
