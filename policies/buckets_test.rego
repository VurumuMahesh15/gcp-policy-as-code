package main

test_buckets_private if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_storage_bucket_iam_member.private",
		"type": "google_storage_bucket_iam_member",
		"values": {"member": "user:dev@example.com"},
	}]}}}
	result := deny with input as inp
	count(result) == 0
}

test_buckets_all_users if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_storage_bucket_iam_member.public",
		"type": "google_storage_bucket_iam_member",
		"values": {"member": "allUsers"},
	}]}}}
	result := deny with input as inp
	count(result) == 1
	result[_] == "Bucket IAM resource google_storage_bucket_iam_member.public grants access to public member: allUsers"
}

test_buckets_all_authenticated if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_storage_bucket_iam_member.public",
		"type": "google_storage_bucket_iam_member",
		"values": {"member": "allAuthenticatedUsers"},
	}]}}}
	result := deny with input as inp
	count(result) == 1
}

test_buckets_binding_public if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_storage_bucket_iam_binding.public",
		"type": "google_storage_bucket_iam_binding",
		"values": {"members": ["user:dev@example.com", "allUsers"]},
	}]}}}
	result := deny with input as inp
	count(result) == 1
	result[_] == "Bucket IAM resource google_storage_bucket_iam_binding.public grants access to public member: allUsers"
}

test_buckets_binding_private if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_storage_bucket_iam_binding.private",
		"type": "google_storage_bucket_iam_binding",
		"values": {"members": ["user:dev@example.com"]},
	}]}}}
	result := deny with input as inp
	count(result) == 0
}

test_buckets_uniform_access_disabled if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_storage_bucket.data",
		"type": "google_storage_bucket",
		"values": {
			"uniform_bucket_level_access": false,
			"versioning": [{"enabled": true}],
		},
	}]}}}
	result := deny with input as inp
	count(result) == 1
	result[_] == "Bucket google_storage_bucket.data must enable uniform bucket-level access"
}

test_buckets_versioning_disabled if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_storage_bucket.data",
		"type": "google_storage_bucket",
		"values": {
			"uniform_bucket_level_access": true,
			"versioning": [{"enabled": false}],
		},
	}]}}}
	result := deny with input as inp
	count(result) == 1
	result[_] == "Storage bucket google_storage_bucket.data must enable versioning"
}

test_buckets_secure if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_storage_bucket.secure",
		"type": "google_storage_bucket",
		"values": {
			"uniform_bucket_level_access": true,
			"versioning": [{"enabled": true}],
		},
	}]}}}
	result := deny with input as inp
	count(result) == 0
}

test_bucket_uniform_access_real_boolean_enabled if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_storage_bucket.test",
		"type": "google_storage_bucket",
		"values": {
			"uniform_bucket_level_access": true,
			"versioning": [{"enabled": true}],
		},
	}]}}}
	result := deny with input as inp
	count(result) == 0
}

test_bucket_uniform_access_real_boolean_disabled if {
	inp := {"planned_values": {"root_module": {"resources": [{
		"address": "google_storage_bucket.test",
		"type": "google_storage_bucket",
		"values": {
			"uniform_bucket_level_access": false,
			"versioning": [{"enabled": true}],
		},
	}]}}}
	result := deny with input as inp
	count(result) == 1
	result[_] == "Bucket google_storage_bucket.test must enable uniform bucket-level access"
}
