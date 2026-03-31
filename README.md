# dotfiles-zsh

Zshシェルの設定ファイルとカスタム関数が格納されています。

## 管理と共存関係

> [!IMPORTANT]
> 本リポジトリは [dotfiles-core](https://github.com/yohi/dotfiles-core) によって管理されるコンポーネントの一つです。

> [!WARNING]
> **使用時の注意点**
> 本リポジトリは `dotfiles-core` の共通 Makefile ルール（`common-mk`）に依存しており、実行時には `common-mk` へのシンボリックリンクが必要です。そのため、**本リポジトリ単体での使用（クローンしての利用）はサポートされていません。**
>
> 推奨される使用方法は、`dotfiles-core` リポジトリから `make setup` を実行し、適切なディレクトリ構造とシンボリックリンクが構成された状態で利用することです。

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

- **環境変数を追加したい場合**: `.zsh_env` を編集してください。
- **特定の関数ファイルを読み込みたくない場合**: ファイル拡張子を `.disabled` に変更するか、`config.zsh` の `FUNCTIONS_SKIP_PATTERNS` にパターンを追加してください。
- **デバッグ**: 関数が正しく読み込まれない場合は、`config.zsh` で `FUNCTIONS_DEBUG=true` に設定して詳細を確認してください。
