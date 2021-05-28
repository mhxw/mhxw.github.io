---
title: Ubuntu安装docker
date: 2020/08/22 21:00:00
tags: 
- ubuntu
- docker
category: 
- Tutorial
---

移除系统旧版本

```shell script
sudo apt-get remove docker docker-engine docker-ce docker.io
```

更新索引库

```shell script
apt-get update
```
<!-- more -->
安装一些必要的系统工具（安装以下包以使apt可以通过HTTPS使用存储库）

```shell script
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
```

添加Docker官方的GPG密钥或者阿里云的

```shell script
curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
```

写入软件源信息

```shell script
sudo add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"

```

更新并安装 Docker-CE

```shell script
sudo apt-get -y update
sudo apt-get -y install docker-ce
```

验证docker运行状态

```shell script
systemctl status docker
```

启动docker

使用加速器（采用阿里云加速器）

```shell script
https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors

sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://b02pnumc.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```



