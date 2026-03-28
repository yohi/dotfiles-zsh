# Orchestrator core configuration
# Note: These are symlinked from ../../common-mk/ when managed by dotfiles-core
include _mk/core.mk
include _mk/help.mk

# Component-specific logic





REPO_ROOT ?= $(CURDIR)
include _mk/zsh.mk

.PHONY: link
link: ## シンボリックリンクを展開し、dotfiles を配置します
	@echo "==> Linking dotfiles-zsh"
	mkdir -p $(HOME)
	ln -sfn $(REPO_ROOT)/zshrc $(HOME)/.zshrc
	ln -sfn $(REPO_ROOT)/zsh_env $(HOME)/.zsh_env
	@if [ ! -f $(HOME)/.zsh_secrets.example ]; then \
		cp $(REPO_ROOT)/zsh_secrets.example $(HOME)/.zsh_secrets.example; \
		chmod 600 $(HOME)/.zsh_secrets.example; \
		echo "Copied zsh_secrets.example to $(HOME)/.zsh_secrets.example"; \
	fi

.PHONY: setup
setup: ## セットアップ（依存関係、設定適用）を一括実行します
	@echo "==> Setting up dotfiles-zsh"
	$(MAKE) setup-zsh
