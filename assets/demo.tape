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
Set PlaybackSpeed 0.8

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
Sleep 6s
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

# 6. git: create multiple changes (modified + new file), then show with delta
Type "echo '# demo change for delta' >> README.md" Enter
Sleep 200ms
Type "echo '# demo notes' > demo-notes.md" Enter
Sleep 200ms
Type "echo 'alias lt=' >> .bashrc.d/lsd.bash" Enter
Sleep 200ms
Type "git st" Enter
Sleep 1s
Type "git add README.md" Enter
Sleep 200ms
Type "git dc" Enter
Sleep 2s
Type "git diff" Enter
Sleep 3s
Ctrl+l
Sleep 300ms

# 7. lazygit: staged + unstaged + untracked all visible
Type "lgit" Enter
Sleep 4s
Type "q" Enter
Sleep 1s

# 8. cleanup: unstage, restore, remove untracked demo file
Type "git reset HEAD README.md" Enter
Sleep 300ms
Type "git checkout -- ." Enter
Sleep 300ms
Type "rm -f demo-notes.md" Enter
Sleep 300ms
Ctrl+l
Sleep 300ms

# 9. glow: markdown render (piped, no pager needed)
Type "echo '# MyFlec Demo' | glow -" Enter
Sleep 2s
Ctrl+l
Sleep 300ms

# Finale
Type "echo 'MyFlec - My Favorite Linux Environment Configuration'" Enter
Sleep 1s
