package main

import rego.v1

deny contains msg if {
  resource := input.resource_changes[_]
  resource.type == "local_file"
  not resource.change.after.filename
  msg := "local_file resources must specify a filename"
}
