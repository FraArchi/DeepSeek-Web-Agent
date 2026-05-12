#!/bin/bash
set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if config.json exists
if [ ! -f "$SCRIPT_DIR/config.json" ]; then
  echo "[ERROR] config.json not found."
  read -n 1 -p "Press any key to exit..."
  echo ""
  exit 1
fi

# Read port from config.json
PORT=$(grep -o '"port"[[:space:]]*:[[:space:]]*[0-9]*' "$SCRIPT_DIR/config.json" | grep -o '[0-9]*')

# Find and stop processes listening on the port
echo "Looking for processes listening on port $PORT..."

if command -v lsof &> /dev/null; then
  PIDS=$(lsof -t -i :"$PORT" 2>/dev/null || true)
  if [ -z "$PIDS" ]; then
    echo "Port $PORT currently has no listening processes."
    read -n 1 -p "Press any key to exit..."
    echo ""
    exit 0
  fi
  
  for PID in $PIDS; do
    echo "Stopping PID $PID, port $PORT"
    kill -9 "$PID" 2>/dev/null || true
  done
else
  # Fallback: try to use fuser
  if command -v fuser &> /dev/null; then
    PIDS=$(fuser -k -9 "$PORT"/tcp 2>/dev/null || true)
    if [ -z "$PIDS" ]; then
      echo "Port $PORT currently has no listening processes."
    else
      echo "Stopped processes on port $PORT"
    fi
  else
    echo "Cannot determine processes on port $PORT. Please install lsof or fuser."
    echo "Port $PORT currently has no listening processes (assumed)."
  fi
fi

echo ""
read -n 1 -p "Press any key to exit..."
echo ""
