# ~/.bashrc.d/go.bash

# export Golang env
export GOROOT=/usr/local/go
export PATH=$GOROOT/bin:$PATH

# Go basics
alias gover='go version'                        # Show Go version
alias gopath='echo $GOPATH'                     # Show Go workspace path
alias gobin='echo $GOBIN'                       # Show Go binary path
alias gore='go run'                             # Run Go code
alias gob='go build'                            # Build Go project
alias got='go test ./...'                       # Run all tests
alias gobench='go test -bench=.'                # Run benchmarks

# Go project management
goinit() {
    if [ -z "$1" ]; then
        echo "Usage: goinit <project_name>"
        return 1
    fi
    mkdir -p "$1" && cd "$1" && go mod init "$1"
    echo "Initialized Go module in '$1'."
}

gocd() {
    if [ -z "$1" ]; then
        echo "Usage: gocd <project_name>"
        return 1
    fi
    cd "$GOPATH/src/$1" && echo "Switched to Go project '$1'."
}

# Go module management
alias gomod='go mod tidy'                        # Clean up module dependencies
alias goup='go get -u ./...'                    # Update all dependencies
alias golist='go list -m all'                    # List all modules

# Go build & run
alias gorebuild='go clean && go build'           # Clean and rebuild project
alias goclean='go clean -cache'                  # Clear build cache
alias gorunmain='go run main.go'                 # Run main.go
alias goinstall='go install'                     # Install Go binary

# Go formatting & linting
alias gofmt='gofmt -w .'                         # Format Go code
alias govet='go vet ./...'                       # Static code analysis
alias golint='golangci-lint run'                 # Run Go linter (requires golangci-lint)

# Miscellaneous
alias godo='godoc -http=:6060'                   # Serve Go documentation locally
alias goenv='go env'                             # Show Go environment variables
alias godl='go mod download'                     # Download dependencies
