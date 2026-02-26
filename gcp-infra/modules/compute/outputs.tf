output "instances" {
	value = {
		for name, instance_module in module.compute_instance :
		name => {
			instance_name        = instance_module.instance_name
			instances_self_links = instance_module.instances_self_links
			instances_details    = instance_module.instances_details
		}
	}
}