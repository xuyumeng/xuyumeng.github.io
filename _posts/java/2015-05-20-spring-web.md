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

# MapStruct

## 安装Idea MapStruct Support插件

写MapStruct Mapper的时候，可以进行友好的提示。

可以通过Idea的marketplace搜索安装，也可以去[官网](https://plugins.jetbrains.com/plugin/10036-mapstruct-support/versions)下载后，本地安装。

## 添加MapStruct依赖，参考[官方文档](http://mapstruct.org/documentation/installation/#gradle)

```Groovy
plugins {
    id 'net.ltgt.apt' version '0.9'
}

ext {
    mapstructVersion = "1.3.0.Final"
}


dependencies {
    compile "org.mapstruct:mapstruct:${mapstructVersion}"
    apt "org.mapstruct:mapstruct-processor:${mapstructVersion}"
}
```

我用的Idea 2018.3.4可以直接运行。 同事用的2018.3.3无法直接运行，需要打开如下配置：

```confg
Settings(Preferences) -> Build, Execution, Deployment -> Build Tools -> Gradle -> Runner -> Delegate IDE build/run actions to gradle
```

## 编写Mapper

### Spring方式

```Java
import com.mingdutech.wms.base.dao.entity.SysUserEntity;
import com.mingdutech.wms.base.dto.SysUserDto;
import com.mingdutech.wms.commons.mapstruct.EntityMapper;
import org.mapstruct.Mapper;
import org.mapstruct.ReportingPolicy;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface SysUserMapper extends EntityMapper<SysUserDto, SysUserEntity> {
}
```