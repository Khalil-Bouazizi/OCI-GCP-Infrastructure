# The MASTER CONTROLLER that:
# Creates resources (compartment)
# Calls modules (VCN, Compute)
# Connects outputs from one module to inputs of another

resource "oci_identity_compartment" "oci_identity_compartment_details" {
  compartment_id = var.tenancy_ocid # root compartment (tenancy) OCID
  name           = var.compartment_name
  description    = var.compartment_description
  enable_delete  = var.compartment_enable_delete

  freeform_tags = var.compartment_freeform_tags
  defined_tags  = var.compartment_defined_tags
}

module "vcn" {
  source = "./modules/vcn"

  for_each = local.vcns_resolved # iterate over normalized VCN definitions

  compartment_id = oci_identity_compartment.oci_identity_compartment_details.id
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

locals {
  sorted_vcn_keys = sort(keys(var.vcns)) # return all keys of vncs map in list

  vcns_resolved = {
    for name, vcn in var.vcns :
    name => {
      index_resolved = coalesce(try(vcn.vcn_index, null), index(local.sorted_vcn_keys, name))

      cidr_block = coalesce(
        try(vcn.cidr_block, null),
        cidrsubnet(var.network_supernet_cidr, var.vcn_newbits, coalesce(try(vcn.vcn_index, null), index(local.sorted_vcn_keys, name)))
      )

      dns_label = coalesce(
        try(vcn.dns_label, null),
        substr(regexreplace(lower(format("vcn%s", name)), "[^a-z0-9]", ""), 0, 15)
      )

      public_subnet_cidr = coalesce(
        try(vcn.public_subnet_cidr, null),
        cidrsubnet(
          coalesce(
            try(vcn.cidr_block, null),
            cidrsubnet(var.network_supernet_cidr, var.vcn_newbits, coalesce(try(vcn.vcn_index, null), index(local.sorted_vcn_keys, name)))
          ),
          var.subnet_newbits,
          var.public_subnet_netnum
        )
      )

      private_subnet_cidr = coalesce(
        try(vcn.private_subnet_cidr, null),
        cidrsubnet(
          coalesce(
            try(vcn.cidr_block, null),
            cidrsubnet(var.network_supernet_cidr, var.vcn_newbits, coalesce(try(vcn.vcn_index, null), index(local.sorted_vcn_keys, name)))
          ),
          var.subnet_newbits,
          var.private_subnet_netnum
        )
      )

      public_subnet_dns_label = coalesce(
        try(vcn.public_subnet_dns_label, null),
        substr(regexreplace(lower(format("pub%s", name)), "[^a-z0-9]", ""), 0, 15)
      )

      private_subnet_dns_label = coalesce(
        try(vcn.private_subnet_dns_label, null),
        substr(regexreplace(lower(format("prv%s", name)), "[^a-z0-9]", ""), 0, 15)
      )

      public_ingress_cidrs     = try(vcn.public_ingress_cidrs, ["0.0.0.0/0"])
      public_ingress_tcp_ports = try(vcn.public_ingress_tcp_ports, [22])
      freeform_tags            = try(vcn.freeform_tags, {})
      defined_tags             = try(vcn.defined_tags, {})
    }
  }


  default_availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name

  instances_resolved = {
    for name, instance in var.instances :
    name => { # check line 50 and 51 for how we resolve availability domain and subnet_id based on instance properties and module outputs
      availability_domain = coalesce(try(instance.availability_domain, null), local.default_availability_domain)
      subnet_id           = lower(instance.subnet_type) == "public" ? module.vcn[instance.vcn_key].public_subnet_id : module.vcn[instance.vcn_key].private_subnet_id

      image_ocid              = instance.image_ocid
      ssh_authorized_keys     = length(try(instance.ssh_authorized_keys, [])) > 0 ? instance.ssh_authorized_keys : [trimspace(file(instance.ssh_public_key_path))]
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

  compartment_id = oci_identity_compartment.oci_identity_compartment_details.id
  instances      = local.instances_resolved
}
