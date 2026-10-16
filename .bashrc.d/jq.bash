# ~/.bashrc.d/jq.bash
# jq - lightweight and flexible command-line JSON processor
# https://jqlang.github.io/jq/
#
# Prefer the native binary (installed via mise) when available.
# Falls back to docker run (zero-install) when only docker is present.
# Supports pipes (echo '...' | jq ...) and files in $PWD.

_myflec_docker_fallback jq ghcr.io/jqlang/jq:1.7.1
