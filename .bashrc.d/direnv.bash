# ~/.bashrc.d/direnv.bash
# direnv - load/unload environment variables based on current directory
# https://direnv.net/
#
# Order of env hooks (PROMPT_COMMAND): fnox -> direnv
# Each hook runs only when relevant (.envrc / fnox.toml / mise.toml present).

if _myflec_has direnv; then
    eval "$(direnv hook bash)"
fi
