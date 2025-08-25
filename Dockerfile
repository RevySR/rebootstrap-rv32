FROM debian:trixie

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# 安装基础依赖
RUN rm -f /etc/apt/sources.list.d/* \
    && echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian/ trixie main contrib non-free non-free-firmware" > /etc/apt/sources.list \
    && echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian/ trixie-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list \
    && echo "deb http://mirrors.tuna.tsinghua.edu.cn/debian-security/ trixie-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list \
    && apt-get update && apt-get install -y \
    build-essential \
    sudo \
    wget \
    curl \
    git \
    python3 \
    python3-pip \
    ca-certificates \
    gnupg \
    lsb-release \
    qemu-user-static \
    && rm -rf /var/lib/apt/lists/*

# 创建工作目录
WORKDIR /rebootstrap

# 设置权限
RUN chmod 755 /rebootstrap

# 默认命令
CMD ["/bin/bash"]