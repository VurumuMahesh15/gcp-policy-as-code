package main

required_labels := ["environment", "project", "managed_by"]

allowed_environments := {"dev", "staging", "production"}

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

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]
	resource.type == "google_container_cluster"

	environment := resource.values.resource_labels.environment
	not environment in allowed_environments

	msg := sprintf(
		"Cluster %s has invalid environment label: %s",
		[resource.address, environment],
	)
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]
	resource.type == "google_container_node_pool"

	environment := resource.values.node_config[0].labels.environment
	not environment in allowed_environments

	msg := sprintf(
		"Node pool %s has invalid environment label: %s",
		[resource.address, environment],
	)
}
