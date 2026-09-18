package main

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]

	resource.type == "google_compute_firewall"

	"0.0.0.0/0" in resource.values.source_ranges

	msg := sprintf(
		"Firewall rule %s allows traffic from 0.0.0.0/0",
		[resource.address],
	)
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]

	resource.type == "google_compute_firewall"

	"0.0.0.0/0" in resource.values.source_ranges

	some allow in resource.values.allow
	allow.protocol == "tcp"
	some port in allow.ports
	port == "22"

	msg := sprintf(
		"Firewall rule %s allows unrestricted SSH access from 0.0.0.0/0",
		[resource.address],
	)
}

deny contains msg if {
	resource := input.planned_values.root_module.resources[_]

	resource.type == "google_compute_firewall"

	"0.0.0.0/0" in resource.values.source_ranges

	some allow in resource.values.allow
	allow.protocol == "tcp"
	some port in allow.ports
	port == "3389"

	msg := sprintf(
		"Firewall rule %s allows unrestricted RDP access from 0.0.0.0/0",
		[resource.address],
	)
}
