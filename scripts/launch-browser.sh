#!/usr/bin/env bash
# Open Chrome with a persistent aitools profile.
# --remote-debugging-port=9222 enables CDP so browser-use can attach via `connect`.
# Idempotent: if port 9222 is already listening (any Chrome, any profile,
# any project), this exits 0 without launching a second instance.

set -euo pipefail

PORT=9222

if lsof -iTCP:"$PORT" -sTCP:LISTEN -n -P >/dev/null 2>&1; then
  echo "Port $PORT already listening — reusing existing Chrome debug session." >&2
  lsof -iTCP:"$PORT" -sTCP:LISTEN -n -P >&2
  exit 0
fi

exec "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --user-data-dir="$HOME/.chrome-profiles/aitools" \
  --remote-debugging-port="$PORT" \
  "$@"
