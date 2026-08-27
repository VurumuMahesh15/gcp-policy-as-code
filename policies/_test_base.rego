package main

# Fully-compliant cluster values. Tests overlay exactly one violation via
# object.union so only the policy under test fires.
compliant_cluster_values(env) := {
	"resource_labels": {
		"environment": env,
		"project": "p",
		"managed_by": "terraform",
	},
	"deletion_protection": true,
	"private_cluster_config": [{"enable_private_nodes": true}],
	"network_policy": [{"enabled": true}],
	"master_authorized_networks_config": [{"cidr_blocks": [{"cidr_block": "1.2.3.4/32"}]}],
}

# Cluster values with an explicit labels map (avoids deep merge from union).
cluster_values_with_labels(labels) := {
	"resource_labels": labels,
	"deletion_protection": true,
	"private_cluster_config": [{"enable_private_nodes": true}],
	"network_policy": [{"enabled": true}],
	"master_authorized_networks_config": [{"cidr_blocks": [{"cidr_block": "1.2.3.4/32"}]}],
}

# Fully-compliant node pool values.
compliant_pool_values := {
	"node_config": [{
		"machine_type": "e2-small",
		"image_type": "COS_CONTAINERD",
		"labels": {"environment": "dev", "project": "p", "managed_by": "terraform"},
		"workload_metadata_config": [{"mode": "GKE_METADATA"}],
	}],
	"management": [{"auto_repair": true, "auto_upgrade": true}],
}

# Cluster-only plan (no configuration section).
cluster_plan(values) := {
	"planned_values": {"root_module": {"resources": [{
		"address": "google_container_cluster.primary",
		"type": "google_container_cluster",
		"values": values,
	}]}},
}

# SA expression for the node pool config; declares a reference to the dedicated
# service account only when has_sa is true.
sa_expression(has_sa) := {
	"service_account": {"references": ["google_service_account.gke_nodes.email"]},
} if has_sa

sa_expression(has_sa) := {} if not has_sa

# Node-pool plan; has_sa controls the service account in the configuration section.
pool_plan(values, has_sa) := {
	"planned_values": {"root_module": {"resources": [{
		"address": "google_container_node_pool.primary_nodes",
		"type": "google_container_node_pool",
		"values": values,
	}]}},
	"configuration": {"root_module": {"resources": [{
		"address": "google_container_node_pool.primary_nodes",
		"type": "google_container_node_pool",
		"name": "primary_nodes",
		"expressions": {"node_config": [sa_expression(has_sa)]},
	}]}},
}
