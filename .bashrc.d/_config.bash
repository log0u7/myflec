# ~/.bash/config.bash

# Disconnect after 5min inactivity
#Disable w/ `export TMOUT=0` or `unset TMOUT`
#export TMOUT=300

# Set language and locale
export LANG="fr_FR.UTF-8"       # Set language
export LC_ALL="fr_FR.UTF-8"     # Ensure all locale settings use UTF-8

# History management and timestamping
export HISTTIMEFORMAT="[%d/%m/%Y %H:%M:%S] "    # Timestamp
export HISTSIZE=5000                            # Increase history size
export HISTFILESIZE=10000                       # Increase the size of history file
export HISTCONTROL=ignoredups:erasedups         # Ignore duplicate commands in history
export HISTIGNORE="pwd:exit:clear"              # Ignore trivial commands
export PROMPT_COMMAND="history -a"              # Append commands to history file after execution

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Pager
[[ $(command -v most) ]] && { most=$(command -v most); export PAGER="$most"; }

# Default terminal multiplexer
export TERM="xterm-256color"
