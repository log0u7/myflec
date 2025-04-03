# MyFlec - My Favorite Linux Environment Configuration
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

A comprehensive collection of shell configurations and aliases to enhance your Linux experience. For my Vim setup, see [MyVim](https://github.com/log0u7/myvim).

## Table of Contents

- [Features](#features)
  - [Shell Enhancements](#shell-enhancements)
  - [Development Tools](#development-tools)
  - [Docker Integration](#docker-integration)
  - [SSH Management](#ssh-management)
  - [Git Configuration](#git-configuration)
- [Installation](#installation)
- [Version Control](#version-control)

## Features

### Shell Enhancements

- **Custom Aliases**: Convenient shortcuts for common commands
  - File navigation with enhanced `ls` using `lsd`
  - Quick file extraction with the `extract` function
  - Hexadecimal editor with color support
  - Calculator function with `calc`

- **Shell Options**: Optimized Bash behavior
  - Autocompletion improvements
  - Directory navigation enhancements
  - History management with timestamps
  - Locale configuration
  - Colored GCC warnings and errors

- **Terminal Customization**:
  - Integration with Starship prompt (when available)
  - Support for Byobu terminal multiplexer
  - Optional Powerline integration

### Development Tools

- **Python Environment**:
  - Virtual environment management
  - Package installation shortcuts
  - Code formatting and linting tools
  - Debugging helpers

- **Go Development**:
  - Project management helpers
  - Build and test shortcuts
  - Module management
  - Code formatting tools

- **Rust Development**:
  - Cargo command shortcuts
  - Build and test automation
  - Documentation generation
  - Linting and formatting

### Docker Integration

- **Container Management**:
  - Shorthand aliases for Docker commands
  - Container inspection utilities
  - Image and volume management
  - Docker Compose workflows

- **Specialized Tools**:
  - Sherlock container for OSINT investigations
  - Dive for Docker layer analysis
  - Lazydocker for container management

### SSH Management

- **Key Management**:
  - SSH key generation with `sshkg`
  - Easy key adding with `sshadd`
  - SSH agent management

- **Host Configuration**:
  - Domain-specific configurations
  - Jump host setups
  - Connection persistence
  - Host searching

### Git Configuration

- **Multiple Identities**:
  - Context-aware Git identities based on repository path
  - Separate configurations for work, GitHub, and GitLab

- **Useful Aliases**:
  - Shortened common Git commands
  - Enhanced logging and visualization
  - Status overview improvements

## Installation

```bash
git clone https://github.com/log0u7/myflec
rsync -av --progress --exclude-from 'myflec/myflec.exclude.lst' myflec/ ~/
cat myflec/profile >> ~/.bashrc
. ~/.bashrc
```

## Version Control

You may want to use git to keep track of your own setup and back it up.

**! Use only private repositories and/or don't track any unencrypted secrets !**

1. Copy `.gitignore` to your home directory:
   ```bash
   cp myflec/.gitignore ~/
   ```
   _Note: You may want to modify exceptions in `.gitignore`_

2. Initialize git repository:
   ```bash
   git init
   git remote add origin your_repository_url
   git add *
   git commit -m "Initial sync to your_repository_url"
   git push -u origin main
   ```