# ~/.bashrc.d/mdq.bash
# mdq - jq for markdown: query/filter markdown sections by selectors
# https://github.com/ysugimoto/mdq

if command -v mdq >/dev/null 2>&1; then
    alias mdq='mdq'
    alias md-query='mdq'
fi
