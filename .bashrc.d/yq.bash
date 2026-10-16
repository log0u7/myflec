# ~/.bashrc.d/yq.bash
# yq - portable command-line YAML/JSON processor
# https://github.com/mikefarah/yq
#
# Prefer the native binary (installed via mise) when available.
# Falls back to docker run (zero-install) when only docker is present.
# Supports pipes (echo '...' | yq ...) and files in $PWD.

if ! _myflec_has yq && _myflec_has docker; then
    alias yq='docker run --rm -i -v "$PWD":/work -w /work mikefarah/yq:4'
fi
