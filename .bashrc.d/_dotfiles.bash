# ~/.bashrc.d/_dotfiles.bash
# Dotfiles bare git repo management: version control for $HOME.
# https://www.atlassian.com/git/tutorials/dotfiles
#
# Purpose: keep your dotfiles under version control without symlinks or rsync.
# The bare repo lives at $HOME/.dotfiles, using $HOME as the working tree.
# The 'dot' alias provides direct git access when the repo exists.
#
# Usage: go through the 'myflec' command (_myflec.bash), which wraps this
# toolbox. The dotfiles-* functions stay available for compatibility:
#   dotfiles-init         -> myflec init
#   dotfiles-backup       -> myflec backup
#   dotfiles-restore      -> myflec restore
#   dotfiles-sync         -> myflec sync
#   dotfiles-status       -> myflec changes
#   dotfiles-list         -> myflec files
#   dotfiles-remotes      -> myflec remote
#   dotfiles-addbackup    -> myflec remote add
#   dotfiles-removebackup -> myflec remote rm

_DOTFILES_DIR="$HOME/.dotfiles"

# git on the bare repo, with $HOME as work tree. Every call goes through it.
_dot_git() {
	git --git-dir="$_DOTFILES_DIR" --work-tree="$HOME" "$@"
}

# Expose a bare-git alias when the repo exists
if [ -d "$_DOTFILES_DIR" ]; then
	alias dot=_dot_git
fi

# ---- Helpers -----------------------------------------------------------

_dot_require_repo() {
	[ -d "$_DOTFILES_DIR" ] && return 0
	echo "Error: no dotfiles bare repo found at $_DOTFILES_DIR" >&2
	echo "Run 'myflec init <url>' or 'myflec restore <url>' first." >&2
	return 1
}

# ---- Init (no repo required) -------------------------------------------

dotfiles-init() {
	if [ -z "$1" ]; then
		echo "Usage: myflec init <remote-url> [<extra-push-url> ...]"
		echo ""
		echo "Create a new bare dotfiles repo at $_DOTFILES_DIR."
		echo "The first URL becomes the primary remote (fetch + push)."
		echo "Additional URLs are added as extra push targets."
		echo ""
		echo "Example:"
		echo "  myflec init git@github.com:user/dotfiles.git"
		echo "  myflec init git@github.com:user/dotfiles.git git@gitlab.com:user/dotfiles.git"
		return 1
	fi

	if [ -d "$_DOTFILES_DIR" ]; then
		echo "Error: $_DOTFILES_DIR already exists." >&2
		echo "Use 'myflec sync' to update it, or remove it first." >&2
		return 1
	fi

	git init --bare "$_DOTFILES_DIR" || return 1
	_dot_git config status.showUntrackedFiles no

	# Set primary remote (fetch + push)
	local primary="$1"
	shift
	_dot_git remote add origin "$primary"

	# Explicitly start the push URL list with the primary URL: the first
	# `set-url --add --push` REPLACES the implicit fetch-url push, so without
	# this line extra URLs would silently shadow the primary push target.
	_dot_git remote set-url --add --push origin "$primary"

	# Add extra push URLs (multi-forge)
	for url in "$@"; do
		_dot_git remote set-url --add --push origin "$url"
	done

	# First push must not require manual upstream setup
	_dot_git config push.autoSetupRemote true

	echo "Dotfiles bare repo initialized at $_DOTFILES_DIR"
	echo "Primary remote: $primary"
	[ $# -gt 0 ] && echo "Extra push targets: $*"
	echo ""
	echo "Next steps:"
	echo "  myflec changes               -> status of tracked files"
	echo "  myflec add <file>             -> track a file"
	echo "  myflec backup 'first commit' -> commit and push"
}

# ---- Restore (no repo required) ----------------------------------------

dotfiles-restore() {
	if [ -z "$1" ]; then
		echo "Usage: myflec restore <clone-url>"
		echo ""
		echo "Clone an existing bare dotfiles repo to $_DOTFILES_DIR"
		echo "and check out the files into \$HOME."
		echo ""
		echo "Example:"
		echo "  myflec restore git@github.com:user/dotfiles.git"
		return 1
	fi

	if [ -d "$_DOTFILES_DIR" ]; then
		echo "Error: $_DOTFILES_DIR already exists." >&2
		echo "Remove it first if you want a fresh clone." >&2
		return 1
	fi

	local url="$1"
	git clone --bare "$url" "$_DOTFILES_DIR" || return 1

	# Check out the work tree, backing up files that would be overwritten
	local tmp_backup
	tmp_backup="$(mktemp -d)"

	if ! _dot_git checkout 2>"$tmp_backup/checkout.err"; then
		echo "Some files conflict with existing ones." >&2
		echo "Backing up conflicting files to $tmp_backup/conflicts/" >&2
		# git lists the conflicting paths as tab-indented lines
		grep '^\s' "$tmp_backup/checkout.err" | sed 's/^\s*//' | while read -r file; do
			mkdir -p "$(dirname "$tmp_backup/conflicts/$file")"
			[ -f "$HOME/$file" ] && cp "$HOME/$file" "$tmp_backup/conflicts/$file"
		done

		_dot_git checkout -f || return 1
		echo "Conflicting files backed up to: $tmp_backup/conflicts/"
	fi

	_dot_git config status.showUntrackedFiles no

	echo "Dotfiles restored from $url"
	echo "Configs are now live in \$HOME. Run 'myflec changes' to verify."
}

# ---- Status ------------------------------------------------------------

dotfiles-status() {
	_dot_require_repo || return 1
	_dot_git status -sb
}

dotfiles-list() {
	_dot_require_repo || return 1
	_dot_git ls-files
}

# ---- Backup ------------------------------------------------------------

dotfiles-backup() {
	_dot_require_repo || return 1
	local msg="${1:-dotfiles update $(date +%Y-%m-%d_%H:%M)}"

	_dot_git add -u || return 1

	if _dot_git diff --cached --quiet; then
		echo "Nothing to commit (no changes in tracked files)."
		return 0
	fi

	_dot_git commit -m "$msg" || return 1
	_dot_git push
}

# ---- Sync --------------------------------------------------------------

dotfiles-sync() {
	_dot_require_repo || return 1
	_dot_git pull --rebase
}

# ---- Multi-forge backup targets ----------------------------------------

dotfiles-addbackup() {
	_dot_require_repo || return 1
	if [ -z "$1" ]; then
		echo "Usage: myflec remote add <remote-url>"
		return 1
	fi
	_dot_git remote set-url --add --push origin "$1"
	echo "Added push target: $1"
}

dotfiles-removebackup() {
	_dot_require_repo || return 1
	if [ -z "$1" ]; then
		echo "Usage: myflec remote rm <remote-url>"
		return 1
	fi
	_dot_git remote set-url --delete --push origin "$1"
	echo "Removed push target: $1"
}

dotfiles-remotes() {
	_dot_require_repo || return 1
	_dot_git remote -v
}
