---
layout:     post
title:      "Spring AOP"  
subtitle:   "Spring面向切面编程的实现原理和使用方法"
author:     Sun Jianjiao
header-style: text
catalog: true
tags:
    - java

---

Spring AOP是基于动态代理实现的，首先介绍jDK动态代理和CGLig动态代理，然后介绍Spring 面向切面编程的使用方法。

# 1 动态代理

动态代理在Java中有着广泛的应用，比如Spring AOP。静态代理的代理关系在编译时就确定了，而动态代理的代理关系是在运行时确定的。

## 1.1 Java动态代理

假设我们有一个接口UserService和一个简单实现UserServiceImpl。使用接口制定协议，然后用不同的实现来实现具体行为。

```java
// 接口
public interface UserService {
    void save();
    int select();
}

// 接口的实现
public class UserServiceImpl implements UserService {
    @Override
    public void save() {
        System.out.println("save");
    }

    @Override
    public int select() {
        System.out.println("query");

        return 10;
    }
}
```

### 1.1.1 静态代理调用

```java

@RunWith(SpringRunner.class)
@SpringBootTest
public class ProxyApplicationTests {

    @Test
    public void contextLoads() {
        UserService userService = new UserServiceImpl();

        userService.save();
        userService.select();
    }
}

```

### 1.1.2 动态代理调用

```java
package com.example.proxy.service.impl;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

public class UserProxyFactory implements InvocationHandler {
    private Object target;

    public UserProxyFactory(Object target) {
       this.target = target;
    }

    //获取代理对象
    public Object getProxyObject() {
        return Proxy.newProxyInstance(target.getClass().getClassLoader(), target.getClass().getInterfaces(), this);
    }

    //
    @Override
    public Object invoke(Object proxy, Method method, Object args[]) throws  Throwable{
        System.out.println("add code");                     // 加入需要执行的逻辑代码

        return method.invoke(target, args);
    }
}
```

Proxy.newProxyInstance(ClassLoader loader, Class<?>[] interfaces, InvocationHandler handler)方法会根据指定的参数动态创建代理对象。三个参数的意义如下：

- loader，指定代理对象的类加载器；
- interfaces，代理对象需要实现的接口，可以同时指定多个接口；
- handler，方法调用的实际处理者，代理对象的方法调用都会转发到这里
- newProxyInstance()会返回一个实现了指定接口的代理对象，对该对象的所有方法调用都会转发给InvocationHandler.invoke()方法。

代理对象是在程序运行时产生的，而不是编译期；对代理对象的所有接口方法调用都会转发InvocationHandler.invoke()方法，在invoke()方法里我们可以加入任何逻辑，比如修改方法参数，加入日志功能、安全检查功能等；之后我们通过某种方式执行真正的方法体。

```java
package com.example.proxy;

import com.example.proxy.service.UserService;
import com.example.proxy.service.impl.UserProxyFactory;
import com.example.proxy.service.impl.UserServiceImpl;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest
public class ProxyApplicationTests {

    @Test
    public void contextLoads() {
        UserService userService = new UserServiceImpl();

        UserProxyFactory userProxyFactory = new UserProxyFactory(userService);
        UserService proxy = (UserService) userProxyFactory.getProxyObject();
        proxy.save();

        proxy.select();
    }
}

```

每次调用都新增了“add code”的输出：

```Log
add code
save
add code
query
```

## 1.2 CGLIB 动态代理

```java
package com.example.proxy.service;

public class OrderService {
    public void save() {
        System.out.println("order save successfully");
    }

    public int select () {
        System.out.println("query successfully");

        return 0;
    }
}
```

```java
package com.example.proxy.service;

import net.sf.cglib.proxy.Enhancer;
import net.sf.cglib.proxy.MethodInterceptor;
import net.sf.cglib.proxy.MethodProxy;

import java.lang.reflect.Method;

public class OrderServiceCglibProxyFactory implements MethodInterceptor {
    private Object target;

    public OderServiceCglibProxyFactory(Object target) {
        this.target = target;
    }

    // 通过CGLIB动态代理获取代理对象
    public Object getProxyObject() {
        Enhancer enhancer = new Enhancer();

        enhancer.setSuperclass(target.getClass());
        enhancer.setCallback(this);

        return enhancer.create();
    }

    // 方法调用会被转发到该类的intercept()方法。
    @Override
    public Object intercept(Object o, Method method, Object[] objects, MethodProxy methodProxy) throws Throwable {
        System.out.println("add new code");                    // 增加逻辑代码

        return method.invoke(target, objects);
    }
}
```

