package main

default allow := true

allow := false if {
	count(deny) > 0
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]
	resource.type == "google_container_cluster"

	private_nodes := resource.values.private_cluster_config[0].enable_private_nodes
	private_nodes != true

	msg := sprintf("Cluster %s must enable private nodes", [resource.address])
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]
	resource.type == "google_container_cluster"

	network_policy := resource.values.network_policy[0].enabled
	network_policy != true

	msg := sprintf("Cluster %s must enable network policy", [resource.address])
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]
	resource.type == "google_container_cluster"

	cidrs := resource.values.master_authorized_networks_config[0].cidr_blocks
	count(cidrs) == 0

	msg := sprintf("Cluster %s must restrict master authorized networks", [resource.address])
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]
	resource.type == "google_container_node_pool"

	image := resource.values.node_config[0].image_type
	image != "COS_CONTAINERD"

	msg := sprintf("Node pool %s must use COS_CONTAINERD image, got %q", [resource.address, image])
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]
	resource.type == "google_container_node_pool"

	mode := resource.values.node_config[0].workload_metadata_config[0].mode
	mode != "GKE_METADATA"

	msg := sprintf("Node pool %s must use GKE_METADATA workload metadata mode, got %q", [resource.address, mode])
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]
	resource.type == "google_container_node_pool"

	management := resource.values.management[0]
	management.auto_repair != true

	msg := sprintf("Node pool %s must enable auto repair", [resource.address])
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]
	resource.type == "google_container_node_pool"

	management := resource.values.management[0]
	management.auto_upgrade != true

	msg := sprintf("Node pool %s must enable auto upgrade", [resource.address])
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]
	resource.type == "google_container_node_pool"

	not dedicated_service_account(resource)

	msg := sprintf("Node pool %s must use a dedicated (non-default) service account", [resource.address])
}

dedicated_service_account(resource) if {
	config_resources := input.configuration.root_module.resources[_]
	config_resources.type == "google_container_node_pool"
	config_resources.name == trim_prefix(resource.address, "google_container_node_pool.")

	sa_expr := config_resources.expressions.node_config[0].service_account
	some ref in sa_expr.references
	startswith(ref, "google_service_account.")
}
