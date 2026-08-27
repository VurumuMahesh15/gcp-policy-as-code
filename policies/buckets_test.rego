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
