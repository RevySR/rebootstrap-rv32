#!/usr/bin/env bash

DIR=/rebootstrap
REPODIR=/rebootstrap/tmp_repo
HOST_ARCH=riscv32
DOMAIN=mirror.nju.edu.cn
MIRROR=http://${DOMAIN}/debian

in_container() {
  if [ -f /proc/self/cgroup ] && grep -qE '/(docker|kubepods)' /proc/self/cgroup; then
    return 0
  fi

  if [ -f /.dockerenv ]; then
    return 0
  fi

  return 1
}

if in_container; then
  rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes
  sed -i "s/deb.debian.org/${DOMAIN}/g" /etc/apt/sources.list.d/debian.sources
fi

sh ${DIR}/bootstrap.sh \
  HOST_ARCH=${HOST_ARCH} \
  REPODIR=${REPODIR} \
  MIRROR=${MIRROR} 2>&1 | tee ${DIR}/bootstrap.log


#mmdebstrap --verbose --variant=apt --mode=unshare \
#  --customize-hook="upload bootstrap.sh /bootstrap.sh" \
#  --customize-hook='chroot "$1" sh /bootstrap.sh HOST_ARCH=riscv32 REPODIR=/rebootstrap/tmp_repo' \
#  trixie /dev/null
