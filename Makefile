macos:
	@echo "Installing macos dotfiles..."
	./scripts/macos/install.sh && ./scripts/macos/setup.sh

arch:
	@echo "Installing arch linux dotfiles..."
	./scripts/arch/install.sh && ./scripts/arch/setup.sh
