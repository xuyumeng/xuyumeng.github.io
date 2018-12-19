 ## @PostConstruct 和 @PreDestroy
 
通过@PostConstruct 和 @PreDestroy 方法 实现初始化和销毁bean之前进行的操作

```
package com.example.mongodemo;
import lombok.Data;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

@Data
@Component
public class PrePostDestory {
    @PostConstruct
    public void  init(){
        System.out.println("I'm  init  method  using  @PostConstruct....");
    }

    @PreDestroy
    public void  destory(){
        System.out.println("I'm  destory method  using  @PreDestroy.....");
    }

}
```

