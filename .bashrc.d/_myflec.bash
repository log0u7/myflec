# ~/.bashrc.d/_myflec.bash
# myflec - self-management: module status check and hot reload.
#
# Purpose: verify that all MyFlec modules are present and reload them without
# opening a new shell.
#
# Usage:
#   myflec                 -> show help
#   myflec status          -> list all modules (core then tool) with a count
#   myflec reload          -> re-source every module (safe, hooks preserved)
#   myflec reload --full   -> re-source the full loader (hooks may accumulate)
#   myflec help            -> show help
#
# Internals:
#   Core module (_*.bash), loads after _functions.bash, before _shopts.bash.
#   The alias myflec=fMyflec lives in _aliases.bash and resolves at call time.

fMyflec() {
    local _cmd="${1:-help}"
    local _dir="${MYFLEC_DIR:-$HOME/.bashrc.d}"

    case "$_cmd" in
        status)
            _myflec_status "$_dir"
            ;;
        reload)
            if [ "${2:-}" = "--full" ]; then
                _myflec_reload_full "$_dir"
            else
                _myflec_reload "$_dir"
            fi
            ;;
        help|--help|-h|"")
            _myflec_help
            ;;
        *)
            echo "myflec: unknown subcommand '$_cmd'" >&2
            echo "Run 'myflec help' for usage." >&2
            return 1
            ;;
    esac
}

_myflec_help() {
    echo "Usage: myflec <command>"
    echo ""
    echo "Commands:"
    echo "  status        List all loaded modules"
    echo "  reload        Re-source modules (safe, hooks preserved)"
    echo "  reload --full Re-source full loader (hooks may accumulate)"
    echo "  help          Show this help"
}

_myflec_status() {
    local _dir="$1"
    local _core=0 _tools=0
    local _f _name

    echo "MyFlec modules ($_dir)"
    echo ""

    for _f in "$_dir"/_*.bash; do
        [ -r "$_f" ] || continue
        _core=$((_core + 1))
        _name="$(basename "$_f" .bash)"
        _name="${_name#_}"
        printf "  core  %s\n" "$_name"
    done

    for _f in "$_dir"/*.bash; do
        case "$(basename "$_f")" in
            _*) continue ;;
        esac
        [ -r "$_f" ] || continue
        _tools=$((_tools + 1))
        _name="$(basename "$_f" .bash)"
        printf "  tool  %s\n" "$_name"
    done

    echo ""
    echo "$((_core + _tools)) modules ($((_core)) core, $((_tools)) tool)"
}

_myflec_reload() {
    local _dir="$1"
    local _f

    for _f in "$_dir"/_*.bash "$_dir"/*.bash; do
        [ -r "$_f" ] || continue
        source "$_f"
    done

    echo "MyFlec reloaded (modules only, hooks preserved)."
}

_myflec_reload_full() {
    local _dir="$1"

    source "$_dir/loader"
    echo "MyFlec reloaded (full). Note: PROMPT_COMMAND hooks may have accumulated."
    echo "For a clean state, open a new shell."
}