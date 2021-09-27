---
title: Linux安装Git以及Git常见命令
date: 2020/2/20 21:00:00
tags: 
- linux
- mac
- git
- github
category: 
- 技术教程
---

### 安装步骤
---
1. 在Mac的终端上输入git检测是否安装git，如果没有，点击弹出的“安装”按钮。

```shell script
https://git-scm.com/downloads
```
2. 安装完成之后，在终端输入 `git --version` 查看版本信息

```shell script
git --version
```
<!-- more -->
3. 创建一个全局用户名、全局邮箱作为配置信息

```shell script
git config --global user.name "your_name"  
git config --global user.email "your_email@youremail.com"
```
4. 配置信息可以更改，以后想要更改使用上面指令就可以。同时可以使用`git config --list`指令查看Git的配置信息。

```shell script
git config --list
```
5. Git默认对大小写不敏感，也就是说，将一个文件名某个字母做了大小写转换的修改Git是忽略这个改动的，导致在同步代码时候会出现错误，所以建议把Git设置成大小写敏感。

```shell script
git config core.ignorecase false
```
6. 生成密匙
- Git关联远端仓库时候需要提供公钥，本地保存私钥，每次与远端仓库交互时候，远端仓库会用公钥来验证交互者身份。使用以下指令生成密钥，如果有提示，一路点击回车。

```shell script
ssh-keygen -t rsa -C "your_email@youremail.com"
```
- 生成密钥后，在本地的/Users/当前电脑用户/.ssh目录下会生成两个文件id_rsa、id_rsa.pub，id_rsa文件保存的是私钥，保存于本地，id_rsa.pub文件保存的是公钥，需要将里面内容上传到远端仓库。
7. 获取密匙字符串
- 输入cd指令，进入当前用户目录
- 输入ls -a指令，查看当前用户目录下所有文件，包括隐藏文件
- 输入cd .ssh指令，进入.ssh目录
- 输入ls指令，查看.ssh目录下的文件
- 输入cat id_rsa.pub指令，查看id_rsa.pub文件中内容
8. 打开你的github账号，在`Settings`中的左侧边导航中找到`SSH and GPG keys`，点击左面面板右上方的`New SSH key`添加密匙。
- 图片中的`Title`填写自己的备注标题名称（自定义），`Key`填写刚才`id_rsa.pub`中的内容。
![Github添加密匙](http://p1.pstatp.com/origin/pgc-image/7e8f447727584940bcd0ef5e46928cbc)
- 填写完毕后点击`Add SSH key`按钮，这样就添加OK啦~~。

### Git常用命令
---
- 切换分支

```shell script
git checkout <branch_name>
```
#### tag相关命令
- 查看所有分支

```shell script
git tag
```

- 查看具体某条分支

```shell script
git show <tag_name>
```
- 新建tag

```shell script
git tag v1.0
```
- 删除tag

```shell script
git tag -d v1.0
```
### 合并

- 合并分支

```shell script
git merge <branch>hexo
```

### 重命名
- git克隆远程仓库指定分支，并在本地重命名

```shell script
git clone -b <远程指定分支> <repo address> <dir name>
```
