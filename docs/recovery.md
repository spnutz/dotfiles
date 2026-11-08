# Recovery and troubleshooting

On failure, inspect the private run log and restore configuration with scripts/restore.sh --run RUN_ID. Fix the missing dependency or network problem and rerun. Existing configuration requires consent before replacement. A failed shell clone may leave a partial directory; inspect it manually before retrying. No existing repository is reset or deleted.

Install Command Line Tools with Apple's supported interactive workflow and Homebrew from https://brew.sh before selecting packages. Shell repositories are cloned only if absent, then checked out at recorded revisions. Existing installations are left unchanged. If a pinned revision is unavailable, stop and investigate rather than substitute arbitrary code.

Configuration restore does not remove installed packages or clones, reset the fnm default alias, remove created parent directories, or restore original app versions. Review these changes manually. Before changing Node, record the existing `fnm default`. Restore it manually if needed. App sign-in, Git identity and credential setup remain manual.
