---
title: 如何上传和删除js库到npmjs.com
date: 2020/08/14 10:00:00
tags: 
- npm
- js
category: 
- Project
---

1. npm init 初始化你的包名和版本，之后也可以在package.json文件里修改

2. npm login 登录你的npm账号，输账户，密码即可

3.如果是淘宝镜像源，要切换成npmjs的镜像源`npm config set registry http://registry.npmjs.org`

4. npm publish 上传包，你发布的包名不能和npm现有的包名重复，可以去https://www.npmjs.com查询一下你设置的包名有没有存在的，没有存在的就可以发布了。

出现下面这行的时候，说明上传成功

5. npm unpublish 包名@版本号 取消上传的包，头两次上传的时候可能会让输两步验证码