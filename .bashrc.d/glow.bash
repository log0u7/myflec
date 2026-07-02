# ~/.bashrc.d/glow.bash
# glow - render markdown in the terminal
# https://github.com/charmbracelet/glow
#
# Zero-install: uses docker run. No local binary needed.
# Limitation: only files in the current directory ($PWD) are accessible.

if command -v docker >/dev/null 2>&1; then
    alias glow='docker run --rm -it -v "$PWD":/work -w /work charmcli/glow:v2'
    alias md='glow'
fi
