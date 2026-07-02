# ~/.bashrc.d/_host.bash
# Per-host configuration: source a machine-specific file if it exists.
#
# Usage: create ~/.bashrc.d/hosts/$(hostname).bash with settings
# specific to this machine (display config, tool overrides, etc.).
#
# The file is loaded at the end of core module initialization, so you
# can override any core variable or alias in the host-specific file.

_host_file="$HOME/.bashrc.d/hosts/$(hostname).bash"
[ -r "$_host_file" ] && . "$_host_file"
unset _host_file
