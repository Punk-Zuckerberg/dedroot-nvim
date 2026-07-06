NVIM_CONFIG_DIR = $(HOME)/.config/nvim
BACKUP_DIR = $(HOME)/.config/nvim_backup_$(shell date +%Y%m%d_%H%M%S)

.PHONY: help install backup sync clean deps-macos deps-arch deps-linux deps-manjaro deps-ubuntu deps-debian deps-fedora deps-opensuse

help:
	@echo "DedRoot Neovim IDE"
	@echo ""
	@echo "Targets:"
	@echo "  make deps-macos    Install deps on macOS"
	@echo "  make deps-arch     Install deps on Arch Linux"
	@echo "  make deps-ubuntu   Install deps on Ubuntu/Debian"
	@echo "  make deps-fedora   Install deps on Fedora"
	@echo "  make deps-opensuse Install deps on openSUSE"
	@echo "  make install       Install Neovim config"
	@echo "  make sync          Sync Lazy plugins"
	@echo "  make clean         Remove Neovim cache/state"

install: backup
	mkdir -p $(NVIM_CONFIG_DIR)
	cp init.lua $(NVIM_CONFIG_DIR)/init.lua
	nvim --headless "+Lazy! sync" +qa

backup:
	@if [ -d "$(NVIM_CONFIG_DIR)" ]; then \
		echo "Backing up old config to $(BACKUP_DIR)"; \
		mv "$(NVIM_CONFIG_DIR)" "$(BACKUP_DIR)"; \
	fi

deps-macos:
	brew install git ripgrep fd llvm neovim make
	brew install --cask font-jetbrains-mono-nerd-font

deps-arch:
	sudo pacman -S --needed git ripgrep fd llvm clang neovim make

deps-linux: deps-arch

deps-manjaro: deps-arch

deps-ubuntu:
	sudo apt update
	sudo apt install -y git ripgrep fd-find clang neovim make

deps-debian: deps-ubuntu

deps-fedora:
	sudo dnf install -y git ripgrep fd-find clang neovim make

deps-opensuse:
	sudo zypper install -y git ripgrep fd clang neovim make

sync:
	nvim --headless "+Lazy! sync" +qa

clean:
	rm -rf $(HOME)/.local/share/nvim
	rm -rf $(HOME)/.local/state/nvim
	rm -rf $(HOME)/.cache/nvim
