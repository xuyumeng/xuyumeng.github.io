---
layout:     post
title:      "网络IO实现方式"  
subtitle:   "BIO, NIO, AIO"
author:     Sun Jianjiao
header-style: text
catalog: true
tags:

    - java

---

# 1. BIO

BIO即Blocking IO, 采用阻塞的方式实现。也就是一个Socket套接字需要使用一个线程来进行处理。发生建立连接，读数据，写数据的操作时，都可能会阻塞。这个模式的好处是简单，但是带来的主要问题是一个线程只能处理一个socket， 如果是Server端，支持并发的连接时，就需要更多的线程来完成这个工作。