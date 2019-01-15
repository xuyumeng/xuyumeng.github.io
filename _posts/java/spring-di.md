Spring的目标是致力于全方位简化Java开发。为了降低Java开发的复杂性，Spring采取了一下4中关键策略:
- 基于POJO的轻量级和最小侵入性编程；
- 通过依赖注入和面向接口实现松耦合；
- 基于切面和惯例进行声名式编程；
- 通过切面和模板减少样板式代码。

# IOC控制反转

IoC（Inversion of Control​，控制反转）也称为依赖注入（Dependency Injection），作为Spring的一个核心思想，是一种设计对象之间依赖关系的原则及其相关技术，作为Spring的一个关键技术，让我们好好的了解一下吧。

当一个对象创建时，它所依赖的对象由外部传递给它，而非自己去创建所依赖的对象（比如通过new操作）。因此，也可以说在对象如何获取它的依赖对象这件事情上，控制权反转了。这便不难理解控制反转和依赖注入这两个名字的由来了。


对象的创建交给外部容器完成，这个就做控制反转。

- Spring使用控制反转来实现对象不用在程序中写死
- 控制反转解决对象处理问题【把对象交给别人创建】

那么对象的对象之间的依赖关系Spring是怎么做的呢？？依赖注入，dependency injection.

Spring使用依赖注入来实现对象之间的依赖关系

在创建完对象之后，对象的关系处理就是依赖注入

上面已经说了，控制反转是通过外部容器完成的，而Spring又为我们提供了这么一个容器，我们一般将这个容器叫做：IOC容器.

无论是创建对象、处理对象之间的依赖关系、对象创建的时间还是对象的数量，我们都是在Spring为我们提供的IOC容器上配置对象的信息就好了。


ioc的思想最核心的地方在于，资源不由使用资源的双方管理，而由不使用资源的第三方管理，这可以带来很多好处。第一，资源集中管理，实现资源的可配置和易管理。第二，降低了使用资源双方的依赖程度，也就是我们说的耦合度。

也就是说，甲方要达成某种目的不需要直接依赖乙方，它只需要达到的目的告诉第三方机构就可以了，比如甲方需要一双袜子，而乙方它卖一双袜子，它要把袜子卖出去，并不需要自己去直接找到一个卖家来完成袜子的卖出。它也只需要找第三方，告诉别人我要卖一双袜子。这下好了，甲乙双方进行交易活动，都不需要自己直接去找卖家，相当于程序内部开放接口，卖家由第三方作为参数传入。甲乙互相不依赖，而且只有在进行交易活动的时候，甲才和乙产生联系。反之亦然。这样做什么好处么呢，甲乙可以在对方不真实存在的情况下独立存在，而且保证不交易时候无联系，想交易的时候可以很容易的产生联系。甲乙交易活动不需要双方见面，避免了双方的互不信任造成交易失败的问题。因为交易由第三方来负责联系，而且甲乙都认为第三方可靠。那么交易就能很可靠很灵活的产生和进行了。这就是ioc的核心思想。生活中这种例子比比皆是，支付宝在整个淘宝体系里就是庞大的ioc容器，交易双方之外的第三方，提供可靠性可依赖可灵活变更交易方的资源管理中心。另外人事代理也是，雇佣机构和个人之外的第三方。
==========================update===========================

在以上的描述中，诞生了两个专业词汇，依赖注入和控制反转所谓的依赖注入，则是，甲方开放接口，在它需要的时候，能够讲乙方传递进来(注入)所谓的控制反转，甲乙双方不相互依赖，交易活动的进行不依赖于甲乙任何一方，整个活动的进行由第三方负责管理。

# 6 大模块
Spring可以分为6大模块：

- Spring Core  spring的核心功能： IOC容器, 解决对象创建及依赖关系

- Spring Web  Spring对web模块的支持。

可以与struts整合,让struts的action创建交给spring

spring mvc模式

Spring DAO  Spring 对jdbc操作的支持  【JdbcTemplate模板工具类】

- Spring ORM  spring对orm的支持：

既可以与hibernate整合，【session】

也可以使用spring的对hibernate操作的封装

- Spring AOP  切面编程

- SpringEE   spring 对javaEE其他模块的支持

## Core模块

Core是IOC容器，解决对象创建和之间的依赖关系。

### 得到Spring容器对象【IOC容器】
