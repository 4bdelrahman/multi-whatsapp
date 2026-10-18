
#!/bin/bash
set -eu

export HOME=/config
export DISPLAY=:0
export XDG_RUNTIME_DIR=/tmp/runtime
export DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/dbus-session

mkdir -p "$HOME" "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# Start the virtual desktop
Xvfb :0 -screen 0 1440x900x24 -ac &
sleep 2

fluxbox &
sleep 2

# Start a password-protected VNC server
if [ -z "${VNC_PASSWORD:-}" ]; then
  echo "ERROR: Set VNC_PASSWORD in EasyPanel."
  exit 1
fi

mkdir -p /tmp/vnc
x11vnc -storepasswd "$VNC_PASSWORD" /tmp/vnc/passwd

x11vnc \
  -display :0 \
  -rfbauth /tmp/vnc/passwd \
  -rfbport 5900 \
  -localhost \
  -forever \
  -shared &

# Expose the VNC desktop through the browser
websockify \
  --web=/usr/share/novnc \
  6080 \
  localhost:5900 &

# Start Electron
cd /app
npm start -- --no-sandbox
