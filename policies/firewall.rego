package terraform.firewall

deny contains msg if {
    resource := input.planned_values.root_module.resources[_]

    resource.type == "google_compute_firewall"

    "0.0.0.0/0" in resource.values.source_ranges

    msg := sprintf(
        "Firewall rule %s allows traffic from 0.0.0.0/0",
        [resource.address]
    )
}