#!/bin/bash

# Define Neovim version
NVIM_VERSION="v0.10.4"

# Define installation and config directories
INSTALL_DIR="$HOME/bin"
NEOVIM_BIN="$INSTALL_DIR/nvim"
CONFIG_DIR="$HOME/.config/nvim"
DATA_DIR="$HOME/.local/share/nvim"
NEOVIM_SETUP_REPO="https://github.com/marblestation/neovim-complex-sensible"

LAZY_PATH="$HOME/.local/share/nvim/lazy/lazy.nvim"
LAZY_REPO="https://github.com/folke/lazy.nvim"
LAZY_VERSION="v11.17.1"

# Global variable to hold the Neovim command (system-wide or local)
NVIM_CMD=""

# Function to check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Function to get installed Neovim version
get_nvim_version() {
    local nvim_cmd="$1"
    if [[ -x "$nvim_cmd" ]]; then
        "$nvim_cmd" --version | head -n 1 | awk '{print $2}'
    fi
}

# Function to detect OS and architecture
detect_platform() {
    local os=""
    local arch=""

    case "$(uname -s)" in
        Linux*) os="linux" ;;
        Darwin*) os="macos" ;;
        *) echo "❌ Unsupported OS: $(uname -s)"; exit 1 ;;
    esac

    case "$(uname -m)" in
        x86_64) arch="x86_64" ;;
        aarch64|arm64) arch="arm64" ;;
        armv6l) arch="armv6l" ;;
        armv7l) arch="armv7l" ;;
        *) echo "❌ Unsupported architecture: $(uname -m)"; exit 1 ;;
    esac

    echo "$os-$arch"
}

# Function to download files using curl or wget
download_file() {
    local url="$1"
    local dest="$2"

    if command_exists "curl"; then
        curl -sL -o "$dest" "$url"
    elif command_exists "wget"; then
        wget -q -O "$dest" "$url"
    else
        echo "❌ Neither curl nor wget is installed. Cannot download files."
        exit 1
    fi
}

# Function to download and install Neovim
install_neovim() {
    local platform
    platform=$(detect_platform)

    case "$platform" in
        #linux-x86_64) URL="https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-x86_64.tar.gz" ;;
        #linux-arm64)  URL="https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-arm64.tar.gz" ;;
        macos-x86_64) URL="https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-macos-x86_64.tar.gz" ;;
        #macos-arm64)  URL="https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-macos-arm64.tar.gz" ;;
        linux-x86_64) URL="https://github.com/marblestation/neovim-complex-sensible/releases/download/$NVIM_VERSION/nvim-linux-x86_64.tar.gz" ;;
        linux-arm64)  URL="https://github.com/marblestation/neovim-complex-sensible/releases/download/$NVIM_VERSION/nvim-linux-arm64.tar.gz" ;;
        macos-arm64)  URL="https://github.com/marblestation/neovim-complex-sensible/releases/download/$NVIM_VERSION/nvim-macos-arm64.tar.gz" ;;
        linux-armv6l)  URL="https://github.com/marblestation/neovim-complex-sensible/releases/download/$NVIM_VERSION/nvim-linux-armv6l.tar.gz" ;;
        linux-armv7l)  URL="https://github.com/marblestation/neovim-complex-sensible/releases/download/$NVIM_VERSION/nvim-linux-armv7l.tar.gz" ;;
        *)
            echo "❌ No valid download URL for detected platform: $platform"
            echo -e "\n🔹 You can manually compile Neovim from source using the following commands:"
            echo "----------------------------------------------------------------------------------------------"
            echo "sudo apt-get install git cmake gettext ninja-build  # For Debian-based systems"
            echo "git clone --depth 1 --branch $NVIM_VERSION https://github.com/neovim/neovim.git"
            echo "cd neovim"
            echo "make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=\$HOME/bin/nvim-install/"
            echo "make install CMAKE_INSTALL_PREFIX=\$HOME/bin/nvim-install/"
            echo "ln -sf \$HOME/bin/nvim-install/bin/nvim \$HOME/bin/nvim"
            echo "----------------------------------------------------------------------------------------------"
            echo -e "\nThen, re-run this script."
            exit 1
            ;;
    esac

    echo "⬇️  Downloading Neovim $NVIM_VERSION for $platform..."
    
    mkdir -p "$INSTALL_DIR"
    
    PREVIOUS_DIR=$(pwd)
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR" || exit
    download_file "$URL" "nvim.tar.gz"
    tar xzf nvim.tar.gz

    mv nvim-* "$INSTALL_DIR/nvim-install"
    ln -sf "$INSTALL_DIR/nvim-install/bin/nvim" "$NEOVIM_BIN"

    echo "✅ Neovim $NVIM_VERSION installed successfully in $INSTALL_DIR"

    cd "${PREVIOUS_DIR}"
    rm -rf "$TMP_DIR"
}

