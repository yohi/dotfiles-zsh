#!/usr/bin/env zsh
# ===================================================================
# AWS CloudWatch Logs関連関数
# ===================================================================
#
# 概要:
#   CloudWatch Logsのストリーミング表示機能
#
# 提供関数:
#   awslogs [-v|--verbose]    - CloudWatch Logsの表示
#
# 依存関係:
#   - AWS CLI v2
#   - fzf (fuzzy finder)
#   - sed (stream editor)
#   - aws/core.zsh (_aws_select_profile)
#
# ===================================================================

# CloudWatch Logs表示
# 引数: -v, --verbose (詳細表示モード)
# 戻り値: 0=成功, 1=失敗
# 機能: fzfでロググループを選択し、ログをストリーミング表示
awslogs() {
    echo "📋 CloudWatch Logs表示ツール"
    local verbose=false
    # シンプルな引数チェック
    if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
        verbose=true
    fi

    # プロファイル選択
    _aws_select_profile || return 1

    # ロググループ選択
    echo "📋 ロググループを検索中..."
    local log_groups=($(aws logs describe-log-groups --profile "$AWS_PROFILE" --query 'logGroups[].logGroupName' --output text))

    if [[ ${#log_groups[@]} -eq 0 ]]; then
        echo "❌ ロググループが見つかりません。"
        return 1
    fi

    local selected_log_group=$(printf '%s\n' "${log_groups[@]}" | fzf --prompt="ロググループを選択: " --layout=reverse --border)
    if [[ -z "$selected_log_group" ]]; then
        echo "❌ ロググループが選択されませんでした。"
        return 1
    fi

    # 直接コマンド実行（eval不使用で安全性向上）
    if [[ "$verbose" == "true" ]]; then
        echo "📋 ログを詳細表示でストリーミングします... (Ctrl+Cで終了) ($selected_log_group)"
        aws logs tail "$selected_log_group" --follow --profile "$AWS_PROFILE"
    else
        echo "📋 ログを簡易表示でストリーミングします... (Ctrl+Cで終了) ($selected_log_group)"
        # タイムスタンプとメッセージのみ表示 (ログストリーム名を削除)
        # sed -uでパイプのバッファリングを無効化
        aws logs tail "$selected_log_group" --follow --profile "$AWS_PROFILE" | \
            sed -u -E 's/^(\S+T\S+)\s+\S+\s+(.*)/\1 \2/'
    fi
}
