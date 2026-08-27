package main

test_labels_cluster_compliant if {
	result := deny with input as cluster_plan(compliant_cluster_values("dev"))
	count(result) == 0
}

test_labels_cluster_missing_environment if {
	values := cluster_values_with_labels({"project": "p", "managed_by": "terraform"})
	result := deny with input as cluster_plan(values)
	count(result) == 1
	result[_] == "Cluster google_container_cluster.primary is missing required label: environment"
}

test_labels_cluster_missing_managed_by if {
	values := cluster_values_with_labels({"environment": "dev", "project": "p"})
	result := deny with input as cluster_plan(values)
	count(result) == 1
	result[_] == "Cluster google_container_cluster.primary is missing required label: managed_by"
}

test_labels_node_pool_compliant if {
	result := deny with input as pool_plan(compliant_pool_values, true)
	count(result) == 0
}

test_labels_node_pool_missing_project if {
	values := object.union(compliant_pool_values, {
		"node_config": [{
			"machine_type": "e2-small",
			"image_type": "COS_CONTAINERD",
			"labels": {"environment": "dev", "managed_by": "terraform"},
			"workload_metadata_config": [{"mode": "GKE_METADATA"}],
		}],
	})
	result := deny with input as pool_plan(values, true)
	count(result) == 1
	result[_] == "Node pool google_container_node_pool.primary_nodes is missing required label: project"
}
