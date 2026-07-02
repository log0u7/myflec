# ~/.bashrc.d/hosts/$(hostname).bash
# Per-host configuration example.
#
# Copy this file to ~/.bashrc.d/hosts/$(hostname).bash and customize it.
# It is sourced automatically by _host.bash during shell startup.
#
# Use this file for:
#   - Machine-specific environment variables (e.g. DISPLAY, TERMINAL)
#   - Tool overrides per host (e.g. editor preference on a server vs desktop)
#   - Hardware-specific config (e.g. number of parallel jobs)
#
# Example:
#   export EDITOR=$(command -v nvim || command -v vim)
#   export BROWSER=$(command -v firefox || command -v chromium)
#   export MAKEFLAGS="-j$(nproc)"
