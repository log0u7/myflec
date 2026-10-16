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
#   myflec deploy [-C repo] [--yes] -> install into $HOME (dry run, confirm, backup, checks)
#   myflec update [-C repo] [--yes] -> update ~/.bashrc.d, keeping local changes
#   (deploy/update fetch MyFlec online by default; -C or MYFLEC_REPO: local clone)
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
#   deploy uses the repo myflec.exclude.lst rules; deploy and update read a
#   git repo: the online cache ~/.cache/myflec/repo or a local clone. The backup commands delegate
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

Install and update (MyFlec -> $HOME, online by default):
  deploy [-C repo] [--yes]
                          Install everything: dry run, confirm, backup, checks
  update [-C repo] [--yes]
                          Update ~/.bashrc.d only; files you changed are kept
                          (new version: <file>.myflec-new)
                          -C <clone> or MYFLEC_REPO: use a local clone

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

# ---- source: online cache or local clone ---------------------------------
# deploy and update read MyFlec from a git repository: by default an online
# copy kept in ${XDG_CACHE_HOME:-~/.cache}/myflec/repo (bare, without file
# contents until needed), fetched from MYFLEC_URL or the public mirrors in
# turn; with -C <clone> or MYFLEC_REPO, from a local clone instead.

_MYFLEC_MIRRORS="https://github.com/log0u7/myflec.git https://gitlab.com/log0u7/myflec.git https://notabug.org/log0u7/myflec.git"

# Parse "[-C repo] [--yes]" for deploy/update. Sets _repo (empty: online),
# _local (1 for a local clone) and _assume_yes in the caller's scope.
_myflec_repo_args() {
	local _cmd="$1"
	shift
	_repo="" _local=0 _assume_yes=0
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

	_repo="${_repo:-${MYFLEC_REPO:-}}"
	[ -z "$_repo" ] && return 0
	_repo="${_repo%/}"
	_local=1
	if [ ! -f "$_repo/myflec.exclude.lst" ]; then
		echo "myflec $_cmd: no myflec.exclude.lst in '$_repo'" >&2
		echo "Pass -C <repo-root> or set MYFLEC_REPO to a myflec clone." >&2
		return 1
	fi
}

# Online mode: create or refresh the cache from the first reachable mirror,
# then point _repo at it.
_myflec_fetch() {
	local _cache="${XDG_CACHE_HOME:-$HOME/.cache}/myflec/repo" _url
	for _url in ${MYFLEC_URL:-$_MYFLEC_MIRRORS}; do
		echo "Fetching MyFlec from $_url ..."
		if [ -d "$_cache" ]; then
			git -C "$_cache" remote set-url origin "$_url" &&
				git -C "$_cache" fetch -q origin "+refs/heads/main:refs/heads/main" &&
				_repo="$_cache" && return 0
		else
			mkdir -p "${_cache%/*}" &&
				git clone -q --bare --filter=blob:none "$_url" "$_cache" &&
				_repo="$_cache" && return 0
			rm -rf "$_cache"
		fi
	done
	echo "myflec: no mirror reachable (set MYFLEC_URL, or use -C <clone>)." >&2
	return 1
}

# Ask before a change unless --yes was given: _myflec_confirm <yes> <question>
# Reads the terminal, so it also works under "curl ... | bash".
_myflec_confirm() {
	[ "$1" -eq 1 ] && return 0
	local _answer=""
	printf "%s [y/N] " "$2"
	if [ ! -t 0 ] && { exec 3</dev/tty; } 2>/dev/null; then
		read -r _answer <&3
		exec 3<&-
	else
		read -r _answer
	fi
	case "$_answer" in
	y | yes) return 0 ;;
	*) return 1 ;;
	esac
}

# Record the commit now installed: the base of the next update
_myflec_record() {
	local _state="${XDG_STATE_HOME:-$HOME/.local/state}/myflec/deployed"
	mkdir -p "${_state%/*}" && git -C "$_repo" rev-parse HEAD >"$_state"
}

# ---- deploy ---------------------------------------------------------------
# Install the whole repo (minus myflec.exclude.lst) into $HOME: dry run,
# confirmation, backup of every overwritten file, then informative checks.

