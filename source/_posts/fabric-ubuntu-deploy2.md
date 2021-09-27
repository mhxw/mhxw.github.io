---
title: 【Hyperledger第二讲】Ubuntu 16.04部署HyperLedger Fabric1.0并成功运行e2e-cli
date: 2018/12/02 21:00:00
tags: 
- blockchain
- hyperledger
category: 
- Hyperledger
---

## **准备环境**

> 操作系统：阿里云Ubuntu16.04
> Git、Golang
> Docker环境支持：docker、docker-compose
> Fabric组件Docker镜像
> Fabric源码库
<!-- more -->
## **安装步骤**

**更新系统源**
```
sudo apt-get update
```

### **安装Git**

```
sudo apt install git
```

*   查看git版本信息

```
git version
```

### **安装Docker**

```
参考文档：
https://docs.docker.com/install/linux/docker-ce/ubuntu/
https://yq.aliyun.com/articles/110806
```

*   自动安装

```
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
```

*   查看docker版本

```
docker version
```

![image](http://upload-images.jianshu.io/upload_images/5946072-cca35bb656ec72b2.jpg)

*   设置阿里云docker镜像加速器

```
网址：https://cr.console.aliyun.com/mirrors
```

### **安装Docker-compose**

```
参考文档：
https://docs.docker.com/compose/install/
最新版地址：
https://github.com/docker/compose/releases/
```

*   (官方途径)下载docker-compose，也可访问：[https://get.daocloud.io](http://link.zhihu.com/?target=https%3A//get.daocloud.io/)国内高速下载

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

*   授权

```
sudo chmod +x /usr/local/bin/docker-compose
```

*   查看版本信息

```
docker-compose --version
```

![image](http://upload-images.jianshu.io/upload_images/5946072-596232dbcc9460e9.jpg)

*   创建docker用户组
```
sudo groupadd docker
```

*   将当前用户添加到用户组（${USER}为自己当前的用户名）

```
sudo usermod -aG docker ${USER}
```

*   重启docker

```
sudo systemctl restart docker
```

*   切换或者退出当前账户再重新登入

```
su root             #切换到root用户
su ${USER}          #再切换到原来的应用用户以上配置才生效
```

### **安装Golang**

*   访问国内此网站下载最新Linux稳定版的golang

```
中文社区网址：https://studygolang.com/dl
获取安装包：wget https://dl.google.com/go/go1.11.linux-amd64.tar.gz
```

*   使用tar命令把安装包解压缩/usr/local文件夹下面
```
tar -zxvf go1.11.linux-amd64.tar.gz -C /usr/local
```

*   设置环境变量

```
sudo vim /etc/profile
```

*   添加内容，其中go的安装目录是/usr/local/go，go的工作目录是/home/go

```
export GOPATH=/home/go
export GOROOT=/usr/local/go
export PATH=$GOROOT/bin:$PATH
```

*   使用source命令，使其配置信息生效

```
source /etc/profile
```

*   查看go的版本信息

```
go version
```

*   查看go的具体配置信息

```
go env
```

*   在GOPATH目录下创建go目录

```
mkdir go
```

*   进入go项目路径

```
cd /home/go
```

## **Fabric部署**

*   在/home/go下创建目录

```
mkdir -p src/github.com/hyperledger
cd src/github.com/hyperledger
git clone https://github.com/hyperledger/fabric.git
```

*   进入 fabric 目录查看版本分支并切换分支

```
cd fabric
git branch
此处选择对应版本或公开发行版，我选择v1.0.0
git checkout v1.0.0
```

*   下载fabric示例

```
git clone -b master https://github.com/hyperledger/fabric-samples.git
cd fabric-samples
```

*   进入 fabric-samples 目录查看版本分支并切换分支

```
cd fabric-samples
git branch
此处选择对应版本或公开发行版，我选择v1.0.0
git checkout v1.0.0
```

**Fabric的Docker镜像下载**

*   进入`fabrci/examples/e2e_cli/`目录，完成镜像下载，执行命令：

```
cd /home/go/src/github.com/hyperledger/fabrci/examples/e2e_cli/
ls
```

*   ls之后显示，在官网找对应的docker镜像版本号（[https://hub.docker.com/u/hyperledger](http://link.zhihu.com/?target=https%3A//hub.docker.com/u/hyperledger)），因为安装的fabric1.0.0，故我找的是1.0.0，这一步十分重要

![image](http://upload-images.jianshu.io/upload_images/5946072-0a2ba8815895b61e.jpg)

![image](http://upload-images.jianshu.io/upload_images/5946072-c575cb530dd7752e.jpg)

```
source download-dockerimages.sh -c {tags：输版本号} -f {tags：输版本号}
source download-dockerimages.sh -c x86_64-1.0.0 -f x86_64-1.0.0
docker images
```

![image](http://upload-images.jianshu.io/upload_images/5946072-434668a920ccc3e5.jpg)

**启动Fabric并自动完成chaincode测试**

*   进入刚刚的e2e_cli文件目录，执行

```
./network_setup.sh up
```

![image](http://upload-images.jianshu.io/upload_images/5946072-299d82437a79b55a.jpg)

显示END-E2E表示测试成功

**官方通过chaincode手动测试Fabric案例**

*   重新打开一个窗口，在fabric目录下输入

```
docker exec -it cli bash
```

![image](http://upload-images.jianshu.io/upload_images/5946072-57cf73dc7ec190f9.jpg)

*   再输入

```
peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'
```

*   图例显示a结果90
*   a给b转账50

```
peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n mycc -c '{"Args":["invoke","a","b","50"]}'
```

*   再执行查询语句，此时结果为40

```
peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'
```

*   最后，如果打算退出网络，先执行

```
exit
```

*   在刚才fabric/examples/e2e_cli目录下执行

```
./network_setup.sh down
```

## **安装Fabric SDK Go**

> 安装SDK

*   下载软件包

```
go get -u github.com/hyperledger/fabric-sdk-go
```

*   安装依赖包

```
cd $GOPATH/src/github.com/hyperledger/fabric-sdk-go/
chmod +x test/scripts/*.sh  # make depend-install操作会调用dependencies.sh脚本
make depend
```

* * *

**FAQ**

1、阿里云服务器，Ubuntu 报错 sudo: unable to resolve host

```
解决方案：https://blog.csdn.net/hhtnan/article/details/79551969
```

```
参考文档
https://blog.csdn.net/cao0507/article/details/82080924
https://docs.docker.com/install/linux/docker-ce/ubuntu/
https://yq.aliyun.com/articles/110806
https://github.com/docker/compose/releases/
https://docs.docker.com/compose/install/
https://github.com/hyperledger/fabric-sdk-go
https://hub.docker.com/u/hyperledger
```
