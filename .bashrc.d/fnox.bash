# ~/.bashrc.d/fnox.bash
# fnox - secrets management (age, cloud KMS, 1Password, Bitwarden, Vault, ...)
# https://fnox.jdx.dev/

if command -v fnox >/dev/null 2>&1; then
    # Auto-load secrets on directory change via PROMPT_COMMAND hook.
    # This calls `fnox load` before each prompt to load secrets for the
    # current directory if a fnox.toml (or parent) is found.
    # No-op silently when no fnox.toml is present.
    _fnox_load() { fnox load 2>/dev/null; }
    PROMPT_COMMAND="_fnox_load;${PROMPT_COMMAND:-}"

    # Short aliases
    alias fn='fnox'
    alias fns='fnox set'
    alias fng='fnox get'
    alias fnl='fnox list'
    alias fnd='fnox delete'
    alias fne='fnox exec --'
    alias fnx='fnox exec --'
    alias fnedit='fnox edit'

    # Completion
    eval "$(fnox complete bash 2>/dev/null)"
fi
