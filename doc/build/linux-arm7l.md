# Raspberry Pi 2 (linux-arm7l)

Instructions to build neovim and treesitter parsers on an Ubuntu 24.04 (amd64) for Raspberry Pi 2 (arm7l):

***Note that the debroot environment is the same as for [linux-arm6l](build/linux-arm6l.md)***

```bash
sudo apt update
sudo apt install qemu-user-static binfmt-support debootstrap schroot
export RASPBIAN_MIRROR=http://archive.raspbian.org/raspbian/
export RASPBIAN_RELEASE=bookworm
export TARGET_DIR=/srv/chroot/raspbian-armhf
sudo debootstrap --foreign --arch=armhf --variant=minbase \
    --include=ca-certificates,apt-transport-https \
    $RASPBIAN_RELEASE $TARGET_DIR $RASPBIAN_MIRROR
sudo cp /usr/bin/qemu-arm-static $TARGET_DIR/usr/bin/
sudo chroot $TARGET_DIR /usr/bin/qemu-arm-static -cpu max /bin/bash

/debootstrap/debootstrap --second-stage
apt update
apt install build-essential cmake git ninja-build gettext unzip curl -y
#--------------------------------------------------------------------------------
export NVIM_VERSION="v0.10.4"
git clone --depth 1 --branch $NVIM_VERSION https://github.com/neovim/neovim.git /nvim-linux-arm7l
cd /nvim-linux-arm7l
make CMAKE_EXTRA_FLAGS="-DCMAKE_C_FLAGS='-march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard'" CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=$HOME/bin/nvim-linux-arm7l/ # re-run if 'Segmentation fault (core dumped)'
make install CMAKE_INSTALL_PREFIX=$HOME/bin/nvim-linux-arm7l/
#
# neovim treesitter will use cc to compile, but it is necessary to wrap it to force the architecture that we want (otherwise it is always armv7l)
mv /usr/bin/cc /usr/bin/cc.orig
cat << 'EOF' > /usr/bin/cc
#!/bin/bash
exec /usr/bin/cc.orig -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard "$@"
EOF
chmod 755 /usr/bin/cc
#
cd $HOME/bin/
ln -sf nvim-linux-arm7l/bin/nvim nvim
curl https://raw.githubusercontent.com/marblestation/neovim-complex-sensible/master/helper/install.sh -sSf | bash
mkdir -p $HOME/bin/nvim-linux-arm7l/share/nvim/nvim-treesitter/
cp -r $HOME/.local/share/nvim/site/nvim-treesitter/parser/  $HOME/bin/nvim-linux-arm7l/share/nvim/nvim-treesitter/parser/
cp -r $HOME/.local/share/nvim/site/nvim-treesitter/parser-info/  $HOME/bin/nvim-linux-arm7l/share/nvim/nvim-treesitter/parser-info/
tar -zcvf /nvim-linux-arm7l.tar.gz nvim-linux-arm7l/
#
rm -rf $HOME/.config/nvim/ $HOME/.local/share/nvim/ $HOME/bin/nvim
mv /usr/bin/cc.orig /usr/bin/cc
#--------------------------------------------------------------------------------
exit
cp $TARGET_DIR/nvim-linux-arm7l.tar.gz .
sudo rm -rf $TARGET_DIR
sudo apt remove --purge qemu-user-static binfmt-support debootstrap schroot
sudo apt autoremove --purge
```

