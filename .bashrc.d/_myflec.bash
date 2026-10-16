# ~/.bashrc.d/_myflec.bash
# myflec - single entry point: modules, deploy, update, backup and restore.
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
#   myflec update [-C repo] [--yes] -> pull, then update ~/.bashrc.d keeping local changes
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
	update)
		shift
		_myflec_update "$@"
		;;
	init)
		shift
		dotfiles-init "$@"
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

Install and update (repo -> $HOME):
  deploy [-C repo] [--yes]
                          First install: dry run, confirm, backup, checks
  update [-C repo] [--yes]
                          Pull the repo, update ~/.bashrc.d only; files you
                          changed are kept (new version: <file>.myflec-new)

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

# Parse "[-C repo] [--yes]" for deploy/update and resolve the repo root.
# Sets _repo and _assume_yes in the caller's scope.
_myflec_repo_args() {
	local _cmd="$1"
	shift
	_repo="" _assume_yes=0
	while [ $# -gt 0 ]; do
		case "$1" in
		-C)
			_repo="${2:-}"
			if [ -z "$_repo" ]; then
				echo "myflec $_cmd: -C requires a repo root" >&2
				return 1
			fi
			shift
			;;
		--yes | -y)
			_assume_yes=1
			;;
		*)
			echo "myflec $_cmd: unknown argument '$1'" >&2
			return 1
			;;
		esac
		shift
	done

	_repo="${_repo:-${MYFLEC_REPO:-$PWD}}"
	_repo="${_repo%/}"
	if [ ! -f "$_repo/myflec.exclude.lst" ]; then
		echo "myflec $_cmd: no myflec.exclude.lst in '$_repo'" >&2
		echo "Run from the myflec repo root, pass -C <repo-root> or set MYFLEC_REPO." >&2
		return 1
	fi
}

# Ask before a change unless --yes was given: _myflec_confirm <yes> <question>
_myflec_confirm() {
	[ "$1" -eq 1 ] && return 0
	local _answer
	printf "%s [y/N] " "$2"
	read -r _answer
	case "$_answer" in
	y | yes) return 0 ;;
	*) return 1 ;;
	esac
}

