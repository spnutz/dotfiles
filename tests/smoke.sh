#!/bin/bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/home with spaces" "$tmp/bin"
cat > "$tmp/bin/uname" <<'EOF'
#!/bin/sh
case "$1" in -s) echo Darwin;; -m) echo arm64;; esac
EOF
cat > "$tmp/bin/brew" <<'EOF'
#!/bin/sh
echo 'Unexpected brew mutation' >&2
exit 99
EOF
cp "$tmp/bin/brew" "$tmp/bin/fnm"
chmod +x "$tmp/bin/"*
for script in "$root/install.sh" "$root/scripts/"*.sh; do bash -n "$script"; done
HOME="$tmp/home with spaces" PATH="$tmp/bin:$PATH" bash "$root/install.sh" --dry-run > "$tmp/preview"
[[ -z "$(ls -A "$tmp/home with spaces")" ]]
grep -q 'Would deploy' "$tmp/preview"
grep -q 'Would run:' "$tmp/preview"
HOME="$tmp/home with spaces" PATH="$tmp/bin:$PATH" bash "$root/install.sh" --dry-run > "$tmp/preview2"
cmp "$tmp/preview" "$tmp/preview2"
if HOME="$tmp/home with spaces" bash "$root/install.sh" --unknown >/dev/null 2>&1; then exit 1; fi
printf 'Passed: shell syntax, isolated dry-run, repeat dry-run, spaces, rejected arguments.\n'
