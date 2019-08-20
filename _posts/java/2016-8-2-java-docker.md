---
layout:     post
title:      "Java开发中方便的使用Docker"
subtitle:   "通过gradle palantir的docker插件进行镜像的创建和上传以及docker管理"
author:     Sun Jianjiao
header-img: "img/bg/railway-station-1363771_1280.jpg"
catalog: true
tags:
    - java

---


## 1. build.gradle编写

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

## 2. 编写Dockerfile

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

## 3. IDEA中进行docker操作

![镜像管理和docker管理](/img/post/java/docker/image-management.png)

现在可以通过idea右侧gradle中的docker和 docker run进行管理了。
