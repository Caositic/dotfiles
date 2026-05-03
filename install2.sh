#!/usr/bin/env bash
#===========================================================
# CachyOS Auto-Setup: Packages & Caositic Dotfiles
#===========================================================
# This script will:
# 1. Install 'paru' if it's not already present
# 2. Install all required packages via pacman/paru
# 3. Clone your dotfiles repo and deploy configs for
#    Alacritty, Fastfetch, and Fish
#===========================================================

set -euo pipefail  # Exit on error, undefined variable, or pipe failure

# ---------- Color helpers ----------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}==> Starting CachyOS setup...${NC}"

#===========================================================
# 0. Prerequisites
#===========================================================
echo -e "${YELLOW}==> Installing base-devel and git (if missing)...${NC}"
sudo pacman -S --needed --noconfirm base-devel git

#===========================================================
# 1. Install paru (the default AUR helper on CachyOS)
#===========================================================
if ! command -v paru &> /dev/null; then
    echo -e "${YELLOW}==> Installing paru...${NC}"
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ~
    echo -e "${GREEN}==> paru installed.${NC}"
else
    echo -e "${GREEN}==> paru is already installed.${NC}"
fi

#===========================================================
# 2. Install all requested packages
#===========================================================
echo -e "${YELLOW}==> Installing packages...${NC}"

# Use paru for everything (it wraps pacman and the AUR)
paru -S --needed --noconfirm \
    google-chrome \
    pinta \
    ttf-nerd-fonts-symbols \
    obs-studio \
    prism-launcher \
    qalculate-gtk \
    mpv \
    sxiv \
    fish \
    alacritty \
    fastfetch

echo -e "${GREEN}==> All packages installed.${NC}"

#===========================================================
# 3. Deploy dotfiles from GitHub
#===========================================================
DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="https://github.com/Caositic/dotfiles.git"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${YELLOW}==> Cloning dotfiles repository...${NC}"
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo -e "${YELLOW}==> Dotfiles directory already exists. Pulling latest changes...${NC}"
    git -C "$DOTFILES_DIR" pull
fi

# ---------- Alacritty ----------
echo -e "${YELLOW}==> Deploying Alacritty config...${NC}"
mkdir -p "$HOME/.config/alacritty"
cp -r "$DOTFILES_DIR/alacritty/"* "$HOME/.config/alacritty/"

# ---------- Fastfetch ----------
echo -e "${YELLOW}==> Deploying Fastfetch config...${NC}"
mkdir -p "$HOME/.config/fastfetch"
cp -r "$DOTFILES_DIR/fastfetch/"* "$HOME/.config/fastfetch/"

# ---------- Fish ----------
echo -e "${YELLOW}==> Deploying Fish config...${NC}"
mkdir -p "$HOME/.config/fish"
cp -r "$DOTFILES_DIR/fish/"* "$HOME/.config/fish/"

echo -e "${GREEN}==> Dotfiles deployed successfully.${NC}"

#===========================================================
# 4. Final steps
#===========================================================
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Setup complete!                      ${NC}"
echo -e "${GREEN}  - All packages are installed.        ${NC}"
echo -e "${GREEN}  - Dotfiles are deployed.             ${NC}"
echo -e "${GREEN}  - Restart your shell or run:         ${NC}"
echo -e "${GREEN}    exec fish                           ${NC}"
echo -e "${GREEN}========================================${NC}"
