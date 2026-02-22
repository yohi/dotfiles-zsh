#!/usr/bin/env zsh

# Cursor IDE をカレントディレクトリで起動する関数
# 使用方法: cursor
# または: cursor [ディレクトリパス]

function cursor() {
    local cursor_bin="${CURSOR_BIN}"

    # CURSOR_BINが設定されていない場合、外部コマンドを探す
    if [[ -z "${cursor_bin}" ]]; then
        cursor_bin=$(whence -p cursor 2>/dev/null)
        if [[ -z "${cursor_bin}" ]] && command -v type >/dev/null 2>&1; then
            cursor_bin=$(type -p cursor 2>/dev/null)
        fi
    fi

    # 実行可能性を確認
    if [[ -z "${cursor_bin}" ]] || [[ ! -x "${cursor_bin}" ]]; then
        echo "エラー: Cursor 実行ファイルが見つかりません（PATH または CURSOR_BIN を確認してください）"
        return 127
    fi

    if [[ $# -gt 0 ]]; then
        local target_dir="$1"
        if [[ -d "$target_dir" ]]; then
            echo "Cursor を次のディレクトリで起動します: $target_dir"
            "${cursor_bin}" -- "$target_dir"
        else
            echo "エラー: ディレクトリが存在しません: $target_dir"
            return 1
        fi
    else
        echo "Cursor をカレントディレクトリで起動します: $(pwd)"
        "${cursor_bin}" -- .
    fi
}
