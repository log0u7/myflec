# ~/.bashrc.d/delta.bash
# delta - syntax-highlighting pager for git
# https://github.com/dandavison/delta
#
# Safe: GIT_PAGER is only set when delta is installed on the system.
# .gitconfig is never touched by this module.

if command -v delta >/dev/null 2>&1; then
    export GIT_PAGER=delta
fi
