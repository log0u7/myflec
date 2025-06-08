# ~/.bashrc.d/nodejs.bash

export NODE_ENV="development"
export NODE_OPTIONS="--max-old-space-size=4096"
export NPM_CONFIG_PREFIX="$HOME/.npm-global"

setup_tool_path "NPM_CONFIG_PREFIX" "$HOME/.npm-global" "/bin"
setup_tool_path "PNPM_HOME" "$HOME/.local/share/pnpm"

# NVM (Node Version Manager) Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Basic aliases
alias node='node'
alias npm='npm'
alias npx='npx'
alias yarn='yarn'
alias pnpm='pnpm'

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

# Create a new Node.js project
function node-init() {
    local project_name=${1:-"my-node-project"}
    local template=${2:-"basic"}
    
    echo "🚀 Creating Node.js project: $project_name"
    mkdir -p "$project_name"
    cd "$project_name"
    
    case $template in
        "express")
            npm init -y
            npm install express
            npm install --save-dev nodemon
            echo "const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.json({ message: 'Hello World!' });
});

app.listen(PORT, () => {
    console.log(\`Server running on port \${PORT}\`);
});" > index.js
            ;;
        "typescript")
            npm init -y
            npm install --save-dev typescript @types/node ts-node nodemon
            npx tsc --init
            mkdir src
            echo "console.log('Hello TypeScript!');" > src/index.ts
            ;;
        *)
            npm init -y
            echo "console.log('Hello Node.js!');" > index.js
            ;;
    esac
    
    echo "✅ Project $project_name created with $template template"
}

# Clean node modules and reinstall
function node-clean() {
    echo "🧹 Cleaning node_modules and lock files..."
    rm -rf node_modules package-lock.json yarn.lock pnpm-lock.yaml
    if [ -f "package.json" ]; then
        echo "📦 Reinstalling dependencies..."
        npm install
        echo "✅ Cleanup completed"
    else
        echo "❌ No package.json found"
    fi
}

# Display available scripts
function node-scripts() {
    if [ -f "package.json" ]; then
        echo "📜 Available scripts:"
        cat package.json | grep -A 20 '"scripts"' | grep -E '    ".*":' | sed 's/.*"\(.*\)".*/  \1/' | sort
    else
        echo "❌ No package.json found"
    fi
}

# Check vulnerabilities and fix them
function node-audit() {
    echo "🔍 Checking for vulnerabilities..."
    npm audit
    echo ""
    read -p "Do you want to automatically fix vulnerabilities? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        npm audit fix
        echo "✅ Fix completed"
    fi
}

# Search NPM packages
function npm-search() {
    if [ -z "$1" ]; then
        echo "Usage: npm-search <package-name>"
        return 1
    fi
    echo "🔍 Searching packages for: $1"
    npm search "$1" | head -20
}

# View package information
function npm-info() {
    if [ -z "$1" ]; then
        echo "Usage: npm-info <package-name>"
        return 1
    fi
    npm info "$1"
}

# List installed global packages
function npm-globals() {
    echo "🌍 Installed global packages:"
    npm list -g --depth=0
}

# Update all global packages
function npm-update-globals() {
    echo "⬆️  Updating global packages..."
    npm update -g
    echo "✅ Update completed"
}

# Switch Node version with NVM
function node-use() {
    if [ -z "$1" ]; then
        echo "Available Node.js versions:"
        nvm list
        return 1
    fi
    nvm use "$1"
}

# Install and use a Node version
function node-install() {
    if [ -z "$1" ]; then
        echo "Usage: node-install <version>"
        echo "Example: node-install 18.17.0"
        return 1
    fi
    nvm install "$1"
    nvm use "$1"
}

# Analyze bundle size
function node-analyze() {
    if command -v npx &> /dev/null; then
        echo "📊 Analyzing bundle size..."
        npx bundle-analyzer
    else
        echo "❌ npx not available"
    fi
}

# Generate .gitignore for Node.js
function node-gitignore() {
    echo "# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# Build files
dist/
build/
out/

# Environment files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
logs
*.log

# Temporary files
.tmp/
.cache/

# Coverage
coverage/
.nyc_output/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Others
.eslintcache" > .gitignore
    echo "✅ .gitignore created for Node.js"
}

# Display dependency tree
function node-tree() {
    local depth=${1:-2}
    echo "🌳 Dependency tree (depth: $depth):"
    npm list --depth="$depth"
}

# Check outdated packages
function node-outdated() {
    echo "📅 Outdated packages:"
    npm outdated
    echo ""
    echo "💡 Use 'npm update' to update packages"
}

# Bash completions for NPM
if command -v npm &> /dev/null; then
    eval "$(npm completion bash 2>/dev/null)"
fi

# Display Node.js version on startup (optional)
function show-node-info() {
    if command -v node &> /dev/null; then
        echo "🟢 Node.js $(node --version) | NPM $(npm --version)"
        if command -v nvm &> /dev/null; then
            echo "📍 NVM: $(nvm current)"
        fi
    fi
}

# Uncomment the following line to display Node.js info on startup
# show-node-info

# Custom prompt with Node.js info (optional)
function node_prompt() {
    if [ -f "package.json" ]; then
        local node_version=""
        if command -v node &> /dev/null; then
            node_version="⚡$(node --version)"
        fi
        echo " $node_version"
    fi
}

# Uncomment and adapt these lines for a custom prompt
# export PS1='\u@\h:\w$(node_prompt)\$ '

echo "✅ Node.js configuration loaded for .bashrc"
