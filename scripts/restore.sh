#!/bin/bash
set -euo pipefail
[[ "${1:-}" == --run && "${2:-}" =~ ^[0-9T-]+$ ]] || { echo 'Usage: restore.sh --run RUN_ID'; exit 2; }
base="$HOME/.local/state/dotfiles/$2"
[[ -f "$base/manifest" ]] || exit 1
# Reverse order also restores multiple edits to the same target.
tail -r "$base/manifest" | while IFS=$'\t' read -r id dest; do
 [[ -t 1 ]] || { echo 'Interactive terminal required'; exit 1; }
 printf 'Restore %s (may discard subsequent edits)? [y/N] ' "$dest" > /dev/tty
 read -r reply < /dev/tty
 [[ "$reply" == y || "$reply" == Y ]] || continue
 [[ ! -d "$dest" || -L "$dest" ]] || { echo 'Refusing directory'; exit 1; }
 rm -f "$dest"
 if [[ ! -e "$base/$id.absent" ]]; then cp -pP "$base/$id" "$dest"; fi
done
