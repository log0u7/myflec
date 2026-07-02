# ~/.bashrc.d/fzf.bash
# fzf - fuzzy finder (Ctrl-R, Ctrl-T, Alt-C)
# https://github.com/junegunn/fzf

if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --bash 2>/dev/null)"

    # Use fd (if available) as the default file search command for fzf
    if command -v fd >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi

    # Use bat (if available) as the previewer for fzf
    if command -v bat >/dev/null 2>&1; then
        export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}'"
        export FZF_ALT_C_OPTS="--preview 'lsd --tree {} 2>/dev/null || ls {}'"
    fi
fi
