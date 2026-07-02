# ~/.bashrc.d/yq.bash
# yq - portable command-line YAML/JSON processor
# https://github.com/mikefarah/yq
#
# Zero-install: uses docker run. No local binary needed.
# Supports pipes (echo '...' | yq ...) and files in $PWD.

if command -v docker >/dev/null 2>&1; then
    alias yq='docker run --rm -i -v "$PWD":/work -w /work mikefarah/yq:4'
fi
