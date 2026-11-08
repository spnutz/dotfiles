# Security

Only explicit portable settings are included. Never commit credentials, private keys, authentication databases, tokens, local identity or backups. No shell tracing is used. Review diffs before committing. Backups can contain sensitive existing files and must remain outside Git. Repository symlinks mean updating tracked configuration changes deployed settings immediately; review updates first. Sign in manually to each application. Existing shell repositories are preserved without executing their installers.
