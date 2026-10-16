# ~/.bashrc.d/jq.bash
# jq - lightweight and flexible command-line JSON processor
# https://jqlang.github.io/jq/
#
# Prefer the native binary (installed via mise) when available.
# Falls back to docker run (zero-install) when only docker is present.
# Supports pipes (echo '...' | jq ...) and files in $PWD.

if ! _myflec_has jq && _myflec_has docker; then
	alias jq='docker run --rm -i -v "$PWD":/work -w /work ghcr.io/jqlang/jq:1.7.1'
fi
