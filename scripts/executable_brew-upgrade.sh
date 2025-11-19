#!/bin/bash

set -e

echo "🍺 Homebrew Manual Upgrade Script"
echo "=================================="
echo ""

# Update Homebrew
echo "📦 Updating Homebrew..."
brew update

echo ""
echo "⬆️  Upgrading installed packages..."
brew upgrade

echo ""
echo "🧹 Cleaning up old versions..."
brew cleanup

echo ""
echo "✅ Brew upgrade complete!"
echo ""
echo "💡 Tip: Run 'brew bundle cleanup --file=~/.local/share/chezmoi/.chezmoidata/packages.yml' to remove packages not in your list"