```java
import com.example.proxy.service.OrderService;
import com.example.proxy.service.OrderServiceCglibProxyFactory;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest
public class CGlibApplicationTests {

    @Test
    public void contextLoads() {
        OrderService orderService = new OrderService();

        OrderServiceCglibProxyFactory factory = new OrderServiceCglibProxyFactory(orderService);
        factory.getProxyObject();
        OrderService proxy = (OrderService) factory.getProxyObject();

        proxy.save();
        proxy.select();
    }
}

```

输出:

```text
add new code
order save successfully
add new code
query successfully
```

## 1.3 小结

JDK原生动态代理是Java原生支持的，不需要任何外部依赖，但是它只能基于接口进行代理；CGLIB无论目标对象有没有实现接口都可以代理。

# 2 Spring AOP

软件中的一些功能要应用到程序的多个地方，但是我们又不想在每个点都明确调用它们。在软件开发中，散布于应用中多处的功能被称为横切关注点，通常来讲这些横切关注点从概念上是与应用的业务逻辑相分离的（但是往往会直接嵌入到应用的业务逻辑中）。**把这些横切关注点与业务逻辑相分离**正是面向切面编程要解决的问题。横切关注点可以理解为影响应用多出的功能。DI有助于应用对象之间的解耦，AOP可以实现实现横切关注点和它所影响的对象之间的解耦。

使用面向切面编程时，我们在一个地方定义通用功能，通过声名的方式定义这个功能要以何种方式在何处应用，而无需修改受影响的类。

- 每个关注点都集中于一个地方，而不是分散到多处代码中， 维护更方便
- 服务模块更简洁，只需要包含主要关注点的代码，次要关注点的代码被移到切面中了。

## 2.1 Spring 对AOP的支持
![proxy](/img/post/java/AOP/proxy.png)

Spring的切面由目标对象的代理类实现，代理类处理方法的调用，执行额外的切面逻辑，并调用目标方法。

Spring AOP构建在动态代理之上，因此，Spring对AOP的支持局限于方法拦截。如果你的AOP需求超过简单的方法调用，如构造器或者属性拦截，需要考虑使用AspectJ。

## 2.2 使用方法

创建切点来定义切面锁植入的连接点是AOP大的基本功能。

```java
package com.example.proxy.service;

import org.springframework.stereotype.Component;

@Component
public class PlayService {
    public void save() {
        System.out.println("play save successfully");
    }

    public int select (String msg) {
        System.out.println("query successfully: " + msg);

        return 0;
    }
}
```

```java
package com.example.proxy.service;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.stereotype.Component;

@Aspect                                                                //定义切面
@Component
public class SpringAop {
    @Pointcut("execution(* PlayService.save())")                      // 定义切点
    public void save() {}

    @Pointcut("execution(* PlayService.select(String)) && args(msg)")  // 定义有参数的切点
    public void select(String msg) {}

    @Before("save()")
    public void saveBefore() {
        System.out.println("before save proxy: ");
    }

    @Around("save()")
    public void saveAround(ProceedingJoinPoint jp) throws Throwable{
        System.out.println("Around: before save proxy: ");

        jp.proceed();                                                 // 调用方法

        System.out.println("Around: before save proxy: ");
    }

    @After("select(msg)")
    public void selectAfter(String msg) {
        System.out.println("After select: " + msg);
    }
}
```

1. Aspect 定义切面， Aspect注解自动代理会为使用@Aspect注解的bean自动创建一个代理。
2. 定义切点 
- @Pointcut 能够在一个AspectJ切面内定义可重复使用的切点。

- 编写切点

```java
execution          (*             PlayService.save())
在方法执行时触发     返回任意类型   方法所属的类  方法
```

save(..)表示可以使用任意参数

- execution(* PlayService.select(String)) && args(msg)" 使用args限定符传递select(int) 中的参数到被通知的函数中。方法需要指明类型，通过args执行参数。

3. 定义通知
- Before 调用目标方法之前调用
- After 目标方法完成后调用
- After-returning: 调用成功返回后调用
- After-throwing: 目标方法抛出异常后调用
- Around: 可以在目标方法调用之前和之后分别定义执行行为， 环绕通知接收ProceedingJoinPoint作为参数，处理完成后调用proceed()方法。


测试代码：

```java
package com.example.proxy.service;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest
public class SpringAopTest {
    private PlayService playService;

    @Autowired
    public void setPlayService(PlayService playService) {
        this.playService = playService;
    }

    @Test
    public void testProxy() {
        playService.save();
        playService.select("hello aop");
    }
}
```

输出：

```log
Around: before save proxy: 
before save proxy: 
order save successfully
Around: before save proxy: 
query successfully: hello aop
After select: hello aop
```
