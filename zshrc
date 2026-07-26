# if [ "$TERM_PROGRAM" = "vscode" ]; then
#   return
# fi

# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"

# Determine dotfiles root directory (resolves symlinks)
export DOTFILES_SHELL_ROOT="${${(%):-%N}:A:h:h}" # resolves to components/
export ZSH_CONFIG_DIR="${DOTFILES_SHELL_ROOT}/dotfiles-zsh"


# Load environment variables and secrets
[[ -f "$ZSH_CONFIG_DIR/zsh_env" ]] && source "$ZSH_CONFIG_DIR/zsh_env"
[[ -f "$ZSH_CONFIG_DIR/.zsh_secrets" ]] && source "$ZSH_CONFIG_DIR/.zsh_secrets"

# Claude Code オプトアウト環境変数
export DISABLE_TELEMETRY=1
export DISABLE_ERROR_REPORTING=1
export DISABLE_BUG_COMMAND=1
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# コマンドのスペルミスを指摘
setopt correct
alias la="ls -a"
alias ll="ls -l"
# alias du="du -h"
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
# Use cached completions unless the dump file is older than 24 hours or missing.
# This avoids the ~25s full compinit rebuild on every shell startup.
typeset -i compinit_cache_seconds=86400
typeset zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
if [[ -e "$zcompdump" ]]; then
    typeset -i dump_age
    dump_age=$(($(date +%s) - $(date -r "$zcompdump" +%s 2>/dev/null || stat -c %Y "$zcompdump" 2>/dev/null)))
    if (( dump_age < compinit_cache_seconds )); then
        compinit -C -d "$zcompdump"
    else
        compinit -d "$zcompdump"
    fi
else
    mkdir -p "${zcompdump:h}"
    compinit -d "$zcompdump"
fi

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


# ブランチを簡単切り替え。git checkout lbで実行できる - DISABLED (peco dependency)
# alias -g lb='`git branch | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`'

# export DENO_INSTALL=$HOME/.deno
# export PATH="$DENO_INSTALL/bin:$PATH"




# Editor configuration (consolidated from multiple locations)
unset LESSEDIT

# Lazy nodenv initialization to avoid the ~2s startup cost of `nodenv init -`.
# Only configures PATH/shims; `nodenv rehash` is run on first actual nodenv use.
if command -v nodenv 1>/dev/null 2>&1; then
    export PATH="$HOME/.nodenv/shims:${PATH}"
    nodenv() {
        unset -f nodenv 1>/dev/null 2>&1
        eval "$(command nodenv init -)"
        nodenv "$@"
    }
else
    # Fallback to the original eager init if the shim directory isn't present.
    if [[ -d "$HOME/.nodenv/shims" ]]; then
        export PATH="$HOME/.nodenv/shims:${PATH}"
    fi
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

# Load zinit annexes. Required for some zinit ice modifiers but not needed during
# the initial prompt setup, so we defer them to reduce startup time.
zinit wait lucid light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# Defer non-critical plugins to reduce startup time.
# Syntax highlighting and autosuggestions work fine when loaded lazily.
zinit wait lucid for \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-autosuggestions

# Use Starship for a lightweight, cross-shell prompt.
# Starship config: starship/starship.toml
if command -v starship 1>/dev/null 2>&1; then
    export STARSHIP_CONFIG="$ZSH_CONFIG_DIR/starship/starship.toml"
    eval "$(starship init zsh)"
