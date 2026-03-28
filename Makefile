# Orchestrator core configuration
# Note: These are symlinked from ../../common-mk/ when managed by dotfiles-core
include _mk/core.mk
include _mk/help.mk

# Component-specific logic





REPO_ROOT ?= $(CURDIR)
include _mk/zsh.mk

.PHONY: link
link: link-zshrc link-secrets ## シンボリックリンクを展開し、dotfiles を配置します

.PHONY: link-zshrc
link-zshrc:
	@echo "==> Linking zsh configuration files"
	mkdir -p $(HOME)
	ln -sfn $(REPO_ROOT)/zshrc $(HOME)/.zshrc
	ln -sfn $(REPO_ROOT)/zsh_env $(HOME)/.zsh_env

.PHONY: link-secrets
link-secrets:
	@echo "==> Linking/Copying zsh secrets"
	@if [ ! -f "$(HOME)/.zsh_secrets.example" ]; then \
		cp "$(REPO_ROOT)/zsh_secrets.example" "$(HOME)/.zsh_secrets.example" && \
		echo "Copied zsh_secrets.example to $(HOME)/.zsh_secrets.example"; \
	fi
	@if [ -f "$(HOME)/.zsh_secrets.example" ]; then \
		chmod 600 "$(HOME)/.zsh_secrets.example"; \
	fi

.PHONY: all setup clean test
all: setup ## セットアップを実行します（デフォルト）

setup: ## セットアップ（依存関係、設定適用）を一括実行します
	@echo "==> Setting up dotfiles-zsh"
	$(MAKE) setup-zsh

clean: ## クリーンアップ（ダミー）

test: ## テスト（ダミー）
