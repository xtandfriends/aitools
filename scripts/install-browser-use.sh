#!/usr/bin/env bash
# Install browser-use CLI with a pyenv-backed venv.
#
# Why not just run the upstream installer directly?
#   The upstream installer (https://browser-use.com/cli/install.sh) picks the
#   first `python3.13` it finds on PATH, which on macOS is usually Homebrew's
#   `python@3.13` — a framework build. Framework Python ships a `Python.app`
#   bundle, so every browser-use invocation bounces a Python rocket icon in
#   the Dock. Pyenv's default build is non-framework → no bundle, no bounce.
#
# Strategy:
#   Pre-create `~/.browser-use-env` pointing at a pyenv interpreter, then run
#   the upstream installer. Its `install_browser_use` step only creates the
#   venv when the directory is missing, so our pre-created venv survives and
#   just gets populated with packages.
#
# Idempotent: safe to re-run. Will recreate the venv only if its interpreter
# no longer points at pyenv (e.g., someone ran the upstream installer bare).

set -euo pipefail

PYENV_VERSION="${BROWSER_USE_PYENV_VERSION:-3.13.3}"
VENV_DIR="$HOME/.browser-use-env"
PYENV_PY="$HOME/.pyenv/versions/$PYENV_VERSION/bin/python${PYENV_VERSION%.*}"

# --- Preconditions -----------------------------------------------------------

if [ ! -x "$PYENV_PY" ]; then
  echo "error: pyenv interpreter not found at $PYENV_PY" >&2
  echo "       install it with: pyenv install $PYENV_VERSION" >&2
  exit 1
fi

if ! command -v uv >/dev/null 2>&1; then
  echo "error: uv not found on PATH. Install it first:" >&2
  echo "       curl -LsSf https://astral.sh/uv/install.sh | sh" >&2
  exit 1
fi

# --- Venv: create or repair so it points at pyenv ----------------------------

needs_recreate=1
if [ -d "$VENV_DIR" ]; then
  current_base=$("$VENV_DIR/bin/python" -c 'import sys; print(sys.base_prefix)' 2>/dev/null || echo "")
  if [ "$current_base" = "$HOME/.pyenv/versions/$PYENV_VERSION" ]; then
    needs_recreate=0
    echo "venv already pyenv-backed ($current_base) — keeping it."
  else
    echo "venv base_prefix is '$current_base' — recreating against pyenv."
  fi
fi

if [ "$needs_recreate" = "1" ]; then
  rm -rf "$VENV_DIR"
  uv venv "$VENV_DIR" --python "$PYENV_PY"
fi

# --- Run upstream installer (skips venv creation since dir exists) -----------

curl -fsSL https://browser-use.com/cli/install.sh | bash

# --- Verify ------------------------------------------------------------------

base=$("$VENV_DIR/bin/python" -c 'import sys; print(sys.base_prefix)')
if [ "$base" != "$HOME/.pyenv/versions/$PYENV_VERSION" ]; then
  echo "error: venv base_prefix is '$base', expected pyenv path" >&2
  exit 1
fi
echo "ok: browser-use venv backed by $base (non-framework Python, no Dock rocket)."
