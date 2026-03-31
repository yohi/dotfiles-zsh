include _mk/core.mk
include _mk/help.mk
-include _mk/zsh.mk

install: install-zsh ## Zsh 関連のインストール
setup: setup-zsh ## Zsh の設定適用

install-zsh:
	@echo "==> Installing dotfiles-zsh"

setup-zsh:
	@echo "==> Setting up dotfiles-zsh"
	mkdir -p $(HOME)
	ln -sfn $(CURDIR)/zshrc $(HOME)/.zshrc
	ln -sfn $(CURDIR)/zsh_env $(HOME)/.zsh_env
	@if [ ! -f $(HOME)/.zsh_secrets.example ]; then \
		cp $(CURDIR)/zsh_secrets.example $(HOME)/.zsh_secrets.example; \
		chmod 600 $(HOME)/.zsh_secrets.example; \
		echo "Copied zsh_secrets.example to $(HOME)/.zsh_secrets.example"; \
	fi
