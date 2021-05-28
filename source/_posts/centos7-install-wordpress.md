---
title: Centos7安装部署Nginx、Php7.2、MySQL5.7、WordPress
date: 2018/10/24 10:00:00
tags: 
- centos
- wordpress
- linux
category: 
- Tutorial
---

### 准备环境
---
WordPress基于PHP开发的，本文采用Centos7.3、Nginx、MySQL5.7、PHP7.2部署。
### 设置阿里云镜像
---
1. 备份原来的yum源
```
sudo cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup 
```
<!-- more -->
2. 设置阿里云的yum源
```
sudo wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 
```
3. 添加epel源
```
sudo wget -P /etc/yum.repos.d/ http://mirrors.aliyun.com/repo/epel-7.repo 
```
4. 清理缓存并生成新的缓存
```
sudo yum clean all  
sudo yum makecache  
```
### 安装Nginx
---
1. 安装nginx源
执行以下命令，安装该rpm后，在`/etc/yum.repos.d/ `目录中看到一个名为`nginx.repo` 的文件
```
rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
```
2. 安装nginx
```
yum install -y nginx
```
3. nginx的默认目录
> nginx配置路径：/etc/nginx/
> pid目录：/var/run/nginx.pid
> 错误日志：/var/log/nginx/error
> 访问日志：/var/log/nginx/access.log
> 默认站点目录：/usr/share/nginx/html

只需知道nginx配置路径即可，一会儿仅需修改/etc/nginx/nginx.conf 以及/etc/nginx/conf.d/default.conf 
- 修改配置文件
修改/etc/nginx/conf.d/default.conf中下面两段内容：
```
vi /etc/nginx/conf.d/default.conf
```
更改前：
```
location / {
    root   /usr/share/nginx/html;
    index  index.html index.htm;
}
```
更改后：
```
    root   /usr/share/nginx/html;
    index  index.html index.htm index.php;
    location / {
      try_files $uri $uri/ /index.php$is_args$args;
   }
```
更改前：
```
#location ~ \.php$ {
#    root           html;
#    fastcgi_pass   127.0.0.1:9000;
#    fastcgi_index  index.php;
#    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
#    include        fastcgi_params;
#}
```
更改后：
```
location ~ \.php$ {
    fastcgi_pass   127.0.0.1:9000;
    fastcgi_index  index.php;
    fastcgi_param  SCRIPT_FILENAME  $request_filename;
    include        fastcgi_params;
}
```
修改 ```/etc/php-fpm.d/www.conf```配置：
```
vi /etc/php-fpm.d/www.conf
```
将`user = apache`改为`user = nginx`，将`group = apache`改为`group = nginx`。

4. nginx的常用命令
- 启动
```
/usr/sbin/nginx –s start
//或者
systemctl start nginx.service
```
- 重启
```
/usr/sbin/nginx –s reload
//或者
systemctl restart nginx.service
```
- 关闭
```
/usr/sbin/nginx –s stop
//或者
systemctl stop nginx.service
```
- 查看进程
```
ps -ef |grep nginx
```
### 安装MySQL
1. 安装MySQL5.7
- 下载并安装MySQL官方的 Yum Repository
```
wget -i -c http://dev.mysql.com/get/mysql57-community-release-el7-10.noarch.rpm
```
- yum安装
```
yum -y install mysql57-community-release-el7-10.noarch.rpm
```
- 安装MySQL Sever
```
yum -y install mysql-community-server
```
2. MySQL数据库设置
-  首先启动MySQL
```
systemctl start  mysqld.service
```
- 查看MySQL运行状态
出现`Active: active(runing)`则表示启动成功
```
systemctl status mysqld.service
```
- 此时已运行成功并进入MySQL，执行以下命令找到密码
```
grep "password" /var/log/mysqld.log
```
- 进入数据库
```
mysql -uroot -p
```
- 在数据库中修改密码，下面的`new password`填写新密码（密码设置格式为大小写、字符等）
```
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new password';
```
- 由于安装了yum repository，以后每次yum操作都会自动更新，需要把这个卸载掉
```
yum -y remove mysql57-community-release-el7-10.noarch
```
### 安装PHP
---
1. 如果之前已经安装先卸载之前的
```
yum -y remove php*
```
2. 由于linux的yum源不存在php7.x，所以我们要更改yum源
```
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm   
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
```
3. 安装php扩展，选择自己需要的
```
yum -y install php72w php72w-cli php72w-common php72w-devel php72w-embedded php72w-fpm php72w-gd php72w-mbstring php72w-mysqlnd php72w-opcache php72w-pdo php72w-xml
```
4. 检验是否安装成功
```
php -V
```
5. 开启服务
```
systemctl start nginx.service
systemctl start mysqlb.service
systemctl start php-fpm.service
```
### 安装WordPress
1. 移除/usr/share/nginx/html内所有文件
```
cd /usr/share/nginx/html
rm 50x.html index.html
```
2. 下载并解压wordpress安装包
```
wget https://cn.wordpress.org/wordpress-5.0.2-zh_CN.zip
tar -zxvf wordpress-5.0.2-zh_CN.zip
```
### FAQ
---
1. 远程连接MySQL出现1130错误，无法远程连接：error 1130: host '192.168.1.3' is not allowed to connect to this MySQL
```
mysql> use mysql
mysql> select host, user from user;
```
- 将相应用户数据表中的host字段改成'%';
```
update user set host='%' where user='root';
```
- 刷新保存，重新连接即可
 ```
flush privileges;
```