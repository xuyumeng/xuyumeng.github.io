---
layout:     post
title:      "简化java微服务开发 "
subtitle:   "Java微服务开发环境搭建和流程优化"
author:     Sun Jianjiao
header-img: "img/bg/railway-station-1363771_1280.jpg"
catalog: true
tags:
    - java

---

微服务虽然使得单个模块的开发变得简单，但是由于依赖多个服务，使得开发和调试比单体应用麻烦很多。怎么保证引入微服务后，打开IDE就可以进行开发和调试，和单体应用开发差不多，是保证和提高微服务开发效率的关键。同时由于服务越来越多，部署运行环境成为一个负担。本文通过介绍开发过程中使用的工具和方法来简化开发和部署，提高开发效率。

# 1. 方便快速创建/发布docker镜像

为了解决部署环境的问题，现在都会通过docker来管理，所以能够方便的构建和发布镜像变得很重要，下面介绍通过gradle插件完成镜像生成和发布。

## 1.1 build.gradle编写

```groovy
plugins {
    id 'org.springframework.boot' version '1.5.21.RELEASE'
    id 'java'
    id "com.palantir.docker" version "0.22.1"                     // 引入镜像管理插件
    id 'com.palantir.docker-run' version "0.22.1"                 // 引入docker管理插件
}

... ... //省略无用的代码


// docker镜像生成和上传
docker {
    dependsOn(build)

    name "${hub-host}/${user-name}/${app-name}:${version}"               // 指定上传的docker hub地址，用户名，应用名称和版本号
    dockerfile file('dockerfile/Dockerfile')                             // 指定Dockerfile的地址, 相对build.gradle的路径
    files jar.archiveFile, "src/main/resources/bootstrap.yml"            // 指定docker build 上下中需要包含的文件
}


// docker运行管理
dockerRun {
    image  "${hub-host}/${user-name}/${app-name}:${version}"             // 同上面的name， 最简单的方式只指定image就可以了，后面的配置根据需要选择
    ports "${expose-port}:${port}"                                       // 端口映射
    name '${container-name}'                                             // 指定docker 运行的名称
    network 'ectd-network'                                               // 制定所在网络
    env 'JAVA_OPTS':'-Xmx512m -Xms512m', 'PROFILE':'testing'             // 指定环境变量  
}
```

## 1.2 编写Dockerfile

```Dockerfile
FROM openjdk:8-jdk-alpine

# 添加清华的alpine镜像，下载和安装更快一些
RUN echo "https://mirror.tuna.tsinghua.edu.cn/alpine/latest-stable/community" > /etc/apk/repositories
RUN echo "https://mirror.tuna.tsinghua.edu.cn/alpine/latest-stable/main" >> /etc/apk/repositories

ENV APP_DIR=/app
ENV APP=configuration.jar
ENV APP_PORT=28888
ENV SPRING_OUTPUT_ANSI_ENABLED=ALWAYS \
    JAVA_OPTS=""
ENV PROFILE="default"

# 因为在build.gradle中已经放在docker build的上下文了，所以直接复制就可以了
COPY *.jar $APP_DIR/$APP
COPY bootstrap.yml $APP_DIR/bootstrap.yml

# 可选，为了可以在docker里面使用jps/jstack/jstat/jmap等进行问题定位，具体原因参考
# https://unanao.github.io/2018/03/16/jvm/
RUN apk add --no-cache tini

EXPOSE $APP_PORT
WORKDIR $APP_DIR

ENTRYPOINT /sbin/tini -- java \
        ${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom \
        -Dspring.profiles.active=${PROFILE} \
        -jar $APP
```

## 1.3 IDEA中进行docker操作

![镜像管理和docker管理](/img/post/java/docker/image-management.png)

现在可以通过idea右侧gradle中的docker和 docker run进行管理了。

## 1.4 通过gradle的命令行进行docker的操作

``` shell
    ./gradlew clean dockerClean    # 清理编译环境
    ./gradlew docker -x test       # Docker镜像生成
    ./gradlew dockerPush -x test   # Docker镜像上传

```

# 2 远程调试和监控
> docker让部署更方便，但是调试起来比本地开发稍微有些麻烦。 

## 2.1 docker-compose 文件修改

1. 指定启动参数：在 Dockerfile 中有一个指令叫做 ENTRYPOINT 指令，用于指定接入点，在docker-compose.yml 中可以定义接入点，覆盖 Dockerfile 中的定义就可以指定启动的调试参数了。
2. 暴露调试端口

### 2.1.1 配置举例
```
  export-distro:
    image: edgexfoundry/docker-export-distro
    ports:
      - "48070:48070"
      - "5566"
      - "58070:58070"                           # 暴露调试端口
      - "38070:38070"                           # 暴露jmx端口
    container_name: edgex-export-distro
    hostname: edgex-export-distro
    networks:
      - edgex-network
    volumes:
      - db-data:/data/db
      - log-data:/edgex/logs
      - consul-config:/consul/config
      - consul-data:/consul/data
    depends_on:
      - volume
      - config-seed
      - mongo
      - logging
      - notifications
      - metadata
      - data
      - export-client
                                               # 覆盖docker entrypoint
    entrypoint: java -jar -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=58070 -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.port=38070 -Dcom.sun.management.jmxremote.rmi.port=38070 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=192.168.88.235 -Djava.security.egd=file:/dev/urandom export.jar

```

### 2.1.2 开启远程调试
```
-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=58070
```
将58080换成实际的端口， 只要端口不冲突就可以使用。

### 2.1.3 开启jmx支持visualVM远程监控

