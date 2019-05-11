---
layout:     post
title:      "Spring boot中使用Caffeine缓存"  
subtitle:   "基本使用方法和缓存信息查看"
author:     Sun Jianjiao
header-style: text
catalog: true
tags:
    - java

---

缓存是将数据从读取较慢的介质上放到读取较快的介质上，如将磁盘上的读取出来放到内存里，这样当需要获取数据时，就能够直接从内存中拿到数据返回，能够很大程度的提高速度。

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

```yaml
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

```java
@SpringBootApplication
@EnableCaching                //让spring boot开启对缓存的支持
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

## 3.3 配置文件

```yaml
spring:
  cache:
    cache-names: outLimit，notOutLimit
    caffeine:
      spec: maximumSize=500, expireAfterAccess=600s
```

## 3.4 查看统计信息
对于缓存命中率非常重要，所以需要对缓存的命中率进行统计，至少在调试和开发阶段需要对命中率进行确认。

### 3.4.1 开启记录统计信息

application.yml中启用recoredStats, 对缓存信息进行统计。

```yaml
spring:
  cache:
    cache-names: 
      - cacheName1
      - cacheName2
    caffeine:
      spec: maximumSize=500, expireAfterAccess=600s, recordStats
```

### 3.4.2 获取指定cache统计信息:

```yaml
    @Autowired
    CacheManager cacheManager;

    private CacheStats stats(String cacheName) {
        Cache cache = (Cache) cacheManager.getCache(cacheName).getNativeCache();

        return cache.stats();
    }

```

### 3.4.3 获取所有cache统计信息：

由于CacheStats没有记录缓存的名字，所以需要对CacheStats增加name字段，封装成新的Dto：

```java
import com.github.benmanes.caffeine.cache.stats.CacheStats;
import lombok.Data;

@Data
public class CacheStatsDto {
    String name;
    CacheStats cacheStats;

    public CacheStatsDto(String name, CacheStats cacheStats) {
        this.name = name;
        this.cacheStats = cacheStats;
    }
}
```

遍历所有的缓存，添加统计信息到链表：

```java
    public List<CacheStatsDto> stats() {
        Collection<String> names = cacheManager.getCacheNames();
        List<CacheStatsDto> cacheStatsDtoList = new LinkedList<>();

        for (String name: names) {
            CacheStats cacheStats = stats(name);

            CacheStatsDto cacheStatsDto = new CacheStatsDto(name, cacheStats);
            cacheStatsDtoList.add(cacheStatsDto);
        }

        return cacheStatsDtoList;
    }

```

## 3.5 对指定的操作进行缓存

```Java
    @Cacheable(value = "cacheName1", key="#id",sync = true)
    public String getNodeInfo(int id) {
        String node =  collectNodeClient.findDataType("315b24e65624620d996715d8e1eb1b41",
                "贴片机采集点1", "生产数");

        return node;
    }
```

缓存操作的接口和调用的函数分成独立的类，我这里在同一个类里面不生效，没有使用caffeine, 使用了缺省的ConcurrentMap。 修改为独立的类后，使用了caffeine。

# 4. Redis

## 4.1 过期机制
千万不要忘记设立过期时间，若不设，只能等内存满了，一个个查看Key有没有使用。

### 4.1.1 过期策略
Redis采用的是定期删除策略和懒汉式的策略互相配合。**Redis内部自动完成！**

- 定期删除策略：每隔一段时间执行一次删除过期key操作
- 懒惰淘汰策略：key过期的时候不删除，每次通过key获取值的时候去检查是否过期，若过期，则删除，返回null

懒惰淘汰机制会造成内存浪费，但是节省CPU资源。定时淘汰机制保证过期的数据一定会被释放掉，但是相对消耗CPU资源
所以，在实际中，如果我们要自己设计过期策略，在使用懒汉式删除+定期删除时，控制时长和频率这个尤为关键，需要结合服务器性能，已经并发量等情况进行调整，以致最佳。

