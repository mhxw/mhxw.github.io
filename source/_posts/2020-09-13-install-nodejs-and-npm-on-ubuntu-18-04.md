---
title: Ubuntu18.04上安装nodejs和npm
date: 2020/09/13 21:00:00
tags: 
- ubuntu
- nodejs
- npm
category: 
- 技术教程
---

### 更新ubuntu软件源

按顺序执行

```shell script
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:chris-lea/node.js
sudo apt-get update
```

### 安装NodeJS和NPM

```shell script
sudo apt-get install nodejs
sudo apt install libssl1.0-dev nodejs-dev node-gyp npm
```
<!-- more -->
#### 设置镜像源

````shell script
sudo npm config set registry https://registry.npm.taobao.org
sudo npm config list
````

### 其他命令

- 查看安装的所有软件

```shell script
dpkg -l | grep nodejs
``` 

- 查看软件安装的路径

```shell script
dpkg -L | grep ftp
```

### 链接

```shell script
https://github.com/nodesource/distributions
```