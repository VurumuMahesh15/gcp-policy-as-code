package main

test_machines_approved if {
	result := deny with input as pool_plan(compliant_pool_values, true)
	count(result) == 0
}

test_machines_unapproved if {
	values := object.union(compliant_pool_values, {
		"node_config": [{
			"machine_type": "n1-standard-8",
			"image_type": "COS_CONTAINERD",
			"labels": {"environment": "dev", "project": "p", "managed_by": "terraform"},
			"workload_metadata_config": [{"mode": "GKE_METADATA"}],
		}],
	})
	result := deny with input as pool_plan(values, true)
	count(result) == 1
	result[_] == "Node pool google_container_node_pool.primary_nodes uses unapproved machine type: n1-standard-8"
}
