#!/usr/bin/env zsh
opencode() {
    local port=""
    if command -v ss >/dev/null 2>&1; then
        for p in {4090..4100}; do
            if ! ss -tln | grep -q ":$p " >/dev/null 2>&1; then
                port=$p
                break
            fi
        done
    fi

    local effective_profile="${PROFILE:-personal}"
    local ai_component_dir="${DOTFILES_SHELL_ROOT:-$HOME/dotfiles/components}/dotfiles-ai"
    local env_file="${ai_component_dir}/opencode/${effective_profile}.env"

    if [[ -f "$env_file" ]]; then
        set -a
        source "$env_file"
        set +a
        # echo "DEBUG: Loaded $env_file"
        # echo "DEBUG: ULTRABRAIN_MODEL is $ULTRABRAIN_MODEL"
    fi

    if [[ -n "$port" ]]; then
        echo "✅ Profile [${effective_profile}] | Port [${port}]"
        command opencode --port "$port" "$@"
    else
        echo "✅ Profile [${effective_profile}] | Port [default]"
        command opencode "$@"
    fi
}
