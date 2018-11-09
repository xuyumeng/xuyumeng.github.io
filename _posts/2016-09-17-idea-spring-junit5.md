---
layout:     post
title:      "Idea 创建Junit5 单元测试"  
subtitle:   "遇到问题的解决方法"
date:       2016-09-17 11:08:00 +08:00
author:     "Sun Jianjiao <jianjiaosun@163.com>"
header-img: "img/bg/default-bg.jpg"
catalog: true
tags:
    - idea
    - 单元测试
    - Junit

---

最近Junit5发布了，使用时候时候和Junit4还是有一些区别的，如生成测试类，依赖的jar包等，将遇到的问题简单整理了一下。

# 1. 目录结构

```
├─.gradle
├─gradle
├─out
└─src
    ├─main
    └─test
```

一般情况，test 目录和main放在同一级目录。不存在的话，新建一个目录。

# 2. 新建测试类
## 2.1. 在需要创建单元测试的类上，按“Alt + Enter”键
![新建测试类图片](/img/post/2018/junit/createTest.png)

## 2.2 解决“No test Roots Found”问题
![No test Roots Found](/img/post/2018/junit/no-test-roots-found.png)


方法一： 通过 "Mark directory as" 应该也可以。

方法二： File->Project Structure->Modules and in "Sources" 选择 "test folder" 
![No test Roots Found](/img/post/2018/junit/set-test-root.png)

# 3. 添加依赖
```
    testCompile "org.springframework.boot:spring-boot-starter-test"
    testCompile "org.springframework.boot:spring-boot-test-autoconfigure"
```

# 4. 测试代码编写

运行有rest接口的程序
```
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;

@RunWith(SpringJUnit4ClassRunner.class) // SpringJUnit支持，由此引入Spring-Test框架支持！
@SpringBootTest(classes = Application.class) // 指定我们SpringBoot工程的Application启动类
@WebAppConfiguration // 由于是Web项目，Junit需要模拟ServletContext，因此我们需要给我们的测试类加上@WebAppConfiguration。
public class MsgServiceTest {

    @Before
    public void setUp() throws Exception {
    }

    @After
    public void tearDown() throws Exception {
    }

    @Test
    public void add2Queue() {
        System.out.println("hello");
    }
```


# 5. 问题解决
## 5.1 Command line is too long
```
Error running 'Test1.test': Command line is too long. Shorten command line for Test1.test or also for JUnit default configuration. 
```
注意： 最简单的方法，就是你重新创建一个新的测试类，在里面重新写一遍测试方法，代码都可以粘贴过去。如果不行，尝试下面的方法。
也可以通过修改workspace.xml解决。详见 [链接](https://www.cnblogs.com/sxdcgaq8080/p/9025201.html)