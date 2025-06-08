# ~/.bashrc.d/vim.bash

## Set Editor
[[ $(command -v vim) ]] && { vim=$(command -v vim); export EDITOR="$vim"; export VISUAL="$vim"; }

# Aliases
alias vi="vim"
#If shell is spawned by vim quit by :q
[[ $(ps -ef |awk "\$2 == $(ps -ef | awk "\$2 == $$ {print \$3}") {print \$8}" |grep vi) ]]&& alias :q='exit' || alias :q='echo "Not in vi{m} !"';
