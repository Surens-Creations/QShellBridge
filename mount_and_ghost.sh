#!/bin/bash

# === CONFIG ===
MOUNT_POINT="/Users/surensahaydachny/repl"
SSH_KEY="$HOME/.ssh/replit2"
SSH_USER="0878ae1c-00ff-427e-af71-d1227c194900"
SSH_HOST="0878ae1c-00ff-427e-af71-d1227c194900-00-buxxwefgcfiw.kirk.replit.dev"
SSH_PORT=22
REMOTE_PATH="/home/runner/workspace"
LOG_DIR="$HOME/.ghostlog"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/session_$TIMESTAMP.log"

# === CREATE LOG + MOUNT DIRS ===
echo "📁 Creating log directory..."
mkdir -p "$LOG_DIR"
mkdir -p "$MOUNT_POINT"

# === MOUNT REMOTE FILESYSTEM ===
echo "🔗 Mounting Replit filesystem via SSHFS..."
sshfs \
  -o IdentityFile="$SSH_KEY" \
  -p "$SSH_PORT" \
  "${SSH_USER}@${SSH_HOST}:${REMOTE_PATH}" \
  "$MOUNT_POINT"

# === CHECK SUCCESS ===
if mount | grep -q "$MOUNT_POINT"; then
  echo "✅ Replit filesystem mounted at: $MOUNT_POINT"
else
  echo "❌ Failed to mount remote FS. Check your SSH credentials and permissions."
  exit 1
fi

# === LAUNCH GHOSTSHELL IN NEW TERMINAL TAB ===
if [ -f "ghostshell.py" ]; then
  echo "👻 Launching GhostShell in new tab..."
  osascript <<EOF
tell application "Terminal"
  activate
  do script "cd \"$(pwd)\" && python3 ghostshell.py | tee \"$LOG_FILE\"; umount \"$MOUNT_POINT\"; echo '🛑 Replit FS unmounted.'"
end tell
EOF
else
  echo "⚠️ ghostshell.py not found in current directory."
fi