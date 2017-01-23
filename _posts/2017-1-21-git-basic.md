---
layout:     post
title:      "使用Git进行开发（二）"  
subtitle:   "Git 基本使用"
date:       2017-01-20 16:08:00 +08:00
author:     "Sun Jianjiao <jianjiaosun@163.com>"
header-img: "img/bg/railway-station-1363771_1280.jpg"
catalog: true
tags:
    - Git
    - 命令
    - 客户端

---




# 简介
![three steps](/img/post/git/four_stages.png)  


第一次使用git需要习惯分3步进行代码提交：  

1. git add 将工作区的文件添加到暂存区
2. git commit 将暂存区的内容提交到本地仓库
3. git push 将本地仓库提交到远程仓库

# git config
查看配置的内容：

	$ git config --list
	core.symlinks=false
	core.autocrlf=true
	core.fscache=true
	color.diff=auto
	color.status=auto
	color.branch=auto
	color.interactive=true
	help.format=html
	http.sslcainfo=C:/Program Files/Git/mingw64/ssl/certs/ca-bundle.crt
	diff.astextplain.textconv=astextplain
	rebase.autosquash=true
	credential.helper=manager
	user.name=unanao
	user.email=jianjiaosun@126.com
	core.editor=notepad
	core.repositoryformatversion=0
	core.filemode=false
	core.bare=false
	core.logallrefupdates=true
	core.symlinks=false
	core.ignorecase=true
	remote.origin.url=git@192.168.200.128:sunjj/git-example.git
	remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
	branch.master.remote=origin
	branch.master.merge=refs/heads/master

第一次使用需要配置邮箱和用户名：

	$ git config --global user.name "$your-name"
	$ git config --global user.email "$your-email"

配置git commit提交添加的编辑器：
	使用vim:
	git config --global core.editor vim

	windows下配置使用记事本：
	git config --global core.editor notepad

	同样的防范可以配置自己喜欢的其它编辑器


# Git 基本命令

## 克隆一个仓库：  

	git clone git@192.168.200.128:sunjj/git-example.git

## 它会把工作时的所有变化提交到暂存区，包括文件内容修改(modified)以及新文件(new)，但不包括被删除的文件
	git add $file-name/$dir-name

## 删除文件和目录
	git rm $file-name
	git rm -r $dir-name

## 提交当前暂存区的修改内容
	git commit -m "add README"

## 提交修改到远程主机
	git push origin $branch-name
经常会到好多资料上写了git push -u, 这个-u主要用于pull, 可以少写点参数，如果使用git pull origin $branch-name, 这个-u没有用。

## 回退
### 恢复到某次commit-id的状态
	git reset $commit-id --hard
### 撤销工作区的修改：
	git checkout $file
### 撤销某次提交
	git revert $commit-id

## 查看差异
	git diff 

## 产看某次提交的内容
	git show $commit-id

## 日志
git log列出本分提交的日志:
	$ git log
	commit 46aecf1b2c56db30c35ba1cb82ce7d8a7e938727
	Author: unanao <jianjiaosun@126.com>
	Date:   Thu Jan 19 16:38:12 2017 +0800
	
	    yes
	
	commit 0c944508c6e5787984f8c0cc6f36eb09c26f60f2
	Author: unanao <jianjiaosun@126.com>
	Date:   Thu Jan 19 16:37:22 2017 +0800
	
	    init
 
git reset 会退到某次提交：

	$ git reset 0c944508c6e5787984f8c0cc6f36eb09c26f60f2 --hard
	$ git log
	commit 0c944508c6e5787984f8c0cc6f36eb09c26f60f2
	Author: unanao <jianjiaosun@126.com>
	Date:   Thu Jan 19 16:37:22 2017 +0800
	
	    init


