package main

test_deletion_production_protected if {
	result := deny with input as cluster_plan(compliant_cluster_values("production"))
	count(result) == 0
}

test_deletion_production_unprotected if {
	values := object.union(compliant_cluster_values("production"), {"deletion_protection": false})
	result := deny with input as cluster_plan(values)
	count(result) == 1
	result[_] == "Production cluster google_container_cluster.primary must have deletion protection enabled"
}

test_deletion_non_production_unprotected if {
	values := object.union(compliant_cluster_values("dev"), {"deletion_protection": false})
	result := deny with input as cluster_plan(values)
	count(result) == 0
}
