---
layout:     post
title:      "Nginx + Docker 实现单点负载均衡"
subtitle:   "如何在预算有限的情况下实现不停机更新并减少宕机概率"
date:       2016-06-15 23:05:52 +08:00
author:     "Y.M. Xu"
header-img: "img/bg/post-2016-fractal.jpg"
catalog: true
tags:
    - 服务器
    - Linux
    - CentOS 7
    - Nginx
    - Docker
    - 负载均衡

---

最近在给一个电子商务平台做服务器维护，因为预算有限，只能支撑一台服务器，负责做后台的工程师用的是 Java + Tomcat，在运维过程中，经常出现更新程序之后重启应用失败，而重启 Tomcat 一般都会出现无法访问的问题，需要多次重启甚至是重启服务器才可以解决问题，每次服务器都要 down 几分钟甚至十几分钟，这对电子商务网站来说是很严重的问题。

因为我主要用的是 Rails，对 Tomcat 不熟悉，所以并不知道是哪里导致的问题，虽然建议使用两台服务器负载均衡来解决单点故障，但是因为资金问题没有被采纳，最近再次看到了 Docker，突然想到为什么不在一台服务器里虚拟两个 Docker，然后用 Nginx 来做负载均衡呢？然后就开始了尝试。

> 所用系统：CentOS 7

## Docker 的安装

1\. 首先确认是否安装了 `curl` (一般发行版里都带):

```bash
$ which curl
```
如果没有的话，在 CentOS 里用 `yum` 安装，在 Ubuntu 里用 `apt-get` 安装

```bash
$ sudo yum install -y curl
```

2\. 下载最新的 Docker

```bash
$ curl -fsSL https://get.docker.com/ | sh
```

3\. 启动 Docker 服务（这个在官方文档中没有写，找了好久问题才发现需要启动服务，囧……😢）
	
```bash
$ systemctl start docker
```

只需要这三步 Docker 就在你的服务器中安装完成了


## Nginx 的安装

