# AWS関連カスタム関数 - モジュール構成

## 📁 ディレクトリ構造

```
zsh/functions/
├── aws.zsh              # エントリーポイント（164行）
├── aws.zsh.backup       # 元ファイルのバックアップ（3,131行）
└── aws/                 # モジュール化されたファイル群
    ├── core.zsh         # 共通関数（127行）
    ├── ec2.zsh          # EC2関連（69行）
    ├── ecs.zsh          # ECS関連（29行）
    ├── logs.zsh         # CloudWatch Logs関連（64行）
    ├── rds.zsh          # RDS-SSMメイン（132行）
    └── rds-helpers.zsh  # RDS内部ヘルパー（2,801行）
```

**総行数**: 3,222行（元: 3,131行 + ドキュメント増加分）

---

## 🎯 モジュール概要

### core.zsh（共通関数）
AWS操作で共通利用される基本機能

**提供関数**:
- `_aws_select_profile()` - AWSプロファイルをfzfで選択
- `_aws_select_ec2_instance()` - EC2インスタンスをfzfで選択

**依存関係**: AWS CLI v2, fzf

---

### ec2.zsh（EC2関連）
EC2インスタンスの管理・接続機能

**提供関数**:
- `ec2-list` - EC2インスタンス一覧表示
- `ec2-ssm` - EC2にSSM経由で接続

**依存関係**: core.zsh, AWS Session Manager Plugin

---

### ecs.zsh（ECS関連）
ECSクラスター管理機能

**提供関数**:
- `ecs-list` - ECSクラスター一覧表示

**依存関係**: AWS CLI v2

---

### logs.zsh（CloudWatch Logs関連）
CloudWatch Logsのストリーミング表示機能

**提供関数**:
- `awslogs [-v|--verbose]` - ログ表示（簡易/詳細モード）

**依存関係**: core.zsh, sed

---

### rds.zsh（RDS-SSMメイン）
RDS接続のメイン処理

**提供関数**:
- `rds-ssm [options]` - RDSにSSM経由で接続
- `rds-ssm-cleanup [port]` - ポートフォワーディングのクリーンアップ

**オプション**:
- `-h, --help` - ヘルプ表示
- `-a, --all-regions` - 全リージョン検索
- `-s, --show-all` - 全RDS表示（接続不可含む）
- `-c, --connectable-only` - 接続可能のみ表示（デフォルト）
- `-p, --parallel` - 並列処理（デフォルト）
- `--sequential` - 逐次処理

**依存関係**: core.zsh, rds-helpers.zsh, psql/mysql/sqlcmd

---

### rds-helpers.zsh（RDS内部ヘルパー）
RDS-SSM機能の内部実装（28関数）

**主要関数カテゴリ**:
1. **UI・選択**: `_rds_ssm_show_help`, `_rds_ssm_select_rds_instance`, `_rds_ssm_select_cluster_endpoint`
2. **接続設定**: `_rds_ssm_input_connection_info`, `_rds_ssm_setup_authentication`, `_rds_ssm_find_available_port`, `_rds_ssm_start_port_forwarding`
3. **データベース接続**: `_rds_ssm_connect_to_database`, `_rds_ssm_setup_database_env_vars`
4. **クリーンアップ**: `_rds_ssm_setup_cleanup_trap`, `_rds_ssm_cleanup_port_forwarding`, `_rds_ssm_cleanup`
5. **並列処理**: `_rds_ssm_parallel_sg_check`, `_rds_ssm_parallel_process_manager`, `_rds_ssm_check_completed_jobs`, `_rds_ssm_merge_parallel_results`
6. **セキュリティ**: `_rds_ssm_check_security_group_connectivity`, `_rds_ssm_get_connectivity_status`
7. **認証情報管理**: `_rds_ssm_test_secrets_access`, `_rds_ssm_check_available_secrets`, `_rds_ssm_smart_filter_secrets`, `_rds_ssm_auto_fill_credentials`, `_rds_ssm_setup_iam_auth`
8. **Secrets Manager**: `_rds_ssm_search_secrets_manager`, `_rds_ssm_retrieve_secret_credentials`, `_rds_ssm_parse_json_credentials`
9. **手動入力**: `_rds_ssm_manual_password_input`

