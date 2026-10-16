# ~/.bashrc.d/fzf.bash
# fzf - fuzzy finder (Ctrl-R, Ctrl-T, Alt-C)
# https://github.com/junegunn/fzf

if _myflec_has fzf; then
    eval "$(fzf --bash 2>/dev/null)"

    # Use fd (if available) as the default file search command for fzf
    if _myflec_has fd; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi

    # Use bat (if available) as the previewer for fzf
    if _myflec_has bat; then
        export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}'"
        export FZF_ALT_C_OPTS="--preview 'lsd --tree {} 2>/dev/null || ls {}'"
    fi
fi
