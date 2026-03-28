# Orchestrator core configuration
# Note: These are symlinked from ../../common-mk/ when managed by dotfiles-core
include _mk/core.mk
include _mk/help.mk

# Component-specific logic

REPO_ROOT ?= $(CURDIR)
include _mk/zsh.mk

.PHONY: all setup clean test
all: setup ## セットアップを実行します（デフォルト）

setup: ## セットアップ（依存関係、設定適用）を一括実行します
	@echo "==> Setting up dotfiles-zsh"
	$(MAKE) link
	$(MAKE) setup-zsh

clean: ## クリーンアップ（ダミー）

test: ## テスト（ダミー）
