---
layout:     post
title:      "Spring boot支持多配置文件的方法"  
subtitle:   "同时支持开发和生产环境"
author:     Sun Jianjiao
header-style: text
catalog: true
tags:
    - java

---

# spring boot支持多配置文件

在spring boot的开发中,会有不同的配置,例如日志打印,数据库连接等,开发,测试,生产每个环境可能配置都不一致, spring boot支持通过不同的profile来配置不同环境的配置。

**推荐方案1.2 使用多个yml配置文件进行配置属性文件。**


## 1.1 方案1 —— 通过不同的profile来配置属性文件:

application.yml配置如下：

```
# 公共配置
spring:
  profiles:
    active: dev

# dev 环境配置
---
spring:
    profiles: "dev"
    datasource:
        url: jdbc:sqlserver://127.0.0.1:1433;DatabaseName=dev_db
        username: sa
        password: db-password

# 测试环境配置
---
spring:
    profiles: "test"
    datasource:
        url: jdbc:sqlserver://192.168.1.2:1433; DatabaseName=test_db
        username: sa
        password: db-password

# 生产环境配置
---
spring:
    profiles: "production"
    datasource:
        url: jdbc:sqlserver://192.168.12.104:1433;DatabaseName=production_db
        username: sa
        password: db-password

```

非常简单的配置,application.yml文件分为四部分,使用一组(---)来作为分隔符,第一部分,为通用配置部分,表示三个环境都通用的属性

后面三段分别为,开发,测试,生产,都用spring.profiles指定了一个值(开发为dev,测试为test,生产为pro),这个值表示该段配置应该用在哪个profile里面,

上面的XXX是每个环境的 spring.profiles对应的value,通过这个,可以控制本地启动调用哪个环境的配置文件,例如:

```
spring:
    profiles:
        active: dev
```

加载的,就是开发环境的属性,如果dev换成test,则会加载测试环境的属性,生产也是如此,

PS:如果spring.profiles.active没有指定值,那么只会使用没有指定spring.profiles文件的值,也就是只会加载通用的配置

如果是部署到服务器的话,我们正常打成jar包,发布是时候,采用:

--spring.profiles.active=test或者pro 来控制加载哪个环境的配置,完整命令如下:

```
java -jar xxxxx.jar --spring.profiles.active=test  表示加载测试环境的配置

java -jar xxxxx.jar --spring.profiles.active=pro  表示加载生产环境的配置
```

## 1.2 使用多个yml配置文件进行配置属性文件:
    如果是使用多个yml来配置属性,我们则可以这么使用,通过与配置文件相同的明明规范,创建application-{profile}.yml文件,将于环境无关的属性,放置到application.yml文件里面,可以通过这种形式来配置多个环境的属性文件,在application.yml文件里面指定spring.profiles.active=profiles的值,来加载不同环境的配置,如果不指定,则默认只使用application.yml属性文件,不会加载其他的profiles的配置

application.yml 设置缺省为
```
spring:
    profiles:
        active: "dev"
```

## 1.3 idea 选择启动的配置文件
![set-profile](/img/post/spring/spring-boot-multi-conifg-set-profile.png)
