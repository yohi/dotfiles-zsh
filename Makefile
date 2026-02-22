REPO_ROOT ?= $(CURDIR)
.DEFAULT_GOAL := setup
include _mk/zsh.mk

.PHONY: link
link:
	@echo "==> Linking dotfiles-zsh"
	mkdir -p $(HOME)
	ln -sfn $(REPO_ROOT)/zshrc $(HOME)/.zshrc
	ln -sfn $(REPO_ROOT)/zsh_env $(HOME)/.zsh_env
	ln -sfn $(REPO_ROOT)/zsh_secrets.example $(HOME)/.zsh_secrets.example

.PHONY: setup
setup:
	@echo "==> Setting up dotfiles-zsh"
	$(MAKE) setup-zsh
