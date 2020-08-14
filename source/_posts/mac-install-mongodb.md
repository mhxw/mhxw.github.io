---
title: Mac安装配置MongoDB
date: 2019/01/05 21:00:00
tags: 
- mac
- mongodb
category: 
- 学习笔记
---

### 安装MongoDB
---
1. 打开官方下载网站
```
https://www.mongodb.com/download-center/community
```
![下载mangodb](http://p1.pstatp.com/origin/pgc-image/c05c636c30f4402b8f7276b7488d6a22)
2. 进入`/usr/local`目录
```
cd /usr/local
```
<!-- more -->
3. 下载并解压
```
sudo curl -O https://fastdl.mongodb.org/osx/mongodb-osx-ssl-x86_64-4.0.9.tgz
sudo tar -zxvf mongodb-osx-ssl-x86_64-4.0.9.tgz
```
4. 重命名为 mongodb 目录
```
sudo mv mongodb-osx-x86_64-4.0.9/ mongodb
```
5. 把mangodb的二进制命令目录添加到PATH路径中
```
export PATH=/usr/local/mongodb/bin:$PATH
```
### 运行MongoDB
---
1. 首先创建一个数据库存储目录 `/data/db`
```
sudo mkdir -p /data/db
```
2. 启动 mongodb，默认数据库目录则为` /data/db`
```
sudo mongod
```

![运行MangoDB](http://p1.pstatp.com/origin/pgc-image/59887aa4ae4e4f3f9e2e173f34007896)

3. 再打开一个终端，执行以下命令，进入MangoDB
```
cd /usr/local/mongodb/bin
./mongo
```
![进入MangoDB](http://p1.pstatp.com/origin/pgc-image/6edb6c25cb904c6f96bc079a83019cf0)

### 下载MongoDB-Compass
---
- 进入官网直接下载
```
https://www.mongodb.com/download-center/compass
```
- 或者执行以下命令下载
```
sudo curl -O https://downloads.mongodb.com/compass/mongodb-compass-1.18.0-darwin-x64.dmg
```
- 双击安装运行即可

### FAQ
---
- 如果你的数据库目录不是/data/db，可以通过 --dbpath 来指定。
```
sudo mongod --dbpath=/data/db
```
