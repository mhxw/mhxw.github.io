---
title: 在Ubuntu上安装Golang
date: 2019-2-26
tags: 
  - golang
  - linux
category:
  - Golang
author: MHXW
---

## 下载

```shell
https://golang.org/dl/
```

```shell
wget -c https://golang.org/dl/go1.16.5.linux-amd64.tar.gz -O - | sudo tar -xz -C /mhxw
```

<!-- more -->

## 设置环境变量

```shell
vim ~/.profile
export PATH=$PATH:/mhxw/go/bin
source ~/.profile
```

## 校验版本

```shell
go version
```