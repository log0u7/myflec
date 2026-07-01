# ~/.bashrc.d/python.bash
# Python and Pip aliases with dynamic virtual environment management

# Python basics
alias py='python3'                             # Default to Python 3
alias py3='python3'                            # Explicit Python 3
alias ipy='ipython'                            # Launch IPython
alias pyv='python --version'                   # Show Python version
alias pywhich='which python'                   # Find Python executable

# Pip package management (fallback when mise is not available)
if ! command -v mise >/dev/null 2>&1; then
    alias pipi='pip install'                       # Install package
    alias pips='pip show'                          # Show package details
    alias pipu='pip uninstall'                     # Uninstall package
    alias pipl='pip list'                          # List installed packages
    alias pipup='pip install --upgrade'            # Upgrade package
    alias pipreq='pip freeze > requirements.txt'   # Generate requirements file
    alias pipinst='pip install -r requirements.txt' # Install from requirements file
    alias pipcache='pip cache purge'               # Clear pip cache
fi

# Virtual environments with argument
venv() {
    if [ -z "$1" ]; then
        echo "Usage: venv <env_name>"
        return 1
    fi
    python -m venv "$1" && echo "Virtual environment '$1' created."
}

act() {
    if [ -z "$1" ]; then
        echo "Usage: act <env_name>"
        return 1
    fi
    source "$1/bin/activate" && echo "Activated virtual environment '$1'."
}

deact() {
    deactivate && echo "Virtual environment deactivated."
}

venvdel() {
    if [ -z "$1" ]; then
        echo "Usage: venvdel <env_name>"
        return 1
    fi
    rm -rf "$1" && echo "Virtual environment '$1' deleted."
}

# Running & debugging
alias pyrun='python main.py'                   # Run main.py
alias pydebug='python -m pdb'                  # Start Python debugger
alias pytime='python -m timeit'                # Run time performance tests

# Miscellaneous
alias pydeps='pipdeptree'                      # Show dependency tree
alias pyclean="find . -name '*.pyc' -delete"   # Remove Python cache files
alias pyshell='python -m code'                 # Start interactive Python shell
