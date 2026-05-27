#!/usr/bin/env zsh
# ===================================================================
# opencode: AI Agent Harness Wrapper
# ===================================================================

opencode() {
    # 1. Automatic Port Detection (4090-4100)
    local port=""
    if command -v ss >/dev/null 2>&1; then
        for p in {4090..4100}; do
            if ! ss -tln | grep -q ":$p " >/dev/null 2>&1; then
                port=$p
                break
            fi
        done
    fi

    # 2. Profile Loading
    local effective_profile="${PROFILE:-personal}"
    # Use a more robust way to find the dotfiles components directory
    local ai_component_dir="${DOTFILES_SHELL_ROOT:-$HOME/dotfiles/components}/dotfiles-ai"
    local env_file="${ai_component_dir}/opencode/${effective_profile}.env"

    if [[ -f "$env_file" ]]; then
        # Load and EXPORT each line
        # This handles quotes correctly and ensures they are exported to the environment
        while read -r line || [[ -n "$line" ]]; do
            # Skip comments and empty lines
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${line//[[:space:]]/}" ]] && continue
            
            # Use eval to let the shell parse the assignment (handles quotes, spaces, etc.)
            eval "export $line"
        done < "$env_file"
        
        local status_msg="✅ Profile [${effective_profile}]"
    else
        # If the file isn't found, we want to know why
        echo "⚠️  Profile file not found: $env_file" >&2
        local status_msg="❌ Profile [${effective_profile}] (Not Found)"
    fi

    # 3. Execution
    if [[ -n "$port" ]]; then
        echo "${status_msg} | Port [${port}]"
        if [[ "$*" != *"--port"* ]]; then
            command opencode --port "$port" "$@"
        else
            command opencode "$@"
        fi
    else
        echo "${status_msg} | Port [default]"
        command opencode "$@"
    fi
}
