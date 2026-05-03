#!/usr/bin/env bash

# Exit on error
set -e

echo "Starting Setup..."

# 1. Update system and install base dependencies
sudo pacman -Syu --needed --noconfirm base-devel git

# 2. Check/Install paru (AUR Helper)
if ! command -v paru &> /dev/null; then
    echo "Installing paru..."
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru && makepkg -si --noconfirm && cd -
else
    echo "paru is already installed."
fi

# 3. Install requested packages
# Split into official repos (pacman) and AUR (paru) for efficiency
echo "Installing packages..."
PACKAGES_PACMAN=(
    pinta obs-studio qalculate-gtk mpv sxiv fish alacritty fastfetch
)
PACKAGES_AUR=(
    google-chrome prism-launcher ttf-nerd-fonts-symbols-common # or nerd-fonts-complete if available
)

sudo pacman -S --needed --noconfirm "${PACKAGES_PACMAN[@]}"
paru -S --needed --noconfirm "${PACKAGES_AUR[@]}"

# 4. Clone Dotfiles and setup configs
DOTFILES_DIR="$HOME/dotfiles"
echo "Cloning dotfiles from https://github.com/Caositic/dotfiles..."

if [ ! -d "$DOTFILES_DIR" ]; then
    git clone https://github.com/Caositic/dotfiles "$DOTFILES_DIR"
else
    echo "Dotfiles directory already exists, pulling latest changes."
    cd "$DOTFILES_DIR" && git pull && cd -
fi

# Create config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Function to safely symlink configs
setup_config() {
    local name=$1
    local src="$DOTFILES_DIR/$name"
    local dest="$HOME/.config/$name"

    if [ -d "$src" ] || [ -f "$src" ]; then
        echo "Linking $name configuration..."
        # Backup existing config if it's not already a symlink
        if [ -e "$dest" ] && [ ! -L "$dest" ]; then
            mv "$dest" "${dest}.bak"
        fi
        ln -sf "$src" "$dest"
    else
        echo "Warning: $name not found in dotfiles repository."
    fi
}

# Link your specific requested apps
setup_config "alacritty"
setup_config "fastfetch"
setup_config "fish"

# 5. Set Fish as default shell
if [[ $SHELL != "/usr/bin/fish" ]]; then
    echo "Changing default shell to fish..."
    chsh -s /usr/bin/fish
fi

echo "Setup complete! Please log out and back in for shell changes."
