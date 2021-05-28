---
title: Centos7.5安装部署Golang、Beego框架
date: 2018/10/25 21:00:00
tags: 
- centos
- beego
- golang
category: 
- Tutorial
---

### 安装Golang
---
1. 进入home目录下
```
cd /home 
```
2. mkdir Go 创建一个Golang的目录
```
mkdir Go
cd Go
```
![image](http://p1.pstatp.com/large/pgc-image/1539564410823d00ecea058)
<!-- more -->
3. 在 [http://www.studygolang.com/dl](http://www.studygolang.com/dl) 找到go对应的安装包

![image](http://p1.pstatp.com/large/pgc-image/15395644106433baa6d69d9)

![image](http://p3.pstatp.com/large/pgc-image/15395644106481993cbc43b)

4. 复制下载文件链接，在命令行执行代码：
```
wget https://dl.google.com/go/go1.11.linux-amd64.tar.gz
```
![image](http://p3.pstatp.com/large/pgc-image/15395644106608d343392ab)

5.  解压缩
```
tar xzvf  go1.11.linux-amd64.tar.gz
```
![image](http://p1.pstatp.com/large/pgc-image/15395644106673de1d27576)

6. 设置环境变量：
```
vi ~/.bashrc
```
![image](http://p1.pstatp.com/large/pgc-image/15395644106498fc0558985)

7. 添加：
```
export GOROOT=/home/Go/go
export PATH=$GOROOT/bin:$PATH
export GOPATH=/home/Go/go-project
export PATH=$PATH:$GOPATH/bin
```
![image](http://p1.pstatp.com/large/pgc-image/153956441077191b826e8e8)

8、填完执行：
```
source ~/.bashrc
```
![image](http://p1.pstatp.com/large/pgc-image/15395644107748da33f31d2)

### 安装Beego
---

1. 安装git
```
yum install git
```
![image](http://p1.pstatp.com/large/pgc-image/1539564410765a5e5c9732a)

![image](http://p9.pstatp.com/large/pgc-image/1539564410775577057f8d8)

2. git下载beego和bee
```
go get -u -v [http://github.com/astaxie/beego](http://github.com/astaxie/beego)
go get -u -v githubcom/beego/bee
```
下载时等待一会儿，直到结束为止
![image](http://p1.pstatp.com/large/pgc-image/1539564410793a1c96192bd)
此时，Go和beego就安装好了
3. 测试：
```
cd $GOPATH/src
bee new class
```
successfully，测试ok~
![image](http://p3.pstatp.com/large/pgc-image/15395644108936aead8c176)
4. 进入class目录
```
cd class
```
5. 运行mian.go文件
```
go run main.go 
```
![image](http://p1.pstatp.com/large/pgc-image/1539564410911f3deafd434)

6. 打开8080访问，显示欢迎页面，ok~
![image](http://p3.pstatp.com/large/pgc-image/153956441089129f32e7bba)
