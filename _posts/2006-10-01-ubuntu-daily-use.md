---
layout:     post
title:      "Ubuntu 日常使用"  
subtitle:   "常用软件和问题解决"
date:       2010-01-18 16:08:00 +08:00
author:     "Sun Jianjiao <jianjiaosun@163.com>"
header-img: "img/bg/default-bg.jpg"
catalog: true
tags:
    - Ubuntu
    - linux
    - 桌面
    - 日常使用

---

# 文本编辑器

## **Atom** 
是由github开发的开源文本编辑器，跨平台，支持插件扩展... ...。　对于我最重要的用途是使用Atom作为Markdown的编辑器。

**1. 下载地址**
[https://www.atom.io/](https://www.atom.io/)

**2. 打开Markdown实时预览功能**  
**方法一：**  
直接通过快捷键打开：　*Ctrl + shift + m*  
** 方法二：**  
通过页面你选择markdown prview toggle打开:  
 1) Linux/Windows上按下快捷键： *ctrl + shift + p*    
 2) 搜索　*markdown*  
 3) 选择　*markdown preview toggle*    
![atom markdonw preview](/img/post/ubuntu-daily-use/atom-markdown-preview.png)

**预览功能增强的插件**
markdown-preview-enhanced， 个人觉得更好用， 支持预览时， 编辑和预览同时滚动。


**4. 导出HTML**  
在预览的页面，鼠标右键->选择 *“Save As HTML...”* 进行导出。

**5. 导出pdf**
第一步：
```
npm install -g html-pdf
npm install -g phantomjs
```
第二步：
搜索安装package: markdown-themeable-pdf

如果先安装markdown-themeable-pdf， 后安装的phantomjs， 提示：
```
AssertionError: html-pdf: Failed to load PhantomJS module. You have to set the path to the PhantomJS binary using ‘options.phantomPath’
```
需要卸载并重新安装markdown-themeable-pdf，重启Atom即可。

**6. TOC**
没有TOC怎么写有目录的文档！没有目录那还是文档吗！
安装markdown-toc, 在Atom中 Command + Shift + P 输入 TOC，回车。保存后还能自动更新。

## visual studio code
微软开发的开源的跨平台编辑器， 功能和atom类似， 但是速度和资源占用比atom少。目前已经抛弃atom, 转到visual studio code。主要用来编写markdown文件。

# 文档格式转换
### i5ting_toc
将markdown 转化为带样式的html字符串，i5ting_toc是node环境下的实现工具，用于直接将markdown文件转化为网页，在浏览器打开 。
使用方法: https://github.com/i5ting/tocmd.npm

## 导出有侧边目录的pdf
https://github.com/unanao/toolbox/tree/master/markdown

# 中文输入法
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
