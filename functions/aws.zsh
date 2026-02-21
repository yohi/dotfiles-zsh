#!/usr/bin/env zsh
# ===================================================================
# AWS関連カスタム関数 - エントリーポイント
# ===================================================================
#
# 概要:
#   AWS CLI操作を効率化するためのインタラクティブな関数群
#
# アーキテクチャ:
#   モジュール化されたファイル構成で保守性と拡張性を向上
#
# ファイル構成:
#   aws/
#   ├── core.zsh         - 共通関数（プロファイル・インスタンス選択）
#   ├── ec2.zsh          - EC2関連関数
#   ├── ecs.zsh          - ECS関連関数
#   ├── logs.zsh         - CloudWatch Logs関連関数
#   ├── rds.zsh          - RDS-SSMメイン関数
#   └── rds-helpers.zsh  - RDS内部ヘルパー関数
#
# 主な機能:
#   - EC2/RDS/ECS操作の簡素化
#   - fzfによる対話的リソース選択
#   - SSM経由のセキュアな接続
#   - CloudWatch Logsのストリーミング表示
#
# 前提条件:
#   - AWS CLI v2 (aws --version)
#   - Session Manager Plugin (aws ssm start-session)
#   - fzf (fuzzy finder)
#   - 適切なIAM権限
#
# 使用方法:
#   aws-help                  # ヘルプ表示
#   ec2-ssm                   # EC2にSSM接続
#   rds-ssm                   # RDSにSSM経由で接続
#   awslogs [-v]              # CloudWatch Logs表示
#
# 設定:
#   export AWS_PROFILE=<profile>  # デフォルトプロファイル
#   export ZSH_FUNCTIONS_DEBUG=true  # デバッグモード
#
# ===================================================================

# モジュールディレクトリのパスを取得
# ${(%):-%N} は source された場合でも正しく現在のファイルパスを取得できる
AWS_FUNCTIONS_DIR="${${(%):-%N}:A:h}/aws"

# デバッグモード
[[ -n "$ZSH_FUNCTIONS_DEBUG" ]] && echo "📂 AWS関数ディレクトリ: $AWS_FUNCTIONS_DIR"

# モジュールの読み込み順序（依存関係を考慮）
# 1. 共通関数（他のモジュールから参照される）
# 2. 各サービス固有の関数
# 3. RDSヘルパー（rds.zshから参照される）

# 共通関数の読み込み
if [[ -f "$AWS_FUNCTIONS_DIR/core.zsh" ]]; then
    source "$AWS_FUNCTIONS_DIR/core.zsh"
    [[ -n "$ZSH_FUNCTIONS_DEBUG" ]] && echo "✅ core.zsh を読み込みました"
else
    echo "❌ エラー: $AWS_FUNCTIONS_DIR/core.zsh が見つかりません" >&2
    return 1
fi

# EC2関連関数の読み込み
if [[ -f "$AWS_FUNCTIONS_DIR/ec2.zsh" ]]; then
    source "$AWS_FUNCTIONS_DIR/ec2.zsh"
    [[ -n "$ZSH_FUNCTIONS_DEBUG" ]] && echo "✅ ec2.zsh を読み込みました"
else
    echo "⚠️  警告: $AWS_FUNCTIONS_DIR/ec2.zsh が見つかりません" >&2
fi

# ECS関連関数の読み込み
if [[ -f "$AWS_FUNCTIONS_DIR/ecs.zsh" ]]; then
    source "$AWS_FUNCTIONS_DIR/ecs.zsh"
    [[ -n "$ZSH_FUNCTIONS_DEBUG" ]] && echo "✅ ecs.zsh を読み込みました"
else
    echo "⚠️  警告: $AWS_FUNCTIONS_DIR/ecs.zsh が見つかりません" >&2
fi

# CloudWatch Logs関連関数の読み込み
if [[ -f "$AWS_FUNCTIONS_DIR/logs.zsh" ]]; then
    source "$AWS_FUNCTIONS_DIR/logs.zsh"
    [[ -n "$ZSH_FUNCTIONS_DEBUG" ]] && echo "✅ logs.zsh を読み込みました"
