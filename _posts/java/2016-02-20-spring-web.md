---
layout:     post
title:      "构建Spring web 应用程序"
subtitle:   "Spring MVC, MapStruct"
author:     Sun Jianjiao
header-img: "img/bg/railway-station-1363771_1280.jpg"
catalog: true
tags:
    - java
---

请求从客户端发起，经过Spring MVC中的组件，最终再返回到客户端。WEB请求的工作类似快递投递，只是投递的不是快递而是信息，将信息从一个地方投递到另一个地方。

# 1 MapStruct

## 1.1 安装Idea MapStruct Support插件

写MapStruct Mapper的时候，可以进行友好的提示。

可以通过Idea的marketplace搜索安装，也可以去[官网](https://plugins.jetbrains.com/plugin/10036-mapstruct-support/versions)下载后，本地安装。

## 1.2 添加MapStruct依赖，参考[官方文档](http://mapstruct.org/documentation/installation/#gradle)

```Groovy
plugins {
    id 'net.ltgt.apt' version '0.9'
}

ext {
    mapstructVersion = "1.3.0.Final"
}


dependencies {
    compile "org.mapstruct:mapstruct:${mapstructVersion}"
    compile "org.mapstruct:mapstruct-processor:${mapstructVersion}"
    annotationProcessor "org.mapstruct:mapstruct-processor:${mapstructVersion}"
}
```

## 1.3 编写Mapper

是默认的方式方式，需要通过Mappers.getMapper声明INSTANCE，但是Spring的方式更简单，而且现在的项目多数是spring的，所以只介绍Spring方式的Mapper编写。

```Java
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_EMPTY)
public class SysUserDto {
    String account;
    String password;
    String name;
}
```

```java
@Data
@NoArgsConstructor
@AllArgsConstructor

public class SysUserEntity {
    BigInteger id;
    String account;
    String password;
    String name;
}
```

```Java
import com.mingdutech.wms.base.dao.entity.SysUserEntity;
import com.mingdutech.wms.base.dto.SysUserDto;
import com.mingdutech.wms.commons.mapstruct.EntityMapper;
import org.mapstruct.Mapper;
import org.mapstruct.ReportingPolicy;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface SysUserMapper {

    SysUserEntity toEntity(SysUserDto dto);

    SysUserDto toDto(SysUserEntity entity);
}
```

# 2 跨域

## 2.1 什么是跨域

跨域，英文叫做cross-domain，是网络安全领域的一个专有名词。简单点理解就是某些操作越过了域名的界限，访问了别的域名。如果脚本可以自由访问其他域，就会产生很多安全问题。比如：
假设有一个网上银行系统，你已经登录过了，它支持一个ajax api可以进行转账；有一个论坛系统，人气很高，但是其中有恶意脚本，这个脚本会调用这个ajax api，从当前登录的用户账户中，转1000块到攻击者的账户。这样，当你访问这个论坛的时候，就会被转走1000块，而你一点都不知道！

为了防范跨域攻击，所有现代浏览器都遵循一套同源策略。根据MDN上的定义，“如果两个页面拥有相同的协议（protocol），端口（如果指定），和主机，那么这两个页面就属于同一个源（origin）”。对于违反同源策略的请求，除了img src等少数嵌入操作之外，都会被浏览器阻止。

这里需要注意的是：同源不仅仅要求相同的域名或ip，连协议和端口也必须相同。以下3个域名就是不同源：

- https://localhost
- http://localhost
- http://localhost:3000

以下是同源的：

- http://localhost/api
- http://localhost/views

我们平常所说的“跨域”其实就是指“发起不同源请求”，而这样的跨域请求会被浏览器阻止。同源策略对保障互联网安全有着非常重要的作用，很多安全策略都是基于同源策略的。

## 2.2 请求跨域了，那么请求到底发出去没有？ 

跨域并不是请求发不出去，请求能发出去，服务端能收到请求并正常返回结果，只是结果被浏览器拦截了。你可能会疑问明明通过表单的方式可以发起跨域请求，为什么 Ajax 就不会?因为归根结底，跨域是为了阻止用户读取到另一个域名下的内容，Ajax 可以获取响应，浏览器认为这不安全，所以拦截了响应。但是表单并不会获取新的内容，所以可以发起跨域请求。同时也说明了跨域并不能完全阻止 CSRF，因为请求毕竟是发出去了。

## 2.3 如何解决跨域问题

这种同源策略会对前后端分离架构下的开发过程带来很大困扰。比如，即使是本地服务器，也没法和前端开发服务器运行在同一个端口上，这时候，跨域是必然的。而如果要让后端程序同时提供web服务，则很难发挥前端工具链的轻量级优势。

CORS方式这是W3C提供的另一种跨域方式。作为一项标准的跨域规范，CORS是最值得采用的。 老式浏览器不支持CORS，如果面对的客户群是不确定的，可以采用反向代理的方式。如果面的客户可以接收使用新的浏览器的要求，那么使用CORS方式吧。CORS的原理是基于服务方授权的模式，也就是说提供服务的程序要主动通过CORS回应头来声明自己信任哪些源（协议+域名+端口）。

### 2.3.1 Spring Boot中打开跨域

```java
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

@Configuration
public class CorsConfig {

    private CorsConfiguration buildConfig() {
        CorsConfiguration corsConfiguration = new CorsConfiguration();
        corsConfiguration.addAllowedOrigin("http://${ip}:${port}");       //允许指定域名使用，也可以设置为*，允许所有地址，但是不安全
        corsConfiguration.addAllowedHeader("*");                          //允许任何头
        corsConfiguration.addAllowedMethod("*");                          //允许任何方法
        corsConfiguration.setAllowCredentials(true);
        return corsConfiguration;
    }

    @Bean
    public CorsFilter corsFilter() {
        //注册CORS过滤器
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", buildConfig());
        return new CorsFilter(source);
    }
}
```

addAllowedOrigin是追加访问源地址，而setAllowedOrigins是可以直接设置多条访问源。可以通过setAllowdOrigins设置多条允许的数据源。

allowdOrigins建议设置指定的地址，如web服务的地址和端口号，这样更加安全。

## 2.4 跨域测试页面代码

```html

<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">

  <script src="http://code.jquery.com/jquery-latest.js"></script>
  <script type="text/javascript">
    $(document).ready(function(){
      $("#b01").click(function(){
      htmlobj=$.ajax({url:"http://${ip}:8083/api/v1/device-status/top?n=4",async:false});
        $("#myDiv").html(htmlobj.responseText);
      });
    });
  </script>
</head>

<body> 
  <div id="myDiv"><h2>通过 AJAX 改变文本</h2></div>
  <button id="b01" type="button">改变内容</button>
</body>

</html>
```

将url替换为对应服务的url即可。