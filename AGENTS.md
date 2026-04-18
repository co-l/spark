# Spark vLLM Cluster Management

## Overview

This repository manages a distributed vLLM inference cluster across two physical GPU nodes ("spark1" and "spark2"). The cluster runs inside Docker containers and is controlled via SSH from a local management machine.

**Tech Stack**: Bash scripts, SSH, tmux, Docker, nvidia-smi, vLLM

**High-Level Architecture**:
- `spark1` (``cat .env | grep SPARK1 | cut -d= -f2``): Primary node - runs the `run-recipe.py` controller inside a tmux session
- `spark2` (``cat .env | grep SPARK2 | cut -d= -f2``): Secondary node - participates in the distributed cluster
- Local machine: Issues commands via SSH to both nodes

## Directory Structure

```
.                       # Root: shell scripts for cluster control
├── .env                # Cluster configuration (IPs, thresholds, etc.)
├── spark-start.sh     # Launch vLLM cluster in tmux, tail logs
├── spark-stop.sh       # Stop containers and kill tmux session
├── spark-shutdown.sh   # Stop cluster then hard-shutdown both nodes
├── spark-tune.sh       # Tune GPU clocks and benchmark both nodes
```

## Build, Lint, Test Commands

This is a shell script project—no build system. Validation is manual:
- Review script logic for correctness before editing
- Test changes with `./script.sh` (or equivalent) on actual hardware

## Code Conventions

- **Shebang**: `#!/bin/bash` on all scripts
- **Variable naming**: Uppercase for constants (e.g., `SPARK1`, `SESSION`, `RECIPE`), lowercase for locals
- **Paths**: Use `$(dirname "$0")` for script-relative paths
- **SSH**: Always quote commands passed to remote hosts to avoid local expansion issues
- **Parallelism**: Use `&` + `wait` to parallelize SSH calls to multiple nodes
- **Error handling**: Use `2>/dev/null` for expected failures (e.g., `tmux kill-session` when no session exists); propagate errors via exit codes
- **Logging**: Use `/tmp/vllm.log` for cluster logs; `mktemp` + `trap cleanup EXIT` for temporary files

## Key Abstractions

| Concept | Implementation |
|---------|----------------|
| Cluster lifecycle | `spark-start.sh` → `spark-stop.sh` / `spark-shutdown.sh` |
| Node tuning | `spark-tune.sh` — drops caches, sets GPU clocks via `nvidia-smi -lgc` |
| Benchmarking | Remote `./benchmark.sh` script on each node; parses TFLOPS output |
| Container management | `docker stop vllm_node` on each node |
| Session management | tmux session named `vllm` on spark1 |

## Common Pitfalls

1. **Unquoted SSH commands**: `ssh $HOST "echo $VAR"` expands `$VAR` locally. Use `ssh $HOST 'echo $VAR'` or escape: `"echo \$VAR"`.

2. **Parallel SSH without wait**: Forked SSH processes (`&`) won't be reaped. Always `wait` before reading results or exiting.

3. **Timing-sensitive cluster startup**: `spark-start.sh` tails logs immediately. vLLM may need time to initialize containers.

4. **Hard shutdown during operation**: `spark-shutdown.sh` sends `sudo shutdown -h now`. Only use after `spark-stop.sh` to cleanly terminate containers.

5. **GPU clock persistence**: `nvidia-smi -lgc` sets clocks temporarily. They reset on reboot—`spark-tune.sh` must be re-run after each boot.

6. **TFLOPS threshold**: Defined in `.env` (`THRESHOLD=58`), used by `spark-tune.sh`. GPUs below this threshold likely have thermal/power issues.