_myflec_deploy() {
	local _repo _local _assume_yes
	_myflec_repo_args deploy "$@" || return 1
	if [ "$_local" -eq 0 ]; then
		_myflec_fetch || return 1
	fi

	local _stamp _backup_dir
	_stamp="$(date +%F-%H%M%S)"
	_backup_dir="${XDG_STATE_HOME:-$HOME/.local/state}/myflec-backup/$_stamp"
	local _stats _count _src="$_repo" _git=0

	# Deploy the committed state only: stray files of a working tree
	# (test artefacts, local tool state) must never reach $HOME.
	if git -C "$_repo" rev-parse --git-dir >/dev/null 2>&1; then
		_git=1
		_src="$(mktemp -d)" || return 1
		git -C "$_repo" archive HEAD | tar -x -C "$_src" || return 1
		echo "Source: $(git -C "$_repo" log --format='%h (%cs) %s' -1)"
	fi
	local -a _flags=(-a --exclude-from "$_src/myflec.exclude.lst")

	echo "Dry run (real target: \$HOME):"
	_stats="$(rsync -avn --stats "${_flags[@]}" "$_src/" "$HOME/")"
	echo "$_stats"
	_count="$(sed -n 's/^Number of regular files transferred: \([0-9,]*\)$/\1/p' <<<"$_stats" | tr -d ',')"
	_count="${_count:-0}"

	if [ "$_count" -eq 0 ]; then
		echo "myflec deploy: nothing to deploy."
		[ "$_git" -eq 1 ] && rm -rf "$_src" && _myflec_record
		_myflec_deploy_checks
		return 0
	fi

	if ! _myflec_confirm "$_assume_yes" "Deploy the $_count file(s) above to \$HOME (backup: $_backup_dir)?"; then
		echo "myflec deploy: aborted."
		[ "$_git" -eq 1 ] && rm -rf "$_src"
		return 1
	fi

	rsync "${_flags[@]}" --backup --backup-dir="$_backup_dir" "$_src/" "$HOME/"
	local _rc=$?
	[ "$_git" -eq 1 ] && rm -rf "$_src"
	if [ "$_rc" -ne 0 ]; then
		echo "myflec deploy: rsync failed (exit $_rc)" >&2
		return "$_rc"
	fi
	[ "$_git" -eq 1 ] && _myflec_record
	echo "myflec deploy: done. Overwritten files backed up in: $_backup_dir"

	_myflec_deploy_checks
	return 0
}

# Informative checks of the identity setup (never fail the deploy)
_myflec_deploy_checks() {
	local _forge _ident _ident_ok
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
			echo "WARN: ssh -G $_forge (no existing IdentityFile)"
		fi
	done
	if [ -n "$(git config --global user.name 2>/dev/null)" ] &&
		[ -n "$(git config --global user.email 2>/dev/null)" ]; then
		echo "PASS: git identity $(git config --global user.name) <$(git config --global user.email)>"
	else
		echo "WARN: git identity missing (user.name/user.email)"
	fi
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

# Print one section of the update plan: a title with a count, then the
# names in columns (core modules first). Nothing when the list is empty.
_myflec_update_list() {
	local _title="$1" _w=0 _cols _i=0 _n
	shift
	[ $# -eq 0 ] && return 0
	local -a _names
	mapfile -t _names < <(printf '%s\n' "$@" | LC_ALL=C sort)
	for _n in "${_names[@]}"; do
		[ ${#_n} -gt "$_w" ] && _w=${#_n}
	done
	_w=$((_w + 2))
	_cols=$(((${COLUMNS:-80} - 4) / _w))
	[ "$_cols" -lt 1 ] && _cols=1
	printf '  %s (%d)\n' "$_title" "$#"
	for _n in "${_names[@]}"; do
		[ $((_i % _cols)) -eq 0 ] && printf '    '
		_i=$((_i + 1))
		if [ $((_i % _cols)) -eq 0 ] || [ "$_i" -eq "$#" ]; then
			printf '%s\n' "$_n"
		else
			printf "%-${_w}s" "$_n"
		fi
	done
	echo ""
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
	local _repo _local _assume_yes
	_myflec_repo_args update "$@" || return 1

	local _live="$HOME/.bashrc.d"
	if [ "$_local" -eq 1 ] && [ "$(cd "$_live" 2>/dev/null && pwd -P)" = "$(cd "$_repo/.bashrc.d" && pwd -P)" ]; then
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

	if [ "$_local" -eq 1 ]; then
		echo "Pulling $_repo ..."
		git -C "$_repo" pull --ff-only || {
			echo "myflec update: pull failed, repo left as is." >&2
			return 1
		}
	else
		_myflec_fetch || return 1
	fi

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
		_myflec_update_list "Kept, your changes (unchanged upstream)" "${_local[@]}"
		_myflec_update_list "Kept, your changes (removed upstream)" "${_drop[@]}"
		rm -rf "$_new"
		_myflec_record
		return 0
	fi

	echo ""
	echo "Update ~/.bashrc.d: ${_base:+${_base:0:7} -> }$(git -C "$_repo" log --format='%h (%cs) %s' -1)"
	echo ""
	if [ -n "$_base" ]; then
		echo "  Changes since your version:"
		git -C "$_repo" log --no-merges --format='    %h %s' "$_base..HEAD" -- .bashrc.d | head -n 20
		echo ""
	fi
	_myflec_update_list "New" "${_add[@]}"
	_myflec_update_list "Updated" "${_upd[@]}"
	_myflec_update_list "Removed" "${_del[@]}"
	_myflec_update_list "Kept, your changes (new version saved as <file>.myflec-new)" "${_keep[@]}"
	_myflec_update_list "Kept, your changes (unchanged upstream)" "${_local[@]}"
	_myflec_update_list "Kept, your changes (removed upstream)" "${_drop[@]}"

	local _backup_dir
	_backup_dir="${XDG_STATE_HOME:-$HOME/.local/state}/myflec-backup/$(date +%F-%H%M%S)/.bashrc.d"
	echo "Backup of replaced and removed files: $_backup_dir"
	if ! _myflec_confirm "$_assume_yes" "Apply?"; then
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
	_myflec_record

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
