# ~/.bashrc.d/vim.bash

# Set default editor
if [ -x "$(command -v vim)" ]; then
    EDITOR="$(command -v vim)"
    export EDITOR VISUAL="$EDITOR"
fi

if command -v vim >/dev/null 2>&1; then
    alias vi="vim"
fi

# :q signature alias.
# vim and neovim both export $VIMRUNTIME into shells they spawn (:sh, :terminal).
# Testing that variable is instant (no subprocess) and covers both editors.
# Manual validation required: run :q inside a vim :terminal and outside vim.
if [ -n "${VIMRUNTIME:-}" ]; then
    alias :q='exit'
else
    alias :q='echo "Not in vim!"'
fi
