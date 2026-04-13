#!/bin/bash
# Cleanly stop the vLLM cluster: stops docker containers on both nodes
# and kills the tmux session on spark1.

SPARK1=192.168.1.223
SPARK2=192.168.1.82
SESSION=vllm
CONTAINER=vllm_node

echo "Stopping cluster..."

ssh "$SPARK1" "docker stop $CONTAINER 2>/dev/null; tmux kill-session -t $SESSION 2>/dev/null; echo 'spark1 done'" &
ssh "$SPARK2" "docker stop $CONTAINER 2>/dev/null; echo 'spark2 done'" &
wait

echo "Cluster stopped."
