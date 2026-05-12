#!/bin/bash
set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Set NODE_EXE
NODE_EXE="$SCRIPT_DIR/node/node.exe"
if [ ! -f "$NODE_EXE" ]; then
  NODE_EXE="node"
fi

# Check if config.json exists
if [ ! -f "$SCRIPT_DIR/config.json" ]; then
  echo "[ERROR] config.json not found."
  echo "Press any key to exit..."
  read -n 1
  exit 1
fi

echo "Opening DeepSeek login browser..."
echo "Please complete login in the browser window. After completion, you can press Ctrl+C to close this console."
echo ""

"$NODE_EXE" "$SCRIPT_DIR/src/index.js" --login

echo ""
echo "Press any key to exit..."
read -n 1
