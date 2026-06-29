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
  YML_BAK=""
  LOCK_BAK=""
  cleanup() {
    if [ -n "$YML_BAK" ] && [ -f "$YML_BAK" ]; then
      mv "$YML_BAK" apm.yml
    fi
    if [ -n "$LOCK_BAK" ] && [ -f "$LOCK_BAK" ]; then
      mv "$LOCK_BAK" apm.lock.yaml
    fi
  }
  trap cleanup EXIT INT TERM

  # 1. Back up original files
  YML_BAK=$(mktemp apm.yml.XXXXXX)
  cp apm.yml "$YML_BAK"
  if [ -f apm.lock.yaml ]; then
    LOCK_BAK=$(mktemp apm.lock.yaml.XXXXXX)
    cp apm.lock.yaml "$LOCK_BAK"
  fi

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
    lines = f.readlines()

new_lines = []
in_deps_or_skills = False

for line in lines:
    stripped = line.strip()
    if not line.startswith(" ") and not line.startswith("\t"):
        if stripped.startswith("dependencies:") or stripped.startswith("skills:"):
            in_deps_or_skills = True
        elif stripped and ":" in stripped:
            in_deps_or_skills = False

    if in_deps_or_skills and stripped.startswith("-"):
        for k, v in env.items():
            if k.startswith("APM_"):
                repo_name = k[4:].lower().replace("_", "-")
                pattern = rf"(?P<prefix>(?:^|/|//)){repo_name}#[a-zA-Z0-9_\.\-]+"
                def replace_func(m):
                    prefix = m.group("prefix")
                    return f"{prefix}{repo_name}#{v}"
                line = re.sub(pattern, replace_func, line)
    new_lines.append(line)

with open("apm.yml", "w", encoding="utf-8") as f:
    f.writelines(new_lines)
'

  # 3. Run the real apm install command
  "$REAL_APM" "$@"
  
  echo "--> [Wrapper] Version overrides reverted. Working tree clean."
else
  # Delegate other commands to real apm
  exec "$REAL_APM" "$@"
fi
