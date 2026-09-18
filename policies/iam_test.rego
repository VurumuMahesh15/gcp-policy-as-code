package main

test_iam_scoped_role_allowed if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_project_iam_member.gke_nodes_logging",
		"type": "google_project_iam_member",
		"values": {"role": "roles/logging.logWriter"},
	}]}}}
	result := deny with input as inp
	count(result) == 0
}

test_iam_editor_denied if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_project_iam_member.overly_broad",
		"type": "google_project_iam_member",
		"values": {"role": "roles/editor"},
	}]}}}
	result := deny with input as inp
	count(result) == 1
	result[_] == "IAM resource google_project_iam_member.overly_broad grants overly broad project role: roles/editor"
}

test_iam_owner_denied if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_project_iam_member.overly_broad",
		"type": "google_project_iam_member",
		"values": {"role": "roles/owner"},
	}]}}}
	result := deny with input as inp
	count(result) == 1
	result[_] == "IAM resource google_project_iam_member.overly_broad grants overly broad project role: roles/owner"
}

test_service_account_key_denied if {
	inp := {
		"planned_values": {
			"root_module": {
				"resources": [{
					"address": "google_service_account_key.test",
					"type": "google_service_account_key",
					"values": {},
				}],
			},
		},
	}
	result := deny with input as inp
	count(result) == 1
	result[_] == "Service account key resource google_service_account_key.test is not allowed; use managed identity instead"
}
