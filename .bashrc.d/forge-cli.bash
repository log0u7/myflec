# ~/.bashrc.d/forge-cli.bash
# gh and glab - official command-line tools for GitHub and GitLab
# https://cli.github.com/  /  https://gitlab.com/gitlab-org/cli

if _myflec_has gh; then
    eval "$(gh completion -s bash 2>/dev/null)"
    alias ghpr='gh pr'
    alias ghrun='gh run'
    alias ghci='gh run'
    alias ghissue='gh issue'
fi

if _myflec_has glab; then
    eval "$(glab completion -s bash 2>/dev/null)"
    alias glmr='glab mr'
    alias glrun='glab ci'
    alias glissue='glab issue'
fi
