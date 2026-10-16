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

# Append commands to the history file after each one. Added to (never
# replacing) PROMPT_COMMAND, once: other hooks (VTE, starship, direnv, fnox)
# survive startup and myflec reload.
case ";${PROMPT_COMMAND:-};" in
*";history -a;"*) ;;
*) PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}history -a" ;;
esac

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Pager
if _myflec_has most; then
    PAGER="$(command -v most)"
    export PAGER
fi

# Terminal type: only set if the environment has not already provided one.
# Let the real terminal emulator or multiplexer (tmux, byobu) set TERM.
if [ -z "${TERM:-}" ]; then
    export TERM=xterm-256color
fi
