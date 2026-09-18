package main

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]
	resource.type == "google_compute_subnetwork"

	resource.values.private_ip_google_access != true

	msg := sprintf(
		"Subnetwork %s must enable Private Google Access",
		[resource.address],
	)
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]
	resource.type == "google_compute_subnetwork"

	not resource.values.log_config[0]

	msg := sprintf(
		"Subnetwork %s must enable VPC Flow Logs",
		[resource.address],
	)
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]
	resource.type == "google_compute_subnetwork"

	log_config := resource.values.log_config[0]

	log_config.aggregation_interval == "INTERVAL_15_SEC"
	log_config.flow_sampling == 0
	log_config.metadata == "EXCLUDE_ALL_METADATA"

	msg := sprintf(
		"Subnetwork %s has overly restrictive VPC Flow Logs configuration",
		[resource.address],
	)
}
