---
title: Ubuntu下安装docker和docker-compose
date: 2021/9/5 21:00:00
tags:
- ubuntu
- docker
- docker-compose
category:
- Tutorial
---

### 一、安装docker

- 使用国内 daocloud 一键安装命令：

```bash
curl -sSL https://get.daocloud.io/docker | sh
```

- 校验版本

```bash
docker --version
```
<!-- more -->
### 二、安装docker-compose

进入github仓库查看想要安装的版本

```
https://github.com/docker/compose/releases/
```

国外服务器可采用github源

```bash
sudo curl -L https://github.com/docker/compose/releases/download/1.29.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
```

国内使用DaoCloud源

```bash
sudo curl -L https://get.daocloud.io/docker/compose/releases/download/1.29.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
```

设置权限

```bash
sudo chmod +x /usr/local/bin/docker-compose
```

检验是否安装成功

```bash
docker-compose --version
```