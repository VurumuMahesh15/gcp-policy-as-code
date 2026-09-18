package main

test_network_private_google_access_enabled if {
	inp := {
		"planned_values": {
			"root_module": {
				"resources": [{
					"address": "google_compute_subnetwork.primary",
					"type": "google_compute_subnetwork",
					"values": {
						"private_ip_google_access": true,
						"log_config": [{
							"aggregation_interval": "INTERVAL_5_SEC",
							"flow_sampling": 0.5,
							"metadata": "INCLUDE_ALL_METADATA",
						}],
					},
				}],
			},
		},
	}
	result := deny with input as inp
	count(result) == 0
}

test_network_private_google_access_disabled if {
	inp := {
		"planned_values": {
			"root_module": {
				"resources": [{
					"address": "google_compute_subnetwork.primary",
					"type": "google_compute_subnetwork",
					"values": {
						"private_ip_google_access": false,
						"log_config": [{
							"aggregation_interval": "INTERVAL_5_SEC",
							"flow_sampling": 0.5,
							"metadata": "INCLUDE_ALL_METADATA",
						}],
					},
				}],
			},
		},
	}
	result := deny with input as inp
	count(result) == 1
	result[_] == "Subnetwork google_compute_subnetwork.primary must enable Private Google Access"
}

test_network_flow_logs_missing if {
	inp := {
		"planned_values": {
			"root_module": {
				"resources": [{
					"address": "google_compute_subnetwork.primary",
					"type": "google_compute_subnetwork",
					"values": {
						"private_ip_google_access": true,
					},
				}],
			},
		},
	}
	result := deny with input as inp
	count(result) == 1
	result[_] == "Subnetwork google_compute_subnetwork.primary must enable VPC Flow Logs"
}

test_network_flow_logs_configured if {
	inp := {
		"planned_values": {
			"root_module": {
				"resources": [{
					"address": "google_compute_subnetwork.primary",
					"type": "google_compute_subnetwork",
					"values": {
						"private_ip_google_access": true,
						"log_config": [{
							"aggregation_interval": "INTERVAL_5_SEC",
							"flow_sampling": 0.5,
							"metadata": "INCLUDE_ALL_METADATA",
						}],
					},
				}],
			},
		},
	}
	result := deny with input as inp
	count(result) == 0
}

test_network_flow_logs_empty_list_real_plan_shape if {
	inp := {
		"planned_values": {
			"root_module": {
				"resources": [{
					"address": "google_compute_subnetwork.primary",
					"type": "google_compute_subnetwork",
					"values": {
						"private_ip_google_access": true,
						"log_config": [],
					},
				}],
			},
		},
	}
	result := deny with input as inp
	count(result) == 1
	result[_] == "Subnetwork google_compute_subnetwork.primary must enable VPC Flow Logs"
}
