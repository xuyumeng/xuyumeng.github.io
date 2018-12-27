---
layout:     post
title:      "spring-data-redis 的使用方法"  
subtitle:   "spring-data-redis基本使用"
author:     Sun Jianjiao
header-img: "img/bg/default-bg.jpg"
catalog: true
tags:
    - spring 
    - redis
    - 缓存
    - java

---

# 1. 过期机制
千万不要忘记设立过期时间，若不设，只能等内存满了，一个个查看Key有没有使用。

## 1.1 过期策略
Redis采用的是定期删除策略和懒汉式的策略互相配合。**Redis内部自动完成！**

- 定期删除策略：每隔一段时间执行一次删除过期key操作
- 懒惰淘汰策略：key过期的时候不删除，每次通过key获取值的时候去检查是否过期，若过期，则删除，返回null

懒惰淘汰机制会造成内存浪费，但是节省CPU资源。定时淘汰机制保证过期的数据一定会被释放掉，但是相对消耗CPU资源
所以，在实际中，如果我们要自己设计过期策略，在使用懒汉式删除+定期删除时，控制时长和频率这个尤为关键，需要结合服务器性能，已经并发量等情况进行调整，以致最佳。

# 2. 使用String还是Hash
STACK OVERFLOW 上一个对 String 和 Hash 的讨论: [Redis strings vs Redis hashes to represent JSON: efficiency?
](https://stackoverflow.com/questions/16375188/redis-strings-vs-redis-hashes-to-represent-json-efficiency)


对于一个对象是把本身的数据序列化后用 String 存储，还是使用 Hash 来分别存储对象的各个属性：

- 如果在大多数时候要访问对象的大部分数据：使用 String
- 如果在大多数时候只要访问对象的小部分数据：使用 Hash
- 如果对象里面还有对象这种结构复杂的，最好用 String。否则最外层用 Hash，里面又将对象序列化，两者混用可能导致混乱。

# 3. redisTemplate

spring RedisTemplate 是对redis的各种操作的封装，它支持所有的 redis 原生的 api。


## 3.1 StringRedisTemplate与RedisTemplate

两者的关系是StringRedisTemplate继承RedisTemplate。
两者的数据是不共通的；也就是说StringRedisTemplate只能管理StringRedisTemplate里面的数据，RedisTemplate只能管理RedisTemplate中的数据。

Redis的String数据结构，推荐使用StringRedisTemplate, 否则使用RedisTemplate需要更改序列化方式。

## 3.2 restTemplate的操作

在RedisTemplate中，提供了一个工厂方法:opsForValue()，这个方法会返回一个默认的操作类。

```
redisTemplate.opsForValue();//操作字符串
redisTemplate.opsForHash();//操作hash
redisTemplate.opsForList();//操作list
redisTemplate.opsForSet();//操作set
redisTemplate.opsForZSet();//操作有序set
```

# 4. 使用举例

## 4.1 build.gradle

```
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

## 4.2 application.yml

```
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

## 4.3 配置jackson序列化
用于写入和读取类，如下文中Test的User

```
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

## 4.4 数据读取

```
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
```
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
```
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

# 5. redis 分布式锁

官方文档给出了单例的操作方式：[https://redis.io/topics/distlock](https://redis.io/topics/distlock)

结合官方的命令行代码，编写了基于spring-data-redis版本的单例redis分布式锁。

## 5.1 分布式锁的接口
```
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.concurrent.TimeUnit;

@Component
public class DistributeLock {
    private static final Long RELEASE_SUCCESS = 1L;

    @Autowired
    private StringRedisTemplate redisTemplate;

    // 加锁
    public boolean tryLock(String lockKey, String requestId, long expireTime) {
        return redisTemplate.opsForValue().setIfAbsent(lockKey, requestId,  expireTime, TimeUnit.SECONDS);
    }

    // 解锁
    public Boolean unLock(String lockKey, String requestId) {

        String script = "if redis.call('get', KEYS[1]) == ARGV[1] then " +
                            "return redis.call('del', KEYS[1]) " +
                        "else " +
                            "return 0 " +
                        "end";

        DefaultRedisScript<Boolean> redisScript =new DefaultRedisScript<>();

        redisScript.setScriptText(script);
        redisScript.setResultType(Boolean.class);

        return redisTemplate.execute(redisScript, Collections.singletonList(lockKey), requestId);
    }
}
```

## 5.2 测试样例代码
```
import com.springexample.rediscache.utils.DistributeLock;
import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.test.context.junit4.SpringRunner;

import java.util.UUID;
import java.util.concurrent.TimeUnit;

@RunWith(SpringRunner.class)
@SpringBootTest
public class DistributeLockTests {
    @Autowired
    private StringRedisTemplate stringRedisTemplate;
    @Autowired
    DistributeLock distributeLock;

    @Test
    public void redisTemplateTest() {
        String requestId = UUID.randomUUID().toString();
        distributeLock.tryLock("test", requestId, 120);

        // 保存字符串
        stringRedisTemplate.opsForValue().set("aaa", "111", 1, TimeUnit.HOURS);
        Assert.assertEquals("111", stringRedisTemplate.opsForValue().get("aaa"));

        Assert.assertEquals(true, distributeLock.unLock("test", requestId));
    }
}
```