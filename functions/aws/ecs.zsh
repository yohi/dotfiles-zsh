#!/usr/bin/env zsh
# ===================================================================
# AWS ECS関連関数
# ===================================================================
#
# 概要:
#   ECSクラスター管理機能
#
# 提供関数:
#   ecs-list    - ECSクラスター一覧表示
#
# 依存関係:
#   - AWS CLI v2
#
# ===================================================================

# ECSクラスター一覧
# 引数: なし
# 戻り値: なし（表形式で出力）
ecs-list() {
    local profile="${AWS_PROFILE:-default}"
    echo "📋 ECSクラスター一覧 (プロファイル: $profile)"

    aws ecs list-clusters \
        --profile "$profile" \
        --query 'clusterArns[]' \
        --output table
}
