# if [ "$TERM_PROGRAM" = "vscode" ]; then
#   return
# fi

# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n] confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Determine dotfiles root directory (resolves symlinks)
export DOTFILES_SHELL_ROOT="${${(%):-%N}:A:h:h}" # resolves to components/
export ZSH_CONFIG_DIR="${DOTFILES_SHELL_ROOT}/dotfiles-zsh"

# Load environment variables and secrets
[[ -f "$ZSH_CONFIG_DIR/dot-zsh_env" ]] && source "$ZSH_CONFIG_DIR/dot-zsh_env"
[[ -f "$ZSH_CONFIG_DIR/dot-zsh_secrets" ]] && source "$ZSH_CONFIG_DIR/dot-zsh_secrets"

# Claude Code オプトアウト環境変数
export DISABLE_TELEMETRY=1
export DISABLE_ERROR_REPORTING=1
export DISABLE_BUG_COMMAND=1
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# コマンドのスペルミスを指摘
setopt correct
alias la="ls -a"
alias ll="ls -l"
alias du="du -h"
alias df="df -h"
alias ld="lazydocker"
alias lg="lazygit"

# ディレクトリ作成と移動
mkdirdate() {
    local d=$(date +"%Y%m%d")
    mkdir -p "$d" && cd "$d"
}

mkdirdatetime() {
    local d=$(date +"%Y%m%d%H%M%S")
    mkdir -p "$d" && cd "$d"
}

# ls で ディレクトリに色を付ける
autoload -Uz compinit
# Fix insecure directories in $fpath
if [[ -n "$(compaudit 2>/dev/null)" ]]; then
    compaudit 2>/dev/null | xargs -r chmod g-w,o-w
fi
compinit

# DELETE KEY 有効化
bindkey "^[[3~" delete-char
#
# HOMEBREW
if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

#     echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /home/y_ohi/.zprofile
#     echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/y_ohi/.zprofile
#     eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
# export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"

# SSH AGENT - Disabled by default, uncomment if needed
# eval $(ssh-agent)

# dockerコンテナに入る。deで実行できる - DISABLED (peco dependency)
# alias de='docker exec -it $(docker ps | peco | cut -d " " -f 1) /bin/bash'

# エクスプローラオープン
alias open='xdg-open .'

# ZSH実行時のコメント許可
setopt interactivecomments

# コマンド履歴系
#
# 履歴ファイルの保存先
export HISTFILE="${HOME}/.zsh_history"

# メモリに保存される履歴の件数
export HISTSIZE=10000

# 履歴ファイルに保存される履歴の件数
export SAVEHIST=1000000

# コマンド履歴共有
setopt share_history

# ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_all_dups

# スペースで始まるコマンド行はヒストリリストから削除
setopt hist_ignore_space

# ヒストリを呼び出してから実行する間に一旦編集可能
setopt hist_verify

# 余分な空白は詰めて記録
setopt hist_reduce_blanks

# 古いコマンドと同じものは無視
setopt hist_save_no_dups

# historyコマンドは履歴に登録しない
setopt hist_no_store

# 補完時にヒストリを自動的に展開
setopt hist_expand

# 履歴をインクリメンタルに追加
setopt inc_append_history

# 開始と終了を記録
setopt EXTENDED_HISTORY

# 🔒 CursorIDE/Claude Code 履歴無効化設定
# CursorIDEやClaude Codeでのコマンド履歴を無効化してプライバシーを保護
#
# 検出条件:
# - TERM_PROGRAM が cursor または vscode を含む
# - VSCODE_INJECTION 環境変数が存在
# - CURSOR_SESSION_ID 環境変数が存在
# - DISABLE_CLAUDE_CODE_HISTORY=1 で強制無効化
# - カレントディレクトリがcursor terminal関連
# - 親プロセスがcursor/codeの場合
#
# 手動で無効化したい場合: export DISABLE_CLAUDE_CODE_HISTORY=1
# 手動で有効化したい場合: unset DISABLE_CLAUDE_CODE_HISTORY (または export DISABLE_CLAUDE_CODE_HISTORY="")
if [[ -n "${TERM_PROGRAM:-}" ]] && [[ "${TERM_PROGRAM}" =~ (cursor|vscode) ]] || \
   [[ -n "${VSCODE_INJECTION:-}" ]] || \
   [[ -n "${CURSOR_SESSION_ID:-}" ]] || \
   [[ -n "${DISABLE_CLAUDE_CODE_HISTORY:-}" ]] || \
   [[ "${PWD}" =~ cursor.*terminal ]] || \
   { [[ -n "${PPID:-}" ]] && { parent_process_info=$(ps -p "${PPID}" -o comm= 2>/dev/null || true); [[ -n "$parent_process_info" ]] && echo "$parent_process_info" | grep -Eqi 'cursor|code'; }; }; then

    # 履歴を無効化
    export HISTFILE=/dev/null        # 履歴ファイルを無効化
    export HISTSIZE=1                # メモリ内履歴を最小限に
    export SAVEHIST=0                # ファイル保存履歴を無効化
    setopt HIST_NO_STORE 2>/dev/null || true  # 履歴コマンド自体を保存しない

    # デバッグ情報（必要に応じてコメントアウト解除）
    # echo "🔒 IDE環境検出: コマンド履歴を無効化しました (TERM_PROGRAM=${TERM_PROGRAM:-'N/A'})"
