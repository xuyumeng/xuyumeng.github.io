---
layout:     post
title:      "Idea 创建Junit 单元测试"  
subtitle:   "遇到问题的解决方法"
date:       2016-09-17 11:08:00 +08:00
author:     Sun Jianjiao
header-img: "img/bg/default-bg.jpg"
catalog: true
tags:
    - idea
    - 单元测试
    - Junit
    - spring
    - java

---

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

# 5. 运行单元测试
## 5.1 Idea运行单元测试
idea只需要在测试类上运行就可以了。

## 5.2 gradle运行单元测试

命令:
```
./gradlew test
```

不运行单元测试时，通过-i参数查看具体原因
```
./gradlew test -i
```
如果提示 No Test Source， 在build.gradle中增加sourceSet:
```
sourceSets {
    test {
        java {
            srcDir 'src/test'
        }
    }
}
```
只有"srcDir"指定目录，如果设置srcDir="src/test", 那么gradle会从 “$projectdir/src/test/com/…”寻找测试代码。

# 5. 问题解决
## 5.1 Command line is too long
```
Error running 'Test1.test': Command line is too long. Shorten command line for Test1.test or also for JUnit default configuration. 
```
选择“Edit Configurations”， 将对应的单元测试的command line修改为“JAR mainfest”
![manifest](img/post/java/junit/command-too-long.png)