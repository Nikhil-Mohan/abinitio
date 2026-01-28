#!/usr/bin/env bash
set -euo pipefail

echo "[PIPELINE] Starting ETL run"

# Bootstrap directories
mkdir -p data/curated data/processed

# Validate input
if [ ! -f data/raw/user_events.csv ]; then
  echo "[ERROR] Input file missing"
  exit 1
fi

# Run transformation
echo "[PIPELINE] Running user aggregation"
go run transforms/user_aggregate.go

# Validate output
if [ ! -f data/curated/user_activity_summary.csv ]; then
  echo "[ERROR] Curated output not generated"
  exit 1
fi

# Promote curated → processed (real ETL step)
cp data/curated/user_activity_summary.csv data/processed/

echo "[PIPELINE] ETL completed successfully"
echo "[PIPELINE] Processed data available at data/processed/user_activity_summary.csv"