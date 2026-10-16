# ~/.bashrc.d/tldr.bash
# tldr - simplified man pages (client for tldr.sh)
# https://github.com/tldr-pages/tldr

if _myflec_has tldr; then
    alias tl='tldr'
    alias tldr-help='tldr tldr'
fi
