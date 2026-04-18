#!/bin/bash
echo "Launching benchmark..."
.venv/bin/python3 benchmark.py 2>&1 | grep TFLOPS