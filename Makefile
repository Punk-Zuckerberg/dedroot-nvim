NVIM_CONFIG_DIR = $(HOME)/.config/nvim
BACKUP_DIR = $(HOME)/.config/nvim_backup_$(shell date +%Y%m%d_%H%M%S)

.PHONY: install backup deps-macos deps-linux clean sync

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
	brew install git ripgrep fd llvm neovim
	brew install --cask font-jetbrains-mono-nerd-font

deps-linux:
	sudo pacman -S --needed git ripgrep fd llvm clang neovim

sync:
	nvim --headless "+Lazy! sync" +qa

clean:
	rm -rf $(HOME)/.local/share/nvim
	rm -rf $(HOME)/.local/state/nvim
	rm -rf $(HOME)/.cache/nvim
