# dotfiles

Portable Apple Silicon macOS bootstrap built from the inspected machine. Requires macOS arm64, Bash, Git/Command Line Tools, and Homebrew for package installation. Install missing Apple tools and Homebrew manually first. No sudo is invoked by these scripts.

## Install and update

Keep this repository at `~/Developer/projects/dotfiles` (symlinks depend on its location). A future GitHub repository should be named `dotfiles`; no remote is configured.

```sh
cd ~/Developer/projects/dotfiles
./install.sh --dry-run
./install.sh
./scripts/verify.sh
```

Interactive choices default to no. Noninteractive execution skips all components. Dry-run previews every component without writing or downloading. Rerun after updating the checkout to apply changes. Brewfile contains verified leaf formulae; apps are individually optional. Existing packages are not intentionally upgraded. Homebrew resolves current package versions, rather than reproducing the complete historical dependency graph.

Shell bootstrap preserves existing Oh My Zsh installations. New checkouts use recorded revisions. Existing shell initialization may duplicate fnm/Oh My Zsh initialization: review your shell configuration before enabling the managed block. Remove superseded initialization manually after backup. VS Code and Git configuration replacement is previewed and requires consent; preserve desired Git settings in `~/.gitconfig.local`, including your identity and global ignore path, before selecting Git. No credentials are copied. Existing installed extensions are not inferred.

## Backup and restore

Backups and logs live at `~/.local/state/dotfiles/<run-id>` with owner-only permissions. They may contain sensitive original configuration: do not publish them. Restore with `./scripts/restore.sh --run <run-id>` from a terminal. Every restore requires confirmation because subsequent edits may exist. Restore handles configuration only; packages, Node aliases, cloned shell repositories and directories are not automatically undone. See docs/recovery.md.

## Validation

Run `bash tests/smoke.sh`. Tests use an isolated HOME and mock external commands, never installing packages into your current environment. Authentication for GitHub, Codex and applications remains manual.
