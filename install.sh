#!/usr/bin/env bash
# MyFlec installer.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/log0u7/myflec/main/install.sh | bash
#   bash install.sh [-C <clone>] [--yes]
#
# Installs MyFlec into $HOME with 'myflec deploy' (dry run, confirmation,
# backup of every overwritten file), then hooks the loader into ~/.bashrc
# once. Without -C, MyFlec is fetched online (public mirrors in turn, or
# MYFLEC_URL); with -C, it is installed from a local clone. Later updates:
# 'myflec update'.

_myflec_install() {
	local _cmd _src="" _tmp="" _url _arg _prev=""

	for _cmd in git rsync tar; do
		if ! command -v "$_cmd" >/dev/null 2>&1; then
			echo "myflec install: '$_cmd' is required, install it first." >&2
			return 1
		fi
	done

	# Local clone given with -C, or MYFLEC_REPO
	for _arg in "$@"; do
		[ "$_prev" = "-C" ] && _src="${_arg%/}"
		_prev="$_arg"
	done
	_src="${_src:-${MYFLEC_REPO:-}}"

	# Otherwise a throwaway shallow copy, only to load the myflec command
	if [ -z "$_src" ]; then
		_tmp="$(mktemp -d)" || return 1
		for _url in ${MYFLEC_URL:-https://github.com/log0u7/myflec.git https://gitlab.com/log0u7/myflec.git https://notabug.org/log0u7/myflec.git}; do
			git clone -q --depth 1 "$_url" "$_tmp/myflec" 2>/dev/null && _src="$_tmp/myflec" && break
		done
		if [ -z "$_src" ]; then
			echo "myflec install: no mirror reachable (set MYFLEC_URL)." >&2
			rm -rf "$_tmp"
			return 1
		fi
	fi

	# shellcheck source=.bashrc.d/_myflec.bash
	. "$_src/.bashrc.d/_myflec.bash" || return 1
	fMyflec deploy "$@"
	local _rc=$?
	if [ "$_rc" -eq 0 ] && ! grep -q 'bashrc.d/loader' "$HOME/.bashrc" 2>/dev/null; then
		cat "$_src/profile" >>"$HOME/.bashrc" && echo "Loader hooked into ~/.bashrc."
	fi
	[ -n "$_tmp" ] && rm -rf "$_tmp"
	[ "$_rc" -eq 0 ] || return "$_rc"

	echo ""
	echo "MyFlec is installed. Open a new shell (exec bash), then:"
	echo "  myflec help      all commands"
	echo "  myflec update    update later, keeping your changes"
}

_myflec_install "$@"
