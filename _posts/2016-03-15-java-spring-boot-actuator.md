---
layout:     post
title:      "Spring boot actuator进行系统监控"  
subtitle:   "Spring boot 2.0 actuator的使用方法"
date:       2016-09-10 17:19:00 +08:00
author:     Sun Jianjiao
header-img: "img/bg/default-bg.jpg"
catalog: true
tags:
    - spring
    - actuator
    - 系统监控
    - java
---

本文以spring boot 2.X为例介绍actuator。 

# 1. 文档查看
spring boot 2和spring boot 1.x还是有一点区别的。其实spring boot 2.1.x 和2.0.x还是有区别的。

所以， 不同的spring boot版本参考对应的文档，不同的文档支持的功能是不一样的。
所有版本文档地址： https://docs.spring.io/spring-boot/docs/ ， 选择对应的版本， 选择“reference”就可以了。 

最新的spring-boot actuator的文档： https://docs.spring.io/spring-boot/docs/current/reference/html/production-ready-endpoints.html

可以通过文档查看支持哪些endpoint，以及endpoint对应的内容。


- Spring boot 1.x 默认expose 的endpoint很多
- spring boot 2.x 默认值expose 2个endpoint—— “info”和“health”
- spring boot 2.x 访问endpoint的URI需要加上/actuator
- Spring boot 2.1.x启动的时候，已经不打印Map了。
- 支持的功能不一样， spring boot 2.1.0.RELEASE支持caches， 但是2.0.1.RELEASE不支持

# 2. 使用方法
## 2.1 引入actuator

build.gradle中增加如下引用：
```
compile "org.springframework.boot:spring-boot-starter-actuator"
```

## 2.2 启用方法
缺省情况下，除了shutdown以外，所有的endpoints都是使能的，但是至少有 health 和 info 对外可以通过web的方式访问.

### 2.2.1 启用所有
application.yml 中增加如下内容：

```
management:
  endpoints:
    web:
      exposure:
        include: "*"
```

## 2.2.2 启用指定对外可以访问的endpoint
如果指定metrics, env, 在application中增加如下内容：
```
management:
  endpoints:
    web:
      exposure:
        include: metrics, env
```

# 3. 使用方法
查看支持endpoint, 然后根据href进一步访问
```
http://${ip}:${port}/actuator/
```
支持caches(需要spring boot 2.1.0.RELEASE)和info的返回结果，通过json格式化后的结果：
```
{
    "_links":{
        "self":{
            "href":"http://127.0.0.1:8083/actuator",
            "templated":false
        },
        "caches-cache":{
            "href":"http://127.0.0.1:8083/actuator/caches/{cache}",
            "templated":true
        },
        "caches":{
            "href":"http://127.0.0.1:8083/actuator/caches",
            "templated":false
        },
        "info":{
            "href":"http://127.0.0.1:8083/actuator/info",
            "templated":false
        }
    }
}
```