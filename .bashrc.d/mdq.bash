# ~/.bashrc.d/mdq.bash
# mdq - jq for Markdown: query/filter markdown sections by selectors
# https://github.com/yshavit/mdq
#
# Prefer the native binary when available (install: cargo install mdq).
# Falls back to docker run (zero-install) when only docker is present.
# Supports pipes: cat file.md | mdq '# usage'
# Limitation (docker fallback): only files in the current directory ($PWD) are accessible.

if command -v mdq >/dev/null 2>&1; then
    alias md-query='mdq'
elif command -v docker >/dev/null 2>&1; then
    alias mdq='docker run --rm -i -v "$PWD":/work -w /work yshavit/mdq:v0.10.0'
    alias md-query='mdq'
fi
