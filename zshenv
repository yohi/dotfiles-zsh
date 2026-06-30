# ~/.zshenv - Zsh環境変数設定（全シェルで読み込まれる）
# This file is sourced on all invocations of the shell.
# Load order: .zshenv → .zshrc → .zsh_env
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# uv
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"

# Fix Homebrew Zsh version path issue in fpath.
# When Homebrew updates Zsh (e.g., 5.9 -> 5.9.1), the stale version path in the inherited FPATH breaks.
# We dynamically replace the stale version in the fpath array with the currently installed version.
if [[ -d /home/linuxbrew/.linuxbrew/Cellar/zsh ]]; then
    # Get the currently installed version of Zsh via Homebrew
    typeset active_zsh_ver
    active_zsh_ver=$(ls -1 /home/linuxbrew/.linuxbrew/Cellar/zsh 2>/dev/null | tail -n 1)
    if [[ -n "$active_zsh_ver" ]]; then
        # Replace "/Cellar/zsh/<stale_version>/" with the active version in fpath array safely
        # Using [0-9.]# (zsh notation for 0 or more numbers/dots) to avoid greedy matching over slashes
        fpath=(${fpath[@]/\/Cellar\/zsh\/[0-9.]#\//\/Cellar\/zsh\/$active_zsh_ver\/})
    fi
fi

# Ensure standard system paths and subdirectories are present in fpath as fallback
# Using zsh globbing to dynamically add all subdirectories under /usr/share/zsh/functions
if [[ -d /usr/share/zsh/functions ]]; then
    fpath=(
        /usr/share/zsh/functions
        /usr/share/zsh/functions/**/*(N/)
        $fpath
    )
fi

