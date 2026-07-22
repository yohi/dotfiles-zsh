#!/usr/bin/env zsh
# ===================================================================
# AWS RDS-SSM接続関数
# ===================================================================
#
# 概要:
#   EC2インスタンスを踏み台としてRDSに接続する機能
#
# 提供関数:
#   rds-ssm [options]    - RDSインスタンスにSSM経由で接続
#   rds-ssm-cleanup      - ポートフォワーディングのクリーンアップ
#
# オプション:
#   -h, --help            ヘルプ表示
#   -a, --all-regions     全リージョン検索
#   -s, --show-all        全RDS表示（接続不可含む）
#   -c, --connectable-only 接続可能のみ表示（デフォルト）
#   -p, --parallel        並列処理（デフォルト）
#   --sequential          逐次処理
#
# 依存関係:
#   - AWS CLI v2
#   - AWS Session Manager Plugin
#   - fzf (fuzzy finder)
#   - psql, mysql, sqlcmd (各DBクライアント)
#   - aws/core.zsh (_aws_select_profile, _aws_select_ec2_instance)
#   - aws/rds-helpers.zsh (全ヘルパー関数; zshrc 読み込み時はスキップされ、ここで遅延読み込み)
#
# ===================================================================

# rds-helpers.zsh は起動時間短縮のため zshrc 読み込み対象から外している。
# rds-ssm 実行時にここで読み込む。
[[ -f "${0:A:h}/rds-helpers.zsh" ]] && source "${0:A:h}/rds-helpers.zsh"

# ===================================================================
# RDS-SSM接続機能
# ===================================================================

# ===================================================================
# RDS-SSM接続機能
# ===================================================================

rds-ssm() {
    local profile=""
    local instance_id=""
    local rds_endpoint=""
    local db_name=""
    local db_user=""
    local db_engine=""
    local use_iam_auth=""
    local rds_port=""
    local local_port=""
    local search_all_regions=false
    local connectable_only=true  # デフォルトで接続可能のみ表示
    local parallel_processing=true  # デフォルトで並列実行

    # ポートフォワーディングプロセス管理用グローバル変数
    export RDS_SSM_PORT_FORWARD_PID=""
    export RDS_SSM_LOCAL_PORT=""
    export RDS_SSM_CLEANUP_REGISTERED=""

    # 終了時の自動クリーンアップ設定
    _rds_ssm_setup_cleanup_trap

    # パラメータ解析
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                _rds_ssm_show_help
                return 0
                ;;
            --all-regions|-a)
                search_all_regions=true
                shift
                ;;
            --connectable-only|-c)
                connectable_only=true
                shift
                ;;
            --show-all|-s)
                connectable_only=false
                shift
                ;;
            --parallel|-p)
                parallel_processing=true
                shift
                ;;
            --sequential|--no-parallel)
                parallel_processing=false
                shift
                ;;
            *)
                echo "❌ 不明なオプション: $1"
                echo "使用法: rds-ssm [--help|-h] [--all-regions|-a] [--connectable-only|-c] [--show-all|-s] [--parallel|-p] [--sequential]"
                return 1
                ;;
        esac
    done

    echo "🚀 RDS-SSM接続ツールを開始します..."
    echo

    if ! _aws_select_profile; then return 1; fi
    profile="$AWS_PROFILE"
    if ! _aws_select_ec2_instance "$profile"; then return 1; fi

    if ! _rds_ssm_select_rds_instance "$search_all_regions" "$connectable_only"; then echo "❌ RDSインスタンス選択に失敗しました"; return 1; fi
    if ! _rds_ssm_input_connection_info; then echo "❌ 接続情報入力に失敗しました"; return 1; fi
    if ! _rds_ssm_setup_authentication; then echo "❌ 認証設定に失敗しました"; return 1; fi
    if ! _rds_ssm_start_port_forwarding; then echo "❌ ポートフォワーディング開始に失敗しました"; return 1; fi

    _rds_ssm_connect_to_database
}

rds-ssm-cleanup() {
    local target_port="${1:-all}"

    echo "🧹 手動クリーンアップを実行します..."

    if [[ "$target_port" == "all" ]]; then
        echo "   対象: 全てのSSMポートフォワーディングプロセス"
        _rds_ssm_cleanup_port_forwarding

        # 追加で一般的なポートもチェック
        local common_ports=(5432 3306 5433 3307)
        for port in "${common_ports[@]}"; do
            local pids=$(lsof -ti:$port 2>/dev/null)
            if [[ -n "$pids" ]]; then
                echo "   🔍 ポート $port の使用状況:"
                lsof -i:$port

                while IFS= read -r pid; do
                    if [[ -n "$pid" ]]; then
                        local cmd_line=$(ps -p "$pid" -o cmd= 2>/dev/null || echo "")
                        if [[ "$cmd_line" =~ "aws ssm start-session" || "$cmd_line" =~ "session-manager-plugin" ]]; then
                            echo "   🧹 SSMプロセス $pid を停止中..."
                            kill -TERM "$pid" 2>/dev/null
                        fi
                    fi
                done <<< "$pids"
            fi
        done

    else
        echo "   対象ポート: $target_port"
        local pids=$(lsof -ti:$target_port 2>/dev/null)
        if [[ -n "$pids" ]]; then
            echo "   使用中のプロセス:"
            lsof -i:$target_port

            while IFS= read -r pid; do
                if [[ -n "$pid" ]]; then
                    local cmd_line=$(ps -p "$pid" -o cmd= 2>/dev/null || echo "")
                    if [[ "$cmd_line" =~ "aws ssm start-session" || "$cmd_line" =~ "session-manager-plugin" ]]; then
                        echo "   🧹 SSMプロセス $pid を停止中..."
                        kill -TERM "$pid" 2>/dev/null
                        sleep 2
                        if kill -0 "$pid" 2>/dev/null; then
                            kill -KILL "$pid" 2>/dev/null
                        fi
                    fi
                fi
            done <<< "$pids"
        else
            echo "   ✅ ポート $target_port は使用されていません"
        fi
    fi

    echo "🎉 クリーンアップ完了"
}
