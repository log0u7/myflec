# Git identity resolution

Example setup: a repository lives in a catch-all directory `~/projets/perso/`
(also reachable via the `~/projets/github/perso/` and `~/projets/gitlab/perso/`
symlink views), and it mirrors to three platforms:

```
[remote "origin"]
	url = git@github.com:your-username/project.git
	pushurl = git@github.com:your-username/project.git
	pushurl = git@gitlab.com:your-username/project.git
	pushurl = git@notabug.org:your-username/project.git
```

## Purpose

Identity follows the **remote**, not the path, so the same identity applies
whatever symlink view or physical directory you work from.

## Usage

Resolution order in `~/.gitconfig` (last matching include wins):

1. `includeIf gitdir:~/projets/github/**` -> `.gitconfig.d/github`
   (matches repos physically under `~/projets/github/`, i.e. real directories
   such as `~/projets/github/some-tool`)
2. `includeIf gitdir:~/projets/gitlab/**` -> `.gitconfig.d/gitlab` (same idea)
3. `includeIf gitdir:~/projets/perso/` -> `.gitconfig.d/perso`
   (catch-all fallback for the junk-drawer directory)
4. `includeIf gitdir:~/projets/{work,company}/`
   -> `.gitconfig.d/<context>` (work identities)
5. `includeIf hasconfig:remote.*.url:git@gitlab.com:your-username/*`
   -> `.gitconfig.d/gitlab`
6. `includeIf hasconfig:remote.*.url:git@github.com:your-username/*`
   -> `.gitconfig.d/github` (declared last, so **it wins** for multi-forge mirrors)

Final identity for that repository:

| field | value |
|---|---|
| email | `<id>+your-username@users.noreply.github.com` (GitHub noreply: auto-associated with the account, always shows Verified when signed) |
| signing key | `~/.ssh/github.com_<label>_ed25519.pub` (ED25519) |
| commit/tag signing | automatic (`commit.gpgsign = true`, `tag.gpgsign = true`, `gpg.format = ssh`) |

Repos with no matching forge remote (notabug-only, no remote) fall back to
the base identity of `~/.gitconfig` (unsigned).

## Internals

### Why hasconfig and not only gitdir

`gitdir:` patterns are matched against the canonicalized `$GIT_DIR` path.
The intermediate symlink `~/projets/github/perso -> ../perso/` is resolved
before matching, and every repo in the catch-all lives physically under
`~/projets/perso/`:

```
$ git -C ~/projets/github/perso/project rev-parse --path-format=absolute --git-dir
/home/user/projets/perso/project/.git
```

So `gitdir:~/projets/github/**` only matches repos whose physical path is
under `~/projets/github/` (real directories); it never matches anything in
the catch-all, via any symlink view. Remote-URL matching (`hasconfig`) is
path-independent and fixes exactly this.

### hasconfig mechanics

- `hasconfig:remote.*.url:<pattern>` matches the `remote.<name>.url` values
  only; `pushurl` entries are **not** scanned. The gitlab identity therefore
  matches because the repository also declares a separate `gitlab` remote (a
  pushurl-only mirror would not match).
- On first occurrence, git scans the remaining config files for remote URLs.
  Files pulled in by such an include must not declare remote URLs
  (`.gitconfig.d/*` only declare `[user]`/signing blocks).
- Git >= 2.36 required.

### Pushing

`git push origin` pushes to **all three pushurls at once** (github, gitlab, notabug).

The Verified badge can only appear on one platform per commit, because the
committer email must be a verified email of the account on that platform:

- github.com: noreply email -> Verified
- gitlab.com: noreply email is not (and cannot be) a verified email there -> the
  signature is present but shown as Unverified. That is the accepted trade-off of
  a single-email mirror setup.

## Checklist for a new repo

1. Set the origin (and pushurls if mirroring).
2. No local `[user]` in `.git/config` unless intentionally overriding everything
   (a local `[user]` wins over every include).
3. Check: `git config --show-origin --get user.email` should point to
   `.gitconfig.d/github` (or the platform file matching the origin).
4. First commit must end up signed: `git log -1 --format=%G?` prints `N`
   without `gpg.ssh.allowedSignersFile` (expected); verify
   with a signers file:

   ```
   printf '<id>+your-username@users.noreply.github.com %s\n' "$(cat ~/.ssh/github.com_<label>_ed25519.pub)" > /tmp/allowed_signers
   git -c gpg.ssh.allowedSignersFile=/tmp/allowed_signers log -1 --show-signature
   ```
