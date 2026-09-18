package main

test_machine_e2_small_allowed if {
	values := object.union(compliant_pool_values, {
		"node_config": [{
			"machine_type": "e2-small",
			"image_type": "COS_CONTAINERD",
			"labels": {
				"environment": "dev",
				"project": "policy-platform",
				"managed_by": "terraform",
			},
			"workload_metadata_config": [{
				"mode": "GKE_METADATA",
			}],
		}],
	})
	result := deny with input as pool_plan(values, true)
	count(result) == 0
}

test_machine_e2_medium_allowed if {
	values := object.union(compliant_pool_values, {
		"node_config": [{
			"machine_type": "e2-medium",
			"image_type": "COS_CONTAINERD",
			"labels": {
				"environment": "dev",
				"project": "policy-platform",
				"managed_by": "terraform",
			},
			"workload_metadata_config": [{
				"mode": "GKE_METADATA",
			}],
		}]
	})
	result := deny with input as pool_plan(values, true)
	count(result) == 0
}

test_machine_e2_standard_2_allowed if {
	values := object.union(compliant_pool_values, {
		"node_config": [{
			"machine_type": "e2-standard-2",
			"image_type": "COS_CONTAINERD",
			"labels": {
				"environment": "dev",
				"project": "policy-platform",
				"managed_by": "terraform",
			},
			"workload_metadata_config": [{
				"mode": "GKE_METADATA",
			}],
		}]
	})
	result := deny with input as pool_plan(values, true)
	count(result) == 0
}

test_machine_unapproved_type_denied if {
	values := object.union(compliant_pool_values, {
		"node_config": [{
			"machine_type": "e2-standard-4",
			"image_type": "COS_CONTAINERD",
			"labels": {
				"environment": "dev",
				"project": "policy-platform",
				"managed_by": "terraform",
			},
			"workload_metadata_config": [{
				"mode": "GKE_METADATA",
			}],
		}]
	})
	result := deny with input as pool_plan(values, true)
	count(result) == 1
	result[_] == "Node pool google_container_node_pool.primary_nodes uses unapproved machine type: e2-standard-4"
}
