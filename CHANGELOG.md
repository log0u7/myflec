# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-07-02

### Added

- Modern CLI tooling: bat, ripgrep, fd, fzf, zoxide, direnv, atuin, lazygit,
  gh, glab, delta, tldr, glow, mdq, yq, jq (guarded by availability)
- Mise module with activation, short aliases (mi, miu, mii, ...), completion
- Fnox module with PROMPT_COMMAND hook, short aliases (fn, fns, fng, ...)
- Dotfiles bare repo management: `dotfiles-*` functions + `dot` alias
- Per-host configuration (`_host.bash` + `hosts/` directory)
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

[0.3.0]: https://github.com/log0u7/myflec/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/log0u7/myflec/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/log0u7/myflec/releases/tag/v0.1.0