_myflec_deploy() {
	local _repo _assume_yes
	_myflec_repo_args deploy "$@" || return 1

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

	if ! _myflec_confirm "$_assume_yes" "Deploy the $_count file(s) above to \$HOME (backup: $_backup_dir)?"; then
		echo "myflec deploy: aborted."
		return 1
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

# ---- update ---------------------------------------------------------------
# Update the live modules (~/.bashrc.d only) from the repo, never overwriting
# a local change. A live file is "pristine" when its exact content is a
# version the repo has shipped at that path (its blob id appears in the
# path history): only pristine files are replaced or removed. Modified files
# are kept; when the repo changed them since the last update (commit recorded
# in $XDG_STATE_HOME/myflec/deployed), the new version is written next to
# them as <file>.myflec-new (not sourced by the loader). Files unknown to the
# repo (your own modules) are never touched.

# True when $2 (blob id) is a version of repo path $1 in the repo history.
_myflec_shipped() {
	git -C "$_repo" log --format= --raw --no-abbrev -- "$1" | grep -q " $2 "
}

# Record the repo HEAD as the installed version
_myflec_update_record() {
	mkdir -p "${1%/*}" && git -C "$_repo" rev-parse HEAD >"$1"
}

# Modified files of ~/.bashrc.d tracked by your backup repo (myflec backup)
# that are not a version shipped by the repo: your own unsaved changes.
# Shipped versions (e.g. left by a previous update) need no saving.
_myflec_update_unsaved() {
	[ -d "$_DOTFILES_DIR" ] || return 0
	local _path _out=""
	while IFS= read -r _path; do
		[ -f "$HOME/$_path" ] || continue
		_myflec_shipped "$_path" "$(git hash-object "$HOME/$_path")" || _out+="${_path#.bashrc.d/} "
	done < <(_dot_git diff --name-only -- .bashrc.d 2>/dev/null)
	printf '%s' "${_out% }"
}

_myflec_update() {
	local _repo _assume_yes
	_myflec_repo_args update "$@" || return 1

	local _live="$HOME/.bashrc.d"
	if [ "$(cd "$_live" 2>/dev/null && pwd -P)" = "$(cd "$_repo/.bashrc.d" && pwd -P)" ]; then
		echo "myflec update: $_live is the repo itself, use git pull." >&2
		return 1
	fi

	# Your own unsaved changes must be in your backup before anything moves
	local _unsaved
	_unsaved="$(_myflec_update_unsaved)"
	if [ -n "$_unsaved" ]; then
		echo "myflec update: unsaved changes in your backup of ~/.bashrc.d: $_unsaved" >&2
		echo "Save them first with 'myflec backup', then run update again." >&2
		return 1
	fi

	echo "Pulling $_repo ..."
	git -C "$_repo" pull --ff-only || {
		echo "myflec update: pull failed, repo left as is." >&2
		return 1
	}

	# Commit of the last update, if still known to the repo
	local _state="${XDG_STATE_HOME:-$HOME/.local/state}/myflec/deployed" _base=""
	[ -r "$_state" ] && _base="$(cat "$_state")"
	git -C "$_repo" cat-file -e "${_base:-none}^{commit}" 2>/dev/null || _base=""

	# Tracked files of HEAD only (no stray file of the working tree)
	local _new
	_new="$(mktemp -d)" || return 1
	git -C "$_repo" archive HEAD .bashrc.d | tar -x -C "$_new" || return 1

	local -a _add=() _upd=() _keep=() _local=() _del=() _drop=()
	local _f _name _blob
	for _f in "$_new"/.bashrc.d/*; do
		_name="${_f##*/}"
		if [ ! -e "$_live/$_name" ]; then
			_add+=("$_name")
		elif cmp -s "$_f" "$_live/$_name"; then
			continue
		else
			_blob="$(git hash-object "$_live/$_name")"
			if _myflec_shipped ".bashrc.d/$_name" "$_blob"; then
				_upd+=("$_name")
			elif [ -n "$_base" ] && git -C "$_repo" diff --quiet "$_base" HEAD -- ".bashrc.d/$_name"; then
				_local+=("$_name")
			else
				_keep+=("$_name")
			fi
		fi
	done
	# Removed upstream: drop the live copy only if it is a shipped version
	for _f in "$_live"/*; do
		_name="${_f##*/}"
		[ -f "$_f" ] || continue
		[ -e "$_new/.bashrc.d/$_name" ] && continue
		_blob="$(git hash-object "$_f")"
		if _myflec_shipped ".bashrc.d/$_name" "$_blob"; then
			_del+=("$_name")
		elif git -C "$_repo" log --format=%h -1 -- ".bashrc.d/$_name" | grep -q .; then
			_drop+=("$_name")
		fi
	done

	local _total=$((${#_add[@]} + ${#_upd[@]} + ${#_keep[@]} + ${#_del[@]}))
	if [ "$_total" -eq 0 ]; then
		echo "myflec update: ~/.bashrc.d is up to date ($(git -C "$_repo" log --format=%h -1))."
		[ ${#_local[@]} -gt 0 ] && echo "Local changes kept: ${_local[*]}"
		[ ${#_drop[@]} -gt 0 ] && echo "Modified, removed upstream (kept): ${_drop[*]}"
		rm -rf "$_new"
		_myflec_update_record "$_state"
		return 0
	fi

	echo ""
	echo "Update ~/.bashrc.d to $(git -C "$_repo" log --format='%h %s' -1):"
	[ ${#_add[@]} -gt 0 ] && echo "  new       : ${_add[*]}"
	[ ${#_upd[@]} -gt 0 ] && echo "  update    : ${_upd[*]}"
	[ ${#_del[@]} -gt 0 ] && echo "  remove    : ${_del[*]}"
	[ ${#_keep[@]} -gt 0 ] && echo "  modified  : ${_keep[*]} (kept, new version saved as <file>.myflec-new)"
	[ ${#_drop[@]} -gt 0 ] && echo "  modified, removed upstream (kept): ${_drop[*]}"
	[ ${#_local[@]} -gt 0 ] && echo "  local changes kept (unchanged upstream): ${_local[*]}"

	local _backup_dir
	_backup_dir="${XDG_STATE_HOME:-$HOME/.local/state}/myflec-backup/$(date +%F-%H%M%S)/.bashrc.d"
	if ! _myflec_confirm "$_assume_yes" "Apply (replaced and removed files backed up in $_backup_dir)?"; then
		echo "myflec update: aborted."
		rm -rf "$_new"
		return 1
	fi

	mkdir -p "$_backup_dir" "$_live" || return 1
	for _name in "${_upd[@]}" "${_del[@]}"; do
		cp -p "$_live/$_name" "$_backup_dir/" || return 1
	done
	for _name in "${_add[@]}" "${_upd[@]}"; do
		cp -p "$_new/.bashrc.d/$_name" "$_live/$_name" || return 1
	done
	for _name in "${_keep[@]}"; do
		cp -p "$_new/.bashrc.d/$_name" "$_live/$_name.myflec-new" || return 1
	done
	for _name in "${_del[@]}"; do
		rm -f "$_live/$_name"
	done
	rm -rf "$_new"
	rmdir "$_backup_dir" "${_backup_dir%/*}" 2>/dev/null
	_myflec_update_record "$_state"

	echo "myflec update: done. Open a new shell (exec bash) to load it."
	if [ -d "$_DOTFILES_DIR" ] && [ -n "$(_dot_git status --porcelain -- .bashrc.d 2>/dev/null)" ]; then
		echo "Your backup tracks ~/.bashrc.d: save this update with myflec backup."
	fi
	[ ${#_keep[@]} -gt 0 ] && echo "Merge your changes with the .myflec-new files, then delete them."
	return 0
}

# ---- backup / restore (delegates to _dotfiles.bash) ----------------------
# Argument checks of init, restore and remote add/rm live in the dotfiles-*
# functions; only the commands implemented here check their own.

# Usage guard: _myflec_need <argc> <min> <usage>
_myflec_need() {
	[ "$1" -ge "$2" ] && return 0
	echo "Usage: myflec $3" >&2
	return 1
}

_myflec_add() {
	_myflec_need $# 1 "add <path>..." || return 1
	_dot_require_repo || return 1
	_dot_git add -- "$@"
}

_myflec_rm() {
	_myflec_need $# 1 "rm <path>..." || return 1
	_dot_require_repo || return 1
	# --cached: stop tracking only, never delete the live file
	_dot_git rm -r --cached --quiet -- "$@" &&
		echo "No longer tracked (files kept on disk): $*"
}

_myflec_submodule() {
	_dot_require_repo || return 1
	case "${1:-}" in
	add)
		_myflec_need $# 3 "submodule add <url> <path>" || return 1
		# submodule commands must run from the top of the work tree
		(cd "$HOME" && _dot_git submodule add -- "$2" "$3")
		;;
	update)
		(cd "$HOME" && _dot_git submodule update --init --recursive)
		;;
	*)
		_myflec_need 0 1 "submodule add <url> <path> | update"
		;;
	esac
}

_myflec_backup() {
	# 'backup --init' kept for compatibility with earlier releases
	if [ "${1:-}" = "--init" ]; then
		shift
		dotfiles-init "$@"
	else
		dotfiles-backup "$@"
	fi
}

_myflec_restore() {
	dotfiles-restore "$@" || return 1
	# Bring back embedded repos (e.g. myflec itself as a submodule)
	if _dot_git ls-files --error-unmatch .gitmodules >/dev/null 2>&1; then
		_myflec_submodule update
	fi
}

_myflec_remote() {
	case "${1:-list}" in
	list) dotfiles-remotes ;;
	add) dotfiles-addbackup "${2:-}" ;;
	rm) dotfiles-removebackup "${2:-}" ;;
	*)
		echo "myflec remote: unknown action '$1' (list, add, rm)" >&2
		return 1
		;;
	esac
}