## 重返未来
git reflog几乎可以找回所有删除的内容

	$ git reflog
	0c94450 HEAD@{0}: reset: moving to 0c944508c6e5787984f8c0cc6f36eb09c26f60f2
	46aecf1 HEAD@{1}: checkout: moving from master to hello
	0c94450 HEAD@{2}: checkout: moving from branch-1 to master
	46aecf1 HEAD@{3}: commit: yes
	0c94450 HEAD@{4}: checkout: moving from master to branch-1
	0c94450 HEAD@{5}: commit (initial): init

	git reset 46aecf1 --hard
	$ git log
	commit 46aecf1b2c56db30c35ba1cb82ce7d8a7e938727
	Author: unanao <jianjiaosun@126.com>
	Date:   Thu Jan 19 16:38:12 2017 +0800
	
	    yes
	
	commit 0c944508c6e5787984f8c0cc6f36eb09c26f60f2
	Author: unanao <jianjiaosun@126.com>
	Date:   Thu Jan 19 16:37:22 2017 +0800
	
	    init



# git 分支

## 分支创建和切换
创建名字为*feature*的分支：
  
	git branch feature  

切换到*feature*分支:  

	git checkout feature  

创建并切换分支，如分支名字为*dev*： 

	$ git checkout -b dev
	Switched to a new branch 'dev'

基于指定分支创建新分支, 源分支为*dev*, 新分支为*new-dev*:

	$ git checkout -b new-dev dev
	Switched to a new branch 'new-dev'


### 将远程分支信息获取到本地
方法一：

	$ git fetch
	From 192.168.200.128:sunjj/git-example
	 * [new branch]      new-feature -> origin/new-feature

方法二：

	$ git pull origin
		From 192.168.200.128:sunjj/git-example
		 * [new branch]      feature    -> origin/feature
		 * [new branch]      new-dev    -> origin/new-dev

## 列出分支：

### 列出本地已经checekout的分支，git branch 不带参数， 并且在当前分支的前面加“*”号标记：

	$ git branch
	* master

### 列出所有分支， 本地分支和远程分支：

	$ git branch -a
	* master
	  remotes/origin/master

### 获取远程分支
	$ git pull origin
		From 192.168.200.128:sunjj/git-example
		 * [new branch]      feature    -> origin/feature
		 * [new branch]      new-dev    -> origin/new-dev

### 列出更新后的所有分支：
	$ git branch -a
	* master
	  remotes/origin/HEAD -> origin/master
	  remotes/origin/dev
	  remotes/origin/feature
	  remotes/origin/master
	  remotes/origin/new-dev

### 列出更新后的本地分支：
	$ git branch
	* master

### check 分支到本地， 再列出本地分支：
	$ git checkout dev
	Branch dev set up to track remote branch dev from origin.
	Switched to a new branch 'dev'
	
	unanao@DESKTOP-FSBVPHM MINGW64 /f/code/git-example (dev)
	$ git branch
	* dev
	  master


## 远程分支

### 添加远程分支：

	$ git remote add origin git@192.168.200.128:sunjj/git-example.git

### 查看远程分支：

	$ git remote -v
	origin  git@192.168.200.128:sunjj/git-example.git (fetch)
	origin  git@192.168.200.128:sunjj/git-example.git (push)


### 删除分支
	git branch -d | -D branchname 删除branchname分支

### 分支重命名
如果newbranch名字分支已经存在，则需要使用-M强制重命名，否则，使用-m进行重命名。  

	git branch -m | -M oldbranch newbranch 

### 清除远程已经删除的本地分支
	git remote prune origin

# git 客户端
## 命令行客户端
* [git for windows](https://git-for-windows.github.io/), 下载慢可以直接在360, 腾讯管家等搜索git，安装即可。
  git for windows也有图形界面。
  
  在对应的项目目录下， 右键，选择："git bash here",  可以省着使用cd 进行切换。
* Linux, apt-get/yum 直接install 就好了。



## SourceTree
在360上直接搜sourcetree安装接可以了， 支持mac和windows。 估计使用linux的人不会使用图形化界面的工具。
使用SourceTree因为TortoiseGit, 需要单独要装git, 搞一个ssh key还要配置putty，实在太不人性化了。

Source设置SSH Key容易， 而且还自带了内置的git。

如果已经有ssh key，导入方法如下：
“工具”->"选项":

![three steps](/img/post/git/sourcetree-ssh.png)