## 4.2. 使用String还是Hash
STACK OVERFLOW 上一个对 String 和 Hash 的讨论: [Redis strings vs Redis hashes to represent JSON: efficiency?
](https://stackoverflow.com/questions/16375188/redis-strings-vs-redis-hashes-to-represent-json-efficiency)

对于一个对象是把本身的数据序列化后用 String 存储，还是使用 Hash 来分别存储对象的各个属性：

- 如果在大多数时候要访问对象的大部分数据：使用 String
- 如果在大多数时候只要访问对象的小部分数据：使用 Hash
- 如果对象里面还有对象这种结构复杂的，最好用 String。否则最外层用 Hash，里面又将对象序列化，两者混用可能导致混乱。

## 4.3. redisTemplate

spring RedisTemplate 是对redis的各种操作的封装，它支持所有的 redis 原生的 api。

### 4.3.1 StringRedisTemplate与RedisTemplate

两者的关系是StringRedisTemplate继承RedisTemplate。
两者的数据是不共通的；也就是说StringRedisTemplate只能管理StringRedisTemplate里面的数据，RedisTemplate只能管理RedisTemplate中的数据。

Redis的String数据结构，推荐使用StringRedisTemplate, 否则使用RedisTemplate需要更改序列化方式。

### 4.3.2 restTemplate的操作

在RedisTemplate中，提供了一个工厂方法:opsForValue()，这个方法会返回一个默认的操作类。

```Java
redisTemplate.opsForValue();//操作字符串
redisTemplate.opsForHash();//操作hash
redisTemplate.opsForList();//操作list
redisTemplate.opsForSet();//操作set
redisTemplate.opsForZSet();//操作有序set
```

## 4.4 使用举例

### 4.4.1 build.gradle

```groovy
dependencies {
    implementation('org.springframework.boot:spring-boot-starter-cache')
    implementation('org.springframework.boot:spring-boot-starter-data-redis')

    // https://mvnrepository.com/artifact/com.fasterxml.jackson.core/jackson-databind
    compile group: 'com.fasterxml.jackson.core', name: 'jackson-databind', version: '2.9.7'

    // https://mvnrepository.com/artifact/org.projectlombok/lombok
    implementation group: 'org.projectlombok', name: 'lombok', version: '1.18.4'



    compileOnly('org.projectlombok:lombok')
    testImplementation('org.springframework.boot:spring-boot-starter-test')
}
```

### 4.4.2 application.yml

```yaml
spring:
    redis:
      time-to-live: 600000
      database: 0 # Database index used by the connection factory.
      host: localhost # Redis server host.
      jedis.pool.max-active: 8 # Maximum number of connections that can be allocated by the pool at a given time. Use a negative value for no limit.
      jedis.pool.max-idle: 8 # Maximum number of "idle" connections in the pool. Use a negative value to indicate an unlimited number of idle connections.
      jedis.pool.max-wait: -1ms # Maximum amount of time a connection allocation should block before throwing an exception when the pool is exhausted. Use a negative value to block indefinitely.
      jedis.pool.min-idle: 0 # Target for the minimum number of idle connections to maintain in the pool. This setting only has an effect if it is positive.
      password: # Login password of the redis server.
      port: 6379 # Redis server port.
      ssl: false # Whether to enable SSL support.
```

### 4.4.3 配置jackson序列化

用于写入和读取类，如下文中Test的User

```Java
import com.fasterxml.jackson.annotation.JsonAutoDetect;
import com.fasterxml.jackson.annotation.PropertyAccessor;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.Jackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;

@Configuration
public class RedisConf {
    @Bean
    public RedisTemplate redisTemplate(RedisConnectionFactory redisConnectionFactory) {
        RedisTemplate redisTemplate = new RedisTemplate();
        redisTemplate.setConnectionFactory(redisConnectionFactory);
        Jackson2JsonRedisSerializer jackson2JsonRedisSerializer = new Jackson2JsonRedisSerializer(Object.class);

        ObjectMapper objectMapper = new ObjectMapper();// <1>
        objectMapper.setVisibility(PropertyAccessor.ALL, JsonAutoDetect.Visibility.ANY);
        objectMapper.enableDefaultTyping(ObjectMapper.DefaultTyping.NON_FINAL);

        jackson2JsonRedisSerializer.setObjectMapper(objectMapper);

        redisTemplate.setKeySerializer(new StringRedisSerializer()); // <2>
        redisTemplate.setValueSerializer(jackson2JsonRedisSerializer); // <2>

        redisTemplate.afterPropertiesSet();
        return redisTemplate;
    }
}
```

### 4.4.4 数据读取

```Java
package com.springexample.rediscache;

import lombok.Data;
import lombok.NoArgsConstructor;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.test.context.junit4.SpringRunner;


@Data
@NoArgsConstructor                      //Jackson进行转换的时候需要没有参数的构造函数
class User {
    int id;
    String name;

    public User(int id, String name) {
        this.id = id;
        this.name = name;
    }
}

@RunWith(SpringRunner.class)
@SpringBootTest
public class RedisCacheApplicationTests {
    @Autowired
    private StringRedisTemplate stringRedisTemplate;

    @Autowired
    private RedisTemplate redisTemplate;

    @Test
    public void redistTemplateTest() {
        //字符串
        stringRedisTemplate.opsForValue().set("aaa", "111", 1, TimeUnit.HOURS);
        Assert.assertEquals("111", stringRedisTemplate.opsForValue().get("aaa"));

        //hash
        redisTemplate.opsForHash().put("hello", "yes", 0);
        redisTemplate.expire("hello",  30, TimeUnit.MINUTES);
        Assert.assertEquals(0, redisTemplate.opsForHash().get("hello", "yes"));

        //对象
        redisTemplate.opsForValue().set("xiaoming", new User(1, "xiaoming"), 60, TimeUnit.MINUTES);
        User user1 = (User) redisTemplate.opsForValue().get("xiaoming");

        //publish
        redisTemplate.convertAndSend("yeah", "hello");
    }
}

```

发布的时候可以在redis-cli中subscribe:

```redis
127.0.0.1:6379> subscribe yeah
Reading messages... (press Ctrl-C to quit)
1) "subscribe"
2) "yeah"
3) (integer) 1
1) "message"
2) "yeah"
3) "\"hello\""

```

通过ttl查看过期时间：

```redis
127.0.0.1:6379> ttl hello
(integer) 1747
127.0.0.1:6379> ttl hello
(integer) 1699
127.0.0.1:6379> ttl hello
(integer) 1698
127.0.0.1:6379> ttl aaa
(integer) 3480
127.0.0.1:6379> ttl aaa
(integer) 3479
127.0.0.1:6379> ttl xiaoming
(integer) 3468
```

# 5. 参考文档
1. [Spring Boot features: Caching](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-caching.html#boot-features-caching-provider-caffeine)

2. [spring caffeine cache tutorial](https://github.com/mvpjava/spring-caffeine-cache-tutorial)