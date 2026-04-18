# Spark

Distributed vLLM inference cluster management across two GPU nodes.

## Setup

Copy `.env.example` to `.env` and fill in your node IPs:

```bash
cp .env.example .env
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