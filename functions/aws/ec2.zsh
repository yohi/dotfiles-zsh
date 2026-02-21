#!/usr/bin/env zsh
# ===================================================================
# AWS EC2関連関数
# ===================================================================
#
# 概要:
#   EC2インスタンスの管理・接続機能
#
# 提供関数:
#   ec2-list    - EC2インスタンス一覧表示
#   ec2-ssm     - EC2インスタンスにSSM経由で接続
#
# 依存関係:
#   - AWS CLI v2
#   - AWS Session Manager Plugin
#   - fzf (fuzzy finder)
#   - aws/core.zsh (_aws_select_profile)
#
# ===================================================================

# EC2インスタンス一覧表示
# 引数: なし
# 戻り値: なし（表形式で出力）
ec2-list() {
    local profile="${AWS_PROFILE:-default}"
    echo "📋 EC2インスタンス一覧 (プロファイル: $profile)"

    aws ec2 describe-instances \
        --profile "$profile" \
        --query 'Reservations[].Instances[].[InstanceId,State.Name,InstanceType,Tags[?Key==`Name`].Value|[0],PublicIpAddress,PrivateIpAddress]' \
        --output table
}

# EC2インスタンス接続
# 引数: なし
# 戻り値: 0=成功, 1=失敗
# 機能: fzfでEC2インスタンスを選択し、SSM経由で接続
ec2-ssm() {
    echo "🚀 EC2 SSM接続ツール"

    # プロファイル選択
    _aws_select_profile || return 1

    echo "📋 SSM対応EC2インスタンスを検索中..."
    local instance_info=$(aws ec2 describe-instances \
        --profile "$AWS_PROFILE" \
        --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[].Instances[?PlatformDetails!=`Windows`].[InstanceId, Tags[?Key==`Name`].Value | [0], PrivateIpAddress]' \
        --output text)

    if [[ -z "$instance_info" ]]; then
        echo "❌ 実行中のEC2インスタンスが見つかりません。"
        return 1
    fi

    # インスタンス選択
    local selected_instance_line=$(echo "$instance_info" | fzf --prompt="接続するEC2インスタンスを選択: " --layout=reverse --border --header="InstanceID / Name / PrivateIP")
    local selected_instance=$(echo "$selected_instance_line" | awk '{print $1}')
    if [[ -z "$selected_instance" ]]; then
        echo "❌ インスタンスが選択されませんでした。"
        return 1
    fi

    echo "🔗 EC2インスタンス $selected_instance に接続中..."

    # SSM接続実行
    aws ssm start-session --target "$selected_instance" --profile "$AWS_PROFILE"
}
