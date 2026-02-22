#!/bin/bash

# RDS-SSM接続ツールのテストスクリプト
# 前提条件の確認と基本的な動作テストを実行

echo "🧪 RDS-SSM接続ツール - 前提条件チェック"
echo "============================================"
echo

# 関数: チェック結果表示
check_result() {
    if [ $1 -eq 0 ]; then
        echo "✅ $2"
    else
        echo "❌ $2"
        return 1
    fi
}

# 必要なコマンドの存在確認
echo "📋 必要なコマンドの確認:"
echo

commands_ok=true

# AWS CLI
if command -v aws >/dev/null 2>&1; then
    aws_version=$(aws --version 2>&1 | head -n1)
    check_result 0 "AWS CLI: $aws_version"
else
    check_result 1 "AWS CLI がインストールされていません"
    commands_ok=false
fi

# Session Manager Plugin
if command -v session-manager-plugin >/dev/null 2>&1; then
    session_manager_version=$(session-manager-plugin --version 2>&1)
    check_result 0 "Session Manager Plugin: $session_manager_version"
else
    check_result 1 "Session Manager Plugin がインストールされていません"
    commands_ok=false
fi

# MySQL Client
if command -v mysql >/dev/null 2>&1; then
    mysql_version=$(mysql --version 2>&1)
    check_result 0 "MySQL Client: $mysql_version"
else
    check_result 1 "MySQL Client がインストールされていません (オプション)"
fi

# PostgreSQL Client
if command -v psql >/dev/null 2>&1; then
    psql_version=$(psql --version 2>&1)
    check_result 0 "PostgreSQL Client: $psql_version"
else
    check_result 1 "PostgreSQL Client がインストールされていません (オプション)"
fi

# netcat
if command -v nc >/dev/null 2>&1; then
    check_result 0 "netcat (nc)"
else
    check_result 1 "netcat がインストールされていません"
    commands_ok=false
fi

# lsof
if command -v lsof >/dev/null 2>&1; then
    check_result 0 "lsof"
else
    check_result 1 "lsof がインストールされていません"
    commands_ok=false
fi

echo

# AWS設定確認
echo "🔐 AWS設定の確認:"
echo

aws_config_ok=true

# AWSプロファイル確認
if aws configure list-profiles >/dev/null 2>&1; then
    profiles=($(aws configure list-profiles))
    if [ ${#profiles[@]} -gt 0 ]; then
        check_result 0 "AWS プロファイル設定 (${#profiles[@]}個のプロファイル)"
        echo "   利用可能なプロファイル: ${profiles[*]}"
    else
        check_result 1 "AWS プロファイルが設定されていません"
        aws_config_ok=false
    fi
else
    check_result 1 "AWS設定の読み込みに失敗しました"
    aws_config_ok=false
fi

echo

# デフォルトプロファイルでの認証確認
if [ "$aws_config_ok" = true ]; then
    echo "🔍 デフォルトプロファイルでの認証テスト:"
    echo

    if aws sts get-caller-identity >/dev/null 2>&1; then
        account_id=$(aws sts get-caller-identity --query 'Account' --output text 2>/dev/null)
        user_arn=$(aws sts get-caller-identity --query 'Arn' --output text 2>/dev/null)
        check_result 0 "AWS認証成功"
        echo "   Account ID: $account_id"
        echo "   User ARN: $user_arn"
    else
        check_result 1 "AWS認証に失敗しました"
        echo "💡 'aws configure' でプロファイルを設定してください"
        aws_config_ok=false
    fi
fi

echo

# 関数の読み込み確認
echo "🔧 RDS-SSM関数の確認:"
echo

if type rds-ssm >/dev/null 2>&1; then
    check_result 0 "rds-ssm関数が読み込まれています"
else
    check_result 1 "rds-ssm関数が読み込まれていません"
    echo "💡 zshを再起動するか、以下を実行してください:"
    echo "   source functions/aws.zsh"
fi

echo

# IAM権限チェック (基本的なもののみ)
if [ "$aws_config_ok" = true ]; then
    echo "🛡️  基本的なIAM権限の確認:"
    echo

    # EC2権限確認
    if aws ec2 describe-instances --max-items 1 >/dev/null 2>&1; then
        check_result 0 "EC2 describe-instances 権限"
    else
        check_result 1 "EC2 describe-instances 権限が不足しています"
    fi

    # RDS権限確認
    if aws rds describe-db-instances --max-items 1 >/dev/null 2>&1; then
        check_result 0 "RDS describe-db-instances 権限"
    else
        check_result 1 "RDS describe-db-instances 権限が不足しています"
    fi

    # SSM権限確認
    if aws ssm describe-instance-information --max-items 1 >/dev/null 2>&1; then
        check_result 0 "SSM describe-instance-information 権限"
    else
        check_result 1 "SSM describe-instance-information 権限が不足しています"
    fi
fi

echo

# 総合結果
echo "📊 総合結果:"
echo

if [ "$commands_ok" = true ] && [ "$aws_config_ok" = true ]; then
    echo "🎉 すべての前提条件が満たされています！"
    echo
    echo "✨ rds-ssm関数を使用する準備が整いました"
    echo
    echo "📚 使用方法:"
    echo "   rds-ssm          # 対話式でRDS接続開始"
    echo "   rds-ssm --help   # ヘルプ表示"
    echo
else
    echo "⚠️  一部の前提条件が満たされていません"
    echo
    echo "🔧 必要な対応:"

    if [ "$commands_ok" = false ]; then
        echo "   ❌ 必要なコマンドをインストールしてください"
        echo "      sudo apt-get update"
        echo "      sudo apt-get install mysql-client postgresql-client netcat lsof"
        echo "      # AWS CLI v2とSession Manager Pluginのインストール手順は公式ドキュメントを参照"
    fi

    if [ "$aws_config_ok" = false ]; then
        echo "   ❌ AWS設定を完了してください"
        echo "      aws configure"
        echo "      # または適切なAWSプロファイルを設定"
    fi

    echo
fi

# インストールコマンドの提案
echo "💡 参考: 必要なパッケージのインストールコマンド"
echo
echo "Ubuntu/Debian:"
echo "   sudo apt-get update"
echo "   sudo apt-get install awscli mysql-client postgresql-client netcat-traditional lsof"
echo
echo "Session Manager Plugin (Ubuntu):"
echo "   curl 'https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb' -o 'session-manager-plugin.deb'"
echo "   sudo dpkg -i session-manager-plugin.deb"
echo
echo "Homebrew (Linux):"
echo "   brew install awscli mysql-client postgresql netcat lsof"
echo "   brew install --cask session-manager-plugin"
echo




