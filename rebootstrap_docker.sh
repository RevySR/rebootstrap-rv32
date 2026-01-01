
DOCKER_IMAGE_NAME=debian:trixie_rebootstrap_rv32
MIRROR=https://mirror.bfsu.edu.cn/debian
#https://repo.revyos.rv64gc.org:8443/trixie32/revyos-base/
SUITE=trixie

DIR=/rebootstrap
REPODIR=/rebootstrap/tmp_repo
HOST_ARCH=riscv32
GCC_VER=14
SUITE=trixie

KEY_ID="2D47DD5D5B5C57C7633647672FB3A9E77911527E"

curl -s "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x$KEY_ID" > base.asc

mmdebstrap \
    --variant=minbase \
    --include=nano,apt,ca-certificates \
    --keyring=./base.asc \
    --customize-hook='mkdir -p "$1/etc/apt/trusted.gpg.d/"; cp ./base.asc "$1/etc/apt/trusted.gpg.d/base.asc"' \
    --customize-hook='[ -f "$1/etc/apt/sources.list" ] && sed -i "s/\[trusted=yes\] //g" "$1/etc/apt/sources.list"' \
    $SUITE \
    - \
    "deb [trusted=yes] $MIRROR $SUITE main" | docker import - ${DOCKER_IMAGE_NAME}

docker run --rm -it \
    -v $(pwd):/rebootstrap \
    -v $(pwd)/repo13:/repo \
    --tmpfs /tmp:exec \
    ${DOCKER_IMAGE_NAME} \
    bash \
    -c "bash ${DIR}/bootstrap.sh HOST_ARCH=${HOST_ARCH} REPODIR=${REPODIR} REPODIR=${REPODIR} MIRROR=${MIRROR} SUITE=${SUITE} DIST=${SUITE} GCC_VER=${GCC_VER} 2>&1 | tee ${DIR}/bootstrap.log; bash"