```
-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.port=38071 -Dcom.sun.management.jmxremote.rmi.port=38071 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=192.168.88.235
```
- 将38071换成jmx的实际端口号， 只要端口不冲突就可以使用。
- 192.168.88.235, 换成docker所在的服务器的地址。

## 2.2 让配置生效

启动镜像
```
docker-compose up -d image-name
```
也可以不加-d，查看启动的详细信息。

## 2.3 问题定位
> 如果后续无法连接，可以通过下面的方法进行定位

### 2.3.1 登录到docker里面查看启动的参数

```
E:\project\edgex\images>docker exec -it edgex-export-client sh
/edgex/edgex-export-client # ps aux
PID   USER     TIME   COMMAND
    1 root       0:00 /bin/sh -c java -jar -Djava.security.egd=file:/dev/urando
    5 root       1:43 java -jar -Djava.security.egd=file:/dev/urandom -Xmx100M
  108 root       0:00 sh
  114 root       0:00 ps aux

```
查看ps到的参数是否与docker-compoer.yml中配置的一致。

### 2.3.2 调试端口是否已经被占用
关闭镜像，查看配置的调试端口是否还在
```
netstat -n
```

## 2.4. idea远程调试

1. 进入运行选项配置的
![edit config](/img/post/java/docker/edit-config.png) 

2. 添加remote运行的选项
![remote add](/img/post/java/docker/config-ip-port.png)

## 2.5 Java VisualVM远程监控

### 2.5.1 方法一

“文件” -> "添加JMX连接"

### 2.5.2 方法二

1. “文件” -> "添加远程主机"
2. 在远程主机上， 右键。“添加JMX连接”

添加完成后，“远程“的下面就会出现添加的“远程主机”， 然后点开“+”，就可以看到想要监视的进程啦。

## 2.6 Docker中如何支持jdk工具

建议docker的镜像使用jdk，不要使用jre，使用jre的话，还需要折腾工具链。
使用alpine镜像会有个问题，如果java进程的pid=1，那么无法执行jdk的各种连接java进程的命令，会报如下错误：

```log
Unable to get pid of LinuxThreads manager thread
```

解决的方法是：启动一个init进程（pid=1）来接收docker stop and docker kill的信号，它会转发信号给其他进程，负责关闭僵尸进程。java进程由init进程启动。如Dockerfile中增加和修改如下内容：

```Dockerfile
FROM openjdk:8-jdk-alpine   # 使用jdk的alpine版本，包含开发和定位问题的工具

# 添加清华大学的alpine镜像，加快tini安装
RUN echo "https://mirror.tuna.tsinghua.edu.cn/alpine/latest-stable/community" > /etc/apk/repositories
RUN echo "https://mirror.tuna.tsinghua.edu.cn/alpine/latest-stable/main" >> /etc/apk/repositories

RUN apk add --no-cache tini  # 安装tinit

ENTRYPOINT /sbin/tini -- java -jar ${app-name}  # 使用tinit作为入口进程启动java进程
```

## 2.7 docker alpine 中软件安装

如果使用的jre alpine作为基础镜像，打包的镜像是没有jstat/jps等命令的。建议参考上面的方法初始化时直接添加

```Dockerfile
FROM openjdk:8-jdk-alpine
VOLUME /tmp

# 添加清华大学的alpine镜像，加快软件安装
RUN echo "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.6/community" > /etc/apk/repositories
RUN echo "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.6/main" >> /etc/apk/repositories

```

通过如下命令安装（可以通过[这里](https://pkgs.alpinelinux.org/packages)查询文件在哪个包里，如jstat)

```shell
apk add openjdk8
```

jstat等安装在:

```shell
/usr/lib/jvm/java-1.8-openjdk/bin
```

# 3. 如何保证打开IDE就可以开发

上面2节说明了如果开发和调试单个微服务，但是单个微服务会依赖其它服务，如服务注册，服务发现，配置中心和相关业务服务等。这就导致打开IDE无法运行要开发的服务，必须启动依赖的服务才可以，这就需要启动多个微服务。这就需要开发小组需要有公共的开发环境，运行所有镜像，并且开发网络和镜像网络是通的。这样才能保证通过服务注册的服务名找到对应的服务地址和端口才能通信。

## 3.1 有多份配置文件

如dev/testing/prod， dev专门用开发，testing用于测试，production用于生成环境。

建议将dev的配置文件加一个example后缀，git只管理application-dev.example.yml， 并且设置.gitignore不能上传application-dev.yml, 这样能够保证不会随便上传自己的私有配置，导致不必要的冲突。

## 3.2 服务注册设置prefer-ip

```yaml
eureka:
  instance:
    prefer-ip-address: true
```

## 3.3 docker的网络以host模式运行

```Docker
mysql:
    image: mysql:8.0
    ... ...
    network_mode: "host"   # 设置与宿主机使用相同的网络，这样就直接使用宿主机的ip地址了。
```

如果使用的docker-compose，可能需要新建一个专门用于dev的文件，修改网络模式。

## 3.4 支持参数配置

如果使用的docker-compose, 可以使用.env配置。以配置java的profile为例：

```yaml
  xxxx:
    image: "xxxx/xxxx/xxxx:2.0"
    environment:
      - PROFILE=${PROFILE}

```

通过.env配置文件配置docker-compose的参数，当然建议dev的的.env也命名为example.env, 防止被上传私有的，导致冲突。

```config
$cat .env
PROFILE=dev
```

当然java需要接受PROFILE参数，如Dokerfile的启动参数:

```Dokerfile
ENTRYPOINT /sbin/tini -- java \
        ${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom \
        -Dspring.profiles.active=${PROFILE} \
        -jar $APP
```
