---
layout:     post
title:      "数据库进阶"
subtitle:   "Mysql复制，分库分表，读写分离"
author:     Sun Jianjiao
header-img: "/img/bg/railway-station-1363771_1280.jpg"
catalog: true
tags:
    - 数据库

---

# 1. 主从复制

MySQL 复制允许来自一个数据库服务器的数据自动复制到另外一个或多个其他服务器。

MySQL 支持许多复制拓扑，其中主从拓扑是一个最着名的拓扑之一，其中一个数据库服务器充当主服务器，而一个或多个服务器充当从服务器。默认情况下，复制是异步的，其中主服务器将描述数据库修改的事件发送到其二进制日志，并且从服务器在双方都准备好时请求事件。

## 1.1 Mysql 安装

通过apt安装的方法：https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/

## 1.2 配置主 MySQL 服务器。

$ sudo vim  /etc/mysql/mysql.conf.d/mysqld.cnf

```conf
server-id = 1
log_bin = mysql-bin
```

重启Mysql:

```shell
sudo systemctl restart mysql
```

新增同步的Mysql用户，不建议使用root。其实也没有办法直接使用root, 需要放开root允许非本地访问才可以。

```Sql
CREATE USER 'replica'@'192.168.88.66' IDENTIFIED BY 'password';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'192.168.88.66';
```

如果想要任何地址访问，可以使用'%'替换ip地址。

查看当前的二进制文件名和位置:

```SQL
mysql> SHOW MASTER STATUS\G
*************************** 1. row ***************************
             File: mysql-bin.000002
         Position: 112412
     Binlog_Do_DB: 
 Binlog_Ignore_DB: 
Executed_Gtid_Set: 
1 row in set (0.00 sec)

```

\G让显示更好看。

## 1.3 配置从Mysql服务器

$ sudo vim  /etc/mysql/mysql.conf.d/mysqld.cnf

```conf
log-bin = mysql-bin
server_id = 2
relay_log = /var/lib/mysql/mysql-relay-bin
log_slave_updates = 1
read_only = 1
```

重启Mysql:

```shell
sudo systemctl restart mysql
```

登录mysql，停止SLAVE线程：

```SQL
mysql -uroot -p

STOP SLAVE;
```

执行如下语句, 配置主服务器复制的命令:

```SQL
CHANGE MASTER TO
MASTER_HOST='192.168.88.99',
MASTER_USER='replica',
MASTER_PASSWORD='password',
MASTER_LOG_FILE='mysql-bin.000002',
MASTER_LOG_POS=112412;
```

确保使用正确的 IP 地址，用户名。和密码。日志文件名称和位置必须与从主服务器获取的值相同。

开始复制:

```SQL
START SLAVE;
```

## 1.4 测试

在主服务器上创建一个数据库，在从库就可以看到啦。

# 2. 数据库迁移工具Liquidbase

## 2.1 flyway还是Liquidbase
比较著名的数据库迁移工具主要是flyway和liquidbase, 最开始用的flyway, 后来改成了liquidbase。

Flyway的好处在于简单，而且直接书写SQL并不需要额外的学习。

如果使用过Flyway就会有一定的体会，Flyway的简单是有代价的，如果我们只需要支持多中数据库，SQL语句并不是一个广泛兼容的语言，有些关键字是独有的，这种情况下就需要书写两套SQL迁移文件。Spring Boot是内建这种支持的，可以从目录上做区分。

Liquibase相对就复杂了很多，它支持四种格式

- xml
- json
- yaml
- sql
Liquibase可以根据数据库的情况为你生成最后的迁移语句，同时因为数据库变动首先是被Liquibase解析，所以也可以简单支持回滚。

所以，目前的项目都采用liquidbase进行数据库的管理。

## 2.2 Liquidbase简介

官网地址：http://www.liquibase.org

LiquiBase是一个用于数据库重构和迁移的开源工具，通过日志文件的形式记录数据库的变更，然后执行日志文件中的修改，将数据库更新或回滚到一致的状态。

