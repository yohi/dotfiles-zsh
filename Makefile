REPO_ROOT ?= $(CURDIR)
.DEFAULT_GOAL := setup
include _mk/zsh.mk

.PHONY: setup
setup: setup-zsh
	@echo "==> Setting up dotfiles-zsh"
