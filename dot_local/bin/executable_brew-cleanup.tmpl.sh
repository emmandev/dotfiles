{{ if eq .chezmoi.os "darwin" -}}
#!/bin/bash

set -e

echo "🧹 Homebrew Cleanup Script"
echo "=================================="
echo ""
echo "This will remove packages not in your managed list."
echo "⚠️  Warning: This will uninstall any taps, brews, and casks not defined in packages.yml"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled"
    exit 0
fi

echo ""
echo "🔍 Checking for packages to remove..."

brew bundle cleanup --force --file=/dev/stdin <<EOF
{{ range .packages.darwin.taps -}}
tap {{ . | quote }}
{{ end -}}
{{ range .packages.darwin.brews -}}
brew {{ . | quote }}
{{ end -}}
{{ range .packages.darwin.casks -}}
cask {{ . | quote }}
{{ end -}}
EOF

echo ""
echo "✅ Cleanup complete!"
{{ end -}}
