#!/usr/bin/env bash

set -e

echo "======================================"
echo "   Linux Post Install Script 🚀"
echo "======================================"

# Detect package manager
if command -v pacman &> /dev/null; then
    PM="pacman"
elif command -v apt &> /dev/null; then
    PM="apt"
else
    echo "❌ Unsupported system (no pacman or apt found)"
    exit 1
fi

echo "📦 Detected package manager: $PM"

# Update system
echo "🔄 Updating system..."

if [ "$PM" = "pacman" ]; then
    sudo pacman -Syu --noconfirm
elif [ "$PM" = "apt" ]; then
    sudo apt update && sudo apt upgrade -y
fi

# Install base packages
echo "📦 Installing essential packages..."

if [ "$PM" = "pacman" ]; then
    sudo pacman -S --noconfirm git curl wget unzip base-devel
elif [ "$PM" = "apt" ]; then
    sudo apt install -y git curl wget unzip build-essential
fi

# Install dev tools
echo "💻 Installing development tools..."

if [ "$PM" = "pacman" ]; then
    sudo pacman -S --noconfirm python nodejs npm
elif [ "$PM" = "apt" ]; then
    sudo apt install -y python3 python3-pip nodejs npm
fi

# Git config
echo "🔧 Git configuration..."

read -p "Enter your Git username: " gituser
read -p "Enter your Git email: " gitemail

git config --global user.name "$gituser"
git config --global user.email "$gitemail"

echo "🔑 Generating SSH key..."
ssh-keygen -t ed25519 -C "$gitemail" -N "" -f "$HOME/.ssh/id_ed25519" || true

# Firewall (Debian/Ubuntu only)
if [ "$PM" = "apt" ]; then
    echo "🔥 Setting up firewall..."
    sudo apt install -y ufw
    sudo ufw enable
fi

# Flatpak
echo "📦 Installing Flatpak..."

if [ "$PM" = "pacman" ]; then
    sudo pacman -S --noconfirm flatpak
elif [ "$PM" = "apt" ]; then
    sudo apt install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Cleanup
echo "🧹 Cleaning system..."

if [ "$PM" = "pacman" ]; then
    sudo pacman -Sc --noconfirm
elif [ "$PM" = "apt" ]; then
    sudo apt autoremove -y && sudo apt clean
fi

echo "======================================"
echo "✅ Setup complete! Your system is ready."
echo "======================================"
