#!/usr/bin/env zsh
# ===================================================================
# opencode: AI Agent Harness Wrapper
# ===================================================================
#
# Usage: [PROFILE=work|personal] opencode [options]
#
# Features:
#   - Automatic port assignment (4090-4100)
#   - Profile-based environment loading from dotfiles-ai
#
# Examples:
#   PROFILE=work opencode
#   opencode run "Hello"
# ===================================================================

opencode() {
    # 1. Automatic Port Detection (4090-4100)
    local port=""
    for p in {4090..4100}; do
        # Check if port is in use using zsh's /dev/tcp
        if ! (echo > /dev/tcp/127.0.0.1/$p) >/dev/null 2>&1; then
            port=$p
            break
        fi
    done

    # 2. Profile Loading (if PROFILE is set)
    local effective_profile="${PROFILE:-personal}"
    if [[ -n "$effective_profile" ]]; then
        # Resolve dotfiles-ai directory
        # DOTFILES_SHELL_ROOT is defined in dotfiles-zsh/zshrc
        local ai_component_dir="${DOTFILES_SHELL_ROOT}/dotfiles-ai"
        local env_file="${ai_component_dir}/opencode/${effective_profile}.env"

        if [[ -f "$env_file" ]]; then
            # Load environment variables
            while IFS= read -r line || [[ -n "$line" ]]; do
                # Skip comments and empty lines
                [[ "$line" =~ ^[[:space:]]*# ]] && continue
                [[ -z "${line//[[:space:]]/}" ]] && continue
                
                # Export the variable
                export "${line}"
            done < "$env_file"
            
            echo "✅ Profile [${effective_profile}] loaded"
        else
            echo "⚠️  Profile [${effective_profile}] specified but $env_file not found." >&2
        fi
    fi

    # 3. Execution
    if [[ -n "$port" ]]; then
        # Add --port only if we found an available one and it's not already specified
        if [[ "$*" != *"--port"* ]]; then
            command opencode --port "$port" "$@"
        else
            command opencode "$@"
        fi
    else
        command opencode "$@"
    fi
}
