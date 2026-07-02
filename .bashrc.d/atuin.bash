# ~/.bashrc.d/atuin.bash
# atuin - sync, search, and backup shell history with encryption
# https://atuin.sh/
#
# Purpose: enhanced shell history with fuzzy search and optional sync.
#
# Usage: press Ctrl-R to search history interactively. Up-arrow history search
# requires a preexec provider (bash-preexec or ble.sh). Without one, up-arrow
# is disabled but Ctrl-R still works. To enable up-arrow, install bash-preexec:
#   curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh \
#     -o ~/.bash-preexec.sh
#
# Internals: if bash-preexec or ble.sh is detected it is sourced before
# `atuin init bash` to enable full hook integration. If no provider is present,
# atuin is initialized with --disable-up-arrow to degrade gracefully (no
# keybinding warning at shell startup). If both atuin and fzf are loaded, atuin
# takes over Ctrl-R (last-loaded wins).

if command -v atuin >/dev/null 2>&1; then
    # Source bash-preexec if not already loaded and not using ble.sh.
    if [ -z "${__bp_imported:-}" ] && [ -z "${bleopt_prompt_ps1_transient:-}" ]; then
        for _atuin_bp in \
            "$HOME/.bash-preexec.sh" \
            /usr/share/bash-preexec/bash-preexec.sh; do
            if [ -r "$_atuin_bp" ]; then
                # shellcheck source=/dev/null
                source "$_atuin_bp"
                break
            fi
        done
        unset _atuin_bp
    fi

    if [ -n "${__bp_imported:-}" ] || [ -n "${bleopt_prompt_ps1_transient:-}" ]; then
        # preexec provider available: full integration (Ctrl-R + up-arrow).
        eval "$(atuin init bash)"
    else
        # No preexec provider: disable up-arrow to avoid startup warning.
        # Ctrl-R search remains functional.
        eval "$(atuin init bash --disable-up-arrow)"
    fi
fi
