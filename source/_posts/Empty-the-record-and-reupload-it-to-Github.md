---
title: 清空github远程仓库并重新上传
date: 2020/08/15 21:00:00
tags: 
- github
- git
category: 
- 学习笔记
---

1. 进入本地仓库，删除.git目录

```shell script
cd $REPO_DIR
rm -rf .git
```

2. 重新git初始化并添加commit

```shell script
git init
git add . # 重新添加所有的文件
git commit -m "first commit"
```
<!-- more -->
3. 添加远程仓库链接

在添加远程仓库时，需要设置远程仓库的代号，本教程记为origin

```shell script
git remote add origin git@github.com:xxxx/$REPO_DIR.git
#git remote add origin git@github.com:mhxw/mhxw.github.io.git
```

4. 强制提交，覆盖远程仓库的commits历史记录

假设提交到远程仓库的master分支，则强制提交脚本如下：

```shell script
git push -f origin master 
# 或者 git push --force origin master
```

推送tag到远程

```shell script
git tag v0.1.0
git push --force origin --tags v0.1.0
```

**后续讨论**
- 细心的朋友可能会发现，上述操作之后，如果你还记得历史记录中某个commit的链接，你仍然可以通过链接访问到该commit下的文件，甚至可以基于这个commit重新创建新分支。为什么会出现这种情况呢？这其实和Git本身的设计机制有关，主要是为了提高容错率，防止你因为一些误操作弄丢了某些commits进而造成无法挽回的结果。

- 实际上，这些commits并没有马上被清理掉，仅仅是你的所有分支或标签无法访问到它们，这些commits被称为unreachable commits. 它们通常会被缓存一段时间，这个周期默认是30天，你也可以通过git命令行手动修改缓存周期或者手动清理。由于Github也是建立在Git这个版本管理工具上的网站，所以它也有这个机制。虽然它们在缓存期内仍然可以被访问到，但你clone到本地并不会包含它们，也就是说，你并不能在本地删除Github上已经存在的unreachable commits，因为本地根本访问不到它们（[存在于 GitHub 上但不存在于本地克隆中的提交](https://docs.github.com/cn/github/committing-changes-to-your-project/commit-exists-on-github-but-not-in-my-local-clone)）。如果不着急的话，你可以等30天之后再试试看是否还能访问这些unreachable commits的链接；但如果你很着急，你可以联系[Github Support](https://support.github.com/)帮你清理这些你不想保留的commits。

- 所以，如果你只是维护个人的文件仓库的话，不需要担心这个问题，你在新机器上clone下来的仍然是缩减大小之后的仓库，而Github上的unreachable commit会在缓存期后被清理掉。如果是与他人协作的仓库，还是谨慎使用`git push --force`这种危险的操作吧，确实遇到需要这个操作的场景时，考虑用更安全的`git push --force-with-lease`. 如果你强制提交之后发现后悔了，找到想恢复的commit的链接并创建新分支就可以找回那个commit所在历史分支之前的内容啦。