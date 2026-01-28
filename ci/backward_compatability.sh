#!/usr/bin/env bash
set -euo pipefail

OLD=build/interface.previous.yml
NEW=graphs/user_flow/interface.yml

if [ ! -f "$OLD" ]; then
  echo "No previous interface found – skipping compatibility check"
  exit 0
fi

old_fields=$(yq '.outputs[0].schema[].name' "$OLD")
new_fields=$(yq '.outputs[0].schema[].name' "$NEW")

for field in $old_fields; do
  if ! echo "$new_fields" | grep -q "^$field$"; then
    echo "❌ Backward compatibility break: field removed → $field"
    exit 1
  fi
done

echo "✔ Backward compatibility check passed"
