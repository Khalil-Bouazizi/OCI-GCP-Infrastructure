output "compartment_id" {
  description = "Created compartment OCID."
  value       = oci_identity_compartment.oci_identity_compartment_details.id
}

output "vcn_ids" {
  description = "VCN OCIDs by VCN key."
  value = {
    for name, vcn_module in module.vcn :
    name => vcn_module.vcn_id
  }
}

output "public_subnet_ids" {
  description = "Public subnet OCIDs by VCN key."
  value = {
    for name, vcn_module in module.vcn : 
    name => vcn_module.public_subnet_id
  }
}

output "private_subnet_ids" {
  description = "Private subnet OCIDs by VCN key."
  value = {
    for name, vcn_module in module.vcn :
    name => vcn_module.private_subnet_id
  }
}

output "instance_ids" {
  description = "Compute instance OCIDs by instance key."
  value       = module.compute.instance_ids
}