fi



# MySQL@5.7 configuration (disabled by default)
# export PATH="/home/linuxbrew/.linuxbrew/opt/mysql@5.7/bin:$PATH"
# export LDFLAGS="-L/home/linuxbrew/.linuxbrew/opt/mysql@5.7/lib"
# export CPPFLAGS="-I/home/linuxbrew/.linuxbrew/opt/mysql@5.7/include"
# export PKG_CONFIG_PATH="/home/linuxbrew/.linuxbrew/opt/mysql@5.7/lib/pkgconfig"

# peco settings - DISABLED
# # 過去に実行したコマンドを選択。ctrl-rにバインド
# function peco-select-history() {
#   local selected_command
#   selected_command=$(\history -n -r 1 | sed 's/[[:cntrl:]]//g' | peco --query "$LBUFFER" 2>/dev/null)
#   if [[ -n "$selected_command" ]]; then
#     BUFFER="$selected_command"
#     CURSOR=$#BUFFER
#   fi
#   zle clear-screen
# }
# zle -N peco-select-history
# bindkey '^r' peco-select-history

# search a destination from cdr list - DISABLED
# function peco-get-destination-from-cdr() {
#   cdr -l | \
#   sed -e 's/^[[:digit:]]*[[:blank:]]*//' | \
#   peco --query "$LBUFFER"
# }

# ### 過去に移動したことのあるディレクトリを選択。ctrl-uにバインド - DISABLED
# function peco-cdr() {
#   local destination="$(peco-get-destination-from-cdr)"
#   if [ -n "$destination" ]; then
#     BUFFER="cd $destination"
#     zle accept-line
#   else
#     zle reset-prompt
#   fi
# }
# zle -N peco-cdr
# bindkey '^u' peco-cdr

###
# function ec2-ssm() {
#     local profile=$(aws configure list-profiles | peco )
#     local instance_id=$(aws --profile ${profile} ec2 describe-instances --filter "Name=instance-state-name,Values=running" "Name=dns-name,Values=" | \
#         jq -r '.Reservations[].Instances[] | .InstanceId + " " +  (.Tags[] | select(.Key=="Name").Value)' | \
#         peco | awk '{print $1}')
#     aws --profile ${profile} ssm start-session --target ${instance_id}
# }
# zle -N ec2-ssm


# ブランチを簡単切り替え。git checkout lbで実行できる - DISABLED (peco dependency)
# alias -g lb='`git branch | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`'

# export DENO_INSTALL=$HOME/.deno
# export PATH="$DENO_INSTALL/bin:$PATH"




# Editor configuration (consolidated from multiple locations)
unset LESSEDIT

# nodenv initialization (ensure shims are prioritized in PATH)
if command -v nodenv 1>/dev/null 2>&1; then
  export PATH="$HOME/.nodenv/shims:${PATH}"
  eval "$(nodenv init -)"
fi

# direnv hook
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi




alias pip='pip3'
alias python='python3'
export PATH="/home/linuxbrew/.linuxbrew/opt/python@3.11/libexec/bin:$PATH"

# function nvimvenv {
#   if [[ -e "$VIRTUAL_ENV" && -f "$VIRTUAL_ENV/bin/activate" ]]; then
#     source "$VIRTUAL_ENV/bin/activate"
#     command nvim $@
#     deactivate
#   else
#     command nvim $@
#   fi
# }
#
# alias nvim=nvimvenv

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh



### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

