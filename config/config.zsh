# ===================================================================
# Zsh Configuration File
# ===================================================================
# このファイルで zsh 関数読み込みのパスや設定をカスタマイズできます

# DOTFILES_DIR のカスタム設定
# 環境変数で指定されていない場合、この値が使用されます
#DOTFILES_DIR="$HOME/dotfiles"

# 関数読み込みの設定
FUNCTIONS_SUBDIR="zsh/functions"           # 関数ディレクトリのサブパス
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
_resolved_dotfiles_base="$DOTFILES_DIR"
if [[ -z "$_resolved_dotfiles_base" ]]; then
    for dir in "${CANDIDATE_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            _resolved_dotfiles_base="$dir"
            break
        fi
    done
fi
# デフォルト値として $HOME/dots を使用（いずれも見つからない場合）
_resolved_dotfiles_base="${_resolved_dotfiles_base:-$HOME/dots}"

export SKILLPORT_SKILLS_PATH="$_resolved_dotfiles_base/agent-skills"
alias sp="skillport"
alias spm="skillport-mcp"
alias spv="skillport validate"
