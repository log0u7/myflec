# MyFlec

[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Linux-FCC624?logo=linux&logoColor=black)](https://kernel.org/)
[![Prompt](https://img.shields.io/badge/Prompt-Starship-DD0B78?logo=starship&logoColor=white)](https://starship.rs/)
[![Maintained](https://img.shields.io/badge/Maintained-yes-brightgreen)](https://github.com/log0u7/myflec)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

My Favorite Linux Environment Configuration.

```
         _nnnn_
        dGGGGMMb
       @p~qp~~qMb
       M|@||@) M|
       @,----.JM|
      JS^\__/  qKL
     dZP        qKRb
    dZP          qKKb
   fZP            SMMb
   HZM            MMMM
   FqM            MMMM
 __| ".        |\dS"qML
 |    `.       | `' \Zq
_)      \.___.,|     .'
\____   )MMMMMP|   .'
     `-'       `--'
```

A modular collection of shell configurations, aliases, and helper functions
to enhance your Linux experience.

For my Vim setup, see [MyVim](https://github.com/log0u7/myvim).

## Table of Contents

- [Features](#features)
- [Module Overview](#module-overview)
- [Debug Mode](#debug-mode)
- [Requirements](#requirements)
- [Installation](#installation)
- [Version Control](#version-control)
- [Contributing](#contributing)
- [Repositories](#repositories)
- [License](#license)

## Features

### Shell Enhancements

- Custom aliases: enhanced `ls` via `lsd`, `extract` for archives, colored
  `hexedit`, inline `calc` powered by `bc`
- Optimized Bash options: autocompletion, directory navigation, timestamped
  history, locale, colored GCC output
- Terminal integration: Starship prompt, Byobu, optional Powerline

### Development Tools

- Python: virtualenv management, pip shortcuts, formatting and linting helpers
- Go: project scaffolding, build and test shortcuts, module management
- Rust: Cargo shortcuts, build automation, documentation generation, linting
- Node.js: npm, yarn, and pnpm aliases, NVM integration, project scaffolding

### Docker Integration

- Container, image, volume, and network management shortcuts
- Docker Compose workflows
- Containerized tools: Sherlock (OSINT), Dive (layer analysis), Lazydocker

### SSH Management

- Key generation (`sshkg`), key adding (`sshadd`), agent helpers
- Per-context host configuration, jump hosts, connection persistence,
  host search (`searchhosts`)

### Git Configuration

- Context-aware identities based on repository path (work, GitHub, GitLab)
- Useful aliases and enhanced log visualization

## Module Overview

| File | Purpose |
| --- | --- |
| `myflec` | Loader: sources every `*.bash` module and initializes Starship |
| `_config.bash` | Locale, history, pager (`most`), GCC colors, terminal defaults |
| `_shopts.bash` | Bash `shopt` options |
| `_aliases.bash` | Maps helper functions to short aliases |
| `_functions.bash` | Core helpers: `mkcd`, `extract`, `calc`, GPG cipher, host search |
| `docker.bash` | Docker and Docker Compose aliases and containerized tools |
| `go.bash` | Go environment variables and aliases |
| `python.bash` | Python and pip aliases, virtualenv helpers |
| `rust.bash` | Rust and Cargo aliases |
| `nodejs.bash` | Node.js, npm, yarn, pnpm aliases and project helpers |
| `ssh.bash` | SSH key generation and agent helpers |
| `vim.bash` | Default editor configuration and aliases |
| `lsd.bash` | `lsd` drop-in aliases when `lsd` is available |
| `byobu.bash` | Byobu prompt integration |
| `powerline.bash` | Optional Powerline integration (disabled by default) |

Files prefixed with `_` are core modules loaded before tool-specific ones.

## Debug Mode

Set `MYFLEC_DEBUG` to any non-empty value to print one confirmation line per
loaded module at shell startup. When unset (the default), startup is silent.

```bash
MYFLEC_DEBUG=1 bash -i
# ✅ config configuration loaded
# ✅ shopts configuration loaded
# ✅ aliases configuration loaded
# ...
```

On terminals without UTF-8 support the check mark falls back to a plain
ASCII `+` character automatically.

## Requirements

Every optional tool is guarded by an availability check, so MyFlec degrades
gracefully when a tool is not installed. Recommended tools for the full
experience:

| Tool | Purpose |
| --- | --- |
| [lsd](https://github.com/lsd-rs/lsd) | Enhanced `ls` replacement |
| [starship](https://starship.rs/) | Cross-shell prompt |
| [most](https://www.jedsoft.org/most/) | Pager with color support |
| [byobu](https://byobu.org/) | Terminal multiplexer |
| [docker](https://docs.docker.com/) | Container runtime |
| nvm | Node.js version manager |
| go, rustup, python3 | Language toolchains |

## Installation

```bash
git clone https://github.com/log0u7/myflec
rsync -av --progress --exclude-from 'myflec/myflec.exclude.lst' myflec/ ~/
cat myflec/profile >> ~/.bashrc
. ~/.bashrc
```

## Version Control

The recommended workflow keeps `$HOME` out of git entirely. Use `rsync` to
deploy the repository to your home directory, and keep sensitive files
(real host configurations, private keys, real identities) out of version
control.

If you do want to track your own `$HOME` in a private repository, here is
how to set it up:

> **Warning:** use private repositories only and never track unencrypted
> secrets, private keys, or real host configurations.

1. Copy `.gitignore` to your home directory:

   ```bash
   cp myflec/.gitignore ~/
   ```

   Adjust the exceptions in `.gitignore` to match your setup.

2. Initialize the repository:

   ```bash
   git init
   git remote add origin your_repository_url
   git add -A
   git commit -m "Initial commit"
   git push -u origin main
   ```

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md)
before opening a pull request.

## Repositories

| Forge | URL |
| --- | --- |
| GitHub | https://github.com/log0u7/myflec |
| GitLab | https://gitlab.com/log0u7/myflec |
| NotABug | https://notabug.org/log0u7/myflec |

## License

Released under the MIT License. See [LICENSE](LICENSE) for details.
