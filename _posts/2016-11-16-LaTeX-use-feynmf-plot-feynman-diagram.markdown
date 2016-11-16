---
layout:     post
title:      "用 feynMF 在 LaTeX 中绘制费曼图"
subtitle:   "非常简单的费曼图绘制方法！"
date:       2016-11-16 14:48 +08:00
author:     "Y.M. Xu"
header-img: "img/bg/post-2016-11-particle-collision.jpg"
catalog: true
tags:
    - 物理
    - 量子场论
    - LaTeX
    - 费曼图

---

费曼图是量子场论里面非常重要的工具，在一些额外维的文献中也经常看到，所以如果做这方面工作，学习如何更简单的画出费曼图是非常有用的，物理里的的论文写作基本上都是用 LaTeX，而 LaTeX 经过这么多年的发展，在绘图方面有很多方便的工具，其中 feynMF 和 feynMP 就是用来绘制费曼图的。

feynMF 和 feynMP 的主要区别是图片的输出格式，feynMF 输出的是位图，feynMP 输出的是矢量图 EPS。这里建议使用 feynMP 的 feynmp-auto 包，因为很多格式转换问题都自动解决了，很方便。文档可以互相参考，因为 feynMF 和 feynMP 的具体用法是一样的。

## feynmp-auto

如果你使用的 LaTeX 版本比较新，可以使用 `feynmp-auto` 包，可以更简洁的编译出费曼图，只需要用 latex 或 xelatex 命令编译两次即可。

#### 简单例子
```latex
\documentclass[11pt]{article}
\usepackage{feynmp-auto}

\begin{document}

\begin{fmffile}{a_file_name}
\begin{fmfgraph*}(200,200)
\fmfpen{thick}
\fmfleft{i1,i2}
\fmfright{o1,o2}
\fmf{fermion}{i1,v1,v3,o1}
\fmf{fermion}{o2,v4,v2,i2}
\fmf{photon}{v1,v2}
\fmf{photon}{v3,v4}
\fmfdotn{v}{4}
\end{fmfgraph*}
\end{fmffile}

\end{document}
```

![feynman diagram 1](/img/post/2016-11-16/feynman2.png)

> 以下省略 `\begin{fmfgraph*}...\end{fmfgraph*}`以外的代码

#### 在线上添加标记

```latex
\begin{fmfgraph*}(200,120) 
\fmfpen{thick}
\fmfleft{i1,i2} 
\fmfright{o1,o2}
\fmf{fermion}{i1,v1,o1} 
\fmf{fermion}{i2,v2,o2}
\fmf{photon,label=$q$}{v1,v2} 
\fmfdot{v1,v2}
\end{fmfgraph*}
```

![feynman diagram 3](/img/post/2016-11-16/feynman4.png)

#### 线条类型

feynMP/feynMF 提供了完整的费曼图线条类型，可以使用 `Name` 中的名字，也可以自然的按照粒子或作用类型使用 `Aliases` 一列中的名字。

![line style](/img/post/2016-11-16/line-style.png)


> 文中代码可正常编译，本文介绍比较简略，只作为引，有兴趣和需要的可以参考 [官方文档](http://www.pd.infn.it/TeX/doc/latex/feynmf/manual.pdf)，或者在 [stackexchange](http://tex.stackexchange.com) 搜索问答，更多详细内容请参考文档（英文）