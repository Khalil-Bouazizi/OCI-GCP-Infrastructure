resource "google_compute_firewall" "private_internal" {
  name        = "${var.vpc_name}-private-internal"
  description = "Allow internal east-west tcp and icmp between peered VPCs"
  project     = var.project_id
  network     = var.vpc_name

  direction     = "INGRESS"
  source_ranges = distinct(concat([var.cidr_block], var.peer_cidrs))
  target_tags   = ["private"]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "public_ssh" {
  count = var.subnet_type == "public" && contains(var.public_ingress_tcp_ports, 22) ? 1 : 0

  name        = "${var.vpc_name}-public-ingress-ssh"
  description = "Allow SSH to public-tagged instances"
  project     = var.project_id
  network     = var.vpc_name

  direction     = "INGRESS"
  source_ranges = var.public_ingress_cidrs
  target_tags   = ["public"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
