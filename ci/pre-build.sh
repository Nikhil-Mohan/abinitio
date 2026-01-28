#!/usr/bin/env bash
set -euo pipefail

echo "▶ PRE-BUILD VALIDATION STARTED"

# 1️⃣ Validate graphs directory
if [ ! -d graphs ]; then
  echo "❌ graphs/ directory missing"
  exit 1
fi

# 2️⃣ Validate Ab Initio graph files
GRAPH_COUNT=$(find graphs -name "*.air" | wc -l | tr -d ' ')
if [ "$GRAPH_COUNT" -eq 0 ]; then
  echo "❌ No .air graph files found"
  exit 1
fi
echo "✔ Found $GRAPH_COUNT graph(s)"

# 3️⃣ Validate interface contracts
INTERFACE_COUNT=$(find graphs -name "interface.yml" | wc -l | tr -d ' ')
if [ "$INTERFACE_COUNT" -eq 0 ]; then
  echo "❌ interface.yml missing"
  exit 1
fi
echo "✔ Interface contract(s) present"

# 4️⃣ Validate runtime pipeline
if [ ! -f runtime/master_pipeline.sh ]; then
  echo "❌ runtime/master_pipeline.sh missing"
  exit 1
fi

if [ ! -x runtime/master_pipeline.sh ]; then
  echo "⚠ Making runtime/master_pipeline.sh executable"
  chmod +x runtime/master_pipeline.sh
fi
echo "✔ Runtime pipeline ready"

# 5️⃣ Prevent hardcoded PROD paths (real ETL rule)
if grep -R "/data/prod" graphs runtime >/dev/null 2>&1; then
  echo "❌ Hardcoded PROD path detected"
  exit 1
fi

echo "✔ PRE-BUILD VALIDATION PASSED"
echo "✔ PRE-BUILD VALIDATION COMPLETED"