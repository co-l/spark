# Spark

Distributed vLLM inference cluster management across two GPU nodes.

## Setup

1. Copy `.env.example` to `.env` and fill in your node IPs:
   ```bash
   cp .env.example .env
   ```

2. On each spark node, copy `scripts/` and set up the benchmark environment:
   ```bash
   scp -r scripts spark@<node>:~
   ssh <node> "python3 -m venv ~/.venv && .venv/bin/pip install torch && chmod +x scripts/benchmark.sh"
   ```

   Or if CUDA is already installed in the system Python:
   ```bash
   ssh <node> "python3 -m venv ~/.venv && ~/.venv/bin/pip install torch --index-url https://download.pytorch.org/whl/cu121"
   ```

## Usage

| Command | Description |
|---------|-------------|
| `./spark-tune.sh` | Tune GPU clocks and benchmark nodes before starting |
| `./spark-start.sh` | Launch the vLLM cluster and tail logs |
| `./spark-stop.sh` | Stop containers cleanly |
| `./spark-shutdown.sh` | Stop cluster then power down nodes |

## Attach to Cluster

```bash
ssh -t <spark1> 'tmux attach -t vllm'
```

## Configuration

Edit `.env` to change IPs, TFLOPS threshold, GPU clocks, session name, etc.