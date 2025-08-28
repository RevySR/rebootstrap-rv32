# Docker build Guide

为了避免构建脚本污染宿主机环境，因此提供了docker支持，使用方式如下

## 环境：

```
linux 6.12+
docker 24+
```

## 使用方式
### 提前pull所需的image
```bash
sudo docker pull debian:trixie
sudo docker pull multiarch/qemu-user-static
```
### 构建image：

```bash
cd rebootstrap-rv32
sudo docker compose build
```

### 启动容器，并挂载当前目录:

```bash
sudo docker compose up &
sudo docker start <container_id>
```

### 进入容器并运行构建脚本

```bash
sudo docker exec -it <container_id> /bin/bash
```

在容器内执行./start.sh即可开始构建，日志和package pool会同步到宿主机所挂载的目录中

### 容器内交叉编译基础包完成后在容器内开始构建debootstrap
注意：构建debootstrap之前需要完成以下包的交叉构建，并通过```reprepro```组仓到本地仓库中
```perl、dpkg、debconf、gcc-defaults、liblocale-gettext-perl、libtext-charwidth-perl、libtext-iconv-perl、libtext-wrapi18n-perl、readline、system-helpers```
开始构建debootstrap
```bash
# /rebootstrap
chmod 755 ./start_chroot_assembly.sh
./start_chroot_assembly.sh
```