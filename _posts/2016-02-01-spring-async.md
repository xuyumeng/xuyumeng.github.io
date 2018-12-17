---
layout:     post
title:      "Spring @async的那些坑"  
subtitle:   "@async使用过程中需要注意的事项"
author:     Sun Jianjiao
header-style: text
catalog: true
tags:
    - Spring
    - @async
    - 异步调用

---

Spring @async异步调用使用很方便，使用方法，参考[官方文档](https://spring.io/guides/gs/async-method/)

但是写好后一定要测试，异步函数阻塞，但是调用的地方继续往下执行。

遇到不生效情况，可以参考如下情况：
# 1. 方法不能使用static修饰
如为了调用翻遍的库函数，加了static后， @Async就不生效了。
```
public static asyncPost() {

}
```

# 2. 没有用spring进行bean管理
async方法所在的异步类要用@Compnent或者@Service等注解，否则导致spring无法扫描到异步类

# 3. 调用异步方法不能与异步方法在同一个类中
调用异步方法的类一定是和异步方法在不同的类中，否则不生效。

# 4. 通过@Autowired或@Resource等注解自动注入
不能自己手动new对象，这就是edgex出现的bug，本来@Autowired了httpExecutor,但是又在构造函数里面new了一个。

修改的补丁如下：
```
+import org.springframework.stereotype.Component;

+@Component
 public class ScheduleEventExecutor {

   private static final org.edgexfoundry.support.logging.client.EdgeXLogger logger =
@@ -32,10 +34,6 @@ public class ScheduleEventExecutor {
   @Autowired
   ScheduleEventHTTPExecutor httpExecutor;

-  ScheduleEventExecutor() {
-    httpExecutor = new ScheduleEventHTTPExecutor();
-  }
-
```

# 5. 使用SpringBoot框架必须在启动类中增加@EnableAsync注解
```
@SpringBootApplication
@EnableAsync
@EnableDiscoveryClient
public class Application {
}
```