---
layout:     post
title:      "Spring boot中使用Caffeine缓存"  
subtitle:   "基本使用方法和缓存信息查看"
date:       2016-03-17 11:24:00 +08:00
author:     Sun Jianjiao
header-img: "img/bg/default-bg.jpg"
catalog: true
tags:
    - Spring Boot Caching
    - Caffeine

---

Spring 框架提供了透明的缓存添加方法，通过抽象层屏蔽了不同缓存之间的差异。通过@EnableCaching注解，spring boot自动对缓存进行配置。

本文使用的spring boot版本2.1.0.RELEASE

# 1. 注解说明
- @Cacheable  缓存的入口，首先检查缓存如果没有命中则执行方法并将方法结果缓存
- @CacheEvict  缓存回收，清空对应的缓存数据
- @CachePut   缓存更新，执行方法并将方法执行结果更新到缓存中
- @Caching    组合多个缓存操作
- @CacheConfig 类级别的公共配置

# 2. 缓存信息查看
确认如下信息：
- 缓存的命中率
- 是否是当前配置的缓存（缺省是ConcurrentMap）

可以通过actuator提供的缓存信息查看，可以参看文档[Spring boot actuator系统监控](https://unanao.github.io/2016/09/10/java-spring-boot-actuator/)。

但是2.1.0的版本，caches是没有expose的，所以需要在application.yml中配置暴露caches:
```
management:
  endpoints:
    web:
      exposure:
        include: caches,info
```

# 3. Caffeine
Caffeine 是使用Java8对Guava缓存的重写版本，在Spring Boot 2.0中取代了Guava，作为本地缓存使用。

**本地缓存**的最大的优点是应用和cache是在同一个进程内部，请求缓存非常快速，没有过多的网络开销等，在单应用不需要集群支持或者集群情况下各节点无需互相通知的场景下使用本地缓存较合适；同时，它的缺点也是应为缓存跟应用程序耦合，多个应用程序无法直接的共享缓存，各应用或集群的各节点都需要维护自己的单独缓存，对内存是一种浪费。

## 3.1 添加依赖
build.gradle
```
    compile "org.springframework.boot:spring-boot-starter-cache"
    compile "com.github.ben-manes.caffeine:caffeine:2.6.2"
```

## 3.2 开启缓存的支持
```
@SpringBootApplication
@EnableCaching                //让spring boot开启对缓存的支持
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

## 3.3 配置文件
```
spring:
  cache:
    cache-names: outLimit，notOutLimit
    caffeine:
      spec: maximumSize=500, expireAfterWrite=5s
```

# 4. 参看文档
1. [Spring Boot features: Caching](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-caching.html#boot-features-caching-provider-caffeine)