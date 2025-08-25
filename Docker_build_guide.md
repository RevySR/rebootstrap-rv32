# Docker build Guide

为了避免构建脚本污染宿主机环境，因此提供了docker支持，使用方式如下

## 环境：

```
linux 6.12+
docker 24+
```

## 使用方式

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