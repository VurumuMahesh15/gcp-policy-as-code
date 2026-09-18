package main

public_members := {
	"allUsers",
	"allAuthenticatedUsers",
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]

	resource.type == "google_storage_bucket_iam_member"

	resource.values.member in public_members

	msg := sprintf(
		"Bucket IAM resource %s grants access to public member: %s",
		[resource.address, resource.values.member],
	)
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]

	resource.type == "google_storage_bucket_iam_binding"

	some member in resource.values.members
	member in public_members

	msg := sprintf(
		"Bucket IAM resource %s grants access to public member: %s",
		[resource.address, member],
	)
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]

	resource.type == "google_storage_bucket"

	resource.values.uniform_bucket_level_access != true

	msg := sprintf(
		"Bucket %s must enable uniform bucket-level access",
		[resource.address],
	)
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]

	resource.type == "google_storage_bucket"

	not resource.values.versioning[0].enabled == true

	msg := sprintf(
		"Storage bucket %s must enable versioning",
		[resource.address],
	)
}
