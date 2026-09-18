package main

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]
	resource.type == "google_project_iam_member"

	role := resource.values.role
	role in {"roles/owner", "roles/editor"}

	msg := sprintf(
		"IAM resource %s grants overly broad project role: %s",
		[resource.address, role],
	)
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]
	resource.type == "google_service_account_key"

	msg := sprintf(
		"Service account key resource %s is not allowed; use managed identity instead",
		[resource.address],
	)
}
