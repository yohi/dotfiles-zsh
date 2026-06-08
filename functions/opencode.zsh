#!/usr/bin/env zsh
opencode() {
    local ai_component_dir="${DOTFILES_SHELL_ROOT:-$HOME/dotfiles/components}/dotfiles-ai"
    local wrapper="${ai_component_dir}/_scripts/opencode-wrapper.sh"

    if [[ -x "$wrapper" ]]; then
        # Use the dynamic configuration wrapper
        "$wrapper" "$@"
    else
        # Fallback to direct call if wrapper is missing
        command opencode "$@"
    fi
}
