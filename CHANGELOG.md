# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2026-07-03

### Added

- Starship prompt: Gruvbox Rainbow preset (`~/.config/starship.toml`), requires
  a Nerd Font; tracked and deployed with the rest of MyFlec
- atuin: detect and source bash-preexec/ble.sh when present for full keybinding
  support (Ctrl-R + up-arrow); fall back to `--disable-up-arrow` when no
  preexec provider is available to avoid the startup warning
- lazygit: minimal config (`~/.config/lazygit/config.yml`) disabling startup
  popup, update checks, and random tip; enabling Nerd Font v3 icons
- demo: symlink `.gitconfig.d` and `.config` to HOME so git aliases and tool
  configs (starship, lazygit) are active during GIF recording; install
  bash-preexec for atuin full keybinding support (no warning, up-arrow works)
- demo: enrich git section with staged/unstaged/untracked changes, move cleanup
  after lazygit so the TUI shows real content

### Changed

- Node.js: prefer native binary over docker alias for glow/yq/jq/mdq; remove
  obsolete yarn completion block
- demo: slow down module-loading section (Sleep 6s) for readability

### Fixed

- dotfiles: `_DOTFILES_DIR` was unset at end of module load, breaking the `dot`
  alias and all `dotfiles-*` functions at call time
- demo: git aliases (`git st`, `git dc`) were unavailable during GIF recording
  because `.gitconfig.d/` was not symlinked to HOME

### Removed

- Per-host configuration: removed `_host.bash` module and `hosts/` directory
  (YAGNI; no documented real-world usage)

## [0.3.0] - 2026-07-02

### Added

- Modern CLI tooling: bat, ripgrep, fd, fzf, zoxide, direnv, atuin, lazygit,
  gh, glab, delta, tldr, glow, mdq, yq, jq (guarded by availability)
- Mise module with activation, short aliases (mi, miu, mii, ...), completion
- Fnox module with PROMPT_COMMAND hook, short aliases (fn, fns, fng, ...)
- Dotfiles bare repo management: `dotfiles-*` functions + `dot` alias
- Advanced SSH patterns: self-hosted forges, bastion/ProxyJump, chained
  ProxyJump, connection multiplexing, wildcard hosts, multi-key fallback,
  SOCKS proxy, port forwarding (tunnels)
- SSH config.d/lab (homelab wildcards)
- Company git identity example (.gitconfig.d/company + includeIf)
- Terminal demo GIF (VHS) and GitHub Actions CI workflow
- CHANGELOG.md (Keep a Changelog)
- Enriched CONTRIBUTING.md (conventional commits, branching, versioning)
- Continuous Integration: shellcheck -x, bash -n, loader smoke tests,
  actionlint, yamllint (.github/workflows/lint.yml + .gitlab-ci.yml)
- AGENTS.md with durable agent context
- MYFLEC_DEBUG for verbose module loading
- Mermaid load-order graph in SSH Identity Model documentation
- License (MIT) and CONTRIBUTING.md

### Changed

- Enforce core-then-tools alphabetical load order
- Redesigned README usage-first with quick start, deployment, tooling, module
  reference, SSH identity model (purpose/usage/internals), advanced SSH
  patterns, and requirements
- SSH Identity Model documentation restructured with 3 architecture diagrams
- Python module: uv + poetry support (optional), venv helpers, pip fallback
- Node.js module: cleaned no-op aliases, removed global NODE_ENV, dedup prefix
- Vim module: detect vim subshell via VIMRUNTIME instead of ps
- Config: stop forcing LC_ALL, guard LANG and TERM
- Loader: core-first two-pass, internal `_myflec_load()` helper, unset cleanup
- mdq: switch to docker-run image (yshavit/mdq:v0.10.0)

### Fixed

- SSH host aliases with `User git` for multi-identity forges (github.com-work,
  gitlab.com-work)
- Go: export GOPATH and GOBIN, add GOBIN to PATH via setup_tool_path
- Rsync: exclude repo-only files (myflec.exclude.lst)
- Loader: non-zero exit code leak from sourced files
- CI: replace invalid actionlint GitHub Action with binary v1.7.12 install
- SSH keygen: relaxed email regex TLD `{2,}`, use $HOME paths
- Python: removed no-op black/flake8 aliases
- SSH config.d/private: `Identityfile` -> `IdentityFile` (case fix)
- Docker: removed duplicate `dcrestart` alias
- CI: use tlrc instead of unavailable tldr in mise install (demo workflow)
- mdq: fix broken repository link (ysugimoto -> yshavit)
- CI: remove unneeded Chrome install from demo workflow (fix gpg /dev/tty), install ttyd + ffmpeg
- CI: demo workflow permissions, branch checkout, GIF assertion and explicit push
- CI: lint demo.yml with yamllint and actionlint
- Various typos in README, aliases, comments

## [0.2.0] - 2025-04-03

### Changed

- Updated `.bash_aliases`
- Updated `docker.bash`
- Updated `.gitconfig.d/config`

### Fixed

- Missing bashrc include file
- SSH config typos and comments

## [0.1.0] - 2023-10-27

### Added

- Modular `.bashrc.d/` loader with core and tool modules
- Split `.ssh/config` with `Include config.d/*`
- Split `.gitconfig` with `includeIf gitdir:` for per-directory identities
- Docker, Golang, and Powerline bash modules
- SSH keygen helpers (sshkg, sshadd)
- README with project overview and usage
- MIT License

### Fixed

- Git identities and searchhost function
- Various typos

[0.4.0]: https://github.com/log0u7/myflec/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/log0u7/myflec/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/log0u7/myflec/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/log0u7/myflec/releases/tag/v0.1.0
