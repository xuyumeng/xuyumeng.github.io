---
layout:     post
title:      "服务网关"  
subtitle:   "spring cloud和netflix zuul的使用"
author:     Sun Jianjiao
header-style: text
catalog: true
tags:
    - java

---

# 1 简介

在微服务的分布式框架中，需要确保跨国大个服务调用的关键行为正常运行，如安全，日志记录和用户跟踪等。要实现这些功能，开发人员需要始终如一的强制这些特性，而不需要每个开发团队都构建自己的解决方案。虽然可以使用公共库或框架来解决这些问题，但是这样会造成下面3个影响：

- 容易遗漏: 开发过程中专注功能交付，可能忘记日志记录和跟踪。但是对于医药或者金融领域，完整的记录系统的操作记录才符合法律规范。
- 容易出错：正确的实现一些功能是有挑战的，如实现安全的配置是一个痛苦的事情。
- 增加依赖和耦合：公共框架中的功能越多越多，依赖公共jar的升级成为一个痛苦的过程，如果有很多个微服务，每个微服务都需要重新编译重新部署。

在前后端分离成为主流的微服务时代，前端代码需要配置多个后端地址是一个。

通过将这些横切关注点抽象一个独立的服务，且为所有微服务提供调用的过滤和路由服务，这个服务就是我们所说的服务网关。客户端不在直接调用服务，取而代之的是所有调用都通过服务网关进行路由，然后路由到目的服务。

服务网关位于客户端到各个服务的所有调用之间，并且充当服务调用的中央策略执行点，这样就可以将横切关注点在网关中实现，无需各个开发团队单独实现。如：

- 静态路由：服务网关作为服务调用的入口，开发人员不用感知其他服务，简化了开发。
- 动态路由：服务网关可以根据请求执行智能路由。如灰度发布。
- 验证和授权：所有对外服务都经过网关进行路由，通过网关屏蔽验证和授权。
- 数据收集和日志记录：调用通过网关时，可以收集服务的调用数据，也可以通过网关收集系统的操作日志等。

服务网关需要保证是无状态的，并且是轻量级的，不能有复杂的操作。

# 2 Netflix zuul 的基本用法

Spring cloud支持nexflix zuul和自家的gateway两个网关，本文通过netflix zuul和eureka实现一个API网关。

## 2.1 引入相应的jar包

```groovy
dependencies {
    compile 'org.springframework.cloud:spring-cloud-starter-netflix-zuul'              // zuul 依赖
    compile 'org.springframework.cloud:spring-cloud-starter-netflix-eureka-client'     // eureka 依赖

}
```

## 2.2 配置zuul服务器

```java
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.netflix.zuul.EnableZuulProxy;

@SpringBootApplication
@EnableZuulProxy                                      // 服务作为zuul服务器
@EnableDiscoveryClient                                // 启用服务注册和发现
public class GatewayApplication {

    public static void main(String[] args) {
        SpringApplication.run(GatewayApplication.class, args);
    }
}
```

IDE自动补全功能会有一个@EnableZuulServer的注解，使用此诸界床架zuul服务器，它不会加载反向过滤器，不会使用eureka作为服务发现。开发人员想要构建自己的服务路由，而不是用任何zuul的预置功能时使用@EnableZuulServer。本文使用@EnableZuulProxy。

## 2.3 配置与eureka通信

Zuul代理服务器默认使用Eureka根据服务ID查找服务，使用Ribbon对请求进行负载均衡。

```yaml
eureka:
  instance:
    prefer-ip-address: true
  client:
    registerWithEureka: true
    fetchRegistry: true
    service-url:
      defaultZone: "http://localhost:8761/eureka"

```

就可以通过http://${gateway-host}:${gateway-port}/${sevice-name}/${sevice-uri}访问各个微服务了

- gateway-host: 网关地址
- gateway-port: 网关端口号
- sevice-name: 服务名称
- sevice-uri: 服务的提供的uri

# 3 在网关上通过swagger访问所有的服务的API

swagger是一个很方便的工具，既可以作为api测试使用，也可以作为接口文档使用。

