#!/usr/bin/env zsh
# ===================================================================
# AWS共通関数
# ===================================================================
#
# 概要:
#   AWS CLI操作で共通して使用される基本機能
#
# 提供関数:
#   _aws_select_profile()        - AWSプロファイル選択
#   _aws_select_ec2_instance()   - EC2インスタンス選択
#
# 依存関係:
#   - AWS CLI v2
#   - fzf (fuzzy finder)
#
# ===================================================================

# 共通関数: AWSプロファイル選択
# 引数: なし
# 戻り値: 0=成功, 1=失敗
# 副作用: AWS_PROFILE環境変数を設定
_aws_select_profile() {
    # 依存関係チェック
    if ! command -v aws >/dev/null 2>&1; then
        echo "❌ AWS CLIが見つかりません。インストールしてください。" >&2
        echo "   https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html" >&2
        return 1
    fi

    if ! command -v fzf >/dev/null 2>&1; then
        echo "❌ fzfが見つかりません。インストールしてください。" >&2
        echo "   Ubuntu/Debian: sudo apt-get install fzf" >&2
        echo "   macOS: brew install fzf" >&2
        return 1
    fi

    echo "📋 利用可能なAWSプロファイルを検索中..."
    local profiles=($(aws configure list-profiles 2>/dev/null))
    if [[ ${#profiles[@]} -eq 0 ]]; then
        echo "❌ AWSプロファイルが見つかりません。" >&2
        echo "   設定方法: aws configure --profile <profile-name>" >&2
        echo "   参考: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html" >&2
        return 1
    fi

    local fzf_input=""
    for p in "${profiles[@]}"; do
        fzf_input+="$p"
        [[ "$p" == "default" ]] && fzf_input+=" (default)"
        [[ "$p" == "${AWS_PROFILE:-default}" ]] && fzf_input+=" (current)"
        fzf_input+="\n"
    done

    local selected_line=$(echo -e "$fzf_input" | fzf --prompt="AWSプロファイルを選択してください: " --layout=reverse --border)
    if [[ -z "$selected_line" ]]; then
        echo "❌ プロファイルが選択されませんでした。"
        return 1
    fi

    profile=$(echo "$selected_line" | awk '{print $1}')
    export AWS_PROFILE="$profile"

    echo "✅ プロファイル '$profile' を選択しました。"
    return 0
}

# 共通関数: EC2インスタンス選択
# 引数: $1=プロファイル名（省略時はAWS_PROFILE）
# 戻り値: 0=成功, 1=失敗
# 副作用: 以下の環境変数を設定
#   - instance_id (local変数として設定)
#   - EC2_INSTANCE_NAME, EC2_PRIVATE_IP, EC2_VPC_ID, EC2_INSTANCE_TYPE, EC2_REGION
_aws_select_ec2_instance() {
    local profile="${1:-$AWS_PROFILE}"
    echo "🖥️  EC2インスタンスを検索中 (プロファイル: $profile)..."

    local current_region=$(aws configure get region --profile "$profile" 2>/dev/null || echo "us-east-1")
    echo "🌏 検索リージョン: $current_region"

    local instance_info=$(aws ec2 describe-instances \
        --profile "$profile" \
        --region "$current_region" \
        --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[].Instances[].[InstanceId, Tags[?Key==`Name`].Value | [0], PrivateIpAddress, VpcId, InstanceType]' \
        --output text)

    if [[ -z "$instance_info" ]]; then
        echo "❌ 実行中のEC2インスタンスが見つかりません。"
        return 1
    fi

    local selected_instance_line=$(echo "$instance_info" | fzf --prompt="接続するEC2インスタンスを選択: " --layout=reverse --border --header="InstanceID / Name / PrivateIP / VpcId / Type")

    if [[ -z "$selected_instance_line" ]]; then
        echo "❌ インスタンスが選択されませんでした。"
        return 1
    fi

    # 選択されたインスタンス情報を解析
    instance_id=$(echo "$selected_instance_line" | awk '{print $1}')
    export EC2_INSTANCE_NAME=$(echo "$selected_instance_line" | awk '{print $2}')
    export EC2_PRIVATE_IP=$(echo "$selected_instance_line" | awk '{print $3}')
    export EC2_VPC_ID=$(echo "$selected_instance_line" | awk '{print $4}')
    export EC2_INSTANCE_TYPE=$(echo "$selected_instance_line" | awk '{print $5}')
    export EC2_REGION="$current_region"

    echo "✅ EC2インスタンスを選択しました:"
    echo "   ID: $instance_id"
    echo "   名前: ${EC2_INSTANCE_NAME:-N/A}"
    echo "   プライベートIP: ${EC2_PRIVATE_IP:-N/A}"
    echo "   VPC: ${EC2_VPC_ID:-N/A}"
    echo "   リージョン: $EC2_REGION"

    return 0
}
