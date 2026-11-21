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
#   KEYSBACKUP_RECIPIENT  age public key of the recipient (required)
#   KEYSBACKUP_DEST       archive directory inside $HOME
#                         (default: .local/share/myflec/keys-backup)
#
# The age PRIVATE key is never touched by this module: keep it out of the
# backup repo and store a copy outside the machine it protects.

# Load the config file when it exists, then apply the environment overrides
# and defaults. Sets _keysbackup_recipient and _keysbackup_dest.
_keysbackup_load_config() {
	_keysbackup_recipient="" _keysbackup_dest=""
	local _conf="${XDG_CONFIG_HOME:-$HOME/.config}/myflec/keys-backup.conf"
	[ -r "$_conf" ] && . "$_conf"
	_keysbackup_recipient="${KEYSBACKUP_RECIPIENT:-$_keysbackup_recipient}"
	_keysbackup_dest="${KEYSBACKUP_DEST:-${_keysbackup_dest:-$HOME/.local/share/myflec/keys-backup}}"
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

# Seal ~/.ssh into a dated age archive inside $HOME. Prints the archive path.
# Excluded: known_hosts and authorized_keys travel in the plaintext backup,
# cm-* control sockets are runtime state.
_keysbackup_generate() {
	local _out
	_out="$_keysbackup_dest/ssh-keys-$(date +%Y%m%d).tar.gz.age"
	mkdir -p "$_keysbackup_dest" || return 1
	local _old_umask
	_old_umask="$(umask)"
	umask 077
	tar -C "$HOME" \
		--exclude='.ssh/known_hosts' \
		--exclude='.ssh/known_hosts.old' \
		--exclude='.ssh/authorized_keys' \
		--exclude='.ssh/cm-*' \
		-czf - .ssh | age -r "$_keysbackup_recipient" -o "$_out" || {
		umask "$_old_umask"
		return 1
	}
	umask "$_old_umask"
	printf '%s\n' "${_out#"$HOME"/}"
}

# myflec keys-backup [message]: archive, track, commit, push.
_keysbackup_run() {
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
# Existing files are never overwritten unless --force is given.
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
	_myflec_need $# 1 "keys-restore <archive> [--force]" || return 1
	local _archive="$1" _force=""
	[ "${2:-}" = "--force" ] && _force=1
	[ "${_archive#*/}" != "$_archive" ] || _archive="$HOME/$_archive"
	[ -r "$_archive" ] || {
		echo "Error: cannot read archive '$_archive'" >&2
		return 1
	}
	local _count
	_count="$(age -d -i "${KEYSBACKUP_IDENTITY:-$HOME/.config/age/ssh-keys-backup.key}" \
		"$_archive" | tar -tzf - | grep -c .)" || {
		echo "Error: cannot decrypt or list the archive (wrong identity?)" >&2
		return 1
	}
	if [ -z "$_force" ] && ! _myflec_confirm 0 "Extract $_count file(s) from the keys archive into \$HOME?"; then
		echo "myflec keys-restore: aborted."
		return 1
	fi
	if [ -n "$_force" ]; then
		age -d -i "${KEYSBACKUP_IDENTITY:-$HOME/.config/age/ssh-keys-backup.key}" "$_archive" |
			tar -C "$HOME" -xzf -
	else
		age -d -i "${KEYSBACKUP_IDENTITY:-$HOME/.config/age/ssh-keys-backup.key}" "$_archive" |
			tar -C "$HOME" --skip-old-files -xzf -
	fi
	echo "Keys restored into \$HOME. Check 'ls -l ~/.ssh' and key permissions."
}
