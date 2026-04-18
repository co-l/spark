#!/bin/bash
# Stop the cluster then shut down both spark nodes.

SCRIPT_DIR="$(dirname "$0")"
set -a && . "$SCRIPT_DIR/.env" && set +a
"$SCRIPT_DIR/spark-stop.sh"

echo "Shutting down nodes..."
ssh "$SPARK1" "sudo shutdown -h now" &
ssh "$SPARK2" "sudo shutdown -h now" &
wait

echo "Shutdown commands sent."
