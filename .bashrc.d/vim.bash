# ~/.bashrc.d/vim.bash

## Set Editor
[[ $(command -v vim) ]] && { vim=$(command -v vim); export EDITOR="$vim"; export VISUAL="$vim"; }

# Aliases
alias vi="vim"
# If shell is spawned by vim, allow :q to exit; otherwise warn.
_vim_parent=$(ps -ef | awk "\$2 == $(ps -ef | awk "\$2 == $$ {print \$3}") {print \$8}")
if echo "$_vim_parent" | grep -q vi; then
    alias :q='exit'
else
    alias :q='echo "Not in vi{m}!"'
fi
unset _vim_parent
