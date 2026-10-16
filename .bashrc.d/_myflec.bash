# ~/.bashrc.d/_myflec.bash
# myflec - single entry point: modules, deploy, backup and restore.
#
# Purpose: verify that all MyFlec modules are present, reload them without
# opening a new shell, deploy the repo to $HOME safely, and version the live
# configuration in a git bare repo (~/.dotfiles), all through one command.
#
# Usage:
#   myflec                          -> show help
#   myflec status                   -> list all modules (core then tool) with a count
#   myflec reload [--full]          -> re-source modules (--full: the whole loader)
#   myflec deploy [-C repo] [--yes] -> safe rsync deploy (dry run, confirm, backup, checks)
#   myflec init <url> [<url>...]    -> create the backup repo (first URL = origin)
#   myflec add <path>...            -> start tracking files in the backup
#   myflec rm <path>...             -> stop tracking files (kept on disk)
#   myflec submodule add <url> <path> -> track an embedded git repo
#   myflec submodule update         -> init and update embedded repos
#   myflec backup [message]         -> add -u, commit, push to every remote
#   myflec restore <url>            -> restore live state (and submodules)
#   myflec sync                     -> pull --rebase the backup repo
#   myflec changes                  -> short status of tracked files
#   myflec files                    -> list tracked files
#   myflec remote [add|rm <url>]    -> list, add or remove push targets
#   myflec help                     -> show help
#
# Internals:
#   Core module (_*.bash), loads after _functions.bash, before _shopts.bash.
#   The alias myflec=fMyflec lives in _aliases.bash and resolves at call time.
#   deploy uses the repo myflec.exclude.lst rules. The backup commands delegate
#   to the _dotfiles.bash toolbox, whose dotfiles-* functions stay available
#   for compatibility. 'myflec backup --init' is kept as an alias of 'init'.

fMyflec() {
	local _cmd="${1:-help}"
	local _dir="${MYFLEC_DIR:-$HOME/.bashrc.d}"

	case "$_cmd" in
	status)
		_myflec_status "$_dir"
		;;
	reload)
		if [ "${2:-}" = "--full" ]; then
			_myflec_reload_full "$_dir"
		else
			_myflec_reload "$_dir"
		fi
		;;
	deploy)
		shift
		_myflec_deploy "$@"
		;;
	init)
		shift
		_myflec_init "$@"
		;;
	add)
		shift
		_myflec_add "$@"
		;;
	rm)
		shift
		_myflec_rm "$@"
		;;
	submodule)
		shift
		_myflec_submodule "$@"
		;;
	backup)
		shift
		_myflec_backup "$@"
		;;
	restore)
		shift
		_myflec_restore "$@"
		;;
	sync)
		dotfiles-sync
		;;
	changes)
		dotfiles-status
		;;
	files)
		dotfiles-list
		;;
	remote)
		shift
		_myflec_remote "$@"
		;;
	help | --help | -h | "")
		_myflec_help
		;;
	*)
		echo "myflec: unknown subcommand '$_cmd'" >&2
		echo "Run 'myflec help' for usage." >&2
		return 1
		;;
	esac
}

_myflec_help() {
	cat <<'EOF'
Usage: myflec <command>

Modules:
  status                  List all loaded modules
  reload [--full]         Re-source modules (--full: the whole loader)

Deploy (repo -> $HOME):
  deploy [-C repo] [--yes]
                          Safe rsync deploy: dry run, confirm, backup, checks

Backup ($HOME <-> git, bare repo at ~/.dotfiles):
  init <url> [<url>...]   Create the backup repo (extra URLs = push targets)
  add <path>...           Start tracking files
  rm <path>...            Stop tracking files (they stay on disk)
  submodule add <url> <path>
                          Track an embedded git repo (e.g. a project in $HOME)
  submodule update        Init and update embedded repos
  backup [message]        Commit tracked changes and push to every remote
  restore <url>           Clone a backup repo into $HOME (with submodules)
  sync                    Pull (rebase) the latest backup
  changes                 Short status of tracked files
  files                   List tracked files
  remote                  List remotes and push targets
  remote add <url>        Add a push target
  remote rm <url>         Remove a push target

  help                    Show this help

Notes:
  - 'dot' is plain git on the backup repo, for anything else (log, diff).
  - deploy never transfers the identity templates (.ssh/, .gitconfig,
    .gitconfig.d): they stay in myflec.exclude.lst.
  - Use 'myflec reload --full' after changing the loader or _myflec.bash.
EOF
}

