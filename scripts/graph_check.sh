#!/bin/ksh
# load_daily_sales.ksh

# 1. Source the environment configuration
. ./graph_config.env

# 2. Check if the input file exists
if [[ ! -f ${AI_SERIAL}/${INPUT_FILENAME} ]]; then
    echo "Error: Input file missing."
    exit 1
fi

# 3. Execute the Ab Initio graph
# The graph (process_sales.mp) uses the DML defined above
air sandbox run process_sales.mp \
    -INPUT_FILE ${AI_SERIAL}/${INPUT_FILENAME} \
    -OUTPUT_TABLE "STG_DAILY_SALES" \
    -DML_PATH ${AI_DML}/customer_data.dml

# 4. Check return code
if [[ $? -eq 0 ]]; then
    echo "Graph completed successfully."
else
    echo "Graph failed. Check error logs."
fi