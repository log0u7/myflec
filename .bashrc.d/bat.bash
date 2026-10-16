# ~/.bashrc.d/bat.bash
# bat - cat with syntax highlighting and pager integration
# https://github.com/sharkdp/bat

if _myflec_has bat; then
    alias catp='bat -p'                      # Plain bat (no decorations)
    alias catn='bat --paging=never'           # Bat without pager
    export BAT_THEME="${BAT_THEME:-Dracula}"
fi
