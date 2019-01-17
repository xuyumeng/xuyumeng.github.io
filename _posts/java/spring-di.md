Spring的目标是致力于全方位简化Java开发。为了降低Java开发的复杂性，Spring采取了一下4中关键策略:
- 基于POJO的轻量级和最小侵入性编程；
- 通过依赖注入和面向接口实现松耦合；
- 基于切面和惯例进行声名式编程；
- 通过切面和模板减少样板式代码。

一定程度的耦合是必须的——完全没有耦合的代码什么也做不了。为了完成有意义的功能，不同的类必须以适当的方式进行交互。

# 1. 依赖注入的优点

## 1.1 不使用依赖注入
传统做法：每个对象负责管理与自己相互协作的对象（即它所依赖的对象）的引用这将会导致高度耦合和难以测试的代码。

![不使用依赖注入](img/post/java/DI/DI-no-di.png)


### 1.1.1 早晨去跑步：

```java
class Running{
    public void play() {
        System.out.println("Runing");
    }

}

public class Player {

    private Running running;

    public Player() {
        running = new Running();
    }

    public void doSports() {
        System.out.println("Play Sports: ");
        running.play();
    }
}

public class TestRunning {
    public static void main(String[] args) {
        Player player = new Player();

        player.play();

    }
}

```

### 1.1.2 中午午休时间想打打乒乓球了

```java
class TableTennis{
    public void play() {
        System.out.println("Table tennis");
    }

}

public class Player {

    private TableTennis tableTennis;

    public Player() {
        tableTennis = new TableTennis();
    }

    public void doSports() {
        System.out.println("Play Sports: ");
        tableTennis.play();
    }
}

public class TestTableTennis {
    public static void main(String[] args) {
        Player player = new Player();

        player.play();

    }
}
```

每次修改都需要修改Player类，有没有办法减少Player类的修改呢？

## 1.2 依赖注入

![使用依赖注入](img/post/java/DI/DI-player.png)

如图所示，依赖关系将被注入到需要他们的对象中去。**依赖注入将所有依赖关系交给目标对象，而不是让对象自己去获取依赖**。

```java
public interface Sports() {
    void doSports();
}

class TableTennis implements Sports{
    public void doSports() {
        System.out.println("Table tennis");
    }

}

class Running implements Sports{
    public void doSports() {
        System.out.println("Running");
    }

}

public class Player {

    private Sports sports;

    public Player(Sports sports) {               //Sports被注入进来
        this.sports = sports;
    }

    public void doSports() {
        System.out.println("Play Sports: ");
        sports.doSports();
    }
}

public class TestDoSports {
    public static void main(String[] args) {
        // Running
        Player player = new Player(new Running());
        player.doSports();

        // Table tennis
        Player player = new Player(new TableTennis());
        player.doSports();
    }
}
```

通过依赖注入的方式，不需要修改Player类，就可以完成不同的运动。

# 2. Spring的bean管理
![spring 容器](img/post/java/DI/spring-container.png)

通过依赖注入，对象的依赖关系将由系统中负责协调个对象的第三方组件在创建对象的时候进行设定。对象无需自行创建或管理他们的依赖关系。
依赖注入就是组装应用对象的一种方式，借助这种方式对象无需知道依赖来自何处或者依赖的实现方式。
Spring 容器负责创建对象，装配它们，配置并管理它们的整个生命周期。

资源不由使用资源的双方管理，而由不使用资源的第三方管理，这可以带来很多好处。第一，资源集中管理，实现资源的可配置和易管理。第二，降低了使用资源双方的依赖程度，也就是我们说的耦合度。

## 2.1 配置的可选方案
- 在XML中进行进行显示配置
- 在Java中进行显示配置
- 隐式的bean发现机制和自动装配

尽可能的使用自动装配机制，显示配置越少越好。当需要显示配置的时候，JavaConfig配置更好。

## 2.2 自动化装配Bean
Spring 从2个方面实现自动化装配：
- 组件扫描(component scannning): Spring 会自动发现应用上下文中创建的bean。通过@Component声明
- 自动装配(autowiring): Spring自动满足bean之间的依赖关系。通过@AutoWired注入。

组件扫描和自动装配组合在一起就能发挥强大的威力，他们能够将你的显示配置降低到最少。