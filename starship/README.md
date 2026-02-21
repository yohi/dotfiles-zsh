# Starship Configuration

## 概要
Starship は軽量で高速なクロスシェル対応プロンプトです。Powerlevel10kよりも軽量でtilixとの相性が良好です。

## ファイル構成
```
zsh/starship/
├── README.md           # このファイル
└── starship.toml       # Starship設定ファイル
```

## 設定ファイル
- **設定ファイル**: `starship.toml`
- **シンボリックリンク**: `~/.config/starship.toml` → `~/.dotfiles/zsh/starship/starship.toml`

## 特徴
- **軽量**: Powerlevel10kより高速起動
- **tilix対応**: 安定した動作
- **Git統合**: ブランチ・ステータス表示
- **開発言語検出**: Node.js, Python, Rust, Go等
- **実行時間表示**: 2秒以上のコマンド

## プロンプト構成
```
username@hostname directory git_info language_info
❯
```

### 表示例
```bash
# 通常ディレクトリ
y_ohi@XPS-13-9300 ~/dotfiles ❯

# Gitリポジトリ
y_ohi@XPS-13-9300 ~/project 🌱 main ❯

# Gitリポジトリ + 変更あり
y_ohi@XPS-13-9300 ~/project 🌱 main ⇡1 ❯

# Node.jsプロジェクト
y_ohi@XPS-13-9300 ~/app ⬢ v18.17.0 🌱 main ❯
```

## アクティベーション
zshrcで以下が実行される：
```bash
eval "$(starship init zsh)"
```

## カスタマイズ
設定の変更は `zsh/starship/starship.toml` を編集してください。
変更後は新しいターミナルセッションで反映されます。

## 依存関係
- **Starship**: `brew install starship`
- **Nerd Font**: Git/言語アイコン表示用（推奨）

## トラブルシューティング
- 表示が崩れる場合: Nerd Font対応フォントを使用
- 起動が遅い場合: 設定ファイルの機能を削減
- tilixクラッシュ: この設定では報告なし

## 関連ドキュメント
- [Starship 公式サイト](https://starship.rs/)
- [設定ガイド](https://starship.rs/config/)