## 3.1 增加swagger的依赖

```grovvy
ext {
    set('swaggerVersion', "2.8.0")
}

dependencies {
    compile "io.springfox:springfox-swagger2:${swaggerVersion}"
    compile "io.springfox:springfox-swagger-ui:${swaggerVersion}"
}
```

## 3.2 添加swagger的配置

```java
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.netflix.zuul.filters.RouteLocator;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import springfox.documentation.swagger.web.SwaggerResource;
import springfox.documentation.swagger.web.SwaggerResourcesProvider;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

import java.util.ArrayList;
import java.util.List;

@Configuration
@EnableSwagger2
@Primary
public class SwaggerResourcesProviderConfig implements SwaggerResourcesProvider {
    @Autowired
    private RouteLocator routeLocator;

    @Override
    public List<SwaggerResource> get() {
        //Dynamic introduction of micro services using routeLocator
        List<SwaggerResource> resources = new ArrayList<>();
        resources.add(swaggerResource("gateway","/v2/api-docs"));

        //Recycling Lambda expressions to simplify code
        routeLocator.getRoutes().forEach(route ->{
            //Dynamic acquisition
            resources.add(swaggerResource(route.getId(),route.getFullPath().replace("**", "v2/api-docs")));
        });
        return resources;
    }

    private SwaggerResource swaggerResource(String name,String location) {
        SwaggerResource swaggerResource = new SwaggerResource();

        swaggerResource.setName(name);
        swaggerResource.setLocation(location);
        swaggerResource.setSwaggerVersion("2.0");

        return swaggerResource;
    }
}
```

