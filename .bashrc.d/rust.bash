# ~/.bash/rust.bash

# export Rust env
export CARGO_HOME="$HOME/.cargo"
export PATH=~/.cargo/bin:$PATH

# Rust and Cargo aliases
alias rustc='rustc --edition 2021'             # Use Rust 2021 edition by default
alias cargo='cargo --color always'             # Always show colored output
alias c='cargo'                                # Short alias for cargo
alias cr='cargo run'                           # Build and run the project
alias cb='cargo build'                         # Compile the project
alias cbr='cargo build --release'              # Compile in release mode
alias ct='cargo test'                          # Run tests
alias cta='cargo test --all'                   # Run all tests
alias cf='cargo fmt'                           # Format the code
alias ccl='cargo clippy'                       # Run Clippy (linter)
alias cdoc='cargo doc --open'                  # Generate and open documentation
alias cci='cargo check'                        # Check for compilation errors
alias ccu='cargo clean'                        # Clean up the target directory
alias cup='cargo update'                       # Update dependencies
alias cinit='cargo init'                       # Initialize a new Rust project
alias cnew='cargo new'                         # Create a new Rust project
alias crun='cargo run --release'               # Run project in release mode
alias cbench='cargo bench'                     # Run benchmarks
alias cadd='cargo add'                         # Add a dependency
alias crem='cargo remove'                      # Remove a dependency
alias cset='cargo set-version'                 # Change package version
alias ctree='cargo tree'                       # Show dependency tree
alias cwatch='cargo watch -x run'              # Automatically recompile on change

# Rustup aliases
alias rustupup='rustup update'                 # Update Rust toolchain
alias rustv='rustc --version'                  # Show Rust version
alias cargov='cargo --version'                 # Show Cargo version
alias rusttool='rustup show'                   # Show active toolchain
alias rustdef='rustup default stable'          # Set Rust stable as default
alias rustnightly='rustup default nightly'     # Set Rust nightly as default
alias rustfmt='rustup component add rustfmt'   # Install Rust formatter
alias clippy='rustup component add clippy'     # Install Clippy linter
