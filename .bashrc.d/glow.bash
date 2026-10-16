# ~/.bashrc.d/glow.bash
# glow - render markdown in the terminal
# https://github.com/charmbracelet/glow
#
# Prefer the native binary (installed via mise) when available.
# Falls back to docker run (zero-install) when only docker is present.
# Limitation (docker fallback): only files in the current directory ($PWD) are accessible.

if _myflec_docker_fallback glow charmcli/glow:v3; then
	alias md='glow'
fi
