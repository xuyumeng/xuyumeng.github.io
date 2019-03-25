---
layout:     post
title:      "Java开发环境"  
subtitle:   "Java开发环境的搭建"
author:     Sun Jianjiao
header-style: text
catalog: true
tags:

    - java

---

# 1 环境安装

## 1. JDK

### 1.1.1 Linux

``` shell
apt get install openjdk-8-jdk
```

### 1.2.2 Windows

windows安装麻烦一点。

## 1.2.2.1 JKD下载

开发环境需要使用JDK, 从 [下载地址](https://www.oracle.com/technetwork/java/javase/downloads/index.html)下载对应的JDK就可以啦。

## 1.2.2.2 JDK安装

安装过程中可以自定义安装目录等信息，不定义使用缺省配置一路下一步就可以了。例如我们选择安装目录为：

``` shell
D:\java\jdk1.8.0_08
```

### 1.2.2.3 配置环境变量

1. 右击“我的电脑”，点击“属性”
2. 选择“高级”选项卡，点击“环境变量”
3. 在“系统变量”中，设置下面3项属性，不区分大小写, 若已存在则点击“编辑”，不存在则点击“新建”。
- JAVA_HOME
- PATH
- CLASSPATH

4. JAVA_HOME指明JDK安装路径，就是刚才安装时所选择的路径D:\java\jdk1.8.0_08，此路径下包括lib，bin，jre等文件夹；  
5. Path使得系统可以在任何路径下识别java命令，这个变量是已经存在的，因此不用新增，只需在后面追加就可以了，以英文分号分隔, 设为：;%JAVA_HOME%\bin; 
6. CLASSPATH为java加载类(class or lib)路径，只有类在classpath中，java命令才能识别，设为：.;%JAVA_HOME%\lib\dt.jar;%JAVA_HOME%\lib\tools.jar (要加.表示当前路径)%JAVA_HOME%就是引用前面指定的JAVA_HOME；  

7. “开始”－>;“运行”，键入“cmd”, 键入如下命令几个命令，输出无报错，说明环境变量配置成功；

```shell
java -version
java
javac
```

## 1.2 IDE安装

使用Idea开发：[下载地址](https://www.jetbrains.com/idea/)

# 2 从Git上拉取代码库
需要已经安装好Git，Git基本使用参考[使用Git进行开发](https://unanao.github.io/2017/01/20/git-basic/)

## 2.1 从git上拉取代码库

### 2.1.1 第一种方法：从idea里面配置Git

在idea菜单栏中选择VSC->CheckOut from version Control->Git,打开如下窗口：  
![pull](/img/post/java/dev-environment/pull1.png)  
点击Test按钮，测试是否可以；  
![pull](/img/post/java/dev-environment/pull2.png)  
然后点击Clone按钮就可以拉取代码；  
如果这个方法不行可以使用下面这个方法

### 2.1.2 第二中方法：使用命令行

在放代码库的文件中右键，然后选择Git Clone，打开命令行窗口；  
输入命令 git clone + 地址；  
这里会询问是否连接，需要输入yes;  
然后如下图则表示拉取成功！
![clone](/img/post/java/dev-environment/clone.png)

# 3 idea项目导入

在idea菜单栏选择如下图：  
![import](/img/post/java/dev-environment/import0.png)

选中导入项目  
![import](/img/post/java/dev-environment/import1.png)

选择导入模型
![import](/img/post/java/dev-environment/import2.png)
依次按引导完成。  

# 4 插件安装

## 4.1 插件安装方法  

在菜单栏中 file->setting中选择plugin选项，如下图：  
![plugin](/img/post/java/dev-environment/plugin.png)  
搜索出来后可以点击install，然后可以自动安装；

## 4.2 需要安装的插件

### 4.2.1 lombok plugin  

lombok是一个可以通过简单的注解的形式来帮助我们简化消除一些必须有但显得很臃肿的 Java 代码的工具，简单来说，比如我们新建了一个类，然后在其中写了几个字段，然后通常情况下我们需要手动去建立getter和setter方法、构造函数之类的，lombok的作用就是为了省去我们手动创建这些代码的麻烦，它能够在我们编译源码的时候自动帮我们生成这些方法。  

### 4.2.2 free mybatis plugin

free mybatis plugin 是一个通过Ctrl与点击mapper接口方法名称快速找到xml下的Sql语句功能的插件。  

# 5 注意事项

## 5.1 idea程序目录

idea的程序目录eclipse中文件目录显示的结构不一样，eclipse中文件目录中是有一个个包的形式，而idea是以文件夹的形式来呈现的项目，同学们不要以为自己哪里导入或者配置错了，上一张效果图：
![plugin](/img/post/java/dev-environment/idea-project.png)

## 5.2 idea项目出错

如果你的项目出了跟我一样的问题，如下图：
![plugin](/img/post/java/dev-environment/idea-error.png)
那么就是因为没有打开注解处理器，具体打开方法为alt+ctrl+s（系统setting)：
![plugin](/img/post/java/dev-environment/idea-solve.png)
如果你没有以上问题或者已经处理了，当你编译项目为下图的时候，那么恭喜你，已经成功运行起了项目：
![plugin](/img/post/java/dev-environment/idea-nice.png)

## 5.3 idea使用gradle时出现下载不下来的问题

1. 进入https://services.gradle.org/distributions/ 网址下载所对应的版本，我的是gradle-3.5.1-bin ，进入页面点击相应版本下载
2. 关闭idea，替换下载失败的文件， 进入C:\Users\dell\.gradle\wrapper\dists\gradle-3.5.1-bin  中删除该版本下面的所有文件，我的是3.5.1，直接放入下载完成的zip文件即可重新打开idea即可

> 为了构造一个冲突的环境，先在项目中找个ProductionMonitorTest.java（com.rt.productline.line.module.pack.monitor.ProductionMonitorTest.java）文件，把文件中一段代码改掉，然后在github这个网站上手动修改这个文件中的内容，这样，当在本地pull的时候就会提示代码冲突了。

# 6. Idea 的代码冲突解决

1、出现冲突
![image](/img/post/java/dev-environment/QQ1.png)

2、远程服务git中的文件
![image](/img/post/java/dev-environment/QQ2.png)

3、先commit本地修改的文件到本地repository
![image](/img/post/java/dev-environment/QQ3.png)

4、pull源码，因为存在代码冲突，所以提示pull失败
![image](/img/post/java/dev-environment/QQ4.png)

5、点击 View them 会打开冲突文件列表
![image](/img/post/java/dev-environment/QQ5.png)

双击打开冲突的文件可以进行修改
![image](/img/post/java/dev-environment/QQ6.png)

修改完之后关掉窗口，这样冲突就解决了。然后重新pull就可以了

# 7. Idea 创建多模块项目

## 7.1 Spring Boot项目初始化

1. "File" -> "New" -> "Project...", 选择Spring Initializr

![image](/img/post/java/dev-environment/new-project-initializr.png)

2. gralde项目选择"Gradle Project"

![image](/img/post/java/dev-environment/new-project-gradle.png)
根据实际情况，修改"Group"和"Artifact"。

3. 然后选择依赖， 项目创建完成了

## 7.2 创建module

1. "File" -> "New" -> "Module", 选择“Gradle”

![image](/img/post/java/dev-environment/new-module.png)

2. 拷贝src目录到新建的module

3. 同样的方法创建其他module

4. 删除根目录的src目录

## 7.3 修改settings.gradle

将新建的module包含进来,如新建了"collectmanagement"和"collectmanagementclient"连个module。

```groovy
include 'collectmanagement'
include 'collectmanagementclient'
```

## 7.4 修改build.gradle

根目录的build.gradle, 可以使用**allprojects**或者**subprojects**表明是应用到所有项目还是子项目。如allprojects:

```Groovy
allprojects {
    apply plugin: "java"
    apply plugin: "org.springframework.boot"


    group = "com.mingdutech.cloudplatform"
    version = "1.0.0-SNAPSHOT"
    sourceCompatibility = 1.8
    targetCompatibility = 1.8

    repositories {
        mavenLocal()
        maven { url "http://maven.aliyun.com/nexus/content/groups/public" }
        mavenCentral()

    }

    dependencies {
        compile "org.springframework.boot:spring-boot-starter-web"
        compile "org.springframework.cloud:spring-cloud-starter-config"

        testCompile "org.springframework.boot:spring-boot-test-autoconfigure"
    }

}
```

## 7.5 多模块的目录结构

```shell
│  .gitignore
│  build.gradle
│  gradle.properties
│  README.md
│  settings.gradle
│
├─.gradle
├─collectmanagement                //模块1
│  │  build.gradle
│  │
│  └─src
│      ├─main
│      └─test
├─collectmanagementclient         //模块2
   │  build.gradle
   │
   └─src
       ├─main
       └─test

```