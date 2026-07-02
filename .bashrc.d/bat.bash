# ~/.bashrc.d/bat.bash
# bat - cat with syntax highlighting and pager integration
# https://github.com/sharkdp/bat

if command -v bat >/dev/null 2>&1; then
    alias catp='bat -p'                      # Plain bat (no decorations)
    alias catn='bat --paging=never'           # Bat without pager
    export BAT_THEME="${BAT_THEME:-Dracula}"
fi
