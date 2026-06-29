# apm.zsh: APM custom wrapper loader
apm() {
    local zsh_component_dir="${DOTFILES_SHELL_ROOT:-$HOME/dotfiles/components}/dotfiles-zsh"
    local wrapper="${zsh_component_dir}/_scripts/apm-wrapper.sh"

    if [[ -x "$wrapper" ]]; then
        # Use the dynamic configuration wrapper
        "$wrapper" "$@"
    else
        # Fallback to direct call if wrapper is missing
        command apm "$@"
    fi
}
