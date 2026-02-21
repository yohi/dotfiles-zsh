# Zsh Configuration

このディレクトリには、Zshシェルの設定ファイルとカスタム関数が格納されています。

## ファイル構成と役割

### 1. `zshrc`
メインの設定ファイルです。プラグイン管理（Zinit）、プロンプト（Powerlevel10k）、および以下の設定ファイルの読み込みを制御します。

### 2. `config.zsh` (Internal Framework Settings)
**このZsh設定自体の動作**をカスタマイズするためのファイルです。
- `FUNCTIONS_SUBDIR`: カスタム関数を格納するディレクトリの指定
- `FUNCTIONS_SKIP_PATTERNS`: 読み込みをスキップするファイルパターン
- `CANDIDATE_DIRS`: ドットファイルのリポジトリを探す候補ディレクトリ
- `FUNCTIONS_DEBUG`: 関数読み込みのデバッグモード切り替え

### 3. `.zsh_env` (Global Environment Variables)
**シェル環境全体の環境変数**を定義します。Zsh以外のシェルでも共通して利用可能な設定を記述します。
- 言語設定 (`LANG`)
- 日本語入力設定 (`IBus`, `Fcitx5`)
- 外部ツールのパス (`GOPATH`, `bin` など)
- デフォルトエディタ (`EDITOR`, `VISUAL`)

### 4. `.zsh_secrets` (Private)
APIキーやプライベートなトークンなど、リポジトリにコミットしたくない秘匿情報を記述します。
（`.gitignore` により管理対象外となっています）

### 5. `functions/`
独自のZsh関数を格納するディレクトリです。`config.zsh` の設定に基づき、再帰的に自動読み込みされます。

## セットアップ

初回利用時は、テンプレートから設定ファイルを作成してください。

```bash
cp zsh/config.example.zsh zsh/config.zsh
touch zsh/.zsh_secrets
```

## カスタマイズ

- **環境変数を追加したい場合**: `.zsh_env` を編集してください。
- **特定の関数ファイルを読み込みたくない場合**: ファイル拡張子を `.disabled` に変更するか、`config.zsh` の `FUNCTIONS_SKIP_PATTERNS` にパターンを追加してください。
- **デバッグ**: 関数が正しく読み込まれない場合は、`config.zsh` で `FUNCTIONS_DEBUG=true` に設定して詳細を確認してください。