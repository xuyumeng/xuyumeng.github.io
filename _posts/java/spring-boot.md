Spring boot搞定执行应用程序所需的各种后勤工作，我们只需要专注应用程序的代码。没有配置，没有web.xml, 没有应用服务器。

- 自动配置: 针对spring应用程序常见的应用功能，Spring boot能自动提供相关配置
- 起步依赖: 告诉Spring boot需要什么功能，它就能引入需要的库。
- 命令行界面：Spring boot的可选特性，借此你只需要写代码就能完成完成整的应用程序，无需传统项目构建
- Actuator:让你能够深入运行中的Spring Boot应用程序，一探究竟。

## 自动配置
Spring Boot会为这些常见配置场景进行自动配置，如果Spring Boot在应用程序的Classpath里发现H2数据库的库，那么它就自动配置一个嵌入式H2数据库。如果在Classpath里发现JdbcTemplate， 那么它还会为你配置一个JdbcTemplate的Bean。 无需操心哪些Bean的配置，Spring Boot会做好准备，随时都能将其注入到你的Bean里。

## 起步依赖
起步依赖其实就是特殊的Maven依赖和Gradle依赖，利用了传递依赖解析，Spring boot把常用库聚合在一起，组成了几个为特定功能而定制的依赖。

假设你正在用Spring MVC构造一个REST API，并将JSON（JavaScript Object
Notation）作为资源表述。此外，你还想运用遵循JSR-303规范的声明式校验，并使用嵌入式的
Tomcat服务器来提供服务。要实现以上目标，你在Maven或Gradle里至少需要以下8个依赖：

```groovy
org.springframework:spring-core
org.springframework:spring-web
org.springframework:spring-webmvc
com.fasterxml.jackson.core:jackson-databind
org.hibernate:hibernate-validator
org.apache.tomcat.embed:tomcat-embed-core
org.apache.tomcat.embed:tomcat-embed-el
org.apache.tomcat.embed:tomcat-embed-logging-juli
```

如果使用Spring Boot的起步依赖，你只需添加Spring Boot的Web起步依赖

```groovy
compile "org.springframework.boot:spring-boot-starter-web"
```

仅此一个。它会根据依赖传递把其他所需依赖引入项目里，你都不用考虑它们。

比起减少依赖数量，起步依赖还引入了一些微妙的变化。向项目中添加了Web起步依赖，实
际上指定了应用程序所需的一类功能。因为应用是个Web应用程序，所以加入了Web起步依赖。
与之类似，如果应用程序要用到JPA持久化，那么就可以加入jpa起步依赖。如果需要安全功能，
那就加入security起步依赖。简而言之，你不再需要考虑支持某种功能要用什么库了，引入相关起
步依赖就行。
此外，Spring Boot的起步依赖还把你从“需要这些库的哪些版本”这个问题里解放了出来。
起步依赖引入的库的版本都是经过测试的，因此你可以完全放心，它们之间不会出现不兼容的
情况。

pring Boot起步依赖基本都以spring-boot-starter打头，随后是直接代表其功能的名字，比如web、test。

##  命令行界面

Spring Boot CLI利用了起步依赖和自动配置，让你专注于代码本身。CLI能检测到你使用了哪些类，它知道要向Classpath中添加哪些起步依赖才能让它运转起来。一旦那些依赖出现在Classpath中，一系列自动配置就会接踵而来，Spring Boot CLI是Spring Boot的非必要组成部分。虽然它为Spring带来了惊人的力量，大大简化了开发，但也引入了一套不太常规的开发模型。要是这种开发模型与你的口味相去甚远，那也没关系，抛开CLI，你还是可以利用Spring Boot提供的其他东西。

## Actuator
提供在运行时检视应用程序内部情况的能力。安装了Actuator就能窥探应用程序的内部情况
了，包括如下细节：

- Spring应用程序上下文里配置的Bean
- Spring Boot的自动配置做的决策
- 应用程序取到的环境变量、系统属性、配置属性和命令行参数
- 应用程序里线程的当前状态
- 应用程序最近处理过的HTTP请求的追踪情况
- 各种和内存用量、垃圾回收、Web请求以及数据源用量相关的指标