以前 Nginx 我都是喜欢用 [epel](https://fedoraproject.org/wiki/EPEL/zh-cn) 源安装，觉得简便，但是版本比较老，比较懒的可以试试：

```bash
$ yum install -y epel-release
$ yum install -y nginx
```

更推荐的方式是手动编译:

1\. 从 [Nginx 官方网站](http://nginx.org/en/download.html) 上下载最新的 Nginx 稳定版

```bash
$ wget http://nginx.org/download/nginx-1.10.1.tar.gz  # 换成最新的 stable 版本号
$ tar -xvf nginx-1.10.1.tar.gz
$ cd nginx-1.10.1
```
2\. 编译安装

``` bash
$ ./config \
	--sbin-path=/opt/nginx/sbin \
    --conf-path=/opt/nginx/config/nginx.conf \
    --pid-path=/opt/nginx/config/nginx.pid \
    --with-http_ssl_module
$ make && make install
```

> 因为这次我使用的是 passenger 编译 nginx，没有自己编译过，参数选择没有经过实践，请先参考 [config 设置的官方文档](http://nginx.org/en/docs/configure.html)，等以后我再补上

## Docker 的基本概念和使用方法

Docker 主要要区分的是 image（镜像）和 container（容器）

一个 __image__ 是指打包好的程序和所需的文件及环境，当使用 `docker run` 命令的时候，__image__ 并不会被改变，而是将会创建一个镜像的实例 __container__，当你对一个 __image__ 多次使用 `docker run` 命令的时候，将会创建多个互相独立的 __container__

>暂时先讲这么多，因为这是下面需要的概念，其他的以后会补充。

## Tomcat 的安装与运行

使用`docker search`可以查到 [Docker Hub](https://hub.docker.com/) 最新的 image：

```bash
$ sudo docker search tomcat
NAME                       DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
tomcat                     Apache Tomcat is an open source implementa...   733       [OK]       
dordoka/tomcat             Ubuntu 14.04, Oracle JDK 8 and Tomcat 8 ba...   19                   [OK]
consol/tomcat-7.0          Tomcat 7.0.57, 8080, "admin/admin"              16                   [OK]
consol/tomcat-8.0          Tomcat 8.0.15, 8080, "admin/admin"              14                   [OK]
cloudesire/tomcat          Tomcat server, 6/7/8                            8                    [OK]
davidcaste/alpine-tomcat   Apache Tomcat 7/8 using Oracle Java 7/8 wi...   6                    [OK]
andreptb/tomcat            Debian Jessie based image with Apache Tomc...   4                    [OK]
kieker/tomcat                                                              2                    [OK]
fbrx/tomcat                Minimal Tomcat image based on Alpine Linux      2                    [OK]
nicescale/tomcat           Tomcat service for NiceScale. http://nices...   1                    [OK]
openweb/oracle-tomcat      A fork off of Official tomcat image with O...   1                    [OK]
chrisipa/tomcat            Tomcat docker image based on Debian Jessie...   1                    [OK]
cirit/tomcat               Tomcat Docker Image with collectd               1                    [OK]
ericogr/tomcat             Tomcat 8, 8080, "docker/docker"                 1                    [OK]
jtech/tomcat               Latest Tomcat production distribution on l...   1                    [OK]
abzcoding/tomcat-redis     a tomcat container with redis as session m...   1                    [OK]
bitnami/tomcat             Bitnami Tomcat Docker Image                     0                    [OK]
splazit/tomcat                                                             0                    [OK]
yyqqing/tomcat             Tomcat run on Oracle JRE 8, Alpine              0                    [OK]
foobot/tomcat                                                              0                    [OK]
davidcaste/debian-tomcat   Yet another Debian Docker image for Tomcat...   0                    [OK]
tb4mmaggots/tomcat         Apache Tomcat micro container                   0                    [OK]
cheewai/tomcat             Tomcat and Oracle JRE in docker                 0                    [OK]
inspectit/tomcat           Tomcat with inspectIT                           0                    [OK]
mccoder/tomcat             Tomcat with APR                                 0                    [OK]
```
我们这里使用官方的 docker，也就是标记 `OFFICIAL` 的那个，[官方网站](https://hub.docker.com/_/tomcat/) 描述了支持的标签

![docker tomcat](/img/post/2016-06-15-docker/docker-tomcat.png)

最简单的使用方法是直接用 `docker run` 命令，docker 会直接下载之后运行，我们这里使用 tomcat 6.0：

```bash
$ sudo docker run -p 8080:8080 tomcat:6.0
```

这个命令会下载 tomcat image 后运行 Tomcat 6.0，并将创建的 container 的8080端口暴露到宿主机器的8080端口（目前看来，container 再创建之后端口就不能更改了），这时用 `docker ps` 命令可以查看运行中的 container

```bash
$ docker ps
CONTAINER ID        IMAGE                  COMMAND             CREATED             STATUS              PORTS                    NAMES
e05fa71df20d        tomcat         "catalina.sh run"   3 days ago          Up 3 days           0.0.0.0:8080->8080/tcp   nauseous_liskov
```

这里我们看到的信息有 container 的 ID、image、创建和运行时间、端口映射以及别名，这个别名是自动生成的，当然也可以自己制定。

当然，现在创建的 tomcat 是没有任何设置的，没有设置管理员账户也就意味着我们没办法登陆，虽然可以登陆 docker 修改，但是我们现在希望每一个创建的实例都是配置好了的，所以我们不再从官方的 image 中直接启动，而是使用自己修改的版本。

首先在当前任意目录创建一个 Dockerfile （不用担心位置，因为新的 image 并不会在当前目录存储）：

```bash
FROM tomcat:7.0
MAINTAINER "Y.M. Xu <yumengxu1994@icloud.com>"

ADD tomcat-users.xml /usr/local/tomcat/conf/
```
再在当前目录下创建 `tomcat-users.xml` 文件：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings>
<servers> 
<server>
<id>TomcatServer</id>
<username>admin</username>
<password>password</password>
</server> 
</servers>
```


然后用如下命令构建新的 image ：

```bash
$ sudo docker build -t xym/tomcat .
Sending build context to Docker daemon 5.632 kB
Sending build context to Docker daemon 
Step 0 : FROM tomcat:7.0
---> 77eb038c09d1
Step 1 : MAINTAINER "Y.M. Xu <yumengxu1994@icloud.com>"
---> Using cache
---> 5009ba884f1f
Step 3 : ADD tomcat-users.xml /usr/local/tomcat/conf/
---> Using cache
---> 33917c541bb5
Successfully built 33917c541bb5
```

一般习惯的命名规则是 `域/程序`，这样方便不同的管理人员区分不同的 image，这样，我们定制的 image 就创建好了，然后从定制的 image 创建实例：

```bash
$ sudo docker run -p 8080:8080 xym/tomcat
```

> 未完待续。。。
## Nginx 配置负载均衡

## 总结与问题