随着开发需求的更新，数据库也在随着变化，而每次部署，我们都得重新部署下数据库，这无疑带给我们无穷的烦扰，数据库的部署和迁移工作不止花销我们大量的时间，而且可能因为大意和开发服务器上的数据库不一致，导致程序出错，因此我们得有一个统一的处理机制来部署数据库，让我们的开发工作更快，更准确的进行。而Liquibase就能解决我们这一难题。

Liquibase优点：

- 支持几乎所有主流的数据库，如MySQL, PostgreSQL, Oracle, Sql Server, DB2等；
- 支持多开发者的协作维护；
- 日志文件支持多种格式，如XML, YAML, JSON, SQL等；
- 支持多种运行方式，如命令行、Spring集成、Maven插件、Gradle插件等；

## 2.3 Spring boot集成Liquidbase

新建LiquidbaseConfig.java文件：

```Java
import liquibase.integration.spring.SpringLiquibase;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;

@Configuration
public class LiquibaseConfig {
    private DataSource dataSource;

    public LiquibaseConfig(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Bean
    SpringLiquibase liquibase() {
        SpringLiquibase liquibase = new SpringLiquibase();
        liquibase.setDataSource(dataSource);
        liquibase.setChangeLog("classpath:liquibase/master.xml");
        liquibase.setShouldRun(true);
        return liquibase;
    }
}
```

build.gradle中增加liquidbase的依赖：

```groovy
implementation 'org.liquibase:liquibase-core'
```

## 2.3 Liquidbase使用

