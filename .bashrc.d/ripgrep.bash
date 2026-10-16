# ~/.bashrc.d/ripgrep.bash
# ripgrep (rg) - recursively search directories for a regex pattern
# https://github.com/BurntSushi/ripgrep

if _myflec_has rg && [ -f "$HOME/.ripgreprc" ]; then
    export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi
