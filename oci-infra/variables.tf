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

variable "network_supernet_cidr" {
  description = "Global address pool used for dynamic VCN allocation"
  type        = string
  default     = "10.0.0.0/8"
}

variable "vcn_newbits" {
  description = "Additional CIDR bits to allocate each VCN from network_supernet_cidr"
  type        = number
  default     = 8
}

variable "subnet_newbits" {
  description = "Additional CIDR bits to allocate subnets from each VCN CIDR (for /24 from /16 use 8)."
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

variable "vcns" {
  description = "Map of VCN definitions. CIDR/subnet/dns fields can be omitted and are allocated dynamically."
  type = map(object({
    vcn_index                = optional(number)
    cidr_block               = optional(string)
    dns_label                = optional(string)
    public_subnet_cidr       = optional(string)
    private_subnet_cidr      = optional(string)
    public_subnet_dns_label  = optional(string)
    private_subnet_dns_label = optional(string)
    public_ingress_cidrs     = optional(list(string), ["0.0.0.0/0"])
    public_ingress_tcp_ports = optional(list(number), [22])
    freeform_tags            = optional(map(string), {})
    defined_tags             = optional(map(string), {})
  }))

  validation {
    condition = alltrue([
      for vcn in values(var.vcns) : try(vcn.vcn_index, null) == null || try(vcn.vcn_index, -1) >= 0
    ])
    error_message = "vcns[*].vcn_index must be >= 0 when provided."
  }
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
