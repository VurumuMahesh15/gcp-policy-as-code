package main

test_firewall_open_world if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_compute_firewall.bad_rule",
		"type": "google_compute_firewall",
		"values": {"source_ranges": ["0.0.0.0/0"]},
	}]}}}
	result := deny with input as inp
	count(result) == 1
	result[_] == "Firewall rule google_compute_firewall.bad_rule allows traffic from 0.0.0.0/0"
}

test_firewall_restricted if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_compute_firewall.good_rule",
		"type": "google_compute_firewall",
		"values": {"source_ranges": ["10.0.0.0/8", "192.168.1.0/24"]},
	}]}}}
	result := deny with input as inp
	count(result) == 0
}
