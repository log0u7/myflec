# ~/.bashrc.d/mdq.bash
# mdq - jq for Markdown: query/filter markdown sections by selectors
# https://github.com/yshavit/mdq
#
# Zero-install: uses docker run. No local binary needed.
# Limitation: only files in the current directory ($PWD) are accessible.
# Works as a stdin filter: cat file.md | mdq '# usage'

if command -v docker >/dev/null 2>&1; then
    alias mdq='docker run --rm -i -v "$PWD":/work -w /work yshavit/mdq:v0.10.0'
    alias md-query='mdq'
fi
