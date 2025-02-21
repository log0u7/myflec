# ~/.bash/shopts.bash
# Additional shell optional behaviors

shopt -s autocd                  # Auto cd dirs
shopt -s cdable_vars             # Use cdable vars
shopt -s cdspell                 # Path Autocorrection
shopt -s checkwinsize            # Automatically adjust terminal window size
#shopt -s checkhash               # Verify if hashed executables still exist before execution
#shopt -s checkjobs               # Warn if jobs are running when exiting
#shopt -s cmdhist                 # Merge multi-line commands into a single history entry
shopt -s complete_fullquote      # Use full quotes in completions
#shopt -s compat31                # Enable compatibility with Bash 3.1
#shopt -s compat32                # Enable compatibility with Bash 3.2
#shopt -s compat40                # Enable compatibility with Bash 4.0
#shopt -s compat41                # Enable compatibility with Bash 4.1
#shopt -s compat42                # Enable compatibility with Bash 4.2
#shopt -s compat43                # Enable compatibility with Bash 4.3
#shopt -s compat44                # Enable compatibility with Bash 4.4
#shopt -s direxpand               # Expand `~` when completing directories
shopt -s dirspell                # Directory Autocompletion
#shopt -s dotglob                 # Include hidden files in filename expansion
#shopt -s execfail                # Prevent shell exit if `exec` fails
#shopt -s extdebug                # Enable extended debugging features
#shopt -s extglob                 # Enable advanced globbing patterns
#shopt -s extquote                # Protect special characters in variable expansions
#shopt -s failglob                # Error if a glob expansion matches nothing
shopt -s expand_aliases          # Enable alias expansion
shopt -s force_fignore           # Apply FIGNORE variable in file completion
shopt -s globasciiranges         # Use ASCII ranges for globbing
#shopt -s globskipdots            # Skip hidden files in glob expansions
#shopt -s globstar                # Allow ** for recursive path expansion
#shopt -s gnu_errfmt              # Use GNU-style error messages
#shopt -s histappend              # Append to history file instead of overwriting it
#shopt -s histreedit              # Re-edit command before execution
#shopt -s histverify              # Show command before execution
shopt -s hostcomplete            # Host Autocompletion
#shopt -s huponexit               # Send SIGHUP to background jobs on shell exit
#shopt -s inherit_errexit         # Pass `set -e` to subshells
shopt -s interactive_comments    # Allow comments in interactive mode
#shopt -s lastpipe                # Allow last command in a pipeline to run in the current shell
#shopt -s lithist                 # Store multi-line commands in history as written
#shopt -s localvar_inherit        # Inherit local variables in functions
#shopt -s localvar_unset          # Unset local variables when a function exits
#shopt -s login_shell             # Indicate if this is a login shell
#shopt -s mailwarn                # Warn if mail has been received
#shopt -s no_empty_cmd_completion # Disable completion for empty commands
#shopt -s nocaseglob              # Enable case-insensitive globbing
#shopt -s nocasematch             # Enable case-insensitive pattern matching
#shopt -s noexpand_translation    # Disable expansion of translated strings
#shopt -s nullglob                # Return an empty string for unmatched globs
shopt -s patsub_replacement      # Enable pattern substitution in expansions
shopt -s progcomp                # Enable programmable completion
#shopt -s progcomp_alias          # Enable completion for aliases
shopt -s promptvars              # Expand variables in PS1
#shopt -s restricted_shell        # Indicate if the shell is restricted
#shopt -s shift_verbose           # Warn if `shift` moves beyond available parameters
#shopt -s sourcepath              # Search `$PATH` when using `source`
#shopt -s varredir_close          # Close file descriptors on variable assignment redirection
#shopt -s xpg_echo                # Enable XPG-compatible `echo` behavior
