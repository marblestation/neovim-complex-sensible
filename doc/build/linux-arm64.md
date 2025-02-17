# ARM64/AARCH64 (linux-x86_64)

Instructions to build neovim and treesitter parsers on an Ubuntu 24.04 (amd64) for Linux (arm64, common for docker images running on Apple Silicon/Mac):

```bash
# Update package lists
sudo apt update

# Install required packages
sudo apt install qemu-user-static binfmt-support debootstrap schroot

export DEBIAN_MIRROR=http://deb.debian.org/debian/
export DEBIAN_RELEASE=bookworm
export TARGET_DIR=/srv/chroot/debian-arm64

sudo debootstrap --foreign --arch=arm64 --variant=minbase \
    --include=ca-certificates,apt-transport-https \
    $DEBIAN_RELEASE $TARGET_DIR $DEBIAN_MIRROR

# Enter the chroot environment
sudo cp /usr/bin/qemu-arm64-static $TARGET_DIR/usr/bin/
sudo chroot $TARGET_DIR /usr/bin/qemu-arm64-static /bin/bash
/debootstrap/debootstrap --second-stage

# Inside chroot: Update package list
apt update

# Inside chroot: Install necessary build tools
apt install build-essential cmake git ninja-build gettext unzip curl -y

# Inside the chroot
apt install ntpdate -y
ntpdate pool.ntp.org

#--------------------------------------------------------------------------------
export NVIM_VERSION="v0.10.4"
git clone --depth 1 --branch $NVIM_VERSION https://github.com/neovim/neovim.git /nvim-linux-arm64
cd /nvim-linux-arm64
make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/bin/nvim-linux-arm64/ # re-run if 'Segmentation fault (core dumped)'
make install CMAKE_INSTALL_PREFIX=$HOME/bin/nvim-linux-arm64/
#
cd $HOME/bin/
ln -sf nvim-linux-arm64/bin/nvim nvim
curl https://raw.githubusercontent.com/marblestation/neovim-complex-sensible/master/helper/install.sh -sSf | bash
mkdir -p $HOME/bin/nvim-linux-arm64/share/nvim/nvim-treesitter/
cp -r $HOME/.local/share/nvim/site/nvim-treesitter/parser/  $HOME/bin/nvim-linux-arm64/share/nvim/nvim-treesitter/parser/
cp -r $HOME/.local/share/nvim/site/nvim-treesitter/parser-info/  $HOME/bin/nvim-linux-arm64/share/nvim/nvim-treesitter/parser-info/
tar -zcvf /nvim-linux-arm64.tar.gz nvim-linux-arm64/
#
rm -rf $HOME/.config/nvim/ $HOME/.local/share/nvim/ $HOME/bin/nvim
#
#--------------------------------------------------------------------------------
exit
cp $TARGET_DIR/nvim-linux-arm64.tar.gz .
sudo rm -rf $TARGET_DIR
sudo apt remove --purge debootstrap schroot
sudo apt autoremove --purge
```


