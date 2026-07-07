# ~/.bashrc.d/nodejs.bash

export NODE_OPTIONS="--max-old-space-size=4096"

setup_tool_path "NPM_CONFIG_PREFIX" "$HOME/.npm-global" "/bin"
[ -d "$HOME/.local/share/pnpm" ] && setup_tool_path "PNPM_HOME" "$HOME/.local/share/pnpm"

# NPM shortcuts
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nu='npm uninstall'
alias nud='npm uninstall --save-dev'
alias nug='npm uninstall -g'
alias nr='npm run'
alias ns='npm start'
alias nt='npm test'
alias nb='npm run build'
alias nd='npm run dev'
alias nl='npm list'
alias no='npm outdated'
alias nup='npm update'
alias nci='npm ci'
alias ncl='npm cache clean --force'

# package.json aliases
alias pkg='cat package.json'
alias pkgl='cat package-lock.json'

# Yarn aliases
alias yi='yarn install'
alias ya='yarn add'
alias yad='yarn add --dev'
alias yr='yarn remove'
alias yrun='yarn run'
alias ys='yarn start'
alias yt='yarn test'
alias yb='yarn build'
alias yd='yarn dev'
alias yo='yarn outdated'
alias yup='yarn upgrade'
# pnpm aliases
alias pi='pnpm install'
alias pa='pnpm add'
alias pad='pnpm add --save-dev'
alias pr='pnpm remove'
alias prun='pnpm run'
alias ps='pnpm start'
alias pt='pnpm test'
alias pb='pnpm build'
alias pd='pnpm dev'

# Clean node modules and reinstall
node-clean() {
    echo "Cleaning node_modules and lock files..."
    rm -rf node_modules package-lock.json yarn.lock pnpm-lock.yaml
    if [ -f "package.json" ]; then
        echo "Reinstalling dependencies..."
        npm install
        echo "Cleanup completed"
    else
        echo "No package.json found"
    fi
}



# NVM (Node Version Manager) - fallback when mise is not available
if ! command -v mise >/dev/null 2>&1; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    # Switch Node version with NVM
    node-use() {
        if [ -z "$1" ]; then
            nvm list
            return 1
        fi
        nvm use "$1"
    }

    # Install and use a Node version
    node-install() {
        if [ -z "$1" ]; then
            echo "Usage: node-install <version>"
            echo "Example: node-install 18.17.0"
            return 1
        fi
        nvm install "$1"
        nvm use "$1"
    }
fi

# Bash completions for NPM (only if mise not managing it)
if command -v npm >/dev/null 2>&1; then
    eval "$(npm completion bash 2>/dev/null)"
fi