else
    echo "⚠️  警告: $AWS_FUNCTIONS_DIR/logs.zsh が見つかりません" >&2
fi

# RDSヘルパー関数の読み込み（rds.zshより先に読み込む必要がある）
if [[ -f "$AWS_FUNCTIONS_DIR/rds-helpers.zsh" ]]; then
    source "$AWS_FUNCTIONS_DIR/rds-helpers.zsh"
    [[ -n "$ZSH_FUNCTIONS_DEBUG" ]] && echo "✅ rds-helpers.zsh を読み込みました"
else
    echo "⚠️  警告: $AWS_FUNCTIONS_DIR/rds-helpers.zsh が見つかりません" >&2
fi

# RDS関連関数の読み込み（rds-helpersに依存）
if [[ -f "$AWS_FUNCTIONS_DIR/rds.zsh" ]]; then
    source "$AWS_FUNCTIONS_DIR/rds.zsh"
    [[ -n "$ZSH_FUNCTIONS_DEBUG" ]] && echo "✅ rds.zsh を読み込みました"
else
    echo "⚠️  警告: $AWS_FUNCTIONS_DIR/rds.zsh が見つかりません" >&2
fi

# AWS関数ヘルプ
aws-help() {
    echo "🛠️  AWS関連カスタム関数ヘルプ"
    echo ""
    echo "📋 利用可能な関数:"
    echo ""
    echo "  🖥️  EC2関連:"
    echo "    ec2-list    : EC2インスタンス一覧表示"
    echo "    ec2-ssm     : EC2インスタンスにSSM経由で接続"
    echo ""
    echo "  🗄️  RDS関連:"
    echo "    rds-ssm     : RDSインスタンスにSSM経由で接続"
    echo "                  オプション:"
    echo "                    -h, --help            : ヘルプを表示"
    echo "                    -a, --all-regions     : 全リージョンで検索"
    echo "                    -s, --show-all        : 全RDSを表示（接続不可含む）"
    echo "                    -c, --connectable-only: 接続可能なRDSのみ表示（デフォルト）"
    echo "                    -p, --parallel        : 並列処理（デフォルト）"
    echo "                    --sequential          : 逐次処理"
    echo "    rds-ssm-cleanup : ポートフォワーディングのクリーンアップ"
    echo ""
    echo "  🐳 ECS関連:"
    echo "    ecs-list    : ECSクラスター一覧表示"
    echo ""
    echo "  📊 CloudWatch関連:"
    echo "    awslogs     : CloudWatch Logsの表示"
    echo "                  オプション:"
    echo "                    -v, --verbose         : 詳細表示（ログストリーム名含む）"
    echo ""
    echo "  ❓ その他:"
    echo "    aws-help    : このヘルプを表示"
    echo ""
    echo "📝 前提条件:"
    echo "  - AWS CLI v2"
    echo "  - AWS Session Manager Plugin (SSM用)"
    echo "  - fzf (fuzzy finder)"
    echo "  - 適切なIAM権限"
    echo "  - psql, mysql等のDBクライアント (RDS接続用)"
    echo ""
    echo "🔧 設定:"
    echo "  aws configure           # プロファイル設定"
    echo "  export AWS_PROFILE=名前  # デフォルトプロファイル設定"
    echo ""
    echo "📁 モジュール構成:"
    echo "  zsh/functions/aws/"
    echo "  ├── core.zsh         # 共通関数"
    echo "  ├── ec2.zsh          # EC2関連"
    echo "  ├── ecs.zsh          # ECS関連"
    echo "  ├── logs.zsh         # CloudWatch Logs関連"
    echo "  ├── rds.zsh          # RDS-SSMメイン"
    echo "  └── rds-helpers.zsh  # RDS内部ヘルパー"
}

echo "✅ AWS関数が読み込まれました。'aws-help' でヘルプを表示できます。"
