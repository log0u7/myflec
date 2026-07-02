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

## SSH identity model

Two orthogonal axes:

- **Git identity**: directory-driven via `includeIf "gitdir:..."` in `.gitconfig`.
- **SSH key**: remote-URL-driven via host alias in `.ssh/config`.

Key naming convention: `<forge>_<label>_<type>`
(e.g. `github.com_perso_ed25519`, `gitlab.com_work_ed25519`).

Forges: `github.com`, `gitlab.com`, `notabug.org`.

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
Examples:
- `fix(go): export GOPATH and GOBIN`
- `refactor(vim): detect vim subshell via VIMRUNTIME instead of ps`
- `docs(readme): add mermaid load-order graph`
- `feat: add mise and fnox modules with fallback support`

A change is done only when the validation commands above pass.
