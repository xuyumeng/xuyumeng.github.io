---
layout:     post
title:      "物理学中用到的数学（一）"
subtitle:   "$R^3$空间中的向量分析"
date:       2016-06-16 19:47:52 +08:00
author:     "Y.M. Xu"
header-img: "img/bg/fractal-1078325_1280.jpg"
catalog: true
tags:
    - 物理
    - 数学
    - 数理方法

---
本系列内容是《数学物理方法》（梁昆淼）和《物理学家用的张量和群论导论》（Nadir Jeevanjee）两本书的读书笔记，以后可能还会加入其它书籍的内容，希望能总结一物理研究中用到的数学。

本章内容总结自《数学物理方法》（梁昆淼）

## 1. 向量(vector)

>有方向和大小的量称为向量

向量$A$、$B$的标量积：

$$
\overrightarrow{A} \cdot \overrightarrow{B} = |\overrightarrow{A}|\cdot|\overrightarrow{B}| cos\theta
$$

向量$A$、$B$的矢量积：

$$
\overrightarrow{A} \times \overrightarrow{B} = |\overrightarrow{A}|\cdot|\overrightarrow{B}| cos\theta
$$

向量是几何空间中客观存在的量，它是不依赖于坐标系而客观存在的，正如我们物理世界中的物理规律也是不依赖于坐标系选取的。正是由于这种“不依赖坐标系选择”的共同特征，使得我们用向量空间来描述物理规律成为可能。

定量研究时需要引入坐标系，对于同一向量，由于它是空间中客观存在的量，所以在不同坐标系下的描述是等价的。

## 2. $R^3$ 空间中的向量代数

>$R^3$空间就是三维 Euclidean （欧几里得）空间，即三维正交实向量空间

引入 Descartes 坐标系

$$
\overrightarrow{r} = x \overrightarrow{e_x} + y \overrightarrow{e_y} + z \overrightarrow{e_z}
$$

$R^3$ 空间中向量合成法则

定义向量 $\overrightarrow{A} = A_1\overrightarrow{e_1} + A_2\overrightarrow{e_2} + A_3\overrightarrow{e_3}$，$\overrightarrow{B} = B_1\overrightarrow{e_1} + B_2\overrightarrow{e_2} + B_3\overrightarrow{e_3}$

### 2.1 加法

__定义__

$$
\overrightarrow{A} + \overrightarrow{B} = (A_1 + B_1)\overrightarrow{e_1} + (A_2 + B_2)\overrightarrow{e_2} + (A_3 + B_3)\overrightarrow{e_3}
$$

从定义得：

$$
\overrightarrow{A} + \overrightarrow{B} = \overrightarrow{B} + \overrightarrow{A}
$$

$\overrightarrow{0}$和任何向量相加都等于它本身

$$
\overrightarrow{0} + \overrightarrow{A} = \overrightarrow{A}
$$

同时 $\overrightarrow{A} - \overrightarrow{A} = \overrightarrow{A} + (-\overrightarrow{A}) = \overrightarrow{0}$ 

并可得

$$
\overrightarrow{A} - \overrightarrow{B} = (A_1 - B_1)\overrightarrow{e_1} + (A_2 - B_2)\overrightarrow{e_2} + (A_3 - B_3)\overrightarrow{e_3}
$$

### 2.2 向量数乘

对于任意实数 $\alpha \in \Re$, 有

$$
\alpha \overrightarrow{A} = \alpha A_1\overrightarrow{e_1} + \alpha A_2\overrightarrow{e_2} + \alpha A_3\overrightarrow{e_3}
$$

### 2.3 向量的标量基

定义：

