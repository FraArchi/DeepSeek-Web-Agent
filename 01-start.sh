#!/bin/bash
set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

APP_DIR="$SCRIPT_DIR"
NODE_EXE="$SCRIPT_DIR/node/node.exe"
if [ ! -f "$NODE_EXE" ]; then
  NODE_EXE="node"
fi
COUNTDOWN=5

# Check if config.json exists
if [ ! -f "$SCRIPT_DIR/config.json" ]; then
  echo "[ERROR] config.json not found."
  pause
  exit 1
fi

# Check if node_modules/playwright is installed
if [ ! -f "$SCRIPT_DIR/node_modules/playwright/package.json" ]; then
  echo "[ERROR] node_modules is incomplete. Please keep node_modules in this folder."
  pause
  exit 1
fi

echo "Starting DeepSeekWeb2API in background..."
echo "Config: $SCRIPT_DIR/config.json"
echo "Logs: $SCRIPT_DIR/logs"
echo ""

# Read port from config.json
PORT=$(grep -o '"port"[[:space:]]*:[[:space:]]*[0-9]*' "$SCRIPT_DIR/config.json" | grep -o '[0-9]*')

# Check if port is already in use
if command -v lsof &> /dev/null; then
  if lsof -i :"$PORT" &> /dev/null; then
    echo "Port $PORT is already listening. Skip duplicate start."
    COUNTDOWN_ACTIVE=true
  fi
else
  # Fallback: try to check with netstat or ss
  if ss -tuln 2>/dev/null | grep -q ":$PORT "; then
    echo "Port $PORT is already listening. Skip duplicate start."
    COUNTDOWN_ACTIVE=true
  fi
fi

if [ -z "$COUNTDOWN_ACTIVE" ]; then
  # Create logs directory
  mkdir -p "$SCRIPT_DIR/logs"
  
  # Start the process in background
  nohup "$NODE_EXE" "$SCRIPT_DIR/src/index.js" > "$SCRIPT_DIR/logs/service.out.log" 2> "$SCRIPT_DIR/logs/service.err.log" &
  PID=$!
  
  sleep 1
  
  # Check if process is still running
  if ! kill -0 $PID 2>/dev/null; then
    echo ""
    echo "[ERROR] Background start failed. Please check logs/service.err.log."
    read -p "Press Enter to continue..."
    exit 1
  fi
  
  echo "Background process started. PID: $PID"
fi

# Countdown
echo ""
echo "$COUNTDOWN seconds until this window closes automatically. The program will continue running in the background."
echo "To stop it, please run the stop script."
echo ""
for i in $(seq $COUNTDOWN -1 1); do
  echo "$i seconds until close..."
  sleep 1
done

echo ""
exit 0
