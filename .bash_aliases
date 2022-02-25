# .bash_aliases
alias hexedit='hexedit --color'

#If shell is spawned by vim quit by :q
[[ $(ps -ef |awk "\$2 == $(ps -ef | awk "\$2 == $$ {print \$3}") {print \$8}" |grep vi) ]]&& alias :q='exit' || alias :q='echo "Not in vi{m} !"';

alias calc='fCalc'
alias searchosts='fSearchHosts'
alias sshadd='fSshAdd'
alias sshkeygen='fSshKeygen'
