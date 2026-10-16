# MyFlec

[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Linux-FCC624?logo=linux&logoColor=black)](https://kernel.org/)
[![Prompt](https://img.shields.io/badge/Prompt-Starship-DD0B78?logo=starship&logoColor=white)](https://starship.rs/)
[![Maintained](https://img.shields.io/badge/Maintained-yes-brightgreen)](https://github.com/log0u7/myflec)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

My Favorite Linux Environment Configuration.

![MyFlec demo](assets/demo.gif)

A modular Bash configuration: small modules loaded by a loader, plus Git and
SSH identity templates. Every optional tool is guarded by an availability
check, so MyFlec degrades gracefully when a tool is not installed.

Everything is driven by one command: `myflec`.

## Table of Contents

- [Install](#install)
- [The myflec command](#the-myflec-command)
- [Backup and restore](#backup-and-restore)
- [Tools](#tools)
- [Modules](#modules)
- [SSH and Git identities](#ssh-and-git-identities)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Repositories](#repositories)
- [License](#license)

## Install

```bash
git clone https://github.com/log0u7/myflec ~/myflec
bash -c '. ~/myflec/.bashrc.d/_myflec.bash && fMyflec deploy -C ~/myflec'
cat ~/myflec/profile >> ~/.bashrc
exec bash
```

The second line runs `myflec deploy` before MyFlec is installed: it shows a
dry run, asks for confirmation, backs up every overwritten file under
`~/.local/state/myflec-backup/<date>/`, then checks that SSH keys and the git
identity are in place.

Identity templates (`.ssh/`, `.gitconfig`, `.gitconfig.d`) are never
deployed: they are generic placeholders, see
[SSH and Git identities](#ssh-and-git-identities).

To update later, pull the repo and run `myflec deploy -C ~/myflec` again,
then `myflec reload`.

## The myflec command

| Command | What it does |
|---|---|
| `myflec status` | List loaded modules (core then tool) |
| `myflec reload [--full]` | Re-source modules in the current shell (`--full`: the whole loader) |
| `myflec deploy [-C repo] [--yes]` | Deploy the repo to `$HOME` (dry run, confirm, backup, checks) |
| `myflec init <url> [<url>...]` | Create the backup repo, extra URLs become push targets |
| `myflec add <path>...` | Start tracking files in the backup |
| `myflec rm <path>...` | Stop tracking files (they stay on disk) |
| `myflec submodule add <url> <path>` | Track an embedded git repo |
| `myflec submodule update` | Init and update embedded repos |
| `myflec backup [message]` | Commit tracked changes and push to every remote |
| `myflec restore <url>` | Restore a backup into `$HOME` (new machine) |
| `myflec sync` | Pull the latest backup |
| `myflec changes` | Show changes in tracked files |
| `myflec files` | List tracked files |
| `myflec remote [add\|rm <url>]` | List, add or remove push targets |
| `myflec help` | Show help |

`myflec reload` keeps shell hooks intact. Use `--full` only after changing
the loader or `_myflec.bash` itself (hooks may then accumulate, a new shell
is cleaner).

## Backup and restore

`deploy` installs MyFlec. Backup versions **your own** live configuration,
in a private repo distinct from MyFlec.

### First time

```bash
myflec init git@github.com:user/dotfiles.git

# Whitelist what you want to track
echo '*' > ~/.gitignore
echo '!.bashrc.d' >> ~/.gitignore
echo '!.gitconfig' >> ~/.gitignore

myflec add .gitignore .bashrc.d .gitconfig
myflec backup "initial commit"
```

### Every day

```bash
myflec changes                  # what changed
myflec add .config/foo.toml     # track a new file
myflec backup "update foo"      # commit and push everywhere
```

### New machine

```bash
myflec restore git@github.com:user/dotfiles.git
```

Files that would be overwritten are backed up to a temporary directory
first; the path is printed. Submodules, if any, are restored too.

To stop tracking a file without deleting it: `myflec rm <path>`.

### Embedded repos

A git repo living in `$HOME` (myflec itself, a vim plugin set...) is
tracked as a submodule, by URL rather than by content:

```bash
myflec submodule add https://github.com/log0u7/myflec myflec
myflec backup "track myflec"
myflec submodule update         # resync after a pull or on another machine
```

### Several forges

```bash
myflec remote add git@gitlab.com:user/dotfiles.git
myflec remote                   # verify
myflec remote rm git@gitlab.com:user/dotfiles.git
```

`myflec init` accepts several URLs at once to the same effect.

### How it works

The backup is a git bare repo at `~/.dotfiles` whose work tree is `$HOME`:
no symlinks, no copies. For anything `myflec` does not cover, `dot` is
plain git on that repo (`dot log`, `dot diff`) and exists only once the
repo is created. Untracked files are hidden from status, and the `.gitignore`
whitelist prevents committing sensitive data by accident.

### Compatibility

The former `dotfiles-*` functions and the raw `dot` (git) commands still
work:

| Former | Now |
|---|---|
| `dotfiles-init` | `myflec init` |
| `dotfiles-backup` | `myflec backup` |
| `dotfiles-restore` | `myflec restore` |
| `dotfiles-sync` | `myflec sync` |
| `dotfiles-status` | `myflec changes` |
| `dotfiles-list` | `myflec files` |
| `dotfiles-remotes` | `myflec remote` |
| `dotfiles-addbackup` | `myflec remote add` |
| `dotfiles-removebackup` | `myflec remote rm` |
| `myflec backup --init` | `myflec init` |
| `dot add <path>` | `myflec add <path>` |
| `dot rm --cached <path>` | `myflec rm <path>` |
| `dot submodule add <url> <path>` | `myflec submodule add <url> <path>` |
| `dot submodule update --init` | `myflec submodule update` |

## Tools

### Quick reference

| Need | Command | Tool |
|---|---|---|
| Search file contents | `rg pattern` | ripgrep |
| Find files by name | `fd name` | fd |
| Show a file with colors | `catp file` | bat |
| Fuzzy history / files | `Ctrl-R` / `Ctrl-T` | fzf, atuin |
| Jump to a directory | `z project` | zoxide |
| Git TUI | `lgit` | lazygit |
| Git diff with colors | `git diff` | delta |
| Read Markdown | `md README.md` | glow |
| Query Markdown / YAML / JSON | `mdq`, `yq`, `jq` | mdq, yq, jq |
| Containers | `ctop`, `lazydocker`, `dive` | docker |
| Forges | `gh`, `glab` | GitHub / GitLab CLI |
| Short man pages | `tldr tar` | tldr |
| Per-directory env | automatic on `cd` | direnv, mise, fnox |

### Install

Native tools, through [mise](https://mise.jdx.dev/):

```bash
mise use -g bat ripgrep fd fzf zoxide lazygit gh glab delta atuin direnv tlrc uv
```

`glow`, `yq`, `jq`, `mdq`, `ctop`, `lazydocker`, `dive` and `sherlock` need
no install: they run through Docker on first use. File-reading ones mount the
current directory, so they only see files under `$PWD` (pipes work).

Also expected: [starship](https://starship.rs/) (prompt, Nerd Font
required), `lsd`, `most`, and optionally `docker`, `byobu`,
[fnox](https://fnox.jdx.dev/).

### Mise and fnox

- **mise** manages runtimes, env vars and tasks from `mise.toml`. When it is
  installed, NVM, rustup and manual `GOROOT` are disabled; otherwise they
  take over transparently. Aliases: `miu` (use), `mii` (install), `mir`
  (run), `mix` (exec), `mil` (list). Template:
  [mise.toml.example](mise.toml.example).
- **fnox** loads secrets (age-encrypted in git, or from a cloud or password
  manager backend) when entering a directory with a `fnox.toml`. Aliases:
  `fns` (set), `fng` (get), `fnl` (list), `fne` (exec). Template:
  [fnox.toml.example](fnox.toml.example).

### Coexistence

- fzf and atuin both bind Ctrl-R: atuin wins, fzf keeps Ctrl-T and Alt-C.
  Atuin up-arrow needs bash-preexec or ble.sh.
- `cat` is never overridden: use `catp` for bat.
- `GIT_PAGER=delta` is set only when delta is installed.
- `lgit` (lazygit) and `git lg` (git alias) do not clash.

## Modules

The `profile` snippet in `~/.bashrc` sources `.bashrc.d/loader`, which loads
core modules (`_*.bash`) then tool modules (`*.bash`), each in alphabetical
order, then starts Starship.

| Module | Role |
|---|---|
| `_aliases.bash` | Short aliases for core helpers (`calc`, `mkcd`, `extract`, `myflec`) |
| `_config.bash` | Locale, history, pager, colors, TERM |
| `_dotfiles.bash` | Backup toolbox behind `myflec init/backup/restore/...`, `dot` alias |
| `_functions.bash` | Core helpers (`setup_tool_path`, `mkcd`, `extract`, `calc`, GPG, host search) |
| `_myflec.bash` | The `myflec` command |
| `_shopts.bash` | Bash `shopt` options |
| `mise.bash`, `fnox.bash` | Activation, hooks, aliases, completion |
| `bat`, `ripgrep`, `fd`, `fzf`, `zoxide`, `direnv`, `atuin`, `lazygit`, `delta`, `tldr`, `lsd` | Modern CLI integration |
| `glow`, `mdq`, `yq`, `jq`, `docker` | Docker-run tools and Docker aliases |
| `forge-cli.bash` | `gh` and `glab` completion and aliases |
| `python`, `go`, `rust`, `nodejs` | Language aliases, fallback version managers when mise is absent |
| `ssh.bash` | Key generation (`sshkg`, `sshadd`) |
| `vim.bash`, `byobu.bash`, `opencode.bash` | Editor, multiplexer, AI agent env |

`.bash_aliases` is sourced by the stock Debian/Ubuntu `.bashrc` and kept
separate on purpose.

Set `MYFLEC_DEBUG=1` to print one line per loaded module at startup:

```bash
MYFLEC_DEBUG=1 bash -i
```

## SSH and Git identities

The repo ships generic templates for `.ssh/config`, `.ssh/config.d/`,
`.gitconfig` and `.gitconfig.d/`, built on two independent axes:

- **who you commit as**: chosen by the repository location or remote
  (`includeIf` in `.gitconfig`);
- **which key pushes**: chosen by the SSH host alias in the remote URL
  (`git@github.com-work:org/repo`).

GitHub and GitLab go through SSH over port 443 by default.

These templates are never deployed by `myflec deploy`: adapt and copy them
yourself. Details, bastions, tunnels and multiplexing are in
[SSH.md](SSH.md) and [GIT-IDENTITY.md](GIT-IDENTITY.md).

## Troubleshooting

- **Startup is silent, a module seems missing**: `myflec status`, then
  `MYFLEC_DEBUG=1 bash -i`.
- **vim fails with `No module named '_contextvars'`**: `PYTHONHOME` points
  to a mise or pyenv tree. `python.bash` unsets it in the shell; for vim,
  add `call setenv('PYTHONHOME', v:null)` to `~/.vim/vimrc`.
- **`git push` hangs on a restricted network**: port 22 is blocked; check
  `ssh -G github.com | grep -E 'hostname|port'` (expected: port 443).

## Contributing

Contributions are welcome: read [CONTRIBUTING.md](CONTRIBUTING.md) first.
History is in [CHANGELOG.md](CHANGELOG.md).

## Repositories

| Forge | URL |
|---|---|
| GitHub | https://github.com/log0u7/myflec |
| GitLab | https://gitlab.com/log0u7/myflec |
| NotABug | https://notabug.org/log0u7/myflec |

## License

Released under the MIT License. See [LICENSE](LICENSE).
