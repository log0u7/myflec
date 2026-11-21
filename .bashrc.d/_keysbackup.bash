# ~/.bashrc.d/_keysbackup.bash
# Encrypted SSH keys backup: age-sealed archive of ~/.ssh, committed and
# pushed through the dotfiles backup repo.
#
# Purpose: private keys have no place in the plaintext dotfiles backup, but
# losing them means re-issuing every identity. This module seals ~/.ssh in a
# dated age archive, then hands the commit/push to the dotfiles toolbox.
#
# Usage: go through the 'myflec' command (_myflec.bash):
#   myflec keys-backup            -> archive, commit and push
#   myflec keys-restore <archive> -> decrypt and extract into $HOME
#
# Configuration: ${XDG_CONFIG_HOME:-$HOME/.config}/myflec/keys-backup.conf
# (see keys-backup.conf.example), every setting overridable by environment:
#   KEYSBACKUP_RECIPIENT  age public key of the recipient (required to back up)
#   KEYSBACKUP_DEST       archive directory inside $HOME
#                         (default: .local/share/myflec/keys-backup)
#   KEYSBACKUP_IDENTITY   age identity file used to restore
#                         (default: ~/.config/age/ssh-keys-backup.key)
#
# The age PRIVATE key is never touched by the backup path: keep it out of
# the backup repo and store a copy outside the machine it protects.

# Load the config file when it exists, then apply the environment overrides
# and defaults. Sets _keysbackup_recipient, _keysbackup_dest and
# _keysbackup_identity.
_keysbackup_load_config() {
	_keysbackup_recipient="" _keysbackup_dest="" _keysbackup_identity=""
	local _conf="${XDG_CONFIG_HOME:-$HOME/.config}/myflec/keys-backup.conf"
	[ -r "$_conf" ] && . "$_conf"
	_keysbackup_recipient="${KEYSBACKUP_RECIPIENT:-$_keysbackup_recipient}"
	_keysbackup_dest="${KEYSBACKUP_DEST:-${_keysbackup_dest:-$HOME/.local/share/myflec/keys-backup}}"
	_keysbackup_identity="${KEYSBACKUP_IDENTITY:-${_keysbackup_identity:-$HOME/.config/age/ssh-keys-backup.key}}"
	_keysbackup_dest="${_keysbackup_dest%/}"
}

# Prerequisite check: config and tools. The recipient is a public key and
# lives in the config file, but the module stays useless without it: fail
# loudly instead of archiving in clear text.
_keysbackup_require() {
	_keysbackup_load_config
	if [ -z "$_keysbackup_recipient" ]; then
		echo "Error: no age recipient configured for the keys backup." >&2
		echo "Set KEYSBACKUP_RECIPIENT in" >&2
		echo "${XDG_CONFIG_HOME:-$HOME/.config}/myflec/keys-backup.conf" >&2
		echo "(template: keys-backup.conf.example in the MyFlec repository)." >&2
		return 1
	fi
	local _tool
	for _tool in age tar; do
		_myflec_has "$_tool" || {
			echo "Error: '$_tool' is required for the keys backup." >&2
			return 1
		}
	done
}

# Seal ~/.ssh into a dated age archive inside $HOME. Prints the archive path
# relative to $HOME. Runs in a subshell: pipefail catches a failed tar (a
# broken stream would otherwise encrypt to an empty or partial archive) and
# the 077 umask never leaks into the calling shell. Excluded: known_hosts
# and authorized_keys travel in the plaintext backup, cm-* control sockets
# are runtime state.
_keysbackup_generate() {
	local _out
	_out="$_keysbackup_dest/ssh-keys-$(date +%Y%m%d).tar.gz.age"
	if (
		umask 077 &&
			mkdir -p "$_keysbackup_dest" &&
			set -o pipefail &&
			tar -C "$HOME" \
				--exclude='.ssh/known_hosts' \
				--exclude='.ssh/known_hosts.old' \
				--exclude='.ssh/authorized_keys' \
				--exclude='.ssh/cm-*' \
				-czf - .ssh | age -r "$_keysbackup_recipient" -o "$_out"
	); then
		printf '%s\n' "${_out#"$HOME"/}"
	else
		rm -f "$_out"
		echo "Error: the keys archive could not be created, nothing committed." >&2
		return 1
	fi
}

# myflec keys-backup [message]: archive, track, commit, push.
_keysbackup_run() {
	[ $# -le 1 ] || {
		echo "Usage: myflec keys-backup [message]" >&2
		return 1
	}
	_keysbackup_require || return 1
	_dot_require_repo || return 1
	local _path _msg="${1:-ssh keys backup $(date +%Y-%m-%d)}"
	_path="$(_keysbackup_generate)" || return 1
	echo "Archive: $HOME/$_path"
	# dotfiles-backup commits tracked files only: stage the new archive first
	_dot_git add -- "$_path" || return 1
	dotfiles-backup "$_msg"
}

# myflec keys-restore <archive> [--force]: decrypt and extract into $HOME.
# Existing files are never overwritten unless --force is given. Refuses
# archives whose listing contains absolute paths or '..' traversal: the
# recipient key is public, so a hostile archive is a real scenario.
_keysbackup_extract() {
	# Restore runs on a fresh machine too: no dotfiles repo or recipient
	# needed, only age, tar and the identity file.
	local _tool
	for _tool in age tar; do
		_myflec_has "$_tool" || {
			echo "Error: '$_tool' is required to restore the keys archive." >&2
			return 1
		}
	done
	local _usage="Usage: myflec keys-restore <archive> [--force]"
	local _archive="" _force=""
	while [ $# -gt 0 ]; do
		case "$1" in
		--force) _force=1 ;;
		-*)
			echo "myflec keys-restore: unknown option '$1'" >&2
			echo "$_usage" >&2
			return 1
			;;
		*)
			if [ -n "$_archive" ]; then
				echo "myflec keys-restore: unexpected argument '$1'" >&2
				echo "$_usage" >&2
				return 1
			fi
			_archive="$1"
			;;
		esac
		shift
	done
	if [ -z "$_archive" ]; then
		echo "$_usage" >&2
		return 1
	fi
	_keysbackup_load_config
	[ "${_archive#*/}" != "$_archive" ] || _archive="$HOME/$_archive"
	[ -r "$_archive" ] || {
		echo "Error: cannot read archive '$_archive'" >&2
		return 1
	}
	local _list
	_list="$(age -d -i "$_keysbackup_identity" "$_archive" | tar -tzf -)" || {
		echo "Error: cannot decrypt or list the archive (wrong identity?)" >&2
		return 1
	}
	if printf '%s\n' "$_list" | grep -Eq '^/|(^|/)\.\.(/|$)'; then
		echo "Error: archive contains absolute paths or '..' traversal, refusing." >&2
		return 1
	fi
	local _count
	_count="$(printf '%s\n' "$_list" | grep -c .)"
	if [ -z "$_force" ] && ! _myflec_confirm 0 "Extract $_count file(s) from the keys archive into \$HOME?"; then
		echo "myflec keys-restore: aborted."
		return 1
	fi
	if [ -n "$_force" ]; then
		age -d -i "$_keysbackup_identity" "$_archive" | tar -C "$HOME" -xzf -
	else
		age -d -i "$_keysbackup_identity" "$_archive" | tar -C "$HOME" --skip-old-files -xzf -
	fi
	echo "Keys restored into \$HOME. Check 'ls -l ~/.ssh' and key permissions."
}
