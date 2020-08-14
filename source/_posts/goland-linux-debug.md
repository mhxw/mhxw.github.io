---
title: Goland远程连接Linux开发调试
date: 2018/10/21 21:00:00
tags: 
- linux
- golang
- goland
category: 
- 技术点滴
---


打开Goland，选择File=》Plugins=》Install JetBrains plugins

![image](http://p1.pstatp.com/large/pgc-image/df65cae30df44e248627f8f694a37e0f)

搜索Remote Hosts Access，点击Install
<!-- more -->
![image](http://p1.pstatp.com/large/pgc-image/62f54c080e25416197d4f39ea3cff34a)

安装好之后，重启GoLand

配置

Settings=》build, execution, deployment=》deployment

Add Server：命名和选择SFTP

![image](http://p1.pstatp.com/large/pgc-image/e7ea20e838b048f486d393fd827de93a)

Connection里面的设置：

SFTP host：填写服务器ip

Root path：服务器的go项目存放路径，例如我配置的是/home/Go/go-project

User name：服务器账号

Password：服务器密码

![image](http://p1.pstatp.com/large/pgc-image/479f25e17f0248de9bb1a06bff1f8adb)

Mappings里面的设置：

Local path：本地电脑的项目路径

Deployment path on server：具体某个项目的路径

![image](http://p1.pstatp.com/large/pgc-image/0c45927233ec4ce1817c3e110bd906bd)

配置完成！

把服务器项目下载到本地的项目文件中（2种情况：项目未下载过本地或已下载过本地）：

1、之前未把项目下载到本地：

（1）、Tools=》Deployment=》Browse Remote Host

![image](http://p1.pstatp.com/large/pgc-image/ad416c9ea7264cb0a0b3df07a9bbf3c3)

（2）弹出Remote Host之后，右键选择项目=》Download from here

![image](http://p1.pstatp.com/large/pgc-image/912500691cef4e2da1d5e803e5f2a135)

2、项目已下载的本地

Tools=》Deployment=》Download from xxx

![image](http://p1.pstatp.com/large/pgc-image/0c45927233ec4ce1817c3e110bd906bd)

本地代码修改完成之后，上传到服务器更新：

Tools=》Deployment=》Upload to xxx

![image](http://p1.pstatp.com/large/pgc-image/6ac5ba9dfebf4d82bb9a36442c588e95)

