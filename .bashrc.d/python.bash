# ~/.bash/aliases.bash
# Python and Pip aliases with dynamic virtual environment management

# Python basics
alias py='python'                              # Short alias for Python
alias py3='python3'                            # Ensure using Python 3
alias ipy='ipython'                            # Launch IPython
alias pyv='python --version'                   # Show Python version
alias pywhich='which python'                   # Find Python executable

# Pip package management
alias pipi='pip install'                       # Install package
alias pips='pip show'                          # Show package details
alias pipu='pip uninstall'                     # Uninstall package
alias pipl='pip list'                          # List installed packages
alias pipup='pip install --upgrade'            # Upgrade package
alias pipreq='pip freeze > requirements.txt'   # Generate requirements file
alias pipinst='pip install -r requirements.txt' # Install from requirements file
alias pipcache='pip cache purge'               # Clear pip cache

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

# Formatting & Linting
alias black='black .'                          # Format Python files with Black
alias flake8='flake8 .'                        # Run flake8 linter
alias pylint='pylint'                          # Run pylint linter

# Running & debugging
alias pyrun='python main.py'                   # Run main.py
alias pytest='pytest'                          # Run tests with pytest
alias pydebug='python -m pdb'                  # Start Python debugger
alias pytime='python -m timeit'                # Run time performance tests

# Miscellaneous
alias pydeps='pipdeptree'                      # Show dependency tree
alias pyclean="find . -name '*.pyc' -delete"   # Remove Python cache files
alias pyshell='python -m code'                 # Start interactive Python shell
