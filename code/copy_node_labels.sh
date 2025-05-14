#!/bin/bash
set -euo pipefail

function error() {
  echo "$@" >&2
}

node_groups_json=$(yc managed-kubernetes node-group list --folder-id "$FOLDER_ID" --format json)
groups_count=$(echo "$node_groups_json" | jq 'length')

if (( groups_count == 0 )); then
  error "No node groups found"
  exit 1
fi

for ((i=0; i<groups_count; i++)); do
  node_group=$(echo "$node_groups_json" | jq ".[$i]")
  node_group_id=$(echo "$node_group" | jq -r ".id")
  instance_group_id=$(echo "$node_group" | jq -r ".instance_group_id")
  node_labels=$(echo "$node_group" | jq '.node_labels // {}')
  labels_count=$(echo "$node_labels" | jq 'length')

  if (( labels_count == 0 )); then
    echo "Node group $node_group_id has no labels, skipping"
    continue
  fi

  echo "Processing node group id=$node_group_id with instance group id=$instance_group_id"

  instances_json=$(yc compute instance-group list-instances --folder-id "$FOLDER_ID" --id "$instance_group_id" --format json)
  instances_count=$(echo "$instances_json" | jq 'length')

  if (( instances_count == 0 )); then
    echo "  No instances found in instance group $instance_group_id"
    continue
  fi

  label_str=$(echo "$node_labels" | jq -r '
    to_entries
    | map(
        .key |= (
          ascii_downcase
          | gsub("[^a-z0-9\\-_.\\/\\\\@]"; "_")
          | if test("^[a-z]") then . else "a"+. end
          | .[:63]
        )
        | .value |= (
          ascii_downcase
          | gsub("[^a-z0-9\\-_.\\/\\\\@]"; "_")
          | .[:63]
        )
        | "\(.key)=\(.value)"
      )
    | join(",")
  ')

  for ((j=0; j<instances_count; j++)); do
    instance_id=$(echo "$instances_json" | jq -r ".[$j].instance_id")
    instance_name=$(echo "$instances_json" | jq -r ".[$j].name")

    echo "  Adding labels $label_str to instance $instance_name ($instance_id)..."
    yc compute instance add-labels --folder-id "$FOLDER_ID" --id "$instance_id" --labels "$label_str" >/dev/null 2>&1
    echo "  Labels added to instance $instance_name"

    boot_disk_id=$(yc compute instance get --folder-id "$FOLDER_ID" --id "$instance_id" --format json | jq -r '.boot_disk.disk_id')

    if [[ -n "$boot_disk_id" && "$boot_disk_id" != "null" ]]; then
      echo "  Adding labels $label_str to disk $boot_disk_id..."
      yc compute disk add-labels --folder-id "$FOLDER_ID" --id "$boot_disk_id" --labels "$label_str" >/dev/null 2>&1
      echo "  Labels added to disk $boot_disk_id"
    else
      echo "  Boot disk not found for instance $instance_name ($instance_id)"
    fi
  done
done