if [[ -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
    source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
    autoload -Uz _zinit
    (( ${+_comps} )) && _comps[zinit]=_zinit
fi

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

zinit light zdharma-continuum/fast-syntax-highlighting
# zinit light zdharma/history-search-multi-word  # Disabled due to conflict with peco
zinit light zsh-users/zsh-autosuggestions
zinit light junegunn/fzf-bin

# Load powerlevel10k theme
zinit ice depth"1"
zinit light romkatv/powerlevel10k

# 残骸
# # Load a few important annexes, without Turbo
# # (this is currently required for annexes)
# zinit ice from"gh-r" as"program"
# zinit light-mode for \
# zinit wait lucid atload"zicompinit; zicdreplay" blockf for zsh-users/zsh-completions


### End of Zinit's installer chunk

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


alias kgnome='killall -3 gnome-shell'

# カスタム関数の読み込み（サイレント版 - Powerlevel10k instant prompt対応）

# Load config.zsh for customization
[[ -f "$ZSH_CONFIG_DIR/config.zsh" ]] && source "$ZSH_CONFIG_DIR/config.zsh"

# 互換性と環境変数のための最終調整
export DOTFILES_DIR="${DOTFILES_OVERRIDE:-${DOTFILES_ROOT:-${DOTFILES_SHELL_ROOT}}}"

# config.zsh の設定を反映（未定義時のデフォルト値設定）
typeset functions_subdir="${FUNCTIONS_SUBDIR:-"functions"}"
typeset functions_pattern="${FUNCTIONS_PATTERN:-"**/*.zsh"}"
typeset debug_functions="${FUNCTIONS_DEBUG:-${ZSH_FUNCTIONS_DEBUG:-false}}"

if [[ "$debug_functions" == "true" ]]; then
    echo "🔍 DOTFILES_DIR検出: $DOTFILES_DIR"
    echo "🔍 関数ディレクトリ存在確認: $DOTFILES_DIR/$functions_subdir"
fi

if [[ -d "$ZSH_CONFIG_DIR/$functions_subdir" ]]; then
    # パフォーマンス最適化: glob結果を配列に格納してから処理
    typeset -a func_files
    func_files=("$ZSH_CONFIG_DIR/$functions_subdir"/${~functions_pattern}(N))

    # サブディレクトリを含む全てのzshファイルを再帰的に読み込み
    for func_file in "${func_files[@]}"; do
        [[ ! -r "$func_file" ]] && continue

        # config.zsh の FUNCTIONS_SKIP_PATTERNS にマッチするファイルをスキップ
        typeset skip=false
        if (( ${+FUNCTIONS_SKIP_PATTERNS} )); then
            for pattern in "${FUNCTIONS_SKIP_PATTERNS[@]}"; do
                if [[ "${func_file:t}" == ${~pattern} ]]; then
                    skip=true
                    break
                fi
            done
        fi
        
        if [[ "$skip" == "true" ]]; then
            [[ "$debug_functions" == "true" ]] && echo "⚠️  スキップ: ${func_file:t} (パターン一致)"
            continue
        fi

        # 関数ファイルを安全に読み込み（サイレント）
        if source "$func_file" 2>/dev/null; then
            [[ "$debug_functions" == "true" ]] && echo "✅ 読み込み成功: ${func_file:t}"
        else
            # エラー時のみ出力（instant prompt後に表示）
            {
                echo "❌ zsh関数読み込み失敗: $func_file"
                echo "   構文エラーまたは依存関係の問題があります"
                echo "   デバッグ: FUNCTIONS_DEBUG=true で詳細確認可能"
            } >&2
        fi
    done
    [[ "$debug_functions" == "true" ]] && echo "✅ 関数読み込み完了: $ZSH_CONFIG_DIR/$functions_subdir (${#func_files[@]} files)"
else
    # 関数ディレクトリが見つからない場合の警告
    {
        echo "⚠️  zsh関数ディレクトリが見つかりません"
        echo "   検出したDOTFILES_SHELL_ROOT: ${DOTFILES_SHELL_ROOT:-'(未検出)'}"
        echo "   期待ディレクトリ: \$DOTFILES_DIR/$functions_subdir"
        echo "   設定方法: zsh/config.zsh で修正するか export DOTFILES_DIR を設定"
    } >&2
fi

# Add dotfiles component bin directories to PATH dynamically
if [[ -n "$DOTFILES_SHELL_ROOT" ]]; then
    # Source .env files from each component if they exist
    for env_file in "$DOTFILES_SHELL_ROOT"/*/.env(N); do
        set -a
        source "$env_file"
        set +a
    done

    # Use zsh globbing to find all _bin directories under components
    for bin_dir in "$DOTFILES_SHELL_ROOT"/**/_bin(N/); do
        export PATH="$bin_dir:$PATH"
    done
fi

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
