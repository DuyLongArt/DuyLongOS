# shell.nix - Quick fix for libcc issues in web development

# Use this file to enter a development environment that fixes library linking problems

# Usage: nix-shell (in directory with this file)

{ config, pkgs ? import <nixpkgs> {},.. }:
# /etc/nixos/configuration.
services.desktopManager.plasma6.enable=true;
virtualisation.docker.enable = true;

  users.extraGroups.docker.members = [ docker ];

  # This allows you to use the modern 'docker compose' command
  virtualisation.docker.enableNixOSBuilds = true;


pkgs.mkShell {
name = “webdev-libcc-fix”;

# Core development packages with proper library linking

buildInputs = with pkgs; [
# Essential C/C++ toolchain - fixes most libcc issues
stdenv.cc.cc.lib
stdenv.cc.cc
glibc
glibc.dev
glibc.static
libgcc
binutils
gcc
gnumake
pkg-config

```
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

# Font libraries (sometimes needed for web apps)
fontconfig
freetype

# SSL/TLS support
cacert
```

];

# Environment variables to fix library linking issues

shellHook = ‘’
echo “🔧 NixOS Web Development Environment with LibCC Fixes”
echo “==================================================”

```
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
]}:$LD_LIBRARY_PATH"

# Compiler and linker flags
export CPPFLAGS="-I${pkgs.glibc.dev}/include -I${pkgs.zlib.dev}/include -I${pkgs.openssl.dev}/include"
export LDFLAGS="-L${pkgs.glibc}/lib -L${pkgs.stdenv.cc.cc.lib}/lib -L${pkgs.zlib}/lib -L${pkgs.openssl.out}/lib"

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
export NODE_PATH="${pkgs.nodejs_20}/lib/node_modules"
export NODE_OPTIONS="--max-old-space-size=4096"

# Python environment
export PYTHONPATH="$PWD:$PYTHONPATH"
export PIP_PREFIX=$PWD/.pip-packages
export PYTHON_PATH=$PIP_PREFIX/lib/python3.11/site-packages:$PYTHONPATH
export PATH=$PIP_PREFIX/bin:$PATH
mkdir -p .pip-packages

# Rust environment (if using Rust)
export RUST_SRC_PATH="${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}"

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
  sudo chown -R $USER:$USER ~/.npm
  sudo chown -R $USER:$USER ~/.config
  echo "✅ NPM and config permissions fixed"
}

function test-build() {
  echo "Testing C compilation..."
  echo '#include <stdio.h>
```

int main() { printf(“Hello from C!\n”); return 0; }’ > test.c
gcc test.c -o test && ./test && rm test test.c

```
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
  echo "  test-build          - Test build environment"
  echo "  check-libs          - Show library paths"
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
  export PATH="$HOME/.cargo/bin:$PATH"
fi

echo ""
echo "🎯 Quick Start:"
echo "  Run 'check-env' to see available tools and commands"
echo "  Run 'test-build' to verify everything is working"
echo ""
echo "🔧 If you still get libcc errors:"
echo "  1. Run 'check-libs' to see library paths"
echo "  2. Try 'fix-permissions' for NPM issues"
echo "  3. Use 'nix-shell --pure' for isolated environment"
echo ""
echo "Happy coding! 🚀"
```

‘’;

# Additional environment variables for specific use cases

LOCALE_ARCHIVE = “${pkgs.glibcLocales}/lib/locale/locale-archive”;
FONTCONFIG_FILE = “${pkgs.fontconfig.out}/etc/fonts/fonts.conf”;

# Enable some useful features

hardeningDisable = [ “all” ];  # Disable hardening for development
}
