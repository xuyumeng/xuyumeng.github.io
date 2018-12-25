---
layout:     post
title:      "Spring boot swagger 编写文档"  
subtitle:   "通过注解在代码中编写文档的方法"
author:     Sun Jianjiao
header-img: "img/bg/default-bg.jpg"
catalog: true
tags:
    - spring boot
    - 文档编写
    - swagger

---


# 1. swagger
Swagger作为文档比较流行的方式，文档和代码写在一起还是比较方便维护的。在spring boot中可以通过springfox写注解式的文档。

springfox的文档地址: http://springfox.github.io/springfox/docs/current/ ， 下文主要将常用的功能进行解释说明，同时增加导出html和pdf的方法。

# 2. swagger的使用方法

## 2.1 添加依赖
使用swagger注解需要添加swagger2, 通过web页面访问api需要添加swagger-ui

```
ext {
    swaggerVersion = '2.9.2'
}

dependencies {
    compile "io.springfox:springfox-swagger2:${swaggerVersion}"
    compile "io.springfox:springfox-swagger-ui:${swaggerVersion}"
```

## 2.2 添加配置信息
```
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.google.common.base.Predicate;
import springfox.documentation.builders.ApiInfoBuilder;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

import static com.google.common.base.Predicates.or;
import static springfox.documentation.builders.PathSelectors.regex;


@Configuration
@EnableSwagger2
public class SwaggerConfig {
    @Bean
    public Docket createRestApi(){
        return new Docket(DocumentationType.SWAGGER_2)
                .apiInfo(apiInfo())
                .select()
                .apis(RequestHandlerSelectors.basePackage("com.xxxx.rest"))   //这里是api的路径地址
                .paths(PathSelectors.any())
                .build();
    }


    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("API  title")    //这里写API的title
                .description("")
                .termsOfServiceUrl("http")
                .contact("联系方式")    //这里写连写方式
                .version("版本号")      // 这里是版本号
                .build();
    }


    private Predicate<String> petstorePaths() {
        return or(
                regex("/api/pet.*"),
                regex("/api/user.*"),
                regex("/api/store.*")
        );
    }


    private Predicate<String> userOnlyEndpoints() {
        return new Predicate<String>() {
            @Override
            public boolean apply(String input) {
                return input.contains("user");
            }
        };
    }
}
```

## 2.3 接口中的注解使用

```
@RestController
@Slf4j
@RequestMapping(value = "v1/processParameter")
@Api(value = "工艺参数", description = "用于设备工艺参数的获取")
public class ProcessParameterController {
    @RequestMapping(value = "/history/{id}/{start}/{end}", method = RequestMethod.GET)
    @ApiOperation(value = "获取设备历史工艺参数", notes = "用于根据设备id获取设备的历史工艺参数")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "id", value = "设备ID", required = true, paramType = "query", dataType = "integer"),
            @ApiImplicitParam(name = "start", value = "开始时间", required = true, paramType = "query", dataType = "string"),
            @ApiImplicitParam(name = "end", value = "结束时间", required = true, paramType = "query", dataType = "string")
    })
    public List<ProcessParameterDto> history(@PathVariable long id, @PathVariable String start, @PathVariable String end) {
        ... ...
    }

}
```

上面是多个参数的例子，使用了@ApiImplicitParams注解， 单个个参数可以直接使用@ApiImplicitParam：

```
@ApiImplicitParam(name = "id", value = "设备ID", required = true, paramType = "query", dataType = "integer"),
```


### 2.4.1 @ApiOperation 
> 展示每个API基本信息

- value api名称
- notes 备注说明

### 2.4.2 @ApiImplicitParam 
> 用于规定接收参数类型、名称、是否必须等信息
- name 对应方法中接收参数名称
- value 备注说明
- required 是否必须 boolean<br>
- paramType 参数类型 body、path、query、header、form中的一种
- body 使用@RequestBody接收数据, POST有效
- path 接收在url中使用{}括起来的参数
- query 普通查询参数 例如 ?query=q ,jquery ajax中data设置的值也可以，例如 {query:”q”},springMVC中不需要添加注解接收
- header 使用@RequestHeader接收数据
- dataType 数据类型，如果类型名称相同，请指定全路径，例如 dataType = “java.util.Date”，springfox会自动根据类型生成模型


# 2.5. swagger对象注解

可以使用@ApiModel以及@ApiModelProperty注解来描述我们的对象信息。

```
@Data
@ApiModel
public class StateDto {
    @ApiModelProperty(value = "设备ID", required = true)
    long id;

    @ApiModelProperty(value = "设备状态", required = true)
    StateEnum state;
}
```

# 3. 导出成pdf和html文档
swagger在线文档很方便， 但是对于发布和评审还是有一些不方便的地方，可以通过swagger2markup导出。

参考官方的demo，把[官方demo](https://github.com/Swagger2Markup/spring-swagger2markup-demo)的代码拷贝到项目就可以了。主要包括：

- build.gradle中的内容
- Test目录下的文件
- src/docs/asciidoc 拷贝到项目的src/docs/asciidoc目录。 这里不拷贝过来时无法生成pdf和html文件的

执行gradle命令(windows下面的命令)：
```
.\gradlew.bat clean asciidoctor
```

生成的路径：
- html路径：build\asciidoc\html5
- pdf路径：build\asciidoc\pdf。

这里就不详细说明了，因为这个文档做了详细的说明: [Swagger+spring boot 转换为html,PDF文件等](https://www.jianshu.com/p/0aa7c915ee9e)

中文空白问题参考：https://github.com/nitianziluli/swagger2pdf/