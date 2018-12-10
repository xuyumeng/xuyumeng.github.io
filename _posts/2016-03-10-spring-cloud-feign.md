---
layout:     post
title:      "使用feign开发http客户端"
subtitle:   "Spring cloud feign的使用方法"
date:       2016-03-10 11:20:00 +08:00
author:     "Sun Jianjiao <jianjiaosun@163.com>"
header-img: "img/bg/railway-station-1363771_1280.jpg"
catalog: true
tags:
    - java
    - spring cloud feign
    - http 客户端

---


# 1. 说明

微服务架构中，业务功能的提供者，提供rest接口的同时， 一般会提供接口的jar包，简化其他服务调用。使用Feign作为http客户端，调用远程的http接口就会变得像调用本地方法一样简单。

Feign是一个声名式的web服务客户端，它让写web服务的客户端更容易。在使用Feign时，Spring Cloud通过集成integrates Ribbon和Eureka提供负载均衡。

本文通过一个例子，包括rest接口的声明，客户端接口的编写(jar包)，和其他服务调用。


# 2. 服务的Rest接口
```
    @ApiOperation(value = "根据邮箱获取用户信息")
    @ApiImplicitParams({
            @ApiImplicitParam(paramType = "path", name = "email", value = "用户邮箱", required = true, dataTypeClass = String.class),
    })
    @GetMapping("/user/{email}")
    public User getUser(@PathVariable String email) {
        return userService.findUserByEmail(email);
    }

```

# 3. 客户端编写

## 3.1 公共Dto
UserDto.java
```
import lombok.Data;

@Data
public class NodeInfoDto {
    String nodeName;
    String profileName;
}
```

## 3.2 client编写
UserClient.java
```
@FeignClient(value="cloud-collect-management", path = "/api/v1/collect-nodes")
public interface CollectNodeClient {
    @FeignClient(value="user-management", path = "/userManagement")
    public interface CollectNodeClient {
        @RequestMapping(value = "/user" , method = RequestMethod.GET)
        @ResponseBody
        User getUser(@RequestParam("email") String email);
    }

}
```

1. FeignClient接口，不能使用@GettingMapping类似的组合注解, 例子中的@RequestMapping(value = "/user/{email}", method = RequestMethod.GET) 不能写成@GetMapping("/user/{email}") 。

2. FeignClient接口中，如果使用到@PathVariable，@RequestParam等，必须指定其value, 上面例子的的@PathVariable("email") 中的”email”不能省略，必须指定。如果不加默认的注解，Feign则会对参数默认加上@RequestBody注解，而RequestBody一定是包含在请求体中的，GET方式无法包含。所以上述两个现象得到了解释。Feign在GET请求包含RequestBody时强制转成了POST请求。

3. 参数是对象
```
@FeignClient("user")
public interface UserApi {
    @RequestMapping(value = "/user",method = RequestMethod.POST)
    User update(@RequestBody User user);
}
```

## 3.3 build.gradle
使用spring boot2.0， 依赖openfeign
```
    compile "org.springframework.cloud:spring-cloud-starter-openfeign"
```

# 4. 消费服务
## 4.1 启用Feign
通过@EnableFeignClients
```
@Configuration
@ComponentScan
@EnableAutoConfiguration
@EnableFeignClients
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

}
```

## 4.2 消费
```
public class GetUser {
    @Autowired
    UserClient userClient;

    public void getUser() {
        String email = "user@email.com"
        userClient.getUser(email);
    }
}
```

# 5. 参考文档

- http://cloud.spring.io/spring-cloud-static/Edgware.SR5/multi/multi_spring-cloud-feign.html