# ~/.zshenv - Zsh環境変数設定（全シェルで読み込まれる）
# This file is sourced on all invocations of the shell.
# Load order: .zshenv → .zshrc → .zsh_env

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# uv
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"

# Fix Homebrew Zsh version path issue - add system Zsh functions as fallback
# When Homebrew updates Zsh (e.g., 5.9 -> 5.9.1), the versioned Cellar path
# in fpath may break. System Zsh functions are stable and version-independent.
fpath=(/usr/share/zsh/functions $fpath)
