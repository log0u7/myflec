# ~/.bashrc.d/byobu.bash

# Check if the shell is running under Byobu
if [ -n "$BYOBU" ] || [ -n "$BYOBU_SESSION" ]; then
    # Include prompt    
    [ -r ~/.byobu/prompt ] && . ~/.byobu/prompt
fi
