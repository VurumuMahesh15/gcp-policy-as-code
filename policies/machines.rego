package main

allowed_machine_types := {
    "e2-small",
    "e2-medium",
    "e2-standard-2",
}

deny contains msg if {
    resource := input.planned_values.root_module.resources[_]

    resource.type == "google_container_node_pool"

    machine_type := resource.values.node_config[0].machine_type

    not machine_type in allowed_machine_types

    msg := sprintf(
        "Node pool %s uses unapproved machine type: %s",
        [resource.address, machine_type]
    )
}