**依存関係**: core.zsh, jq

---

## 🚀 使用方法

### 基本コマンド

```bash
# ヘルプ表示
aws-help

# EC2接続
ec2-list              # インスタンス一覧
ec2-ssm               # SSM経由で接続

# RDS接続
rds-ssm               # 基本接続（接続可能のみ、ポート自動選択）
rds-ssm -a            # 全リージョン検索
rds-ssm -s            # 全RDS表示（接続不可含む）
rds-ssm -a -s         # 全リージョン + 全RDS

# ローカルポート設定（rds-ssm実行中に対話的に設定）
# 空欄入力    → 自動的に空きポートを検索（デフォルト）
# 5433        → 指定したポート番号を使用

# ポートフォワーディングのクリーンアップ
rds-ssm-cleanup       # 全ポート
rds-ssm-cleanup 5432  # 特定ポート

# CloudWatch Logs
awslogs               # 簡易表示
awslogs -v            # 詳細表示（ログストリーム名含む）

# ECS
ecs-list              # クラスター一覧
```

---

## 🔧 デバッグモード

モジュール読み込み状況を確認：

```bash
export ZSH_FUNCTIONS_DEBUG=true
source ~/dots/zsh/functions/aws.zsh
```

出力例:
```
📂 AWS関数ディレクトリ: /home/y_ohi/dots/zsh/functions/aws
✅ core.zsh を読み込みました
✅ ec2.zsh を読み込みました
✅ ecs.zsh を読み込みました
✅ logs.zsh を読み込みました
✅ rds-helpers.zsh を読み込みました
✅ rds.zsh を読み込みました
✅ AWS関数が読み込まれました。'aws-help' でヘルプを表示できます。
```

---

## 📋 前提条件

### 必須ツール
- **AWS CLI v2**: `aws --version`
- **AWS Session Manager Plugin**: `aws ssm start-session`（SSM用）
- **fzf**: `fzf --version`（対話的選択）

### データベースクライアント（RDS接続用）
- **PostgreSQL**: `psql --version`
- **MySQL/MariaDB**: `mysql --version`
- **SQL Server**: `sqlcmd` (オプション)

### 必須IAM権限
```
- ec2:DescribeInstances
- ec2:DescribeSecurityGroups
- ec2:DescribeRegions
- rds:DescribeDBInstances
- rds:DescribeDBClusters
- ssm:StartSession
- secretsmanager:GetSecretValue
- secretsmanager:ListSecrets
- sts:GetCallerIdentity
- logs:DescribeLogGroups
- logs:GetLogEvents
- ecs:ListClusters
```

---

## ⚙️ 設定

### AWSプロファイル設定

```bash
# プロファイル作成
aws configure --profile myprofile

# デフォルトプロファイル設定
export AWS_PROFILE=myprofile

# zshrcに追加（永続化）
echo 'export AWS_PROFILE=myprofile' >> ~/.zshrc
```

---

## 🔍 トラブルシューティング

### ポート競合エラー

**症状**: `⚠️ ローカルポート 5432 は既に使用中です`

**自動解決**:
- v2.0以降では、ポートが使用中の場合に**自動的に空きポートを検索**します
- 検索範囲: 希望ポート +10（例: 5432 → 5433 → ... → 5441）
- 見つかった空きポートで自動的にポートフォワーディングを開始

**メッセージ例**:
```
ℹ️  非SSMプロセスがポート 5432 を使用中です
   空きポートを自動検索します...
ℹ️  ポート 5432 は使用中のため、ポート 5433 を使用します
✅ 使用可能なポート 5433 を発見しました
📊 ポートフォワーディング情報:
   プロセスID: 12345
   使用ポート: localhost:5433 → mydb.region.rds.amazonaws.com:5432
```

**手動でポート指定**:
```bash
# rds-ssmの前に環境変数でポート指定（将来実装予定）
export RDS_LOCAL_PORT=5433
rds-ssm
```

### ポートフォワーディング確立失敗

**症状**: `❌ ポートフォワーディングの確立に失敗しました` または `❌ SSMプロセスが異常終了しました`

**原因と解決方法**:

#### 1. EC2→RDS間のネットワーク接続問題
```bash
# EC2インスタンスに接続して確認
aws ssm start-session --profile YOUR_PROFILE --target i-INSTANCE_ID

# EC2内で実行:
# RDSへの接続性確認
nc -zv your-rds-endpoint.amazonaws.com 5432

# DNS解決確認
nslookup your-rds-endpoint.amazonaws.com
```

**チェックポイント**:
- EC2のセキュリティグループがRDSのセキュリティグループに許可されているか
- RDSのセキュリティグループでインバウンドルールに該当ポート（5432/3306等）が開いているか
- EC2とRDSが同じVPC内にあるか、または適切なVPCピアリング/Transit Gatewayが設定されているか

#### 2. タイムアウト時間が不足
**デフォルト**: 60秒
**解決方法**: 再実行を試みる（ネットワーク遅延が一時的な場合）

#### 3. IAM権限の問題
必要な権限:
- `ssm:StartSession`
- `ssm:TerminateSession`
- `rds:DescribeDBInstances`
- `rds:DescribeDBClusters`

#### 4. Session Manager Pluginの問題
```bash
# Session Manager Pluginバージョン確認
session-manager-plugin --version

# 再インストール（必要な場合）
# Ubuntu/Debian:
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
```

**v2.2.0の改善点**:
- タイムアウト延長（30秒→60秒）
- プロセス異常終了の即座検出
- 詳細なログ記録（stdout/stderr分離）
- 具体的なトラブルシューティング情報の提供

### パスワード認証エラー

**症状**: `password authentication failed for user "xxx"` エラーが発生

**原因と解決方法**:

#### 1. Secrets Managerのパスワードが正しくない（最も多い原因）
**対処方法**:
```bash
# RDSマスターパスワードをAWS Consoleで確認
# https://console.aws.amazon.com/rds/ → DBインスタンス → アクション → マスターパスワードの変更

# Secrets Managerのパスワードを更新
aws secretsmanager update-secret --profile YOUR_PROFILE \
  --secret-id SECRET_NAME \
  --secret-string '{"username":"dhadmin","password":"NEW_PASSWORD"}'

# または、rds-ssm実行時に手動入力オプションを選択
```

#### 2. ユーザー名が正しくない
**対処方法**:
- AWS ConsoleでRDSのマスターユーザー名を確認
- rds-ssm実行時のユーザー名入力で正しい値を入力

#### 3. ポートフォワーディングの問題
**診断コマンド**:
```bash
# ポート使用状況確認
lsof -i :5432

# ポートフォワーディングログ確認
cat /tmp/ssm-port-forward-5432.log
cat /tmp/ssm-port-forward-5432.err

# 接続テスト
nc -zv localhost 5432
```

#### 4. データベース名が正しくない
**デフォルト値**:
- PostgreSQL: `postgres`
- MySQL: `mysql` または RDS識別子

**v2.3.0の改善点**:
- データベース接続失敗時に自動的に詳細なトラブルシューティング情報を表示
- 4つの主要原因と具体的な対処方法を提示
- 診断コマンドの提供
- Secrets Manager更新方法の明示

### クリーンアップ失敗（ポートが解放されない）

**症状**: クリーンアップ後もポートが使用中のまま

**v2.3.0での修正**:
- session-manager-plugin子プロセスも確実に停止
- TERM/KILLシグナルによる段階的停止
- プロセス停止後の1秒待機

**手動クリーンアップ**:
```bash
# ポート使用プロセスを強制停止
lsof -ti:5432 | xargs kill -9

# または、rds-ssm-cleanupコマンドを使用
rds-ssm-cleanup 5432
```

### モジュール読み込みエラー

**症状**: `❌ エラー: /path/to/aws/core.zsh が見つかりません`

**解決方法**:
```bash
# ファイル存在確認
ls -la ~/dots/zsh/functions/aws/

# 権限確認
chmod +x ~/dots/zsh/functions/aws/*.zsh

# パス確認
echo ${0:A:h}
```

### 関数が見つからない

**症状**: `command not found: ec2-ssm`

**解決方法**:
```bash
# aws.zshの再読み込み
source ~/dots/zsh/functions/aws.zsh

# 関数確認
type ec2-ssm
```

