# ~/.bashrc.d/jq.bash
# jq - lightweight and flexible command-line JSON processor
# https://jqlang.github.io/jq/
#
# Prefer the native binary (installed via mise) when available.
# Falls back to docker run (zero-install) when only docker is present.
# Supports pipes (echo '...' | jq ...) and files in $PWD.

if ! command -v jq >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then
    alias jq='docker run --rm -i -v "$PWD":/work -w /work ghcr.io/jqlang/jq:1'
fi
