# ~/.bashrc.d/zoxide.bash
# zoxide - smarter cd command inspired by z and autojump
# https://github.com/ajeetdsouza/zoxide
#
# Coexists with bash shopt autocd/cdspell (set in _shopts.bash):
# - autocd: cd by typing a dir name (still works)
# - cdspell: auto-correct typos in cd (still works)
# - zoxide 'z': jump to best match by frecency (adds on top)
# - zoxide 'zi': interactive fuzzy selection

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi
