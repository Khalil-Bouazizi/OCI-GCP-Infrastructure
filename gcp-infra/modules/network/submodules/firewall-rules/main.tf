module "firewall_rules_module" {
  source = "terraform-google-modules/network/google//modules/firewall-rules"

  project_id   = var.project_id
  network_name = var.vpc_name

  ingress_rules = concat(
    [
      {
        name          = "${var.vpc_name}-private-internal"
        description   = "Allow internal east-west traffic in private subnet"
        source_ranges = [var.cidr_block]
        target_tags   = ["private"]
        allow = [
          { protocol = "tcp" },
          { protocol = "udp" },
          { protocol = "icmp" }
        ]
      }
    ],
    [
      for port in var.public_ingress_tcp_ports : {
        name          = "${var.vpc_name}-public-ingress-tcp-${port}"
        description   = "Allow public ingress on TCP ${port}"
        source_ranges = var.public_ingress_cidrs
        target_tags   = ["public"]
        allow = [
          {
            protocol = "tcp"
            ports    = [tostring(port)]
          }
        ]
      }
    ]
  )
}
