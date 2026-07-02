# ~/.bashrc.d/glow.bash
# glow - render markdown in the terminal
# https://github.com/charmbracelet/glow
#
# Prefer the native binary (installed via mise) when available.
# Falls back to docker run (zero-install) when only docker is present.
# Limitation (docker fallback): only files in the current directory ($PWD) are accessible.

if command -v glow >/dev/null 2>&1; then
    alias md='glow'
elif command -v docker >/dev/null 2>&1; then
    alias glow='docker run --rm -i -v "$PWD":/work -w /work charmcli/glow:v2'
    alias md='glow'
fi
