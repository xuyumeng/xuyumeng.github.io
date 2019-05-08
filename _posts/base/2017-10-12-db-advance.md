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

# 3. 数据库优化
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