Actuator通过Web端点和shell界面向外界提供信息。如果要借助shell界面，你可以打开SSH
（Secure Shell），登入运行中的应用程序，发送指令查看它的情况。

从本质上来说，Spring Boot就是Spring，它做了那些没有它你自己也会去做的Spring
Bean配置。有了Spring boot，你不用再写这些样板配置了，可以专注于应用程序的逻辑。

## Spring initializer
Spring Initializr从本质上来说就是一个Web应用程序，它能为你生成Spring Boot项目结构。虽
然不能生成应用程序代码，但它能为你提供一个基本的项目结构，以及一个用于构建代码的
Maven或Gradle构建说明文件。你只需要写应用程序的代码就好了。
Spring Initializr有几种用法：

- 通过Web界面使用，[生成链接](https://start.spring.io/)
- 通过Spring Tool Suite使用。
- 通过IntelliJ IDEA使用。
- 使用Spring Boot CLI使用。

# Spring Boot项目

## Spring 项目

```Java
@SpringBootApplication                                         //开启组件扫描和自动配置
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(ProxyApplication.class, args);   //负责启动引导应用程序
    }

}
```

@SpringBootApplication开启了Spring的组件扫描和Spring Boot的自动配置功能。实际
上，@SpringBootApplication将三个有用的注解组合在了一起。

- Spring的@Configuration：标明该类使用Spring基于Java的配置。虽然本书不会写太多配置，但我们会更倾向于使用基于Java而不是XML的配置。
- Spring的@ComponentScan：启用组件扫描，这样你写的Web控制器类和其他组件才能被自动发现并注册为Spring应用程序上下文里的Bean。本章稍后会写一个简单的Spring MVC控制器，使用@Controller进行注解，这样组件扫描才能找到它。
- Spring Boot的@EnableAutoConfiguration ： 这个不起眼的小注解开启了Spring Boot自动配置的魔力，让你不用再写成篇的配置了。

Application还是一个启动引导类。要运行Spring Boot应用程序有几种方式，其中包含传统的WAR文件部署。但这里的main()方法让你可以在命令行里把该应用程序当作一个可执行JAR文件来运行。这里向SpringApplication.run()传递了一个Application类的引用，还有命令行参数，通过这些东西启动应用程序。

# 自动配置

Spring Boot为Gradle和Maven提供了构建插件，以便辅助构建Spring Boot项目。

```groovy
buildscript {
    ext {
        springBootVersion = '2.1.2.RELEASE'
    }
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath("org.springframework.boot:spring-boot-gradle-plugin:${springBootVersion}")  //依赖Spring Boot插件
    }
}

apply plugin: 'java'
apply plugin: 'org.springframework.boot'                                                      //应用Spring Boot插件
apply plugin: 'io.spring.dependency-management'

group = 'com.example'
version = '0.0.1-SNAPSHOT'
sourceCompatibility = '1.8'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'                      //起步依赖
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}
```

### 起步依赖
起步依赖本质上是一个Maven项目对象模型（Project Object Model，POM），定义了对其他库的传递依赖，这些东西加在一起即支持某项功能。很多起步依赖的命名都暗示了它们提供的某种或某类功能。

查看依赖树：

```shell
gradle dependencies
```

### 覆盖起步依赖
起步依赖是通过构建工具中的功能，可以选择性地覆盖它们引入的传递依赖的版本号，排除传递依赖，当然还可以为那些Spring Boot起步依赖没有涵盖的库指定依赖。
以Spring Boot的Web起步依赖为例，它传递依赖了Jackson JSON库。如果你正在构建一个生产或消费JSON资源表述REST服务，那它会很有用。但是，要构建传统的面向人类用户的Web应用程序，你可能用不上Jackson。虽然把它加进来也不会有什么坏处，但排除掉它的传递依赖，可以为你的项目瘦身。
如果在用Gradle，你可以这样排除传递依赖：

```groovy
compile("org.springframework.boot:spring-boot-starter-web") {
    exclude group: 'com.fasterxml.jackson.core'
}
```

Gradle总是会用最近的依赖, 如果在项目的构建说明文件里增加的依赖，比starter里面的版本新，会覆盖传递依赖引入的另一个依赖，如果使用新版本的依赖，指明版本号就可以了：

```groovy
compile("com.fasterxml.jackson.core:jackson-databind:2.4.3")
```

因为这个依赖的版本比Spring Boot的Web起步依赖引入的要新，所以在Gradle里是生效的。但假如你要的不是新版本的Jackson，而是一个较早的版本呢？Gradle倾向于使用库的最新版本。因此，如果你要使用老版本的Jackon，则不得不把老版本的依赖加入构建，并把Web起步依赖传递依赖的那个版本排除掉：

```groovy
compile("org.springframework.boot:spring-boot-starter-web") {
exclude group: 'com.fasterxml.jackson.core'
}
compile("com.fasterxml.jackson.core:jackson-databind:2.3.1")
```

不管什么情况，在覆盖Spring Boot起步依赖引入的传递依赖时都要多加小心。虽然不同的版本放在一起也许没什么问题，但你要知道，起步依赖中各个依赖版本之间的兼容性都经过了精心的测试。应该只在特殊的情况下覆盖这些传递依赖（比如新版本修复了一个bug）。

### 自动配置

在向应用程序加入Spring Boot时，有个名为spring-boot-autoconfigure的JAR文件，其中包含了
很多配置类。每个配置类都在应用程序的Classpath里，都有机会为应用程序的配置添砖加瓦。

通过Spring Boot的起步依赖和自动配置，你可以更加快速、便捷地开发Spring应用程序。起
步依赖帮助你专注于应用程序需要的功能类型，而非提供该功能的具体库和版本。与此同时，自
动配置把你从样板式的配置中解放了出来。这些配置在没有Spring Boot的Spring应用程序里非常
常见。

# 自定义配置

## 覆盖Spring Boot自动配置
覆盖自动配置很简单，就当自动配置不存在，直接显式地写一段配置。Java形式的配置意味着写一个扩展了WebSecurityConfigurerAdapter的配置类。

```java

@Configuration                                                      //声明是一个配置类
@EnableWebSecurity                                                  //声明创建了一个WebSecurityConfiguration Bean
public class SecurityConfig extends WebSecurityConfigurerAdapter {  //扩展对应配置进行配置
    @Autowired
    private ReaderRepository readerRepository;

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests()
        .antMatchers("/").access("hasRole('READER')")
        .antMatchers("/**").permitAll()
        .and()
        .formLogin()
        .loginPage("/login")
        .failureUrl("/login?error=true");
    }

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
    auth.userDetailsService(new UserDetailsService() { 
        @Override
        public UserDetails loadUserByUsername(String username)throws UsernameNotFoundException {
            return readerRepository.findOne(username);
        }
        });
    }
}
```

### 自动配置的面纱
Spring Boot自动配置自带了很多配置类，每一个都能运用在你的应用程序里。它们都使用了Spring 4.0的**条件化配置**，可以在运行时判断这个配置是该被运用，还是该被忽略。

大部分情况下，**@ConditionalOnMissingBean**注解是覆盖自动配置的关键。Spring Boot的DataSourceAutoConfiguration中定义的JdbcTemplate Bean就是一个非常简单的例子，演示了@ConditionalOnMissingBean如何工作：

```java
@Bean
@ConditionalOnMissingBean(JdbcOperations.class)
public JdbcTemplate jdbcTemplate() {
    return new JdbcTemplate(this.dataSource);
}
```

jdbcTemplate()方法上添加了@Bean注解，在需要时可以配置出一个JdbcTemplate Bean。但它上面还加了@ConditionalOnMissingBean注解，要求当前不存在JdbcOperations类型（JdbcTemplate实现了该接口）的Bean时才生效。如果当前已经有一个JdbcOperationsBean了，条件即不满足，不会执行jdbcTemplate()方法。

什么情况下会存在一个JdbcOperations Bean呢？**Spring Boot的设计是加载应用级配置，随后再考虑自动配置类**。因此，如果你已经配置了一个JdbcTemplate Bean，那么在执行自动配置时就已经存在一个JdbcOperations类型的Bean了，于是忽略自动配置的JdbcTemplate Bean。

## 通过属性文件外置配置
为了微调一些细节，比如改改端口号和日志级别，便放弃自动配置，这是一件痛苦的事情。为了设置数据库URL，是配置一个属性简单，还是完整地声明一个数据源的Bean简单？
Spring Boot自动配置的Bean提供了300多个用于微调的属性。当你调整设置时，只要在环境变量、Java系统属性、JNDI（Java Naming and Directory Interface）、命令行参数或者属性文件里进行指定就好了。

在命令行里运行阅读列表应用程序时，Spring Boot有一个ascii-art Banner。如果你想禁用这个Banner，可以将
spring.main.show-banner属性设置为false。有几种实现方式，其中之一就是在运行应用程
序的命令行参数里指定：

```bash
java -jar readinglist-0.0.1-SNAPSHOT.jar --spring.main.show-banner=false
```

另一种方式是创建一个名为application.properties的文件，包含如下内容：

```property
spring.main.show-banner=false
```

或者，如果你喜欢的话，也可以创建名为application.yml的YAML文件，内容如下：

```yaml
spring:
    main:
        show-banner: false
```

还可以将属性设置为环境变量。举例来说，如果你用的是bash或者zsh，可以用export命令：

```shell
export spring_main_show_banner=false
```

请注意，这里用的是下划线而不是点和横杠，这是对环境变量名称的要求。

实际上，Spring Boot应用程序有多种设置途径。Spring Boot能从多种属性源获得属性，包括
如下几处。

- 命令行参数
- java:comp/env里的JNDI属性
- JVM系统属性
- 操作系统环境变量
- 随机生成的带random.*前缀的属性（在设置其他属性时，可以引用它们，比如${random.long}）
- 应用程序以外的application.properties或者appliaction.yml文件
- 打包在应用程序内的application.properties或者appliaction.yml文件
- 通过@PropertySource标注的属性源
- 默认属性

这个列表按照优先级排序，也就是说，任何在高优先级属性源里设置的属性都会覆盖低优先级的相同属性。例如，命令行参数会覆盖其他属性源里的属性。

application.properties和application.yml文件能放在以下四个位置。
- 外置，在相对于应用程序运行目录的/config子目录里。
- 外置，在应用程序运行的目录里。
- 内置，在config包内。
- 内置，在Classpath根目录。

同样，这个列表按照优先级排序。也就是说，/config子目录里的application.properties会覆盖应用程序Classpath里的application.properties中的相同属性。
此外，如果你在同一优先级位置同时有application.properties和application.yml，那么application.yml里的属性会覆盖application.properties里的属性。

### 通过配置文件获得

```yaml
amazon:
    associateId: habuma-20
```

```java
@Component
@ConfigurationProperties("amazon")                       //注入amzon前缀的属性
public class AmazonProperties {
    private String associateId;

    public void setAssociateId(String associateId) {     //associateId的Setter方法
        this.associateId = associateId;
    }
    public String getAssociateId() {
        return associateId;
    }
}
```

其他的配置:

- @Value从配置文件进行获取
- [通过Profile激活不同环境的配置](https://unanao.github.io/2016/02/01/spring-boot-multi-config/)

当自动配置无法满足需求时，Spring Boot允许你覆盖并微调它提供的配置。覆盖自动配置其实很简单，就是显式地编写那些没有Spring Boot时你要做的Spring配置。Spring Boot的自动配置被设计为优先使用应用程序提供的配置，然后才轮到自己的自动配置。

即使自动配置合适，你仍然需要调整一些细节。Spring Boot会开启多个属性解析器，让你通过环境变量、属性文件、YAML文件等多种方式来设置属性，以此微调配置。这套基于属性的配置模型也能用于应用程序自己定义的组件，可以从外部配置源加载属性并注入到Bean里。

Spring Boot还自动配置了一个简单的白标错误页，虽然它比异常跟踪信息友好一点，但在艺术性方面还有很大的提升空间。幸运的是，Spring Boot提供了好几种选项来自定义或完全替换这个白标错误页，以满足应用程序的特定风格。