### fzfが動作しない

**解決方法**:
```bash
# fzfインストール確認
command -v fzf || sudo apt-get install fzf  # Ubuntu/Debian
command -v fzf || brew install fzf          # macOS
```

---

## 🎨 カスタマイズ

### 新しいサービス追加

1. 新しいモジュールファイルを作成（例: `s3.zsh`）
2. `aws.zsh`に読み込み処理を追加
3. `aws-help`関数を更新

**例 (s3.zsh)**:
```bash
#!/usr/bin/env zsh
# S3関連関数

s3-list-buckets() {
    aws s3 ls --profile "${AWS_PROFILE:-default}"
}
```

**aws.zsh への追加**:
```bash
# S3関連関数の読み込み
if [[ -f "$AWS_FUNCTIONS_DIR/s3.zsh" ]]; then
    source "$AWS_FUNCTIONS_DIR/s3.zsh"
    [[ -n "$ZSH_FUNCTIONS_DEBUG" ]] && echo "✅ s3.zsh を読み込みました"
fi
```

---

## 📊 パフォーマンス最適化

### 並列処理（デフォルト有効）

RDS検索時のセキュリティグループチェックを並列実行し、検索速度を向上：

```bash
# 並列処理（推奨）
rds-ssm -a -p

# 逐次処理（デバッグ時）
rds-ssm -a --sequential
```

**性能差**: 約3-5倍の高速化（リージョン数・RDS数に依存）

---

## 🔐 セキュリティ機能

### IAM認証
RDS IAMデータベース認証をサポート（パスワード不要）

### Secrets Manager統合
認証情報をAWS Secrets Managerから自動取得

**自動フィルタリング**:
- RDSエンジン名での絞り込み
- エンドポイント名での絞り込み
- スマートマッチング

---

## 📝 変更履歴

### 2025-10-07 v2.3: クリーンアップ & 認証エラー診断の強化
- 🐛 **バグ修正**: session-manager-plugin子プロセスの完全停止
  - クリーンアップ時に親プロセスだけでなく子プロセスも確実に停止
  - ポート解放の確実性向上（TERM/KILLシグナル、1秒待機）
- 📊 **改善**: パスワード認証エラー時の詳細トラブルシューティング
  - データベース接続失敗の検出と終了コードのキャプチャ
  - 4つの主要原因（パスワード、ユーザー名、ポートフォワーディング、DB名）の提示
  - 具体的な対処方法と診断コマンドの提供
  - Secrets Manager更新方法の明示

### 2025-10-07 v2.2: ポートフォワーディング診断機能の強化
- 📊 **改善**: ポートフォワーディング確立の診断機能を大幅強化
  - タイムアウトを30秒→60秒に延長
  - stdout/stderrを分離した詳細なログ記録
  - SSMプロセスの異常終了を即座に検出
  - セッション開始とポート確立の段階的確認
  - 10秒ごとの経過時間表示
  - 詳細なトラブルシューティング情報と診断コマンドの提供
  - 失敗時の自動クリーンアップ機能

### 2025-10-07 v2.1: ローカルポート自動選択（デフォルト）
- ✨ **新機能**: ローカルポートのデフォルト動作を自動選択に変更
  - 空欄入力で自動的に空きポートを検索（ユーザー操作不要）
  - 手動でポート番号を指定することも可能
  - 複数RDS接続の同時維持が容易に
- 📝 **ドキュメント**: 使用例とプロンプトメッセージを改善

### 2025-10-07 v2.0: ポート競合自動解決 + モジュール化
- ✨ **新機能**: ポート使用時の自動空きポート検索
  - 非SSMプロセスがポートを使用中の場合、自動的に空きポートを検索（+10範囲）
  - ユーザーに使用ポートを明確に通知
  - `_rds_ssm_find_available_port`関数を追加
- 🏗️ **アーキテクチャ**: 単一ファイル（3,131行）を7ファイルに分割
  - 保守性・拡張性の向上
  - 依存関係の明確化
  - デバッグモードの追加
- 📊 **改善**: ポートフォワーディング情報の表示を強化

---

## 🤝 貢献

改善提案やバグ報告は、リポジトリのIssueで受け付けています。

---

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。
