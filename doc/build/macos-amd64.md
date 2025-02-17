- Apple Silicon (macos-amd64)

Instructions to build neovim and treesitter parsers for Mac on an Mac (macOS Sequoia 15.1.1):

```bash
# Install required tools via Homebrew
brew install cmake ninja gettext curl git

# Clone Neovim repository
export NVIM_VERSION="v0.10.4"
git clone --depth 1 --branch $NVIM_VERSION https://github.com/neovim/neovim.git $HOME/nvim-macos-arm64
cd $HOME/nvim-macos-arm64

# Build with appropriate flags for Apple Silicon
make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_EXTRA_FLAGS="-DCMAKE_OSX_ARCHITECTURES=arm64" CMAKE_INSTALL_PREFIX=$HOME/bin/nvim-macos-arm64/
make install CMAKE_INSTALL_PREFIX=$HOME/bin/nvim-macos-arm64/
#
cd $HOME/bin/
ln -sf nvim-macos-arm64/bin/nvim nvim
curl https://raw.githubusercontent.com/marblestation/neovim-complex-sensible/master/helper/install.sh -sSf | bash
mkdir -p $HOME/bin/nvim-macos-arm64/share/nvim/nvim-treesitter/
cp -r $HOME/.local/share/nvim/site/nvim-treesitter/parser/  $HOME/bin/nvim-macos-arm64/share/nvim/nvim-treesitter/parser/
cp -r $HOME/.local/share/nvim/site/nvim-treesitter/parser-info/  $HOME/bin/nvim-macos-arm64/share/nvim/nvim-treesitter/parser-info/
tar -zcvf $HOME/nvim-macos-arm64.tar.gz nvim-macos-arm64/
#
rm -rf $HOME/.config/nvim/ $HOME/.local/share/nvim/ $HOME/bin/nvim
rm -rf $HOME/nvim-macos-arm64/
```



