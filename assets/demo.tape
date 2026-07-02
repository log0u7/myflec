# MyFlec demo tape
# Source of the terminal demo GIF.
# Regenerate: vhs assets/demo.tape
# Requires: mise, native tools, vhs, ttyd, ffmpeg (see .github/workflows/demo.yml)
Output assets/demo.gif

Set Shell bash
Set FontSize 14
Set FontFamily "Hack Nerd Font"
Set Width 900
Set Height 520
Set TypingSpeed 25ms
Set Theme "Dracula"
Set Padding 20

# Bootstrap (hidden): cd to repo, load MyFlec modules (mise.bash activates mise), preload tldr
Hide
Type "cd $GITHUB_WORKSPACE" Enter
Type "source ~/.bashrc.d/myflec" Enter
Type "tldr --update" Enter
Sleep 4s
Type "clear" Enter
Sleep 300ms
Show

# 1. MYFLEC_DEBUG: module loading
Type "MYFLEC_DEBUG=1 bash -c '. ~/.bashrc.d/myflec'" Enter
Sleep 3s
Ctrl+l
Sleep 300ms

# 2. lsd: directory tree
Type "lt --depth 2" Enter
Sleep 2s
Ctrl+l
Sleep 300ms

# 3. bat: syntax highlighting
Type "catp .gitconfig" Enter
Sleep 2s
Ctrl+l
Sleep 300ms

# 4. ripgrep: fast search
Type `rg "includeIf" .gitconfig` Enter
Sleep 2s
Ctrl+l
Sleep 300ms

# 5. tldr: simplified man pages
Type "tldr tar" Enter
Sleep 2s
Ctrl+l
Sleep 300ms

# 6. git diff with delta (must create a change first)
Type "echo '# demo change for delta' >> README.md" Enter
Sleep 300ms
Type "git diff --stat" Enter
Sleep 1s
Type "git diff" Enter
Sleep 3s
Type "git checkout -- ." Enter
Sleep 500ms
Ctrl+l
Sleep 300ms

# 7. lazygit TUI (glimpse then quit)
Type "lgit" Enter
Sleep 3s
Type "q" Enter
Sleep 1s
Ctrl+l
Sleep 300ms

# 8. glow: markdown render (piped, no pager needed)
Type "echo '# MyFlec Demo' | glow -" Enter
Sleep 2s
Ctrl+l
Sleep 300ms

# Finale
Type "echo 'MyFlec - My Favorite Linux Environment Configuration'" Enter
Sleep 1s
