#!/bin/bash
set -e

CHROOT_DIR="/rebootstrap/riscv32-chroot"
REPO_DIR="file:///rebootstrap/tmp_repo"

echo "======================================================"
echo "  RISC-V 32 Bootstrap -  Chroot Assembly"
echo "======================================================"

if [ -d "$CHROOT_DIR" ]; then
    echo "--> Found existing chroot directory, cleaning up..."
    if mountpoint -q "$CHROOT_DIR/rebootstrap/tmp_repo"; then
        echo "    Unmounting local repository..."
        umount "$CHROOT_DIR/rebootstrap/tmp_repo"
    fi
    umount "$CHROOT_DIR/proc" >/dev/null 2>&1 || true
    umount "$CHROOT_DIR/sys" >/dev/null 2>&1 || true
    umount "$CHROOT_DIR/dev/pts" >/dev/null 2>&1 || true
    umount "$CHROOT_DIR/dev" >/dev/null 2>&1 || true
    echo "    All mountpoints unmounted. Removing old chroot directory..."
    rm -rf "$CHROOT_DIR"
fi

# 1. create chroot folder
echo "--> Creating new chroot directory: $CHROOT_DIR"
mkdir -p "$CHROOT_DIR"

# 2. create debootstrap script link
echo "--> Creating debootstrap script symlink for 'rebootstrap' codename..."
ln -sf /usr/share/debootstrap/scripts/trixie /usr/share/debootstrap/scripts/rebootstrap

# 3. run debootstrap stage1 (using local repo)
echo "--> Running debootstrap first stage (unpacking)..."
debootstrap --foreign --arch=riscv32 --no-check-gpg \
   rebootstrap "$CHROOT_DIR" "$REPO_DIR"
# copy qemu static to chroot
cp /usr/bin/qemu-riscv32-static ./riscv32-chroot/usr/bin/
# 4. mount virtual filesystems
echo "--> Mounting virtual filesystems for chroot..."
mount -t proc proc "$CHROOT_DIR/proc"
mount -t sysfs sys "$CHROOT_DIR/sys"
mount -o bind /dev "$CHROOT_DIR/dev"
mount -o bind /dev/pts "$CHROOT_DIR/dev/pts"
# copy local repo to chroot
cp -a /rebootstrap/tmp_repo "$CHROOT_DIR/rebootstrap/"

# 5. install essential packages manually to avoid dependency issues
# chroot "$CHROOT_DIR" /bin/sh -c 'dpkg --unpack /var/cache/apt/archives/libc6*_riscv32.deb'
# chroot "$CHROOT_DIR" /usr/bin/dpkg --configure libc6
# chroot "$CHROOT_DIR" /bin/sh -c 'dpkg --unpack /var/cache/apt/archives/libbz2*_riscv32.deb'
# chroot "$CHROOT_DIR" /usr/bin/dpkg --configure libbz2-1.0
# chroot "$CHROOT_DIR" /bin/sh -c 'dpkg --unpack /var/cache/apt/archives/liblzma5*_riscv32.deb'
# chroot "$CHROOT_DIR" /usr/bin/dpkg --configure liblzma5
# chroot "$CHROOT_DIR" /bin/sh -c 'dpkg --unpack /var/cache/apt/archives/libmd0*_riscv32.deb'
# chroot "$CHROOT_DIR" /usr/bin/dpkg --configure libmd0
# chroot "$CHROOT_DIR" /bin/sh -c 'dpkg --unpack /var/cache/apt/archives/libpcre2-8-0*_riscv32.deb'
# chroot "$CHROOT_DIR" /usr/bin/dpkg --configure libpcre2-8-0
# chroot "$CHROOT_DIR" /bin/sh -c 'dpkg --unpack /var/cache/apt/archives/libselinux1*_riscv32.deb'
# chroot "$CHROOT_DIR" /usr/bin/dpkg --configure libselinux1
# chroot "$CHROOT_DIR" /bin/sh -c 'dpkg --unpack /var/cache/apt/archives/libzstd1*_riscv32.deb'
# chroot "$CHROOT_DIR" /usr/bin/dpkg --configure libzstd1
# chroot "$CHROOT_DIR" /bin/sh -c 'dpkg --unpack /var/cache/apt/archives/zlib1g*_riscv32.deb'
# chroot "$CHROOT_DIR" /usr/bin/dpkg --configure zlib1g
# chroot "$CHROOT_DIR" /bin/sh -c 'dpkg --unpack /var/cache/apt/archives/libacl1*_riscv32.deb'
# chroot "$CHROOT_DIR" /usr/bin/dpkg --configure libacl1
# chroot "$CHROOT_DIR" /bin/sh -c 'dpkg --unpack /var/cache/apt/archives/tar*_riscv32.deb'
# chroot "$CHROOT_DIR" /usr/bin/dpkg --configure tar
# chroot "$CHROOT_DIR" /bin/sh -c 'dpkg --unpack /var/cache/apt/archives/libdebconfclient0*_riscv32.deb'
# chroot "$CHROOT_DIR" /usr/bin/dpkg --configure libdebconfclient0
# chroot "$CHROOT_DIR" /bin/sh -c 'dpkg --unpack /var/cache/apt/archives/mawk*_riscv32.deb'
# chroot "$CHROOT_DIR" /usr/bin/dpkg --configure mawk
# chroot "$CHROOT_DIR" /bin/sh -c 'dpkg --unpack /var/cache/apt/archives/libcrypt1*_riscv32.deb'
# chroot "$CHROOT_DIR" /usr/bin/dpkg --configure libcrypt1
# chroot "$CHROOT_DIR" /bin/sh -c 'dpkg --unpack /var/cache/apt/archives/dpkg*riscv32.deb'
# chroot "$CHROOT_DIR" /usr/bin/dpkg --configure dpkg



# 6. run debootstrap stage2 (configure rest)
echo "--> Running debootstrap second stage (configuring the rest)..."
chroot "$CHROOT_DIR" /debootstrap/debootstrap --second-stage


# 7. setup apt sources.list to use local repo
cat << EOF > "$CHROOT_DIR/etc/apt/sources.list"
# add local repository
deb [trusted=yes] file:///rebootstrap rebootstrap main
EOF
chroot "$CHROOT_DIR" /usr/bin/apt-get update
chroot "$CHROOT_DIR" /usr/bin/apt list || true

echo ""
echo "======================================================"
echo "  riscv32 chroot environment is ready!"
echo "======================================================"
