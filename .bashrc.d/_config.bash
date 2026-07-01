# ~/.bashrc.d/_config.bash

# Disconnect after 5min inactivity
# Disable with: export TMOUT=0  or  unset TMOUT
#export TMOUT=300

# Locale: prefer fr_FR.UTF-8 but only if the locale is available on the system.
# Do not force LC_ALL: overriding it breaks tools that rely on the user's own
# locale settings (e.g. date formatting, man pages).
if locale -a 2>/dev/null | grep -qiE 'fr_FR\.utf-?8'; then
    export LANG="fr_FR.UTF-8"
fi

# History management and timestamping
export HISTTIMEFORMAT="[%d/%m/%Y %H:%M:%S] "    # Timestamp
export HISTSIZE=5000                              # Increase history size
export HISTFILESIZE=10000                         # Increase the size of history file
export HISTCONTROL=ignoredups:erasedups           # Ignore duplicate commands in history
export HISTIGNORE="pwd:exit:clear"                # Ignore trivial commands
export PROMPT_COMMAND="history -a"                # Append commands to history file after execution

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Pager
[[ $(command -v most) ]] && { most=$(command -v most); export PAGER="$most"; }

# Terminal type: only set if the environment has not already provided one.
# Let the real terminal emulator or multiplexer (tmux, byobu) set TERM.
[ -z "${TERM:-}" ] && export TERM=xterm-256color