fi


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
    typeset -ga func_files
    func_files=("$ZSH_CONFIG_DIR/$functions_subdir"/${~functions_pattern}(N))

    # サブディレクトリを含む全てのzshファイルを再帰的に読み込み
    for func_file in "${func_files[@]}"; do
        [[ ! -r "$func_file" ]] && continue

        # config.zsh の FUNCTIONS_SKIP_PATTERNS にマッチするファイルをスキップ
        typeset skip=false
        if (( ${+FUNCTIONS_SKIP_PATTERNS} )); then
            for pattern in "${FUNCTIONS_SKIP_PATTERNS[@]}"; do
                # ファイル名単体、または絶対パスに含まれるパターンでマッチング
                if [[ "${func_file:t}" == ${~pattern} || "$func_file" == *${~pattern}* ]]; then
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
    # Load .env files from each component if they exist (Safer parsing)
    for env_file in "$DOTFILES_SHELL_ROOT"/*/.env(N); do  # 各コンポーネント直下の.envのみ対象（1階層）
        if [[ ! -r "$env_file" ]]; then
            echo "❌ .env読み込み失敗: $env_file (読み取り権限がありません)" >&2
            continue
        fi

        # Use read loop to only export KEY=VALUE lines, avoiding arbitrary command execution
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Skip comments and empty lines
            [[ "$line" =~ ^\s*# ]] && continue
            [[ -z "${line// /}" ]] && continue
            # Basic validation: ensure it looks like a variable assignment
            if [[ "$line" =~ ^[a-zA-Z_][a-zA-Z0-9_]*=.*$ ]]; then
                # Use export to set the variable without evaluating the line as a script
                export "$line"
            fi
        done < "$env_file"

        # デバッグログの出力
        [[ "$debug_functions" == "true" ]] && echo "✅ .env読み込み完了 (パース済): $env_file"
    done

    # Use zsh globbing to find all _bin directories under components
    for bin_dir in "$DOTFILES_SHELL_ROOT"/*/_bin(N/); do  # 各コンポーネント直下の_binのみ対象（1階層）
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

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$PATH"

# nexus-commit settings
export NEXUS_COMMIT_LLM_URL="http://localhost:11434/v1"
export NEXUS_COMMIT_LLM_MODEL="qwen2.5-coder:1.5b"
export NEXUS_COMMIT_LANG="ja"

# dotfiles-ai .env
if [ -f "$HOME/dotfiles/components/dotfiles-ai/.env" ]; then set -a; . "$HOME/dotfiles/components/dotfiles-ai/.env"; set +a; fi

# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"
# GitHub CLIを用いたGITHUB_TOKENの同期・非同期ハイブリッド取得
if command -v gh >/dev/null 2>&1; then
  # キャッシュファイルが無い場合のみ同期取得。
  # 既存キャッシュがある場合は即座に読み込み、一定時間（1時間）以上経過していればバックグラウンドで更新（次回起動時に反映）
  if [[ ! -s "$HOME/.gh_token" ]]; then
    tmp_file=$(mktemp "$HOME/.gh_token.tmp.XXXXXX" 2>/dev/null || mktemp)
    if (umask 077 && gh auth token >| "$tmp_file" 2>/dev/null); then
      chmod 600 "$tmp_file" 2>/dev/null
      mv "$tmp_file" "$HOME/.gh_token" 2>/dev/null
    else
      rm -f "$tmp_file" 2>/dev/null
    fi
    [ -s "$HOME/.gh_token" ] && export GITHUB_TOKEN=$(cat "$HOME/.gh_token")
  else
    export GITHUB_TOKEN=$(cat "$HOME/.gh_token")
    # キャッシュが1時間（3600秒）以上古い場合のみバックグラウンドで更新
    if [[ -n $(find "$HOME/.gh_token" -mmin +60 2>/dev/null) ]]; then
      (
        tmp_file=$(mktemp "$HOME/.gh_token.tmp.XXXXXX" 2>/dev/null || mktemp)
        if (umask 077 && gh auth token >| "$tmp_file" 2>/dev/null); then
          chmod 600 "$tmp_file" 2>/dev/null
          mv "$tmp_file" "$HOME/.gh_token" 2>/dev/null
        else
          rm -f "$tmp_file" 2>/dev/null
        fi
      ) &
    fi
  fi
fi


# Load AWS functions entry point explicitly after generic loader
[[ -f "$ZSH_CONFIG_DIR/functions/aws.zsh" ]] && source "$ZSH_CONFIG_DIR/functions/aws.zsh"

