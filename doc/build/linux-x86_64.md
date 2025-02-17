# Intel/AMD64 (linux-x86_64)

Instructions to build neovim and treesitter parsers on an Ubuntu 24.04 (amd64) for Linux (amd64):

```bash
# Update package lists
sudo apt update

# Install required packages
sudo apt install debootstrap schroot -y

# Set variables for Ubuntu 24.04
export UBUNTU_MIRROR=http://archive.ubuntu.com/ubuntu
export UBUNTU_RELEASE=noble
export TARGET_DIR=/srv/chroot/ubuntu-amd64

# Bootstrap the minimal Ubuntu system
sudo debootstrap --arch=amd64 --variant=minbase \
    --include=ca-certificates \
    $UBUNTU_RELEASE $TARGET_DIR $UBUNTU_MIRROR

# Enter the chroot environment
sudo chroot $TARGET_DIR /bin/bash

# Inside chroot: Update package list
sed -i 's/^deb http:\/\/archive.ubuntu.com\/ubuntu noble main$/deb http:\/\/archive.ubuntu.com\/ubuntu noble main universe/' /etc/apt/sources.list
apt update

# Inside chroot: Install necessary build tools
apt install build-essential cmake git ninja-build gettext unzip curl -y

#--------------------------------------------------------------------------------
export NVIM_VERSION="v0.10.4"
git clone --depth 1 --branch $NVIM_VERSION https://github.com/neovim/neovim.git /nvim-linux-x86_64
cd /nvim-linux-x86_64
make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/bin/nvim-linux-x86_64/ # re-run if 'Segmentation fault (core dumped)'
make install CMAKE_INSTALL_PREFIX=$HOME/bin/nvim-linux-x86_64/
#
cd $HOME/bin/
ln -sf nvim-linux-x86_64/bin/nvim nvim
curl https://raw.githubusercontent.com/marblestation/neovim-complex-sensible/master/helper/install.sh -sSf | bash
mkdir -p $HOME/bin/nvim-linux-x86_64/share/nvim/nvim-treesitter/
cp -r $HOME/.local/share/nvim/site/nvim-treesitter/parser/  $HOME/bin/nvim-linux-x86_64/share/nvim/nvim-treesitter/parser/
cp -r $HOME/.local/share/nvim/site/nvim-treesitter/parser-info/  $HOME/bin/nvim-linux-x86_64/share/nvim/nvim-treesitter/parser-info/
tar -zcvf /nvim-linux-x86_64.tar.gz nvim-linux-x86_64/
#
rm -rf $HOME/.config/nvim/ $HOME/.local/share/nvim/ $HOME/bin/nvim
#
#--------------------------------------------------------------------------------
exit
cp $TARGET_DIR/nvim-linux-x86_64.tar.gz .
sudo rm -rf $TARGET_DIR
sudo apt remove --purge debootstrap schroot
sudo apt autoremove --purge
```


