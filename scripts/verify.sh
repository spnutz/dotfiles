#!/bin/bash
set -uo pipefail
status=0
for tool in brew git fnm node; do
 command -v "$tool" || status=1
done
/bin/zsh -n "$HOME/.dotfiles.zsh" || status=1
if command -v fnm >/dev/null; then fnm default; fi
for path in "$HOME/.config/ghostty/config" "$HOME/Library/Application Support/Code/User/settings.json"; do
 [[ -r "$path" ]] || status=1
done
exit "$status"
