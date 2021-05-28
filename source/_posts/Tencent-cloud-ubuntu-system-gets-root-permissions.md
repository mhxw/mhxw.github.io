---
title: 腾讯云ubuntu系统切换到root权限
date: 2020/08/23 21:00:00
tags: 
- ubuntu
- ssh
category: 
- Tutorial
---

1. 生成root用户

设置root的密码，建议和ubuntu的密码一样

```shell script
sudo passwd root
```
<!-- more -->
2. 编辑`sshd_config`文件

- 编辑以下文件

```shell script
sudo vi /etc/ssh/sshd_config
```

- 找到`PermitRootLogin`，重新复制一行然后将其后面的文本改为yes

- 保存并退出

- 重新启动ssh服务

```shell script
sudo service ssh restart
```

3. 重新登录

使用root用户名登录ssh，操作完成