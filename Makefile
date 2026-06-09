# dotfiles-core が提供する core.mk を読み込む（スタンドアロン実行は非対応）
include _mk/core.mk
.DEFAULT_GOAL := help

# 共通ルールの読み込み
-include _mk/zsh.mk

.PHONY: help
help: ## ヘルプを表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: install setup
install: install-zsh ## Zsh 関連のインストール
setup: setup-zsh ## Zsh の設定適用 (シンボリックリンク作成)
