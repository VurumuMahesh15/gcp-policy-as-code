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
        [resource.address, resource.values.member]
    )
}