_myflec_status() {
	local _dir="$1"
	local _core=0 _tools=0 _f _name _kind

	echo "MyFlec modules ($_dir)"
	echo ""

	while IFS= read -r _f; do
		_name="$(basename "$_f" .bash)"
		case "$_name" in
		_*)
			_kind=core
			_core=$((_core + 1))
			;;
		*)
			_kind=tool
			_tools=$((_tools + 1))
			;;
		esac
		printf "  %-4s  %s\n" "$_kind" "${_name#_}"
	done < <(_myflec_modules "$_dir")

	echo ""
	echo "$((_core + _tools)) modules ($_core core, $_tools tool)"
}

# Unset previously tracked myflec aliases (preserves user aliases)
_myflec_unset_aliases() {
	local _a
	for _a in "${_MYFLEC_ALIASES[@]}"; do
		unalias "$_a" 2>/dev/null
	done
}

_myflec_reload() {
	local _dir="$1" _f _files

	_myflec_unset_aliases
	mapfile -t _files < <(_myflec_modules "$_dir")
	for _f in "${_files[@]}"; do
		source "$_f"
	done

	# Update tracking with current myflec aliases
	mapfile -t _MYFLEC_ALIASES < <(alias -p | sed -n "s/^alias \([^=]*\)=.*/\1/p")

	echo "MyFlec reloaded (modules only, hooks preserved)."
}

_myflec_reload_full() {
	local _dir="$1"

	_myflec_unset_aliases
	source "$_dir/loader"

	echo "MyFlec reloaded (full). Note: PROMPT_COMMAND hooks may have accumulated."
	echo "For a clean state, open a new shell."
}

# ---- deploy -------------------------------------------------------------

_myflec_deploy() {
	local _repo="" _assume_yes=0 _arg
	while [ $# -gt 0 ]; do
		case "$1" in
		-C)
			_repo="${2:-}"
			if [ -z "$_repo" ]; then
				echo "myflec deploy: -C requires a repo root" >&2
				return 1
			fi
			shift
			;;
		--yes | -y)
			_assume_yes=1
			;;
		*)
			echo "myflec deploy: unknown argument '$1'" >&2
			return 1
			;;
		esac
		shift
	done

	if [ -z "$_repo" ]; then
		_repo="${MYFLEC_REPO:-$PWD}"
	fi
	_repo="${_repo%/}"
	if [ ! -f "$_repo/myflec.exclude.lst" ]; then
		echo "myflec deploy: no myflec.exclude.lst in '$_repo'" >&2
		echo "Run from the myflec repo root, pass -C <repo-root> or set MYFLEC_REPO." >&2
		return 1
	fi

	local _stamp _backup_dir
	_stamp="$(date +%F-%H%M%S)"
	_backup_dir="${XDG_STATE_HOME:-$HOME/.local/state}/myflec-backup/$_stamp"
	local -a _flags=(-a --exclude-from "$_repo/myflec.exclude.lst")
	local _stats _count

	echo "Dry run (real target: \$HOME):"
	_stats="$(rsync -avn --stats "${_flags[@]}" "$_repo/" "$HOME/")"
	echo "$_stats"
	_count="$(sed -n 's/^Number of regular files transferred: \([0-9,]*\)$/\1/p' <<<"$_stats" | tr -d ',')"
	_count="${_count:-0}"

	if [ "$_count" -eq 0 ]; then
		echo "myflec deploy: nothing to deploy."
		_myflec_deploy_checks
		return $?
	fi

	if [ "$_assume_yes" -ne 1 ]; then
		local _answer
		printf "Deploy the %s file(s) above to \$HOME (backup: %s)? [y/N] " "$_count" "$_backup_dir"
		read -r _answer
		case "$_answer" in
		y | yes) ;;
		*)
			echo "myflec deploy: aborted."
			return 1
			;;
		esac
	fi

	rsync "${_flags[@]}" --backup --backup-dir="$_backup_dir" "$_repo/" "$HOME/"
	local _rc=$?
	if [ "$_rc" -ne 0 ]; then
		echo "myflec deploy: rsync failed (exit $_rc)" >&2
		return "$_rc"
	fi
	echo "myflec deploy: done. Overwritten files backed up in: $_backup_dir"

	_myflec_deploy_checks
	return $?
}

