---
layout:     post
title:      "函数式编程 与 Lisp 探索"
subtitle:   "流行语：“这年头，不学点函数式编程好意思说自己会编程？”"
date:       2016-12-16 16:20:52 +08:00
author:     "Y.M. Xu"
header-img: "img/bg/post-2016-lake-wire.png"
catalog: true
tags:
    - macOS
    - Lisp
    - Common Lisp

---

函数式编程最早是由 lambda 演算(lambda calculus) 演化而来的，而 lambda 演算数学家们用来推导和证明的工具。从 20 世纪 50 年代诞生以来，虽然有非常多优秀的地方，因为学习起来太困难、不适用于当时的需求的问题没有发展起来，但是其函数的思想还是被大部分语言借鉴了过去（原来像 Fortran 等语言只有子程序）。

最近不几年函数式编程（functional programming）突然火了起来，很多语言，比如 Python、Ruby、Javascript 都带上了函数式编程的特性，而理论物理最常用的 Mathematica 基础就是函数式编程。相对于面向过程和面向对象等，函数式编程确实在很多情景下有不可替代的作用，所以这也是为什么多少了解一点函数式编程是有好处的。

> 以下内容主要转载自[阮一峰](http://www.ruanyifeng.com/blog/)的[函数式编程初探](http://www.ruanyifeng.com/blog/2012/04/functional_programming.html)，并在此基础上加入自己的探索


## 什么是函数式编程

## 安装 Lisp 

在 macOS 上安装 Lisp 很简单，首先安装 Homebrew（以后可能会写一篇 Homebrew 相关的文章），然后在 Terminal 中输入

```bash
$ brew install clisp
```



## Lisp 基础

## 函数

#### 数学表达式

#### 函数表达方式

#### 逻辑运算

## 表、CAR、CDR

```bash
$ clisp

  i i i i i i i       ooooo    o        ooooooo   ooooo   ooooo
  I I I I I I I      8     8   8           8     8     o  8    8
  I  \ `+' /  I      8         8           8     8        8    8
   \  `-+-'  /       8         8           8      ooooo   8oooo
    `-__|__-'        8         8           8           8  8
        |            8     o   8           8     o     8  8
  ------+------       ooooo    8oooooo  ooo8ooo   ooooo   8

Welcome to GNU CLISP 2.49 (2010-07-07) <http://clisp.cons.org/>

Copyright (c) Bruno Haible, Michael Stoll 1992, 1993
Copyright (c) Bruno Haible, Marcus Daniels 1994-1997
Copyright (c) Bruno Haible, Pierpaolo Bernardi, Sam Steingold 1998
Copyright (c) Bruno Haible, Sam Steingold 1999-2000
Copyright (c) Sam Steingold, Bruno Haible 2001-2010

Type :h and hit Enter for context help.

[1]> 
```