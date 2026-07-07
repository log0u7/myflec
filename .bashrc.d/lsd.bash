# ~/.bashrc.d/lsd.bash
# lsd - modern ls with icons and tree view
# https://github.com/lsd-rs/lsd

if command -v lsd >/dev/null 2>&1; then
    alias ls="lsd"
    alias lt="ls --tree"
fi

