#!/bin/sh
set -eu

echo "[PIPELINE] Starting ETL run"

RUN_MODE=${RUN_MODE:-DEV}

# Bootstrap directories
mkdir -p data/curated data/processed logs public

# Validate ETL Library
echo "[PIPELINE] Validating ETL Library"
test -x ./etl || { echo "ETL binary missing"; exit 1; }
echo "[PIPELINE] ETL Library validated"

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
<!DOCTYPE html>
<html>
<head>
  <title>ETL Dashboard</title>
</head>
<body>
<h2>ETL Dashboard</h2>
<p><strong>Mode:</strong> $RUN_MODE</p>
<p><strong>Rows Processed:</strong> $ROWS</p>
<h3>Recent Logs</h3>
<pre>$(tail -20 logs/etl.log)</pre>
</body>
</html>
EOF

# Verify dashboard was created
if [ ! -f public/index.html ]; then
  echo "[ERROR] Failed to create index.html"
  exit 1
fi
echo "[PIPELINE] Dashboard created: public/index.html ($(wc -c < public/index.html) bytes)"

# DEV only: start dashboard
if [ "$RUN_MODE" = "DEV" ]; then
  echo "[PIPELINE] Starting dashboard on port 8080"
  chmod +x runtime/serve.py
  python3 runtime/serve.py &
  DASHBOARD_PID=$!
  sleep 2
  echo "[PIPELINE] Dashboard PID: $DASHBOARD_PID"
else
  echo "[PIPELINE] CI mode – dashboard skipped"
fi

echo "[PIPELINE] ETL completed successfully"
exit 0