_myflec_deploy_checks() {
	local _ok=0 _forge _ident _ident_ok
	for _forge in github.com gitlab.com notabug.org; do
		_ident_ok=0
		# ssh -G lists several identityfile entries (defaults first, paths
		# possibly starting with a literal ~): pass as soon as ONE exists.
		while IFS= read -r _ident; do
			_ident="${_ident/#\~/$HOME}"
			[ -n "$_ident" ] && [ -f "$_ident" ] && _ident_ok=1 && break
		done < <(ssh -G "$_forge" 2>/dev/null | sed -n 's/^identityfile //p')
		if [ "$_ident_ok" -eq 1 ]; then
			echo "PASS: ssh -G $_forge"
		else
			echo "FAIL: ssh -G $_forge (no existing IdentityFile)"
			_ok=1
		fi
	done
	if [ -n "$(git config --global user.name 2>/dev/null)" ] &&
		[ -n "$(git config --global user.email 2>/dev/null)" ]; then
		echo "PASS: git identity $(git config --global user.name) <$(git config --global user.email)>"
	else
		echo "FAIL: git identity missing (user.name/user.email)"
		_ok=1
	fi
	return "$_ok"
}

# ---- backup / restore (delegates to _dotfiles.bash) ----------------------

_myflec_init() {
	if [ $# -eq 0 ]; then
		echo "Usage: myflec init <url> [<url>...]" >&2
		return 1
	fi
	dotfiles-init "$@"
}

_myflec_add() {
	if [ $# -eq 0 ]; then
		echo "Usage: myflec add <path>..." >&2
		return 1
	fi
	_dot_require_repo || return 1
	git --git-dir="$_DOTFILES_DIR" --work-tree="$HOME" add -- "$@"
}

_myflec_rm() {
	if [ $# -eq 0 ]; then
		echo "Usage: myflec rm <path>..." >&2
		return 1
	fi
	_dot_require_repo || return 1
	# --cached: stop tracking only, never delete the live file
	git --git-dir="$_DOTFILES_DIR" --work-tree="$HOME" rm -r --cached --quiet -- "$@" &&
		echo "No longer tracked (files kept on disk): $*"
}

_myflec_submodule() {
	_dot_require_repo || return 1
	case "${1:-}" in
	add)
		if [ -z "${2:-}" ] || [ -z "${3:-}" ]; then
			echo "Usage: myflec submodule add <url> <path>" >&2
			return 1
		fi
		# submodule commands must run from the top of the work tree
		(cd "$HOME" && git --git-dir="$_DOTFILES_DIR" --work-tree="$HOME" submodule add -- "$2" "$3")
		;;
	update)
		(cd "$HOME" && git --git-dir="$_DOTFILES_DIR" --work-tree="$HOME" submodule update --init --recursive)
		;;
	*)
		echo "Usage: myflec submodule add <url> <path> | update" >&2
		return 1
		;;
	esac
}

_myflec_backup() {
	# 'backup --init' kept for compatibility with earlier releases
	if [ "${1:-}" = "--init" ]; then
		shift
		_myflec_init "$@"
	else
		dotfiles-backup "$@"
	fi
}

_myflec_restore() {
	if [ $# -lt 1 ]; then
		echo "Usage: myflec restore <url>" >&2
		return 1
	fi
	dotfiles-restore "$1" || return 1
	# Bring back embedded repos (e.g. myflec itself as a submodule)
	if git --git-dir="$_DOTFILES_DIR" --work-tree="$HOME" ls-files --error-unmatch .gitmodules >/dev/null 2>&1; then
		_myflec_submodule update
	fi
}

_myflec_remote() {
	case "${1:-list}" in
	list)
		dotfiles-remotes
		;;
	add | rm)
		if [ -z "${2:-}" ]; then
			echo "Usage: myflec remote $1 <url>" >&2
			return 1
		fi
		if [ "$1" = "add" ]; then
			dotfiles-addbackup "$2"
		else
			dotfiles-removebackup "$2"
		fi
		;;
	*)
		echo "myflec remote: unknown action '$1' (list, add, rm)" >&2
		return 1
		;;
	esac
}
