# ~/.bashrc.d/ripgrep.bash
# ripgrep (rg) - recursively search directories for a regex pattern
# https://github.com/BurntSushi/ripgrep

if [ -x "$(command -v rg)" ] && [ -f "$HOME/.ripgreprc" ]; then
    export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi
