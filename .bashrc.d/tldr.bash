# ~/.bashrc.d/tldr.bash
# tldr - simplified man pages (client for tldr.sh)
# https://github.com/tldr-pages/tldr

if command -v tldr >/dev/null 2>&1; then
    alias tl='tldr'
    alias tldr-help='tldr tldr'
fi
