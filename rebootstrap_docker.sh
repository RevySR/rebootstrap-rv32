
DOCKER_IMAGE_NAME=debian:trixie_rebootstrap_rv32
MIRROR=https://repo.revyos.rv64gc.org:8443/trixie32/revyos-base/
SUITE=trixie

DIR=/rebootstrap
REPODIR=/rebootstrap/tmp_repo
HOST_ARCH=riscv32
GCC_VER=14
SUITE=trixie

sudo mmdebstrap \
    --variant=minbase \
    --include=nano,apt,ca-certificates \
    --customize-hook='echo "Acquire::AllowInsecureRepositories \"true\";" > "$1/etc/apt/apt.conf.d/99trusted"' \
    --customize-hook='echo "APT::Get::AllowUnauthenticated \"true\";" >> "$1/etc/apt/apt.conf.d/99trusted"' \
    --customize-hook='sed -i "s/\[trusted=yes\] //g" "$1/etc/apt/sources.list"' \
    trixie \
    - \
    "deb [trusted=yes] $MIRROR $SUITE main" | docker import - ${DOCKER_IMAGE_NAME}

docker run --rm -it \
    -v $(pwd):/rebootstrap \
    -v $(pwd)/repo13:/repo \
    --tmpfs /tmp:exec \
    ${DOCKER_IMAGE_NAME} \
    bash \
    -c "bash ${DIR}/bootstrap.sh HOST_ARCH=${HOST_ARCH} REPODIR=${REPODIR} REPODIR=${REPODIR} MIRROR=${MIRROR} SUITE=${SUITE} GCC_VER=${GCC_VER} 2>&1 | tee ${DIR}/bootstrap.log; bash"
