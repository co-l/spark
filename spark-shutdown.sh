#!/bin/bash
# Stop the cluster then shut down both spark nodes.

SPARK1=192.168.1.223
SPARK2=192.168.1.82

SCRIPT_DIR="$(dirname "$0")"
"$SCRIPT_DIR/spark-stop.sh"

echo "Shutting down nodes..."
ssh "$SPARK1" "sudo shutdown -h now" &
ssh "$SPARK2" "sudo shutdown -h now" &
wait

echo "Shutdown commands sent."
