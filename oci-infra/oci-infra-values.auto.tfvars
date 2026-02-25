# terraform.tfvars - replace the values with your own configuration

tenancy_ocid = "ocid1.tenancy.oc1.." # replace with your tenancy OCID

compartment_name          = "oci-infra-test"
compartment_enable_delete = true

network_supernet_cidr = "10.0.0.0/8" 
vcn_newbits           = 8 
subnet_newbits        = 8 
public_subnet_netnum  = 1
private_subnet_netnum = 2

vcns = {
  vcn-a = { # vcn-a is the key that identifies this VCN in the configuration and outputs
    vcn_index                = 10
    public_ingress_cidrs     = ["0.0.0.0/0"]
    public_ingress_tcp_ports = [22]
  }

  vcn-b = {
    vcn_index                = 20
    public_ingress_cidrs     = ["0.0.0.0/0"]
    public_ingress_tcp_ports = [22]
  }
}

instances = {
  e2-instance-01 = {
    vcn_key             = "vcn-a" # must match a key in the vcns map
    subnet_type         = "public"
    availability_domain = null
    image_ocid          = "ocid1.image.oc1..replace_me"  # A unique identifier (Oracle Cloud Identifier) for a specific operating system image
    ssh_authorized_keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQReplaceMe user@host"]
    shape               = "VM.Standard.E2.1.Micro"
    assign_public_ip    = true
  }
}