同时需要配置security对swagger的相关页面和接口放行，见[第4.2节](#4.2)

# 4. 认证功能

## 4.1 新增安全的依赖

```groovy
dependencies {
    compile 'org.springframework.cloud:spring-cloud-starter-oauth2'
    compile 'org.springframework.cloud:spring-cloud-starter-security'

}
```

## 4.2 配置服务为ResourceServer

```java
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.oauth2.config.annotation.web.configuration.EnableResourceServer;
import org.springframework.security.oauth2.config.annotation.web.configuration.ResourceServerConfigurerAdapter;


@Configuration
@EnableResourceServer
public class ResourceServerConfiguration extends ResourceServerConfigurerAdapter {
    @Override
    public void configure(HttpSecurity httpSecurity)  throws Exception {

        httpSecurity
                .httpBasic().disable()
                .requestMatchers()
                .antMatchers("/${authentication-service}/oauth/token")    // 放行认证的接口
                .antMatchers("/${authentication-service}/v1/auth")        // 放行认证的接口
                .and()
                .authorizeRequests()
                .antMatchers(                                             // 放行swagger的接口
                        "/v2/api-docs", "/configuration/**", "/swagger-resources/**",
                        "/swagger-ui.html", "/webjars/**", "/api-docs/**",
                        "/*/v2/api-docs", "/*/configuration/**", "/*/swagger-resources/**",
                        "/*/swagger-ui.html", "/*/webjars/**", "/*/api-docs/**").permitAll()
                .antMatchers(HttpMethod.POST,"/trial/v1/activeCode", "/trial/v1/trial").permitAll()
                .anyRequest().authenticated();
    }

}
```

放行认证的接口的地址是在[4.3节](#4.3)配置的，是否添加${authentication-service}取决user-info-uri大的配置。因为实际使用过程中，我配置的uri-info-uri走的网关，所以加了${authentication-service}。 为什么要配置网关的uri呢？因为直接配置认证服务的uri，我没有找到可以配置多个uri或者使用eureka查找认证服务的方法，没有办法做认证服务的高可用，认证服务又很重要，万一出问题了，系统就不可用了，所以设置为网关的uri，这样可以使用网关的负载均衡

## 4.3 配置认证相关的信息

```yaml
security:
  oauth2:
    resource:
      user-info-uri: http://localhost:5555/user_management/v1/auth    # 设置走网关的uri
#     user-info-uri: http://${hostIp}:28080/v1/auth
      prefer-token-info: false
  basic:                                                              # 关闭默认的认证，不然无法访问
    enable: false
  ignored: /**

# sensitiveHeaders 中将 Authentication 移除，Base Authorization 的信息就可以发送了
# sensitiveHeaders 是指 http header 中的敏感信息，既然是敏感信息，默认情况下，ZUUL 是不转发的；
# 而如果不显示配置 sensitiveHeaders，那么默认情况下，配置的就是 zuul.sensitiveHeaders: Cookie,Set-Cookie,Authorization，
# 也就是说，默认情况下，cookie 和相关的 Authorization 都不会进行转发，这就导致了通过zuul认证失败的问题
# https://github.com/spring-cloud/spring-cloud-netflix/blob/master/docs/src/main/asciidoc/spring-cloud-netflix.adoc#cookies-and-sensitive-headers
zuul:
  sensitiveHeaders: Cookie,Set-Cookie
```

# 5 通过zuul的过滤器记录操作日志

虽然通过zuul网关代理所有的请求可以简化服务调用，但是根据需要编写应用于所有流经网关服务的自定义逻辑时，zuul的威力才真正显示出来。zuul允许开发人员开发3种过滤器：

- 前置过滤器：在zuul将实际请求发送到目的地之前被调用。
- 后置过滤器：目标服务调用返回时调用。
- 路由过滤器：在路调用目标服务之前调用，通常用于动态路由。

下面介绍一下如何通过过滤器实现系统操作日志记录：

```java
import com.netflix.zuul.ZuulFilter;
import com.netflix.zuul.context.RequestContext;
import com.netflix.zuul.exception.ZuulException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.netflix.zuul.filters.support.FilterConstants;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.util.StreamUtils;

import javax.servlet.http.HttpServletRequest;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;

import static org.springframework.cloud.netflix.zuul.filters.support.FilterConstants.POST_TYPE;
import static org.springframework.cloud.netflix.zuul.filters.support.FilterConstants.SEND_RESPONSE_FILTER_ORDER;

@Slf4j
@Component
public class AuditLogFilter extends ZuulFilter {
    @Autowired
    private SendKafkaUtis sendkafkaUtils;


    @Override
    public String filterType() {
        return POST_TYPE;
    }

    @Override
    public int filterOrder() {
        return SEND_RESPONSE_FILTER_ORDER - 1;
    }

    @Override
    public boolean shouldFilter() {
        return true;
    }

    private boolean isNeedLog() {
        RequestContext requestContext = RequestContext.getCurrentContext();
        int statusCode = requestContext.getResponse().getStatus();
        String method = requestContext.getRequest().getMethod();
        if ((statusCode >= 200 && statusCode <= 206) && (!method.equals(HttpMethod.GET))) {
            return true;
        }

        return false;
    }

    @Override
    public Object run() throws ZuulException {
        if (isNeedLog()) {
            RequestContext requestContext = RequestContext.getCurrentContext();
            HttpServletRequest request = requestContext.getRequest();

            String method = request.getMethod();                         // 获取是哪种方法(Get/Post/Delete/Update)

            // 请求的URI,uri的格式为/${service-name}/${service-uri}
            String uri = request.getRequestURI();  
            String[] uris = uri.split("/");
            String module = uris[0];

            String queryString = request.getQueryString();

            String content = "";
            try {
                InputStream in = request.getInputStream();
                content = StreamUtils.copyToString(in, Charset.forName("UTF-8"));

                sendKafkaUtils.sendMsg(method, username, queryString, content);    // 通过kafka发送到操作日志记录服务
            } catch (IOException ie) {
                log.error("failed to get request body: " + ie);
            } catch (IllegalStateException ise) {
                log.error("failed to get request body: " + ise);
            }

            log.debug(method + " " + userName + " " + content);
        }

        return null;
    }
}
```

# 6 总结

通过介绍zuul的基本用法，以及配置swagger，认证，再加上通过过滤器进行操作日志记录，zuul已经变成一个功能相对比较完全的网关了，通过同样的方法可以不断完善网关的内容，享受它的便利了。
