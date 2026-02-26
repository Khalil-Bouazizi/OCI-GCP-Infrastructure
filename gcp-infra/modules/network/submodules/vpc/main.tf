module "vpc_module" {
  source = "terraform-google-modules/network/google//modules/vpc"

  project_id   = var.project_id
  network_name = var.vpc_name
  routing_mode = "REGIONAL"
}
