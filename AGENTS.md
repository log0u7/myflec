# MyFlec - Agent Context

MyFlec is a modular collection of shell (Bash) configuration for Linux: bash
modules loaded by a small loader, plus native Git and SSH include mechanisms.
This file is the durable, agent-facing context.

## Project structure

- `.bashrc.d/` : bash modules, loaded by `.bashrc.d/myflec` (the loader).
  - Core modules are prefixed with `_` and load first, alphabetically.
  - Tool modules load next, alphabetically.
  - Repertoire `hosts/` pour les fichiers de configuration par machine.
  - The loader is invoked from `~/.bashrc` via the `profile` snippet.
- `.bash_aliases` : native Debian/Ubuntu mechanism, sourced by the default
  `.bashrc`. Kept on purpose, separate from `.bashrc.d/`. Do not consolidate.
- `.gitconfig` + `.gitconfig.d/` : identities selected by repo path via
  `includeIf "gitdir:..."`; shared aliases/colors/config via `include`.
- `.ssh/config` + `.ssh/config.d/` : per-context host configuration; `Include`
  brings in `config.d/*`. Git forge identities use host aliases
  (`github.com-work`, `gitlab.com-work`) so the SSH `User` is always `git`.

## Documentation principle

Sections follow the order: **Purpose** (what it does) -> **Usage** (how to use
it) -> **Internals** (how it is made). "Internals" (guards, load order, docker
image details) come last, not first.

## Conventions

- All code, comments, and documentation in English.
- Every optional tool must be guarded (`command -v <tool>`) so the shell
  degrades gracefully when the tool is absent.
- Apply DRY: reuse `setup_tool_path` from `_functions.bash` for PATH edits.
  Apply KISS and YAGNI: one module = one responsibility.
- No emoji in source files. Never commit secrets, private keys, or real host
  configs; use clearly generic placeholders.
- No em dash (`-`) in any output, file, or commit message. Use `:`, `,`,
  parentheses, or a plain hyphen `-` instead.
- Docker-run modules (zero-install tools): alias with `docker run --rm`,
  guard with `command -v docker`, mount `$PWD:/work -w /work` for file access.
  Pin major version tags when available (e.g. `:4`, `:v2`, `:1`).

## Do not break

- The loader (`.bashrc.d/myflec`) and its core-then-tools alphabetical ordering.
- The `.bash_aliases` mechanism (do not fold it into `.bashrc.d/`).
- Existing per-directory git identity selection (`includeIf`).
- The host-alias SSH pattern: forge blocks in `.ssh/config` use `User git`
  and a personal key; extra identities get a `-<label>` host alias.
- Note: aliases are resolved at call time, so an alias may reference a function
  defined by a later-loaded module. Do not "fix" this by reordering blindly.
- The `dot` alias (`_dotfiles.bash`) must be conditional (`[ -d ~/.dotfiles ]`).
- Native `cat` must not be overridden by bat (use `catp` instead).
- `GIT_PAGER=delta` (`delta.bash`) must be set only when delta is installed.
- Hook order (PROMPT_COMMAND): direnv -> fnox -> atuin. Respect load order.
- fzf Ctrl-R vs atuin Ctrl-R: atuin takes over if both present (last wins).
- `assets/` directory and `CHANGELOG.md` are repo-only: whitelisted in
  `.gitignore` but excluded from rsync deployment (`myflec.exclude.lst`).
- `assets/demo.tape` is the single source of truth for the terminal demo GIF.
  Regenerate only via `vhs assets/demo.tape` or the CI workflow.

## SSH identity model

Two orthogonal axes:

- **Git identity**: directory-driven via `includeIf "gitdir:..."` in `.gitconfig`.
- **SSH key**: remote-URL-driven via host alias in `.ssh/config`.

Key naming convention: `<forge>_<label>_<type>`
(e.g. `github.com_perso_ed25519`, `gitlab.com_work_ed25519`).

Forges: `github.com`, `gitlab.com`, `notabug.org`.

### Advanced SSH patterns (documented in README)

- **Self-hosted forges**: `Host git.company.work` with `User git`, same as
  public forges but internal. Git identity via `includeIf` + repo path.
- **ProxyJump / bastion**: `ProxyJump bastion.company.work` in host stanzas
  to reach internal services through a single bastion.
- **Chained ProxyJump**: comma-separated in `ProxyJump` for multi-hop
  (laptop -> bastion -> swarm-manager -> deploy target).
- **Connection multiplexing**: `ControlMaster auto` + `ControlPersist 10m`
  reuses a single TCP connection for fast subsequent SSH sessions.
