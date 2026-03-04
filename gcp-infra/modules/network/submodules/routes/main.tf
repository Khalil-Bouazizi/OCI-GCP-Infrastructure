module "routes_module" {
	source = "terraform-google-modules/network/google//modules/routes"

	project_id   = var.project_id
	network_name = var.vpc_name
	routes = concat(
		[
			{
				name              = "${var.vpc_name}-${var.subnet_type}-default-route"
				description       = var.subnet_type == "public" ? "Default internet route for public instances" : "Default internet route for private instances"
				destination_range = "0.0.0.0/0"
				tags              = [var.subnet_type]
				next_hop_internet = true
				priority          = 1000
			}
		],
		var.subnet_type == "private" && var.enable_private_googleapis ? [
			{
				name              = "${var.vpc_name}-private-googleapis-route"
				description       = "Private Google APIs restricted VIP route"
				destination_range = "199.36.153.8/30"
				tags              = ["private"]
				next_hop_internet = true
				priority          = 900
			}
		] : []
	)
}
