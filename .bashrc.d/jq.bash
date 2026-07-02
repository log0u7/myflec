# ~/.bashrc.d/jq.bash
# jq - lightweight and flexible command-line JSON processor
# https://jqlang.github.io/jq/
#
# Zero-install: uses docker run. No local binary needed.
# Supports pipes (echo '...' | jq ...) and files in $PWD.

if command -v docker >/dev/null 2>&1; then
    alias jq='docker run --rm -i -v "$PWD":/work -w /work ghcr.io/jqlang/jq:1'
fi
