#!/usr/bin/env/bash
# EUCLID inference runner
# This script runs the EUCLID predictive inference engine

set -euo pipefail

VERSION="v9.0.1"
MODEL_DIR="/home/user/.euclid/models"
CONFIG="$HOME/.euclid/config.yaml"

if [[ ! -f "$CONFIG" ]]; then
    echo "Configuration not found at $CONFIG"
    exit 1
fi

echo "EUCLID v$VERSION - Starting predictive inference..."
echo "Loading model from $MODEL_DIR"

# Simulate model loading time
sleep 2

# Run the inference
python3 -c "
import sys
sys.path.insert(0, '/home/user/euclid/src')
from euclid.src.cli import main
main()
"

echo "Inference complete. Prediction saved to ~/.euclid/output.txt"