# Function to check if $HOME/bin is in PATH
check_path() {
    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        echo -e "\n⚠️  $HOME/bin is not in your PATH."
        echo "To use Neovim easily, add the following line to your shell config file:"
        if [[ -f "$HOME/.bashrc" ]]; then
            echo "  echo 'export PATH=\"\$HOME/bin:\$PATH\"' >> ~/.bashrc && source ~/.bashrc"
        fi
        if [[ -f "$HOME/.bash_profile" ]]; then
            echo "  echo 'export PATH=\"\$HOME/bin:\$PATH\"' >> ~/.bash_profile && source ~/.bash_profile"
        fi
        if [[ -f "$HOME/.zshrc" ]]; then
            echo "  echo 'export PATH=\"\$HOME/bin:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"
        fi
        echo ""
    fi
}

# Function to check and suggest aliasing vi, vim, and vimdiff to nvim
check_aliases() {
    local alias_missing_in_bash=0
    local alias_missing_in_zsh=0

    # Check in interactive Bash
    if ! bash -i -c "alias" | grep -q "vi='nvim'"; then
        echo "⚠️  'vi' is not aliased to 'nvim' in Bash."
        alias_missing_in_bash=1
    fi

    if ! bash -i -c "alias" | grep -q "vim='nvim'"; then
        echo "⚠️  'vim' is not aliased to 'nvim' in Bash."
        alias_missing_in_bash=1
    fi

    if ! bash -i -c "alias" | grep -q "vimdiff='nvim -d'"; then
        echo "⚠️  'vimdiff' is not aliased to 'nvim -d' in Bash."
        alias_missing_in_bash=1
    fi

    # Check in interactive Zsh (if it exists, default in mac)
    if command_exists "zsh"; then
        if ! zsh -i -c "alias" | grep -q 'vi=nvim'; then
            echo "⚠️  'vi' is not aliased to 'nvim' in Zsh."
            alias_missing_in_zsh=1
        fi

        if ! zsh -i -c "alias" | grep -q 'vim=nvim'; then
            echo "⚠️  'vim' is not aliased to 'nvim' in Zsh."
            alias_missing_in_zsh=1
        fi

        if ! zsh -i -c "alias" | grep -q "vimdiff='nvim -d'"; then
            echo "⚠️  'vimdiff' is not aliased to 'nvim -d' in Zsh."
            alias_missing_in_zsh=1
        fi
    fi

    # Suggest fixes only if missing
    if [[ $alias_missing_in_bash -eq 1 || $alias_missing_in_zsh -eq 1 ]]; then
        echo -e "\n🔹 To make Neovim the default for 'vi', 'vim', and 'vimdiff', add this to your shell config:"
        
        if [[ $alias_missing_in_bash -eq 1 ]]; then
            echo "echo 'alias vi=\"nvim\"' >> ~/.bashrc && echo 'alias vim=\"nvim\"' >> ~/.bashrc && echo 'alias vimdiff=\"nvim -d\"' >> ~/.bashrc && source ~/.bashrc"
        fi

        if [[ $alias_missing_in_zsh -eq 1 ]]; then
            echo "echo 'alias vi=\"nvim\"' >> ~/.zshrc && echo 'alias vim=\"nvim\"' >> ~/.zshrc && echo 'alias vimdiff=\"nvim -d\"' >> ~/.zshrc && source ~/.zshrc"
        fi
    else
        echo "✅ All aliases are correctly set in Bash and Zsh."
    fi
}

