---
title: 如何在Ubuntu 18.04上安装Discourse Docker镜像
date: 2020/08/23 21:00:00
tags: 
- ubuntu
- ssh
category: 
- 技术运营
---

## 介绍

Docker环境中安装Discourse，并配置独立的Nginx和SSL

## 安装docker

可查看[ubuntu安装docker](/2020/08/22/install-docker-on-ubuntu/)

## 下载最新版

在下载和安装Discourse之前，请创建`/var/discourse`目录。这是您所有与Discourse相关的文件所在的位置：

```shell script
sudo mkdir /var/discourse
```

将官方[Discourse Docker镜像](https://github.com/discourse/discourse_docker) 复制到`/var/discourse`：
```shell script
sudo git clone https://github.com/discourse/discourse_docker.git /var/discourse
```
<!-- more -->
## 安装和配置

进入目录

```shell script
cd /var/discourse
```

启动脚本

```shell script
sudo ./discourse-setup
```

Discourse安装过程会询问以下问题

- 您的discourse的主机名

discourse.your_domain：您的域名

- 管理员帐户的电子邮件地址配置

以qq邮箱为例
```shell script
# SMTP 服务器
SMTP server address：smtp.qq.com
# 给用户发邮件的邮箱账户
SMTP user name：send@domain.com
# 端口
SMTP port：587
# SMTP密码
SMTP password：这里填qq邮箱授权码
```

## 注册管理员账户

上述均填好之后，等待2-8min的安装，安装成功之后打开你的域名就可以看到管理员注册。如果这一步出现问题无法收到管理员发的邮件，再继续下面步骤，否则可以略过。

- 编辑app.yml文件

1. 位置在`containers/app.yml`，如果没有复制下面这个文件

```shell script
cd /var/discourse
cp samples/standalone.yml containers/app.yml
vim containers/app.yml
```

2. 修改以下几处内容

完整代码可参考最底部代码块
```shell script
# 网站域名
DISCOURSE_HOSTNAME: 'domain.com'
# 管理员邮箱
DISCOURSE_DEVELOPER_EMAILS: 'admin@qq.com'

DISCOURSE_SMTP_ADDRESS: smtp.qq.com
DISCOURSE_SMTP_PORT: 587
DISCOURSE_SMTP_USER_NAME: xxxx@foxmail.com
# qq邮箱授权码 在qq邮箱=》设置=》账户=》开启smtp服务
DISCOURSE_SMTP_PASSWORD:"pwd"
DISCOURSE_SMTP_ENABLE_START_TLS: true 

## 发件邮箱：配置文件最底下找这一行
- exec: rails r "SiteSetting.notification_email='xxxx@foxmail.com'"

```

## 升级Discourse

升级过程中注意规则的改变，例如升级可能加了新的规则自动删除不活跃的好友，多留意官方动态

```shell script
cd /var/discourse
sudo git pull
sudo ./launcher rebuild app
```

## 配置Nginx和SSL

1. 编辑`app.yml`文件，做以下操作

- 注释掉中的所有ssl模板templates

```shell script
  #- "templates/web.ssl.template.yml"
  #- "templates/web.letsencrypt.ssl.template.yml"
```

- 添加套接字模板：

```
  - "templates/web.socketed.template.yml"
```

>注意事项
>套接字模板配置文件中也需要配置discourse.conf文件，如果没有按照路径创建一个并配置

`web.socketed.template.yml`配置文件如下

```shell script
run:
  - file:
     path: /etc/runit/1.d/remove-old-socket
     chmod: "+x"
     contents: |
        #!/bin/bash
        rm -f /shared/nginx.http*.sock
  - file:
     path: /etc/runit/3.d/remove-old-socket
     chmod: "+x"
     contents: |
        #!/bin/bash
        rm -rf /shared/nginx.http*.sock
  - replace:
     filename: "/etc/nginx/conf.d/discourse.conf"
     from: /listen 80;/
     to: |
       listen unix:/shared/nginx.http.sock;
       set_real_ip_from unix:;
  - replace:
     filename: "/etc/nginx/conf.d/discourse.conf"
     from: /listen 443 ssl http2;/
     to: |
       listen unix:/shared/nginx.https.sock ssl http2;
       set_real_ip_from unix:;
```

`discourse.conf`配置文件如下（和下面步骤的nginx.conf配置代码块基本一样）

```shell script
  server {
    listen 80;
    server_name mhxw.com;
    return 301 https://$host$request_uri;
  }
  
  server {
    listen       443 ssl;
    server_name  mhxw.com;

    ssl_certificate      /mhxw/nginx/conf/ssl/mhxw.crt;
    ssl_certificate_key  /mhxw/nginx/conf/ssl/mhxw.key;
    ssl_session_timeout 5m;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; #按照这个协议配置
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE; #按照这个套件配置
    ssl_prefer_server_ciphers on;
    access_log  /mhxw/nginx/logs/access.log  main;
    error_log  /mhxw/nginx/logs/error.log  debug;


    location / {
	    add_header Content-Security-Policy "upgrade-insecure-requests;connect-src *";
        proxy_pass http://unix:/var/discourse/shared/standalone/nginx.http.sock:;
        proxy_set_header Host $http_host;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Real-IP $remote_addr;
    }
  }
```

- 注释掉所有暴露的端口：

```shell script
    #- "8090:80"   # http
    #- "8091:443" # https
```

修改好以后，`app.yml`配置文件如下

```shell script
templates:
  - "templates/postgres.template.yml"
  - "templates/redis.template.yml"
  - "templates/web.template.yml"
  - "templates/web.ratelimited.template.yml"
  - "templates/web.socketed.template.yml"
## Uncomment these two lines if you wish to add Lets Encrypt (https)
  #- "templates/web.ssl.template.yml"
  #- "templates/web.letsencrypt.ssl.template.yml"

## which TCP/IP ports should this container expose?
## If you want Discourse to share a port with another webserver like Apache or nginx,
## see https://meta.discourse.org/t/17247 for details
expose:
        #- "8090:80"   # http
        #- "8091:443" # https

params:
  db_default_text_search_config: "pg_catalog.english"

  ## Set db_shared_buffers to a max of 25% of the total memory.
  ## will be set automatically by bootstrap based on detected RAM, or you can override
  #db_shared_buffers: "256MB"

  ## can improve sorting performance, but adds memory usage per-connection
  #db_work_mem: "40MB"

  ## Which Git revision should this container use? (default: tests-passed)
  #version: tests-passed

env:
  LANG: en_US.UTF-8
  # DISCOURSE_DEFAULT_LOCALE: en

  ## How many concurrent web requests are supported? Depends on memory and CPU cores.
  ## will be set automatically by bootstrap based on detected CPUs, or you can override
  #UNICORN_WORKERS: 3

  ## TODO: The domain name this Discourse instance will respond to
  ## Required. Discourse will not work with a bare IP number.
  DISCOURSE_HOSTNAME: 'mhxw.com'

  ## Uncomment if you want the container to be started with the same
  ## hostname (-h option) as specified above (default "$hostname-$config")
  #DOCKER_USE_HOSTNAME: true

  ## TODO: List of comma delimited emails that will be made admin and developer
  ## on initial signup example 'user1@example.com,user2@example.com'
  DISCOURSE_DEVELOPER_EMAILS: 'hi@mhxw.com'

  ## TODO: The SMTP mail server used to validate new accounts and send notifications
  # SMTP ADDRESS, username, and password are required
  # WARNING the char '#' in SMTP password can cause problems!
  DISCOURSE_SMTP_ADDRESS: smtp.qq.com
  DISCOURSE_SMTP_PORT: 587
  DISCOURSE_SMTP_USER_NAME: sender@mhxw.com
  DISCOURSE_SMTP_PASSWORD: kknvfghgfqrbcee
  DISCOURSE_SMTP_ENABLE_START_TLS: true           # (optional, default true)

  ## If you added the Lets Encrypt template, uncomment below to get a free SSL certificate
  #LETSENCRYPT_ACCOUNT_EMAIL: me@example.com

  ## The http or https CDN address for this Discourse instance (configured to pull)
  ## see https://meta.discourse.org/t/14857 for details
  #DISCOURSE_CDN_URL: https://discourse-cdn.example.com

## The Docker container is stateless; all data is stored in /shared
volumes:
  - volume:
      host: /var/discourse/shared/standalone
      guest: /shared
  - volume:
      host: /var/discourse/shared/standalone/log/var-log
      guest: /var/log

## Plugins go here
## see https://meta.discourse.org/t/19157 for details
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/discourse/docker_manager.git

## Any custom commands to run after building
run:
  - exec: echo "Beginning of custom commands"
  ## If you want to set the 'From' email address for your first registration, uncomment and change:
  ## After getting the first signup email, re-comment the line. It only needs to run once.
  - exec: rails r "SiteSetting.notification_email='sender@mhxw.com'"
  - exec: echo "End of custom commands"

```

2. 编辑`nginx.conf`并重新加载

nginx.conf 配置文件如下

```shell script
  server {
    listen 80;
    server_name mhxw.com;
    return 301 https://$host$request_uri;
  }
  
  server {
    listen       443 ssl;
    server_name  mhxw.com;

    ssl_certificate      /mhxw/nginx/conf/ssl/mhxw.crt;
    ssl_certificate_key  /mhxw/nginx/conf/ssl/mhxw.key;
    ssl_session_timeout 5m;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; #按照这个协议配置
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE; #按照这个套件配置
    ssl_prefer_server_ciphers on;
    access_log  /mhxw/nginx/logs/access.log  main;
    error_log  /mhxw/nginx/logs/error.log  debug;


    location / {
	    add_header Content-Security-Policy "upgrade-insecure-requests;connect-src *";
        proxy_pass http://unix:/var/discourse/shared/standalone/nginx.http.sock:;
        proxy_set_header Host $http_host;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Real-IP $remote_addr;
    }
  }
```


## 参考链接
https://www.digitalocean.com/community/tutorials/how-to-install-discourse-on-ubuntu-18-04
https://meta.discoursecn.org/
https://meta.discourse.org/t/running-other-websites-on-the-same-machine-as-discourse/17247
https://meta.discourse.org/t/wanting-to-run-discourse-alongside-apache/125075