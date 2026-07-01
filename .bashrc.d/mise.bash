# ~/.bashrc.d/mise.bash
# mise - polyglot version manager, task runner, env loader
# https://mise.jdx.dev/

if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash)"

    # Short aliases
    alias mi='mise'
    alias miu='mise use'
    alias mii='mise install'
    alias mir='mise run'
    alias mil='mise list'
    alias mig='mise global'
    alias mix='mise exec --'
    alias mie='mise env'
    alias mit='mise tasks'
    alias miv='mise version'
    alias miup='mise upgrade'
    alias mils='mise ls'
    alias miw='mise where'

    # Completion
    eval "$(mise complete bash 2>/dev/null)"
fi
