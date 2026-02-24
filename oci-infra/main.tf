# The MASTER CONTROLLER that:
# Creates resources (compartment)
# Calls modules (VCN, Compute)
# Connects outputs from one module to inputs of another

data "oci_identity_availability_domains" "ads" { # get availability domains 
  compartment_id = var.tenancy_ocid
} # You can access: data.oci_identity_availability_domains.ads.availability_domains[0].name


resource "oci_identity_compartment" "this" {
  compartment_id = var.tenancy_ocid # root compartment (tenancy) OCID
  name           = var.compartment_name
  description    = var.compartment_description
  enable_delete  = var.compartment_enable_delete

  freeform_tags = var.compartment_freeform_tags
  defined_tags  = var.compartment_defined_tags
}

module "vcn" {
  source = "./modules/vcn"

  for_each = var.vcns # iterate over the map of VCN definitions (2 in this case)

  compartment_id = oci_identity_compartment.this.id
  vcn_name       = each.key
  cidr_block     = each.value.cidr_block
  dns_label      = each.value.dns_label

  public_subnet_cidr       = each.value.public_subnet_cidr
  private_subnet_cidr      = each.value.private_subnet_cidr
  public_subnet_dns_label  = each.value.public_subnet_dns_label
  private_subnet_dns_label = each.value.private_subnet_dns_label

  public_ingress_cidrs     = try(each.value.public_ingress_cidrs, ["0.0.0.0/0"])
  public_ingress_tcp_ports = try(each.value.public_ingress_tcp_ports, [22])

  freeform_tags = try(each.value.freeform_tags, {})
  defined_tags  = try(each.value.defined_tags, {})
}

 # Locals in Terraform are like local variables in programming. They allow you to assign a name to an expression, which you can then use multiple times within a module.
locals {
   # create 2 local variables here
  default_availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name

  instances_resolved = {
    for name, instance in var.instances :
    name => { # check line 50 and 51 for how we resolve availability domain and subnet_id based on instance properties and module outputs
      availability_domain = coalesce(try(instance.availability_domain, null), local.default_availability_domain)
      subnet_id           = lower(instance.subnet_type) == "public" ? module.vcn[instance.vcn_key].public_subnet_id : module.vcn[instance.vcn_key].private_subnet_id

      image_ocid              = instance.image_ocid
      ssh_authorized_keys     = instance.ssh_authorized_keys
      shape                   = try(instance.shape, "VM.Standard.E2.1.Micro")
      assign_public_ip        = try(instance.assign_public_ip, true)
      boot_volume_size_in_gbs = try(instance.boot_volume_size_in_gbs, null)
      fault_domain            = try(instance.fault_domain, null)
      metadata                = try(instance.metadata, {})
      freeform_tags           = try(instance.freeform_tags, {})
      defined_tags            = try(instance.defined_tags, {})
    }
  }
}

module "compute" {
  source = "./modules/compute"

  compartment_id = oci_identity_compartment.this.id
  instances      = local.instances_resolved
}
