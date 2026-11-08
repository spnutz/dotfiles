#!/bin/bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")" && pwd)
DRY=0
case "${1:-}" in --dry-run) DRY=1;; '') ;; *) echo 'Usage: ./install.sh [--dry-run]' >&2; exit 2;; esac
ask() { local reply; if [[ -t 0 ]]; then read -r -p "$1 [y/N] " reply; [[ "$reply" == y || "$reply" == Y ]]; else return 1; fi; }
if [[ "$(uname -s)" != Darwin || "$(uname -m)" != arm64 ]]; then echo 'Requires Apple Silicon macOS' >&2; exit 1; fi
BASE="$HOME/.local/state/dotfiles"
RUN="$(date +%Y%m%dT%H%M%S)-$$"
BACK="$BASE/$RUN"
if (( ! DRY )); then
 umask 077
 mkdir -p "$BACK"
 : > "$BACK/manifest"
 exec > >(tee -a "$BACK/install.log") 2>&1
fi
trap 'echo "Installation failed. Restore configuration with scripts/restore.sh --run $RUN" >&2' ERR
save() {
 local dest="$1" id
 id=$(wc -l < "$BACK/manifest" | tr -d ' ')
 if [[ -e "$dest" || -L "$dest" ]]; then cp -pP "$dest" "$BACK/$id"; else : > "$BACK/$id.absent"; fi
 printf '%s\t%s\n' "$id" "$dest" >> "$BACK/manifest"
}
deploy() {
 local src="$1" dest="$2"
 if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then echo "Unchanged: $dest"; return; fi
 if (( DRY )); then echo "Would deploy $src -> $dest (existing files require confirmation)"; return; fi
 if [[ -d "$dest" && ! -L "$dest" ]]; then echo "Skipping directory: $dest"; return; fi
 if [[ -e "$dest" || -L "$dest" ]]; then ask "Replace $dest?" || return 0; fi
 save "$dest"
 mkdir -p "$(dirname "$dest")"
 ln -s "$src" "$dest.dotfiles-$RUN"
 mv -f "$dest.dotfiles-$RUN" "$dest"
}
command_run() { if (( DRY )); then printf 'Would run:'; printf ' %q' "$@"; printf '\n'; else "$@"; fi; }
for component in packages shell ghostty node git vscode; do
 if (( DRY )); then echo "Preview component: $component"; else ask "Install $component?" || continue; fi
 case "$component" in
 packages)
 if ! command -v brew >/dev/null; then echo 'Install Homebrew manually, then rerun: https://brew.sh'; continue; fi
 command_run brew bundle --file="$ROOT/Brewfile"
 for app in font-jetbrains-mono-nerd-font ghostty visual-studio-code sourcetree dbeaver-community postman codex; do
 if (( DRY )); then echo "Optional cask: $app"; elif ask "Install optional cask $app?"; then brew list --cask "$app" >/dev/null 2>&1 || brew install --cask "$app"; fi
 done;;
 shell)
 command -v git >/dev/null || { echo 'Git missing; install Command Line Tools or packages first'; continue; }
 for spec in 'ohmyzsh/ohmyzsh|.oh-my-zsh|cca3bdfbef8c52ef8939ce7911ff68852b949daa' 'zsh-users/zsh-autosuggestions|.oh-my-zsh/custom/plugins/zsh-autosuggestions|85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5' 'zsh-users/zsh-syntax-highlighting|.oh-my-zsh/custom/plugins/zsh-syntax-highlighting|e6683f20e5c38d3e5447f45845d04ddda75d0f23'; do
 IFS='|' read -r repo target revision <<< "$spec"
 if [[ ! -e "$HOME/$target" ]]; then
 command_run git clone "https://github.com/$repo.git" "$HOME/$target"
 command_run git -C "$HOME/$target" checkout --detach "$revision"
 else echo "Preserving existing $target"; fi
 done
 deploy "$ROOT/configs/zsh/bootstrap.zsh" "$HOME/.dotfiles.zsh"
 if ! grep -Fq '# dotfiles managed' "$HOME/.zshrc" 2>/dev/null; then
 if (( DRY )); then echo 'Would append managed shell block'; elif ask 'Append dotfiles block to ~/.zshrc?'; then
 save "$HOME/.zshrc"
 printf '\n# dotfiles managed\nsource "$HOME/.dotfiles.zsh"\n# end dotfiles managed\n' >> "$HOME/.zshrc"
 fi
 fi;;
 ghostty) deploy "$ROOT/configs/ghostty/config" "$HOME/.config/ghostty/config";;
 node) if command -v fnm >/dev/null; then command_run fnm install 26.13.0; command_run fnm default 26.13.0; else echo 'fnm missing; install packages first'; fi;;
 git) cat "$ROOT/configs/git/config"; deploy "$ROOT/configs/git/config" "$HOME/.gitconfig";;
 vscode) cat "$ROOT/configs/vscode/settings.json"; deploy "$ROOT/configs/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json";;
 esac
done
if (( ! DRY )); then echo "Backup run: $RUN"; fi
