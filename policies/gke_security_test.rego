package main

# --- Private nodes ---

test_gke_private_nodes_enabled if {
	result := deny with input as cluster_plan(compliant_cluster_values("dev"))
	count(result) == 0
}

test_gke_private_nodes_disabled if {
	values := object.union(compliant_cluster_values("dev"), {"private_cluster_config": [{"enable_private_nodes": false}]})
	result := deny with input as cluster_plan(values)
	count(result) == 1
	result[_] == "Cluster google_container_cluster.primary must enable private nodes"
}

# --- Network policy ---

test_gke_network_policy_disabled if {
	values := object.union(compliant_cluster_values("dev"), {"network_policy": [{"enabled": false}]})
	result := deny with input as cluster_plan(values)
	count(result) == 1
	result[_] == "Cluster google_container_cluster.primary must enable network policy"
}

# --- Master authorized networks ---

test_gke_master_networks_open if {
	values := object.union(compliant_cluster_values("dev"), {"master_authorized_networks_config": [{"cidr_blocks": []}]})
	result := deny with input as cluster_plan(values)
	count(result) == 1
	result[_] == "Cluster google_container_cluster.primary must restrict master authorized networks"
}

# --- COS_CONTAINERD image ---

test_gke_cos_container_image if {
	result := deny with input as pool_plan(compliant_pool_values, true)
	count(result) == 0
}

test_gke_non_cos_image if {
	values := object.union(compliant_pool_values, {
		"node_config": [{
			"machine_type": "e2-small",
			"image_type": "cos",
			"labels": {"environment": "dev", "project": "p", "managed_by": "terraform"},
			"workload_metadata_config": [{"mode": "GKE_METADATA"}],
		}],
	})
	result := deny with input as pool_plan(values, true)
	count(result) == 1
	result[_] == "Node pool google_container_node_pool.primary_nodes must use COS_CONTAINERD image, got \"cos\""
}

# --- GKE_METADATA mode ---

test_gke_metadata_server_mode if {
	values := object.union(compliant_pool_values, {
		"node_config": [{
			"machine_type": "e2-small",
			"image_type": "COS_CONTAINERD",
			"labels": {"environment": "dev", "project": "p", "managed_by": "terraform"},
			"workload_metadata_config": [{"mode": "GKE_METADATA_SERVER"}],
		}],
	})
	result := deny with input as pool_plan(values, true)
	count(result) == 1
	result[_] == "Node pool google_container_node_pool.primary_nodes must use GKE_METADATA workload metadata mode, got \"GKE_METADATA_SERVER\""
}

# --- Auto repair / auto upgrade ---

test_gke_auto_repair_disabled if {
	values := object.union(compliant_pool_values, {"management": [{"auto_repair": false, "auto_upgrade": true}]})
	result := deny with input as pool_plan(values, true)
	count(result) == 1
	result[_] == "Node pool google_container_node_pool.primary_nodes must enable auto repair"
}

test_gke_auto_upgrade_disabled if {
	values := object.union(compliant_pool_values, {"management": [{"auto_repair": true, "auto_upgrade": false}]})
	result := deny with input as pool_plan(values, true)
	count(result) == 1
	result[_] == "Node pool google_container_node_pool.primary_nodes must enable auto upgrade"
}

# --- Dedicated service account ---

test_gke_has_dedicated_service_account if {
	result := deny with input as pool_plan(compliant_pool_values, true)
	count(result) == 0
}

test_gke_uses_default_service_account if {
	result := deny with input as pool_plan(compliant_pool_values, false)
	count(result) == 1
	result[_] == "Node pool google_container_node_pool.primary_nodes must use a dedicated (non-default) service account"
}
