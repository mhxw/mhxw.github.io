---
title: Mac下安装与配置Go语言开发环境
date: 2018/12/13 10:00:00
tags: 
- mac
- golang
category: 
- Tutorial
---

![image.png](http://p1.pstatp.com/large/pgc-image/132340be8ea24014a7e191ea66ce96b0)

1. 国内网站下载Mac版安装包
```
https://studygolang.com/dl
```
2. 配置GO环境变量GOPATH和GOBIN
- 打开Mac终端，编辑`.bash_profile`文件
<!-- more -->
```
vi ~/.bash_profile
```
- 在`.bash_profile`文件中添加环境变量
```
export GOROOT=/usr/local/go
#GOPATH是自己的go项目路径，自定义设置
export GOPATH=/Users/nrgh/Documents/Go
export GOBIN=$GOROOT/bin
export PATH=$PATH:$GOBIN
```
- 编译使其生效
```
source ~/.bash_profile
```

3. 查看相关参数
- 查看Go版本
```
go version
```
- 查看Go环境变量
```
go env
```
4. 编辑测试Demo
-   在gopath目录中新建项目，名称自定义，然后新建测试文件并保存。
```
package main
 
import (
  "fmt"
)
 
func main() {
  fmt.Println("hello");
}
```
- 运行测试：在测试文件所在目录运行下方指令
```
#编译并执行
go build /Users/nrgh/Documents/Go/test/main.go
#只看执行结果
go run /Users/nrgh/Documents/Go/test/main.go
```