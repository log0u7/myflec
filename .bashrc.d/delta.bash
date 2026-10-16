# ~/.bashrc.d/delta.bash
# delta - syntax-highlighting pager for git
# https://github.com/dandavison/delta
#
# Safe: GIT_PAGER is only set when delta is installed on the system.
# .gitconfig is never touched by this module.

if _myflec_has delta; then
    export GIT_PAGER=delta
fi
