#!/bin/bash
# Launch vLLM cluster on spark1 inside a tmux session and attach to it.
# Safely kills any existing session first.
# Usage: ./spark-start.sh [extra run-recipe.py args]

SCRIPT_DIR="$(dirname "$0")"
set -a && . "$SCRIPT_DIR/.env" && set +a
"$SCRIPT_DIR/spark-tune.sh" || exit

ssh "$SPARK1" "
  tmux kill-session -t $SESSION 2>/dev/null || true
  tmux new-session -d -s $SESSION -c ~/spark-vllm-docker \
    'python3 run-recipe.py $RECIPE --no-ray $* 2>&1 | tee $LOG'
"

echo "To attach to tmux: ssh -t $SPARK1 'tmux attach -t $SESSION'"
echo ""
ssh -t "$SPARK1" "tail -f $LOG"
