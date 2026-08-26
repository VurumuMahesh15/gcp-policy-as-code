package main

deny contains msg if {
    resource := input.planned_values.root_module.resources[_]

    resource.type == "google_container_cluster"

    resource.values.resource_labels.environment == "production"

    resource.values.deletion_protection != true

    msg := sprintf(
        "Production cluster %s must have deletion protection enabled",
        [resource.address]
    )
}