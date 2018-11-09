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

File->Project Structure->Modules and in "Sources" 选择 "test folder" 
![No test Roots Found](/img/post/2018/junit/set-test-root.png)

通过 "Mark directory as" 应该也可以。

# 3. 添加依赖
```
    compile "org.springframework.boot:spring-boot-starter-test"
    compile("org.junit.jupiter:junit-jupiter-api")
    testRuntime("org.junit.jupiter:junit-jupiter-engine")
```
之所以没有用testCompile， 因为使用testCompile， 我这里经常提示我从maven下载jar包，后续需要再研究。

# 4. 问题解决
## 4.1 Command line is too long
```
Error running 'Test1.test': Command line is too long. Shorten command line for Test1.test or also for JUnit default configuration. 
```
注意： 最简单的方法，就是你重新创建一个新的测试类，在里面重新写一遍测试方法，代码都可以粘贴过去。
也可以通过修改workspace.xml解决。详见 [链接](https://www.cnblogs.com/sxdcgaq8080/p/9025201.html)