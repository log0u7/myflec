# ~/.bashrc.d/glow.bash
# glow - render markdown in the terminal
# https://github.com/charmbracelet/glow
#
# Prefer the native binary (installed via mise) when available.
# Falls back to docker run (zero-install) when only docker is present.
# Limitation (docker fallback): only files in the current directory ($PWD) are accessible.

if _myflec_has glow; then
	alias md='glow'
elif _myflec_has docker; then
	alias glow='docker run --rm -i -v "$PWD":/work -w /work charmcli/glow:v3'
	alias md='glow'
fi
