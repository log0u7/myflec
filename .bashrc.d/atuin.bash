# ~/.bashrc.d/atuin.bash
# atuin - sync, search, and backup shell history with encryption
# https://atuin.sh/
#
# Note: atuin hooks Ctrl-R and replaces the default reverse-search.
# If both atuin and fzf are present, atuin takes over Ctrl-R (loaded last wins).
# Fzf still works for its other bindings (Ctrl-T, Alt-C).

if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init bash)"
fi