# Function to install Neovim config files
install_config() {
    if [ -d "$CONFIG_DIR" ] || [ -d "$DATA_DIR" ]; then
        echo "⚠️  A Neovim configuration already exists!"
        echo "To remove it and install a fresh config, run:"
        echo "rm -rf $CONFIG_DIR $DATA_DIR"
        exit 1
    fi

    echo "📁 Installing Neovim configuration..."
    mkdir -p "$CONFIG_DIR" "$DATA_DIR"
    
    git clone "${NEOVIM_SETUP_REPO}.git" "$CONFIG_DIR"

    echo "✅ Neovim configuration installed successfully."
}

# Function to install plugins and spellchecker files
install_plugins_and_spellchecker() {
    # Check if Lazy.nvim is installed; if not, clone it since it will be needed
    # to download the rest of the plugins
    if [ ! -d "$LAZY_PATH" ]; then
        echo "⬇️  Installing Lazy.nvim..."
        mkdir -p "$(dirname "$LAZY_PATH")"
        if command_exists "git"; then
            git clone "${LAZY_REPO}.git" "$LAZY_PATH"
            cd "$LAZY_PATH"
            git checkout "tags/${LAZY_VERSION}"
        else
            echo "❌ Error: Git is not available. Cannot install Lazy.nvim."
            exit 1
        fi

    else
        echo "✅ Lazy.nvim is already installed."
    fi

    if [ -d "$INSTALL_DIR/nvim-install/share/nvim/nvim-treesitter/parser/" ]; then
        # Particularly useful for Raspberry Pi, where compilation can freeze the system
        echo "🔄 Copying compiled Neovim treesitter parsers..."
        mkdir -p "$DATA_DIR/site/nvim-treesitter/"
        cp -r "$INSTALL_DIR/nvim-install/share/nvim/nvim-treesitter/parser/" "$DATA_DIR/site/nvim-treesitter/parser/"
        if [ -d "$INSTALL_DIR/nvim-install/share/nvim/nvim-treesitter/parser-info/" ]; then
            cp -r "$INSTALL_DIR/nvim-install/share/nvim/nvim-treesitter/parser-info/" "$DATA_DIR/site/nvim-treesitter/parser-info/"
        fi
    fi

    echo "🔄 Installing Neovim plugins..."
    "$NVIM_CMD" --headless +"Lazy! install" +"lua DownloadSpellFiles()" +qall
    echo "✅ Plugins and spellchecker files installed."
}

### MAIN EXECUTION LOGIC


# Priority: If local nvim exists, use it. Otherwise, use the system-wide command if available.
if [[ -x "$NEOVIM_BIN" ]]; then
    NVIM_CMD="$NEOVIM_BIN"
elif command_exists nvim; then
    NVIM_CMD=$(command -v nvim)
fi


if [[ -n "$NVIM_CMD" ]]; then
    INSTALLED_VERSION=$(get_nvim_version "$NVIM_CMD")
    if [[ "$INSTALLED_VERSION" != "$NVIM_VERSION" ]]; then
        # If the chosen nvim is the local one, then warn the user.
        if [[ "$NVIM_CMD" == "$NEOVIM_BIN" ]]; then
            echo "❌ Neovim found at $NVIM_CMD (local) with version $INSTALLED_VERSION, which does not match required version $NVIM_VERSION."
            echo "🛑 Please remove the local Neovim installation with:"
            echo "rm -rf $NEOVIM_BIN $INSTALL_DIR/nvim-install/"
            exit 1
        else
            # Otherwise, NVIM_CMD is system-wide. Reinstall Neovim to install the correct version locally.
            echo "⚠️  Neovim found at $NVIM_CMD (system-wide) with version $INSTALLED_VERSION, which does not match required version $NVIM_VERSION."
            echo "🚀 Reinstalling Neovim..."
            install_neovim
            NVIM_CMD="$NEOVIM_BIN"
        fi
    else
        echo "✅ Neovim is installed at $NVIM_CMD with the correct version ($NVIM_VERSION)."
    fi
else
    echo "🚀 Neovim not found. Installing..."
    install_neovim
    NVIM_CMD="$NEOVIM_BIN"
fi

# Install Neovim configuration
install_config

# Install plugins and spellchecker files using the chosen Neovim command
install_plugins_and_spellchecker

# Ensure $HOME/bin is in the PATH
if [[ "$NVIM_CMD" == "$NEOVIM_BIN" ]]; then
    check_path
fi

# Check if vi, vim, and vimdiff are aliased to nvim
check_aliases

