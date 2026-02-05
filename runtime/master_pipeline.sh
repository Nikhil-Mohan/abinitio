#!/bin/sh
set -eu

echo "[PIPELINE] Starting ETL run"

RUN_MODE=${RUN_MODE:-DEV}

# Bootstrap directories
mkdir -p data/curated data/processed logs public

# Validate Go module
echo "[PIPELINE] Validating Go module"
test -f go.mod || { echo "go.mod missing"; exit 1; }
echo "[PIPELINE] Go module validated"

# Validate input
if [ ! -f data/raw/user_events.csv ]; then
  echo "[ERROR] Input file missing"
  exit 1
fi

# Run transformation (compiled binary)
echo "[PIPELINE] Running user aggregation"
./etl > logs/etl.log 2>&1

# Validate output
if [ ! -f data/curated/user_activity_summary.csv ]; then
  echo "[ERROR] Curated output not generated"
  exit 1
fi

# Promote curated → processed
cp data/curated/user_activity_summary.csv data/processed/

echo "[PIPELINE] Processed data available at data/processed/user_activity_summary.csv"

# Metrics
ROWS=$(($(wc -l < data/processed/user_activity_summary.csv) - 1))

# Generate simple dashboard
cat <<EOF > public/index.html
<html>
<body>
<h2>ETL Dashboard</h2>
<p>Mode: $RUN_MODE</p>
<p>Rows: $ROWS</p>
<pre>$(tail -20 logs/etl.log)</pre>
</body>
</html>
EOF

# DEV only: start dashboard
if [ "$RUN_MODE" = "DEV" ]; then
  echo "[PIPELINE] Starting dashboard on port 8080"
  python3 -m http.server 8080 --directory public &
  sleep 10
else
  echo "[PIPELINE] CI mode – dashboard skipped"
fi

echo "[PIPELINE] ETL completed successfully"
exit 0
