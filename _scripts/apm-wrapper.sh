#!/bin/bash
# apm-wrapper.sh: wrapper for standard APM command to allow transient local overrides
set -euo pipefail

# Find the real apm command (excluding this wrapper script)
REAL_APM=$(which -a apm | grep -v "$0" | head -n 1 || true)

if [ -z "$REAL_APM" ]; then
  echo "Error: standard apm command not found on PATH." >&2
  exit 1
fi

if [ "${1:-}" = "install" ] && [ -f apm.yml ]; then
  echo "--> [Wrapper] Applying version overrides from version.env temporarily..."

  # Setup cleanup trap to ensure file restoration even on failure
  cleanup() {
    if [ -f apm.yml.bak ]; then
      mv apm.yml.bak apm.yml
    fi
    if [ -f apm.lock.yaml.bak ]; then
      mv apm.lock.yaml.bak apm.lock.yaml
    fi
  }
  trap cleanup EXIT INT TERM

  # 1. Back up original files
  cp apm.yml apm.yml.bak
  [ -f apm.lock.yaml ] && cp apm.lock.yaml apm.lock.yaml.bak

  # 2. Modify apm.yml based on version.env using Python
  python3 -c '
import os, re

env = {}
if os.path.exists("version.env"):
    with open("version.env", "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                env[k.strip()] = v.strip().strip("\"").strip("\x27")

with open("apm.yml", "r", encoding="utf-8") as f:
    content = f.read()

for k, v in env.items():
    if k.startswith("APM_"):
        repo_name = k[4:].lower().replace("_", "-")
        # 1. replace shorthand (owner/repo#ref)
        content = re.sub(
            rf"({repo_name}#[a-zA-Z0-9_\.\-]+)",
            f"{repo_name}#{v}",
            content
        )

with open("apm.yml", "w", encoding="utf-8") as f:
    f.write(content)
'

  # 3. Run the real apm install command
  "$REAL_APM" "$@"
  
  echo "--> [Wrapper] Version overrides reverted. Working tree clean."
else
  # Delegate other commands to real apm
  exec "$REAL_APM" "$@"
fi
