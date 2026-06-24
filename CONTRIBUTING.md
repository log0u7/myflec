# Contributing to MyFlec

Thanks for your interest in improving MyFlec. This project is a personal
dotfiles collection, but suggestions, fixes, and improvements are welcome.

## Ground Rules

- Keep modules self-contained: one tool or concern per `.bashrc.d/*.bash` file.
- Guard every optional tool with a availability check (for example
  `command -v lsd`), so a missing tool never breaks shell startup.
- Never commit secrets, private keys, real hostnames, or personal identities.
  The repository ships anonymized examples only.
- Do not use the em dash character (`-`). Prefer a colon, comma,
  parentheses, or a plain hyphen where a dash is needed.

## Module Conventions

- Files prefixed with `_` are core modules and are loaded first.
- Start each file with a header comment: `# ~/.bashrc.d/<name>.bash`.
- Prefer functions for logic, aliases for short command mappings.
- Map helper functions to aliases in `_aliases.bash`, not inline.
- Variable names internal to the loader or module setup should be prefixed
  with `_myflec_` to avoid polluting the user environment, and unset when done.

## Testing Your Changes

Before opening a contribution, run a syntax check on every module:

```bash
for f in .bashrc.d/*.bash; do
    bash -n "$f" || echo "Syntax error: $f"
done
```

Then verify startup behavior in a clean shell:

```bash
# Should list every loaded module
MYFLEC_DEBUG=1 bash -i

# Should be completely silent
bash -i
```

Make sure that:

- No errors appear on startup.
- Tools that are not installed do not produce errors or warnings.
- `MYFLEC_DEBUG` unset leaves startup silent.
- `LANG=C MYFLEC_DEBUG=1 bash -i` shows the ASCII fallback symbol instead
  of the UTF-8 check mark.

## Submitting Changes

1. Fork the repository on GitHub, GitLab, or NotABug.
2. Create a topic branch: `git checkout -b fix/short-description`.
3. Commit with a clear, imperative message (for example: `Fix lsd alias syntax`).
4. Open a pull request or merge request against `main`.

## Reporting Issues

Open an issue on any of the mirrors and include:

- Your distribution and Bash version (`bash --version`).
- The module involved.
- Steps to reproduce the problem.
