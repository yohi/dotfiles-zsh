# dotfiles-zsh

このディレクトリには、Zshシェルの設定ファイルとカスタム関数が格納されています。

## 管理と依存関係

本リポジトリは [dotfiles-core](https://github.com/yohi/dotfiles-core) によって管理されるコンポーネントの一つです。

### ⚠️ 単体使用時の注意点

本リポジトリは `dotfiles-core` の共通 Makefile ルール（`common-mk`）に依存しています。
単体で使用（クローン）する場合は、以下の手順が必要です：

1. `common-mk` ディレクトリを本リポジトリの親ディレクトリに配置するか、パスを適切に設定してください。
2. `make help` を実行して、正しく設定されていることを確認してください。

推奨される使用方法は、`dotfiles-core` から `make setup` を実行することです。

## 主要機能

- **プラグイン管理**: Zinit を使用した高速なプラグインロード。
- **プロンプト**: Powerlevel10k による高機能なコマンドプロンプト。
- **環境変数の統一**: zsh_env によるシェル非依存な環境変数の管理。
- **関数ライブラリ**: `functions/` 配下のカスタム Zsh 関数の自動ロード。

## ディレクトリ構成

```text
.
├── Makefile
├── README.md
├── AGENTS.md
├── zshrc                       # Main config
├── zsh_env                     # Environment variables
├── zsh_secrets.example         # Template for secrets
├── config/                     # Internal settings
├── functions/                  # Custom functions
│   ├── aws/                    # AWS CLI helper functions
│   └── examples/               # Configuration examples
├── prompts/                    # Prompt themes (p10k)
└── starship/                   # Starship prompt configuration
```

### 各ファイルの役割

#### 1. `zshrc`

メインの設定ファイルです。
プラグイン管理（Zinit）、プロンプト（Powerlevel10k）、および以下の設定ファイルの読み込みを制御します。

#### 2. `config.zsh` (Internal Framework Settings)

**このZsh設定自体の動作**をカスタマイズするためのファイルです。

- `FUNCTIONS_SUBDIR`: カスタム関数を格納するディレクトリの指定
- `FUNCTIONS_SKIP_PATTERNS`: 読み込みをスキップするファイルパターン
- `CANDIDATE_DIRS`: ドットファイルのリポジトリを探す候補ディレクトリ
- `FUNCTIONS_DEBUG`: 関数読み込みのデバッグモード切り替え

#### 3. zsh_env (Global Environment Variables)

ホームディレクトリの `~/.zsh_env` にリンクされる、**シェル環境全体の環境変数**を定義するファイルです。

- 言語設定 (`LANG`)
- 日本語入力設定 (`IBus`, `Fcitx5`)
- 外部ツールのパス (`GOPATH`, `bin` など)
- デフォルトエディタ (`EDITOR`, `VISUAL`)

#### 4. `.zsh_secrets` (Private)

APIキーやプライベートなトークンなど、リポジトリにコミットしたくない秘匿情報を記述します。
（`.gitignore` により管理対象外となっています）

#### 5. `functions/`

独自のZsh関数を格納するディレクトリです。`config.zsh` の設定に基づき、再帰的に自動読み込みされます。

## セットアップ

初回利用時は、テンプレートから設定ファイルを作成してください。
特に、**`config/config.example.zsh` から `config/config.zsh` を作成**し、
**`.zsh_secrets` を用意**することが必須です。

```bash
# 設定ファイルの作成
cp config/config.example.zsh config/config.zsh

# 秘匿情報ファイルの作成
touch .zsh_secrets
# またはテンプレートをコピー
# cp zsh_secrets.example .zsh_secrets
```

## カスタマイズ

- **環境変数を追加したい場合**: zsh_env を編集してください。
- **特定の関数ファイルを読み込みたくない場合**:
  ファイル拡張子を `.disabled` に変更するか、
  `config.zsh` の `FUNCTIONS_SKIP_PATTERNS` にパターンを追加してください。
- **デバッグ**:
  関数が正しく読み込まれない場合は、
  `config.zsh` で `FUNCTIONS_DEBUG=true` に設定して詳細を確認してください。
