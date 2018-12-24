---
layout:     post
title:      "Ubuntu 日常使用"  
subtitle:   "常用软件和问题解决"
author:     Sun Jianjiao
header-img: "img/bg/default-bg.jpg"
catalog: true
tags:
    - Ubuntu
    - linux
    - 桌面
    - 日常使用

---

# 1. 文本编辑器

## visual studio code 
微软开发的开源的跨平台编辑器，对于我最重要的用途是文本编辑，写Markdown是我的重要用途之一。

**1. 下载地址**
[https://code.visualstudio.com/](https://code.visualstudio.com/)

**2. 增强Markdown实时预览功能**  
安装mardown的 perview enhanced插件。

** 3. 预览 **
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
## 2.1 i5ting_toc
将markdown 转化为带样式的html字符串，i5ting_toc是node环境下的实现工具，用于直接将markdown文件转化为网页，在浏览器打开 。
使用方法: https://github.com/i5ting/tocmd.npm

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
