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

test_firewall_ssh_open_world if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_compute_firewall.ssh_open",
		"type": "google_compute_firewall",
		"values": {
			"source_ranges": ["0.0.0.0/0"],
			"allow": [{"protocol": "tcp", "ports": ["22"]}],
		},
	}]}}}
	result := deny with input as inp
	count(result) == 2
	result[_] == "Firewall rule google_compute_firewall.ssh_open allows unrestricted SSH access from 0.0.0.0/0"
}

test_firewall_rdp_open_world if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_compute_firewall.rdp_open",
		"type": "google_compute_firewall",
		"values": {
			"source_ranges": ["0.0.0.0/0"],
			"allow": [{"protocol": "tcp", "ports": ["3389"]}],
		},
	}]}}}
	result := deny with input as inp
	count(result) == 2
	result[_] == "Firewall rule google_compute_firewall.rdp_open allows unrestricted RDP access from 0.0.0.0/0"
}

test_firewall_ssh_restricted if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_compute_firewall.ssh_restricted",
		"type": "google_compute_firewall",
		"values": {
			"source_ranges": ["10.0.0.0/8"],
			"allow": [{"protocol": "tcp", "ports": ["22"]}],
		},
	}]}}}
	result := deny with input as inp
	count(result) == 0
}

test_firewall_http_open_world_no_ssh_rdp if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_compute_firewall.http_open",
		"type": "google_compute_firewall",
		"values": {
			"source_ranges": ["0.0.0.0/0"],
			"allow": [{"protocol": "tcp", "ports": ["80"]}],
		},
	}]}}}
	result := deny with input as inp
	count(result) == 1
	result[_] == "Firewall rule google_compute_firewall.http_open allows traffic from 0.0.0.0/0"
}
