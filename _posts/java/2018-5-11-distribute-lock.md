# 1. redis 分布式锁

官方文档给出了单例的操作方式：[https://redis.io/topics/distlock](https://redis.io/topics/distlock)

结合官方的命令行代码，编写了基于spring-data-redis版本的单例redis分布式锁。

## 1.1 分布式锁的接口

```Java
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

## 1.2 测试样例代码

```Java
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