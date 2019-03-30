---
layout:     post
title:      "日常使用的软件"  
subtitle:   "常用软件和问题解决"
author:     Sun Jianjiao
header-img: "img/bg/default-bg.jpg"
catalog: true
tags:
    - 日常使用

---

# 1. 文本编辑器

## visual studio code 
微软开发的开源的跨平台编辑器，对于我最重要的用途是文本编辑，写Markdown是我的重要用途之一。

**1. 下载地址**
[https://code.visualstudio.com/](https://code.visualstudio.com/)

**2. 增强Markdown实时预览功能**  
安装mardown的 perview enhanced插件。

**3. 预览**
先按：Ctrl + k, 然后按“v” 

**4. 导出HTML**  
在预览的页面，鼠标右键->选择 *“HTML”*->"HTML(offline)" 进行导出。

**5. jekll 图片预览 **
由于jekll的目录是相对于博客的根目录的，还有没找到好的方法解决这个问题，所以采用创建一个软链接的方式解决这个问题。
windows下的创建方法：
```
mklink /D img ..\img
```

# 2. 文档格式转换

## 2.1 pandoc

下载地址：https://pandoc.org/

1.Word转换为Markdown格式，同时导出图片

```shell
pandoc --extract-media ./image ${src}.docx -o ${dest}.md
```

## 2.2 导出有侧边目录的pdf
https://github.com/unanao/toolbox/tree/master/markdown

# 3. 中文输入法
**搜狗输入法** 目前是Linux上最好用的中文输入法了。
1. 下载地址  
[http://pinyin.sogou.com/linux/](http://pinyin.sogou.com/linux/)

2. 无法输入中文的问题  
可以呼出搜狗输入法界面, 但是候选词列表不显示中文，　如下图：

![sogou pinin no chinese display](/img/post/ubuntu-daily-use/sogou-can-not--input-chinese.png)

解决方法，　删除Sogou输入法的配置文件：

    cd ~/.config/
    find . -name "[Ss]ogou*" | xargs rm -rf

登出再重新登陆即可。

# 3. JAVA IDE
Idea是非常好用的Java IDE。 Idea提供了一个非常好用的功能, 就是把自己的配置文件备份到Git仓库(如gitlab, github等)，这样就避免了每换一次开发环境就需要重新配置一遍。

1. 创建一个Git仓库， 如Bitbucket 或者 GitHub, 想创建私有的可以使用gitlab。
2. 配置备份：选择 File | Settings Repository. 填写仓库的URL，点击Overwrite Remote。
3. 配置恢复：选择 File | Settings Repository. 填写仓库的URL，如果想使用远程的配置，点击Overwrite Local。如果向合并远程和本地的配置，点击Merge，，如果有冲突，可以在对话框中解决。

[翻译自原文链接](https://www.jetbrains.com/help/idea/sharing-your-ide-settings.html) 《Share settings through a settings repository》 一节

# 4. 数据库设计软件
Mysql workbench的设计功能完全满足我的需求，免费并且跨平台，是一个不错的选择。即使不是使用的mysql，如果只是用来进行数据库的设计，那也足够了。

下载地址：  https://dev.mysql.com/downloads/workbench/
