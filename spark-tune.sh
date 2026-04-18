#!/bin/bash
# Tune and benchmark both spark nodes in parallel

SCRIPT_DIR="$(dirname "$0")"
set -a && . "$SCRIPT_DIR/.env" && set +a

echo "Tuning nodes..."
ssh "$SPARK1" "sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'" &
ssh "$SPARK1" "sudo nvidia-smi -lgc 200,$MAX" &
ssh "$SPARK2" "sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'" &
ssh "$SPARK2" "sudo nvidia-smi -lgc 200,$MAX" &
wait
echo "Tuning commands sent."

echo "Benchmarking nodes..."
TMP1=$(mktemp)
TMP2=$(mktemp)
trap "rm -f $TMP1 $TMP2" EXIT

ssh "$SPARK1" "./benchmark.sh" > "$TMP1" 2>&1 &
ssh "$SPARK2" "./benchmark.sh" > "$TMP2" 2>&1 &
wait

RESULT1=$(cat "$TMP1")
RESULT2=$(cat "$TMP2")

echo "$RESULT1"
echo "$RESULT2"

TFLOPS1=$(echo "$RESULT1" | grep -oP '[\d.]+(?= TFLOPS)')
TFLOPS2=$(echo "$RESULT2" | grep -oP '[\d.]+(?= TFLOPS)')

FAILED=0

check_tflops() {
    local node=$1
    local tflops=$2
    if [[ -z "$tflops" ]]; then
        echo "⚠️  Could not parse TFLOPS for $node"
        return 1
    fi
    if (( $(echo "$tflops < $THRESHOLD" | bc -l) )); then
        cat <<'EOF'

    ██████╗ ██████╗     ██████╗ ██╗   ██╗ ██████╗
    ██╔══██╗██╔══██╗    ██╔══██╗██║   ██║██╔════╝
    ██████╔╝██║  ██║    ██████╔╝██║   ██║██║  ███╗
    ██╔═══╝ ██║  ██║    ██╔══██╗██║   ██║██║   ██║
    ██║     ██████╔╝    ██████╔╝╚██████╔╝╚██████╔╝
    ╚═╝     ╚═════╝     ╚═════╝  ╚═════╝  ╚═════╝
EOF
        echo ""
        echo "    ⚡ $node: ${tflops} TFLOPS (threshold: ${THRESHOLD})"
        echo "    → Unplug node, unplug power brick, replug, reboot"
        echo ""
        return 1
    fi
    echo "✓ $node: ${tflops} TFLOPS"
    return 0
}

check_tflops "SPARK1 ($SPARK1)" "$TFLOPS1" || FAILED=1
check_tflops "SPARK2 ($SPARK2)" "$TFLOPS2" || FAILED=1

echo "Benchmarking done."
exit $FAILED
