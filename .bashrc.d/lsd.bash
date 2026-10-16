# ~/.bashrc.d/lsd.bash
# lsd - modern ls with icons and tree view
# https://github.com/lsd-rs/lsd

if _myflec_has lsd; then
    alias ls="lsd"
    alias lt="ls --tree"
fi

