# ~/.bashrc.d/direnv.bash
# direnv - load/unload environment variables based on current directory
# https://direnv.net/
#
# Order of env hooks (PROMPT_COMMAND): fnox -> direnv
# Each hook runs only when relevant (.envrc / fnox.toml / mise.toml present).

if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi
