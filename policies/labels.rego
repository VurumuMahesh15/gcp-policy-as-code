package terraform.labels

deny contains msg if {
    resource := input.planned_values.root_module.resources[_]

    required := ["environment", "project", "managed_by"]

    some label in required

    not resource.values.labels[label]

    msg := sprintf(
        "Resource %s is missing required label: %s",
        [resource.address, label]
    )
}