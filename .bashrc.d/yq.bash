# ~/.bashrc.d/yq.bash
# yq - portable command-line YAML/JSON processor
# https://github.com/mikefarah/yq
#
# Prefer the native binary (installed via mise) when available.
# Falls back to docker run (zero-install) when only docker is present.
# Supports pipes (echo '...' | yq ...) and files in $PWD.

_myflec_docker_fallback yq mikefarah/yq:4
