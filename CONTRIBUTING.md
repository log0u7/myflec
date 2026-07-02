# Contributing to MyFlec

Thanks for your interest in improving MyFlec. This project is a personal
dotfiles collection, but suggestions, fixes, and improvements are welcome.

## Ground Rules

- Keep modules self-contained: one tool or concern per `.bashrc.d/*.bash` file.
- Guard every optional tool with an availability check (for example
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

## Commit Conventions

This project follows [Conventional Commits](https://www.conventionalcommits.org/).

Format: `type(scope): description`

**Types**: feat, fix, docs, refactor, chore, ci, test, style, perf

**Scopes**: a module name (`ssh`, `go`, `loader`, `vim`, `python`) or a
cross-cutting concern (`ci`, `readme`, `docs`).

**Rules**:
- Lowercase, imperative mood, no period at the end.
- Use the scope to indicate the affected area (omit if too broad).

Examples:
```
fix(go): export GOPATH and GOBIN
refactor(vim): detect vim subshell via VIMRUNTIME instead of ps
docs(readme): add mermaid load-order graph
feat: add mise and fnox modules with fallback support
```

## Branching Model

- `main`: stable branch. Always releasable.
- Topic branches: `feat/<short-description>`, `fix/<short-description>`,
  `docs/<short-description>`, `chore/<short-description>`.
- Open pull requests or merge requests against `main`.
- Keep commits atomic: one logical fix per commit (squash if needed).

## Versioning and Releases

This project uses [Semantic Versioning](https://semver.org/) (MAJOR.MINOR.PATCH).

- **MAJOR**: breaking changes to module API, load order, or deployment
  mechanism.
- **MINOR**: new features, new modules, new tool integrations.
- **PATCH**: bug fixes, documentation, refactoring without behavior change.

### Release process

1. Ensure `CHANGELOG.md` is up to date: move `[Unreleased]` entries into a
   new dated section.
2. Commit the updated changelog.
3. Tag the release: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
4. Push to all forges:
   `git push github --tags && git push gitlab --tags && git push origin --tags`
5. Update `[Unreleased]` in `CHANGELOG.md` for the next cycle.

## Testing Your Changes

Before opening a contribution, run a syntax check on every module:

```bash
for f in .bashrc.d/*.bash; do
    bash -n "$f" || echo "Syntax error: $f"
done
```

Static analysis:

```bash
shellcheck -x .bashrc.d/*.bash .bashrc.d/myflec
```

Then verify startup behavior in a clean shell:

```bash
# Should exit 0 and produce no output
HOME=$PWD bash -c '. .bashrc.d/myflec'

# Should list every loaded module
HOME=$PWD MYFLEC_DEBUG=1 bash -c '. .bashrc.d/myflec'
```

Make sure that:

- No errors appear on startup.
- Tools that are not installed do not produce errors or warnings.
- `MYFLEC_DEBUG` unset leaves startup silent.
- `LANG=C MYFLEC_DEBUG=1 bash -i` shows the ASCII fallback symbol instead
  of the UTF-8 check mark.

For SSH config changes, verify resolution without connecting:

```bash
ssh -F .ssh/config -G github.com
ssh -F .ssh/config -G github.com-work
ssh -F .ssh/config -G gitlab.com
```

For rsync deployment changes, do a dry run:

```bash
rsync -avn --exclude-from 'myflec.exclude.lst' ./ /tmp/myflec-dryrun/
```

Repo-only files (CI workflows, `.tape`, docs, `.gitignore`) must NOT appear
in the rsync destination.

## Reporting Issues

Open an issue on any of the mirrors and include:

- Your distribution and Bash version (`bash --version`).
- The module involved.
- Steps to reproduce the problem.
