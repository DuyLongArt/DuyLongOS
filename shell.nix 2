# shell.nix - Quick fix for libcc issues in web development
# Usage: nix-shell (in directory with this file)

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "webdev-libcc-fix";

  # Core development packages with proper library linking
  buildInputs = with pkgs; [
    # Essential C/C++ toolchain - fixes most libcc issues
    stdenv.cc.cc.lib
    stdenv.cc.cc
    glibc
    glibc.dev
    libgcc
    binutils
    gcc
    gnumake
    pkg-config

    # Core development libraries
    zlib
    zlib.dev
    openssl
    openssl.dev
    libffi
    libffi.dev
    ncurses
    ncurses.dev
    readline
    readline.dev
    sqlite
    sqlite.dev

    # Web development languages and tools
    nodejs_22
    nodePackages.npm
    nodePackages.yarn
    nodePackages.pnpm
    nodePackages.typescript
    nodePackages.ts-node
    nodePackages.nodemon
    nodePackages.eslint
    nodePackages.prettier
    
    # Python development
    python3
    python3Packages.pip
    python3Packages.setuptools
    python3Packages.wheel
    python3Packages.virtualenv
    python3Packages.pipenv

    # Build tools
    cmake
    autoconf
    automake
    libtool

    # Version control and utilities
    git
    curl
    wget
    jq
    tree
    vim

    # Additional libraries commonly needed
    libxml2
    libxml2.dev
    libxslt
    libxslt.dev
    libjpeg
    libpng
    cacert

    # Font libraries
    fontconfig
    freetype

    # For Rust/Cargo support (optional)
    rustPlatform.rustLibSrc # Use rustPlatform for source
  ];

  # Environment variables to fix library linking issues
  shellHook = ''
    echo "🔧 NixOS Web Development Environment with LibCC Fixes"
    echo "=================================================="

    # Create the directory for local Python packages
    mkdir -p .pip-packages

    # Fix library paths - this is the main solution for libcc errors
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
      pkgs.stdenv.cc.cc.lib
      pkgs.glibc
      pkgs.zlib
      pkgs.openssl
      pkgs.libffi
      pkgs.ncurses
      pkgs.readline
      pkgs.sqlite
      pkgs.libxml2
      pkgs.libxslt
      # Add buildInputs here if they contain dynamic libraries needed at runtime
    ]}:$LD_LIBRARY_PATH"

    # Compiler and linker flags
    export CPPFLAGS="-I${pkgs.glibc.dev}/include -I${pkgs.zlib.dev}/include -I${pkgs.openssl.dev}/include $CPPFLAGS"
    export LDFLAGS="-L${pkgs.glibc}/lib -L${pkgs.stdenv.cc.cc.lib}/lib -L${pkgs.zlib}/lib -L${pkgs.openssl.out}/lib $LDFLAGS"

    # Package config paths
    export PKG_CONFIG_PATH="${pkgs.lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
      pkgs.openssl
      pkgs.zlib
      pkgs.libffi
      pkgs.sqlite
      pkgs.libxml2
      pkgs.libxslt
    ]}:$PKG_CONFIG_PATH"

    # SSL certificates
    export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    export NIX_SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"

    # Development environment variables
    export EDITOR="code"
    export BROWSER="firefox"
    # IMPORTANT: The nodejs_20 below should be consistent with the version in buildInputs, which is 22.
    export NODE_PATH="${pkgs.nodejs_22}/lib/node_modules" 
    export NODE_OPTIONS="--max-old-space-size=4096"

    # Python environment
    export PYTHONPATH="$PWD:$PYTHONPATH"
    export PIP_PREFIX=$PWD/.pip-packages
    # IMPORTANT: The python3.11 below should be checked against the default python3 version in nixpkgs
    export PYTHON_PATH=$PIP_PREFIX/lib/$(basename ${pkgs.python3.interpreter})/site-packages:$PYTHONPATH
    export PATH=$PIP_PREFIX/bin:$PATH

    # Rust environment (if using Rust)
    export RUST_SRC_PATH="${pkgs.rustPlatform.rustLibSrc}"

    # Helpful aliases
    alias ll='ls -la'
    alias la='ls -la'
    alias serve='python3 -m http.server 8000'
    alias npmg='npm list -g --depth=0'
    alias fix-node='rm -rf node_modules package-lock.json && npm install'
    alias check-libs='echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"'

    # Functions for common tasks
    function create-react() {
      npx create-react-app "$1" --template typescript
      cd "$1"
      echo "✅ React TypeScript project created: $1"
    }

    function create-vue() {
      npm create vue@latest "$1"
      cd "$1"
      npm install
      echo "✅ Vue project created: $1"
    }

    function create-next() {
      npx create-next-app@latest "$1" --typescript --tailwind --eslint
      cd "$1"
      echo "✅ Next.js project created: $1"
    }

    function setup-python() {
      python3 -m venv venv
      source venv/bin/activate
      pip install --upgrade pip
      echo "✅ Python virtual environment created and activated"
    }

    function fix-permissions() {
      # This is generally not needed in NixOS/nix-shell but kept for cross-platform/legacy use
      # Remove if you encounter errors, as sudo is not always available/desired.
      sudo chown -R $USER:$USER ~/.npm
      sudo chown -R $USER:$USER ~/.config
      echo "✅ NPM and config permissions fixed"
    }

    function test-build() {
      echo "Testing C compilation..."
      # Use single quotes to prevent shell variable expansion in the string
      echo '#include <stdio.h>
int main() { printf("Hello from C!\n"); return 0; }' > test.c
      gcc test.c -o test && ./test && rm test test.c

      echo "Testing Node.js..."
      node --version
      
      echo "Testing Python..."
      python3 --version
      
      echo "✅ Build environment test completed"
    }

    # Check for common issues and provide fixes
    function check-env() {
      echo "🔍 Environment Check:"
      echo "Node.js: $(node --version 2>/dev/null || echo 'Not found')"
      echo "NPM: $(npm --version 2>/dev/null || echo 'Not found')"
      echo "Python: $(python3 --version 2>/dev/null || echo 'Not found')"
      echo "GCC: $(gcc --version 2>/dev/null | head -1 || echo 'Not found')"
      echo "Git: $(git --version 2>/dev/null || echo 'Not found')"
      echo ""
      echo "Library Path: $LD_LIBRARY_PATH"
      echo ""
      echo "💡 Available commands:"
      echo "  create-react <name>  - Create React TypeScript project"
      echo "  create-vue <name>    - Create Vue project"
      echo "  create-next <name>   - Create Next.js project"
      echo "  setup-python         - Create Python virtual environment"
      echo "  fix-permissions      - Fix NPM permissions"
      echo "  test-build           - Test build environment"
      echo "  check-libs           - Show library paths"
    }

    # Auto-detect and setup project environment
    if [ -f "package.json" ]; then
      echo "📦 Node.js project detected"
      if [ ! -d "node_modules" ]; then
        echo "Installing dependencies..."
        npm install
      fi
    elif [ -f "requirements.txt" ]; then
      echo "🐍 Python project detected"
      if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        setup-python
      else
        source venv/bin/activate
      fi
    elif [ -f "Cargo.toml" ]; then
      echo "🦀 Rust project detected"
      # Rust is added to buildInputs, so the path should be available.
      # If you need a specific path, you'd export it here.
    fi

    echo ""
    echo "🎯 Quick Start:"
    echo "  Run 'check-env' to see available tools and commands"
    echo "  Run 'test-build' to verify everything is working"
    echo ""
    echo "🔧 If you still get libcc errors:"
    echo "  1. Run 'check-libs' to see library paths"
    echo "  2. Try 'fix-permissions' for NPM issues (Use with caution)"
    echo "  3. Use 'nix-shell --pure' for isolated environment"
    echo ""
    echo "Happy coding! 🚀"
  '';

  # Additional environment variables for specific use cases
  # These are applied outside of the shellHook, often better practice for environment variables
  LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  FONTCONFIG_FILE = "${pkgs.fontconfig.out}/etc/fonts/fonts.conf";

  # Disable hardening for development (use with caution)
  hardeningDisable = [ "all" ]; 
}