详细使用方法参考[官方文档](https://www.liquibase.org/documentation/index.html), 下面简单举例子说明几个常用的用法。

### 2.3.1 入口文件

根据LiquidbaseConfig.java配置的ChangeLog的路径， 在resource新建liqudbase/master.xml, 用于包含所有的ChangeLog文件。

```xml
<?xml version="1.0" encoding="utf-8"?>
<databaseChangeLog
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
        xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.5.xsd">

    <include file="changelog/create_table/v1_00000000000000_init_db_id.xml" relativeToChangelogFile="true" />
    ...
</databaseChangeLog>
```

### 2.3.2 建表和创建索引

```xml
<?xml version="1.0" encoding="utf-8"?>
<databaseChangeLog
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
        xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.5.xsd">

    <changeSet id="00000000000001" author="mingdutech">

        <createTable tableName="inventory" remarks="库存">
            <column name="id" type="bigint unsigned" remarks="主键">
                <constraints primaryKey="true" nullable="false"/>
            </column>

            <column name="product_id" type="bigint unsigned" remarks="外键:产品ID"/>
            <column name="cargo_space_id" type="bigint unsigned" remarks="外键，货位ID"/>
            <column name="project_id" type="bigint unsigned" remarks="外键: 项目ID"/>
            <column name="project_name" type="varchar(128)" remarks="项目名称"/>
        </createTable>

        <createIndex indexName="idx_inventory" tableName="inventory">
            <column name="product_id" type="bigint unsigned"/>
            <column name="cargo_space_id" type="bigint unsigned"/>
            <column name="project_id" type="bigint unsigned"/>

            <column name="batch_no" type="varchar(32)"/>
            <column name="production_date" type="datetime"/>
        </createIndex>
    </changeSet>

</databaseChangeLog>
```

通过createTable建表，createIndex创建索引。

### 2.3.3 插入数据

```xml
    <insert tableName="customization_table_item">
        <column name="table_name" value="SysUserDto"/>
        <column name="item_key" value="account"/>
        <column name="item_name" value="用户名"/>
    </insert>
    <insert tableName="customization_table_item">
        <column name="table_name" value="SysUserDto"/>
        <column name="item_key" value="name"/>
        <column name="item_name" value="姓名"/>
    </insert>
    <insert tableName="customization_table_item">
        <column name="table_name" value="SysUserDto"/>
        <column name="item_key" value="roleName"/>
        <column name="item_name" value="角色"/>
    </insert>
```

## 2.3 liquidbase基本原理

当Liquibase执行databaseChangeLog时，它按顺序读取changeSets，并为每个检查“databasechangelog”表以查看是否已运行id / author / filepath的组合。如果已经运行，则将跳过changeSet，除非存在真正的“runAlways”标记。在运行changeSet中的所有更改之后，Liquibase将在“databasechangelog”中插入带有id / author / filepath的新行以及changeSet的MD5Sum。

Liquibase尝试在最后提交的事务中执行每个changeSet，或者在出现错误时回滚。某些数据库将自动提交干扰此事务设置的语句，并可能导致意外的数据库状态。因此，通常最好每个changeSet只进行一次更改，除非您希望将一组非自动提交更改应用为插入数据等事务。

当您需要通过手术改变现有的changeSet时，请记住Liquibase的工作原理：每个changeSet都有一个“id”，一个“作者”和一个文件路径，它们共同唯一地标识它。如果DATABASECHANGELOG表具有该changeSet的条目，则它将不会运行它。

如果它有一个条目，如果文件中changeSet的校验和与上次运行时存储的校验和不匹配，则会引发错误。

## 2.4 Liquidbase开发规范

随着项目的发展，一个项目中的代码量会非常庞大，同时数据库表也会错综复杂。如果一个项目使用了Liquibase对数据库结构进行管理，越来越多的问题会浮现出来。

- ChangeSet文件同时多人在修改，自己的ChangeSet被改掉，甚至被删除掉。
- 开发人员将ChangeSet添加到已经执行过的文件中，导致执行顺序出问题。
- 开发人员擅自添加对业务数据的修改，其它环境无法执行并报错。
- ChangeSet中SQL包含schema名称，导致其它环境schema名称变化时，ChangeSet报错。
- 开发人员不小心改动了已经执行过的ChangeSet，在启动时会报错。

### 2.4.1 发布

- 本次发布前的所有的changeLog id都是作为初始发布， v1_00000000-000_description.xml。 否则一堆changelog看着让人痛苦。

### 2.4.2 发布后

- 针对bug的修改， changeLog id格式为 v1_yyyymmdd-001_description.xml, 001是当天顺序递增的序号。
- 已经执行过的ChangeSet严禁修改。

# 3. 数据优化
在不升级硬件的情况下，加压的主要思路：

- 应用优化，看看是否有不要的压力给了数据库
- 引入缓存, 降低对数据库的压力
- 数据库的数据和访问分到多台数据库上

## 3.1 数据拆分

### 3.1.1 垂直拆分
垂直拆分就是把一个数据库中不同业务单元的数据分到不同的数据库里面

- 单机的ACID保证被打破了。数据分散到多机后，原来在单机通过事物进行的处理逻辑会受到很大的影响。要么放弃原来的单机事务，修改实现；要么引入分布式事务。
- 一些Join操作变得很困难
- 靠外键去进行约束的场景会收到影响

### 3.1.2 水平拆分
水平拆分是根据一定的规则把统一业务单元的数据拆分到多个数据库中。

- 同样单机的ACID保证被打破了
- 同样一些Join操作变得很困难
- 同样靠外键去进行约束的场景会收到影响
- 依赖单裤的自增序列生成唯一ID将会受影响。
- 针对单个逻辑意义上的表单的查询要跨库了

从工程上来说，如果能够避免分布式事务的引入，那么还是避免为好；如果一定要引入分布式事务，那么，可以考虑最终一致的方法，而不要追求强一致。而且从实现上来说，最好通过补偿的机制不断重试，让之前因为异常而没有进行到底的操作继续进行，而不是回滚。

## 3.1.3 跨库Join

最好能够设计好分库分表规则，分库分表后需要的数据还在同一个数据库中，同样还是单库单表问题。
分库后，如果原来需要join的数据还在一个库里面，那就可以直接进行join。如按照用户ID进行分布，那么用户信息的join数据同样分布到相同的库中了，还是可以join的。

如果需要join的数据分布在不同的库中，这会比较麻烦:

- 应用层把原来join大的操作分成多次数据库操作。根据ID一个一个查询出来。
- 数据冗余，对一些常用信息进行冗余，这样就可以直接进行join操作。Mycat就有Global操作，只要写入到Global标记的表中，数据会同步到每一个表中，这就解决了常用信息的join问题。

## 3.2 改写SQL

- 表名需要有后缀区分，这样可以减少误操作，同时进行数据迁移的时候也比较方便。
- 索引名也需要修改，需要从逻辑上的名字变为对应数据库中的名字
- 平均值计算不能从多个数据源取平均值，再计算平均值，必须获取所有数据再计算平均值。

## 3.3 读写分离

- Mydql的Replication可以解决复制的问题，并且延时也相对较小。业务根据自身的业务特点从备库读取对数据不太敏感的数据。
- 通过消息系统就数据库的更新送出消息通知，数据同步服务器获得消息通知后会进行数据的复制工作，分库规则配置服务负责通知分库规则。这个方式不是很优雅，比较优雅的方式时通过数据库的日志进行数据的复制。

## 3.4 数据迁移

1. 数据迁移是记录增量日志
2. 迁移结束后，被迁移的数据写暂停，处理增量变化
3. 增量日志处理完毕，切换规则，放开所有的写。

# 4. Sharding-jdbc

Sharding-jdbc是一个分库分表，读写分离的数据库中间件。在Java的JDBC层提供的额外服务。 它使用客户端直连数据库，以jar包形式提供服务，无需额外部署其它服务，可理解为增强版的JDBC驱动，完全兼容JDBC和各种ORM框架。更多介绍，参考[官方地址](https://shardingsphere.apache.org/index_zh.html)

注意：Sharding-jdbc 4.0.0-RC1 版本**不支持** spring-boot2, [不支持spring boot 2 gitlab issu 连接](https://github.com/apache/incubator-shardingsphere/issues/623)。我这里使用spring boot2 会打印如下错误:

```log
The bean 'dataSource', defined in class path resource [org/apache/shardingsphere/shardingjdbc/spring/boot/SpringBootConfiguration.class], could not be registered. A bean with that name has already been defined in class path resource [com/alibaba/druid/spring/boot/autoconfigure/DruidDataSourceAutoConfigure.class] and overriding is disabled.
```

spring-boot使用Sharding-jdbc还是比较容易的，只需要引入依赖和配置applicaition.yml就可以了。

## 4.1 引入依赖关系

build.gradle

```groovy
implementation 'org.apache.shardingsphere:sharding-jdbc-spring-boot-starter:4.0.0-RC1'
implementation 'com.alibaba:druid-spring-boot-starter:1.1.10'                              # 后面使用druid作为连接池
```

## 4.2 读写分离

```yaml
spring:
  shardingsphere:
    datasource:
      names: ds_master,ds_slave_0
      ds_master:
        driver-class-name: com.mysql.jdbc.Driver
        type: com.alibaba.druid.pool.DruidDataSource
        url: jdbc:mysql://192.168.88.153:3306/wms?serverTimezone=UTC&useSSL=false&useUnicode=true&characterEncoding=UTF-8
        password:                                                                               # 填写自己的用户名和密码
        username: 
      ds_slave_0:
        type: com.alibaba.druid.pool.DruidDataSource
        driver-class-name: com.mysql.jdbc.Driver
        url: jdbc:mysql://192.168.88.145:3306/wms?serverTimezone=UTC&useSSL=false&useUnicode=true&characterEncoding=UTF-8
        password: 
        username: 
    masterslave:
      name: ms                                                                                  # name需要写
      load-balance-algorithm-type: round_robin
      master-data-source-name: ds_master
      slave-data-source-names: ds_slave_0
    props:
      sql:
        show: true
```

通过打开mysql的日志，验证读取的主库还是从库：

```SQL
SET GLOBAL general_log = 'ON';
SET GLOBAL general_log_file = '/var/log/mysql/general_log.log';
```

通过tail -f 查看mysql都之行了哪些语句，是在主库还是从库上执行：

```shell
$tail -f general_log.log
2019-05-10T07:05:30.409848Z	 1761 Query	UPDATE wms.DATABASECHANGELOGLOCK SET LOCKED = 0, LOCKEDBY = NULL, LOCKGRANTED = NULL WHERE ID = 1
2019-05-10T07:05:30.410721Z	 1761 Query	commit
2019-05-10T07:05:30.512030Z	 1761 Query	rollback
2019-05-10T07:05:30.512620Z	 1761 Query	SET autocommit=1
2019-05-10T07:05:34.962297Z	 1751 Query	SELECT id,table_name,current_id  FROM db_id
2019-05-10T07:05:49.459433Z	 1751 Query	select @@session.transaction_read_only
2019-05-10T07:05:49.460161Z	 1751 Query	INSERT INTO db_id  ( id,table_name,current_id ) VALUES( null,'base_project',1 )
2019-05-10T07:05:49.583500Z	 1751 Query	select @@session.transaction_read_only
2019-05-10T07:05:49.584177Z	 1751 Query	INSERT INTO base_project  ( create_by,modified_by,gmt_create,gmt_modified,id,user_id,name,code,description,start_time,end_time ) VALUES( null,null,null,null,1,0,'string','string','string','2019-04-11 08:00:00',null )
2019-05-10T07:36:22.943582Z	 1751 Quit	
```

## 4.3 读写分离后导致liquidbase不可用的解决方法

由于shard-jdbc改写了Datasource, liquidbase启动时，去从库读取log和锁， 导致启动失败。liquidbase支持配置数据源，不使用Shard-jdbc的数据源就可以了。

```java
import liquibase.integration.spring.SpringLiquibase;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;

@Configuration
public class LiquibaseConfig {
    private DataSource dataSource;

    @Value("${spring.shardingsphere.datasource.ds_master.driver-class-name}")
    String driver;
    @Value("${spring.shardingsphere.datasource.ds_master.url}")
    String url;
    @Value("${spring.shardingsphere.datasource.ds_master.username}")
    String username;
    @Value("${spring.shardingsphere.datasource.ds_master.password}")
    String password;


    public DataSource masterDbDataSource() {
        return DataSourceBuilder.create().driverClassName(driver).url(url).username(username).password(password).build();
    }

    @Bean
    SpringLiquibase liquibase() {
        SpringLiquibase liquibase = new SpringLiquibase();
        liquibase.setDataSource(masterDbDataSource());
        liquibase.setChangeLog("classpath:liquibase/master.xml");
        liquibase.setShouldRun(true);
        return liquibase;
    }
}
```

## 4.4 强制某些读操作查询主库

一些场景对实时性要求比较高，可以通过Hint强制读取主库。

这段代码时系统初始化时执行的，如果读取从库，这时候从库还没有建表完成，导致报错，所以强制从主库读取。

```Java
public static synchronized void init(DbIdDao dao) {
    DbIdUtil.dao = dao;

    dbIdMap = AtomicLongMap.create();

    HintManager.clear();                                              // 不执行clear，抛异常
    HintManager hintManager = HintManager.getInstance();              // 获取HintManger

    hintManager.setMasterRouteOnly();                                 // 强制读取主库
    List<DbIdEntity> idEntityList = dao.selectAll();
    hintManager.close();                                              // 关闭强制读取主库

    for (DbIdEntity dbIdEntity : idEntityList) {
        dbIdMap.put(dbIdEntity.getTableName(), dbIdEntity.getCurrentId().longValue());
    }
}
```

还有其他方法，设置某条语句， 这里是初始化，所以直接设置读取主库也是可以的，而且比较方便。