- **Wildcard hosts**: `Host *.company.work` applies common settings to a
  group; specific blocks before wildcards take precedence (first match wins).
- **Multiple keys (fallback)**: ed25519 primary, rsa4096 secondary listed in
  order; `IdentitiesOnly yes` prevents extra keys.
- **SOCKS proxy (dynamic forward)**: `DynamicForward 9050` tunnels all
  traffic through a bastion; start with `ssh -f -N socks5`.
- **Port forwarding**: `LocalForward 4443 app.internal.lab:443` exposes a
  remote port locally; start with `ssh -f -N tunnel-app`. Also supports `-f`,
  `-N`, `-o ServerAliveInterval=30`, `-o ExitOnForwardFailure=yes`.

## Dotfiles deployment

Bare git repo at `$HOME/.dotfiles` with `--work-tree=$HOME`.
Module `_dotfiles.bash` provides:
- Alias `dot` (conditional on repo existence)
- Functions: `dotfiles-init`, `dotfiles-restore`, `dotfiles-list`,
  `dotfiles-status`, `dotfiles-backup`, `dotfiles-sync`,
  `dotfiles-addbackup`, `dotfiles-removebackup`, `dotfiles-remotes`
- The dotfiles repo is PRIVATE and DISTINCT from MyFlec (public).
- Multi-forge push via `git remote set-url --add --push origin <url>`.
- `.gitignore` whitelist mode (ignore all, allow specific paths).

## Modern tooling policy

- **Docker-run (zero-install)**: tools usable at first command via Docker.
  Guard: `command -v docker`. Mount `$PWD` for file access. Limited to CWD.
  Ex: glow, yq, jq, ctop, lazydocker, dive, sherlock.
- **Native (recommended)**: tools installed via mise. Guard: `command -v <tool>`.
  Ex: bat, ripgrep, fd, fzf, zoxide, lazygit, gh, glab, delta, atuin, direnv.
- **Native (obligatory)**: tools impossible to run in Docker (hooks, shims).
  Ex: fzf (`eval "$(fzf --bash)"`), zoxide, direnv, atuin.

## Validation commands

Run before proposing changes and again after:

```bash
# Syntax check every module
for f in .bashrc.d/*.bash .bashrc.d/myflec; do
    bash -n "$f" || echo "SYNTAX: $f"
done

# Static analysis (follows source via -x, suppression in .shellcheckrc)
shellcheck -x .bashrc.d/*.bash .bashrc.d/myflec

# Smoke test (must exit 0)
HOME=$PWD bash -c '. .bashrc.d/myflec'

# Smoke test with debug (must list all modules)
HOME=$PWD MYFLEC_DEBUG=1 bash -c '. .bashrc.d/myflec'

# SSH: verify resolved config without connecting
ssh -F .ssh/config -G github.com
ssh -F .ssh/config -G github.com-work
ssh -F .ssh/config -G gitlab.com

# rsync deployment dry run (repo-only files must not appear)
rsync -avn --exclude-from 'myflec.exclude.lst' ./ /tmp/myflec-dryrun/
```

## Commits

Conventional Commits, English, one atomic commit per logical fix.
Format: `type(scope): description`. Types: feat, fix, docs, refactor, chore,
ci, test, style, perf. Scopes: module name or cross-cutting concern.
Examples:
- `fix(go): export GOPATH and GOBIN`
- `refactor(vim): detect vim subshell via VIMRUNTIME instead of ps`
- `docs(readme): add mermaid load-order graph`
- `feat: add mise and fnox modules with fallback support`

## Branching

- `main`: stable branch, always releasable.
- Topic branches: `feat/`, `fix/`, `docs/`, `chore/`.
- One atomic commit per logical change.

## Changelog

- Keep `CHANGELOG.md` up to date (Keep a Changelog format).
- `[Unreleased]` section accumulates changes for the next version.
- On release: move `[Unreleased]` to a dated section, tag `vX.Y.Z`.

## Demo assets

- `assets/demo.tape` is the VHS source for the terminal demo GIF.
- Regenerate: `vhs assets/demo.tape` (requires vhs + ttyd + chrome + tools).
- The GitHub Actions workflow `.github/workflows/demo.yml` automates
  regeneration on push to `assets/demo.tape` or via `workflow_dispatch`.
- `assets/demo.gif` and `assets/demo.tape` are repo-only (excluded from rsync
  deployment via `myflec.exclude.lst`).

A change is done only when the validation commands above pass.
