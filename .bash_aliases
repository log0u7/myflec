# ~/.bash_aliases

if command -v hexedit >/dev/null 2>&1; then
    alias hexedit='hexedit --color'
fi

if command -v dig >/dev/null 2>&1; then
    alias dnsproto='dig +short txt proto.on.quad9.net.'
fi

# diff --color is safe on GNU diffutils; fall back silently on other diff
diff --color /dev/null /dev/null 2>/dev/null && alias diff='diff --color' || true
