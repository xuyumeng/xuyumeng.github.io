---
layout:     post
title:      "Ubuntu 日常使用"  
subtitle:   "常用软件和问题解决"
date:       2011-01-18 16:08:00 +08:00
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

Atom是由github开发的开源文本编辑器，跨平台，支持插件扩展... ...。　对于我最重要的用途是使用Atom作为Markdown的编辑器。

**1. 下载地址**
[https://www.atom.io/](https://www.atom.io/)

**2. 打开Markdown实时预览功能**  
**方法一：**  
直接通过快捷键打开：　*Ctrl + shift + m*  
**方法二：**  
通过页面你选择markdown prview toggle打开:  
 1) Linux/Windows上按下快捷键： *ctrl + shift + p*    
 2) 搜索　*markdown*  
 3) 选择　*markdown preview toggle*    
![atom markdonw preview](/img/post/ubuntu-daily-use/atom-markdown-preview.png)

**3. 导出HTML**  
在预览的页面，鼠标右键->选择 *“Save As HTML...”* 进行导出。

# Markdown格式文档导出到其它格式
Pandoc是一个标记语言转换工具，可实现不同标记语言间的格式转换，以命令行形式实现与用户的交互，并且支持多种操作系统。

1. 安装pandoc  
```
   sudo apt-get install pandoc
```
2. 基本语法  
1) Pandoc会根据文件的后缀名自动判断格式
```
pandoc <input_file> -o <output_file>
```
*input_file*和*output_file* 需要待正确的后缀。　
2) 显式指定输入文件和输出文件格式
```
pandoc -S -f markdown -t html  <input_file> -o <output_file>
```
 * -S --smart，　可以解决一些转换后乱码的问题
 * -f 源文件文件类型
 * -t 转换后的文件类型

3. 更多例子  
官方文档: [http://pandoc.org/demos.html](http://pandoc.org/demos.html)

# 中文输入法
1. 目前Linux最好用的中文输入法就是搜狗输入法了
[http://pinyin.sogou.com/linux/](http://pinyin.sogou.com/linux/)

2. 无法输入中文的问题  
可以呼出搜狗输入法界面, 但是候选词列表不显示中文，　如下图：

![sogou pinin no chinese display](/img/post/ubuntu-daily-use/sogou-can-not--input-chinese.png)

解决方法，　删除Sogou输入法的配置文件：

    cd ~/.config/
    find . -name "[Ss]ogou*" | xargs rm -rf

登出再重新登陆即可。
