# ===================================================================
# Zsh Configuration File
# ===================================================================
# このファイルで zsh 関数読み込みのパスや設定をカスタマイズできます

# DOTFILES_SHELL_ROOT のカスタム設定
# 環境変数で指定されていない場合、この値が使用されます
#DOTFILES_SHELL_ROOT="$HOME/dotfiles"

# 関数読み込みの設定
FUNCTIONS_SUBDIR="functions"           # 関数ディレクトリのサブパス
FUNCTIONS_DEBUG=${ZSH_FUNCTIONS_DEBUG:-false}  # デバッグモード

# 読み込み対象ファイルパターン
FUNCTIONS_PATTERN="**/*.zsh"               # 読み込み対象ファイル

# スキップするファイルパターン
FUNCTIONS_SKIP_PATTERNS=(
    "*.broken"
    "*.disabled"
    "*.tmp"
    "*.backup"
    "*~"
    "aws.zsh"
    "functions/aws/*"
)

# 代替検索ディレクトリ（優先度順）
CANDIDATE_DIRS=(
    "$HOME/.dotfiles"
    "$HOME/dotfiles"
    "$HOME/.config/dotfiles"
    "$HOME/dots"
    "$HOME/.dots"
)

# SkillPort 設定
# ドットファイルのベースディレクトリを特定
_resolved_dotfiles_base=""
if [[ -n "$DOTFILES_SHELL_ROOT" ]]; then
    _resolved_dotfiles_base="$DOTFILES_SHELL_ROOT"
else
    # CANDIDATE_DIRS を優先順に確認
    for dir in "${CANDIDATE_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            _resolved_dotfiles_base="$dir"
            break
        fi
    done
    # 見つからない場合はデフォルトにフォールバック
    _resolved_dotfiles_base="${_resolved_dotfiles_base:-$HOME/dotfiles}"
fi

export SKILLPORT_SKILLS_PATH="$_resolved_dotfiles_base/agent-skills"
alias sp="skillport"
alias spm="skillport-mcp"
alias spv="skillport validate"
