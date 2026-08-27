package main

required_labels := ["environment", "project", "managed_by"]

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]

	resource.type == "google_container_cluster"

	some label in required_labels

	not resource.values.resource_labels[label]

	msg := sprintf(
		"Cluster %s is missing required label: %s",
		[resource.address, label],
	)
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]

	resource.type == "google_container_node_pool"

	some label in required_labels

	not resource.values.node_config[0].labels[label]

	msg := sprintf(
		"Node pool %s is missing required label: %s",
		[resource.address, label],
	)
}
