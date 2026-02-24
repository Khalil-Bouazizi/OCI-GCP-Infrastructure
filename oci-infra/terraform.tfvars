# terraform.tfvars - replace the values with your own configuration

tenancy_ocid = "ocid1.tenancy.oc1.." # replace with your tenancy OCID

compartment_name          = "oci-infra-test"
compartment_enable_delete = true

vcns = {
  vcn-a = {
    cidr_block               = "10.10.0.0/16"
    dns_label                = "vcna"
    public_subnet_cidr       = "10.10.1.0/24"
    private_subnet_cidr      = "10.10.2.0/24"
    public_subnet_dns_label  = "puba"
    private_subnet_dns_label = "prva"
    public_ingress_cidrs     = ["0.0.0.0/0"]
    public_ingress_tcp_ports = [22]
  }

  vcn-b = {
    cidr_block               = "10.20.0.0/16"
    dns_label                = "vcnb"
    public_subnet_cidr       = "10.20.1.0/24"
    private_subnet_cidr      = "10.20.2.0/24"
    public_subnet_dns_label  = "pubb"
    private_subnet_dns_label = "prvb"
    public_ingress_cidrs     = ["0.0.0.0/0"]
    public_ingress_tcp_ports = [22]
  }
}

instances = {
  e2-instance-01 = {
    vcn_key             = "vcn-a" # must match a key in the vcns map
    subnet_type         = "public"
    availability_domain = null
    image_ocid          = "ocid1.image.oc1..replace_me"
    ssh_authorized_keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQReplaceMe user@host"]
    shape               = "VM.Standard.E2.1.Micro"
    assign_public_ip    = true
  }
}
