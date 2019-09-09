# 1 基本概念

1.Measurement：从原理上讲更像SQL中表的概念。这和其他很多时序数据库有些不同，其他时序数据库中Measurement可能与Metric等同，类似于下文讲到的Field，这点需要注意。


2.Tags：维度列

- 在InfluxDB中，表中Tags组合会被作为记录的主键，因此主键并不唯一，所有时序查询最终都会基于主键查询之后再经过时间戳过滤完成。
- 内存中有索引。
- 用于快速查找group等操作。

3.Fields：数值列

- 数值列存放用户的时序数据。
- 能够存储类型有类型的数值(字符串、浮点数、整数、布尔值), 可以用于数学运算，
- 没有索引

4.Point：类似SQL中一行记录，而并不是一个点。

5.单个Infuxdb没有设计支持很多的database
https://community.influxdata.com/t/reasonable-limit-of-influxdb-databases-per-host/4197

# 2 数据模型

## 2.1 数据建模规范

一个Point由measurement名称，tag set和timestamp唯一标识。如果提交具有相同measurement，tag set和timestamp，但具有不同field set的行协议，则field set将变为旧field set与新field set的合并，并且如果有任何冲突以新field set为准。

### 2.1.1 限制
- measurement相当于数据库中的表，时间数据 time、Tag、Field 组合成了 Measurement。
每个 field 的 value 类型必须保持一致，如果不确定，最好用 string 类型

- 不可以更新和重命名tags- see GitHub issue #4157 
- 不能通过tag key 删除tag - see GitHub issue #8604.

https://docs.influxdata.com/influxdb/v1.7/concepts/crosswalk/

### 2.1.2 设计模式

- 名字不要包含特殊字符，比如\，$，=，,，"等等。
- 名字避免关键字，不能是time，名字统一小写。
- 各个部门/模块的measurement name有个统一的前缀，方便维护。

- 不要在一个tag里存储多个信息。
- field的类型一旦写入最好不要修改，默认是float，如果是字符串，需要加双引号。
- measurement的名字和tag set的总长度不要超过65536。

1. 如下情况使用tag
> 一般来说，你的查询可以指引你哪些数据放在tag中，哪些放在field中。
- 把你经常查询的字段作为tag
- 如果你要对其使用GROUP BY()，也要放在tag中
- 如果你要对其使用InfluxQL函数，则将其放到field中
- 如果你需要存储的值不是字符串，则需要放到field中，因为tag value只能是字符串
- tag的名字和值不要太长，名字和值的长度越长，占用的内存越多。

2. 不要有太多的series
tags包含高度可变的信息，如UUID，哈希值和随机字符串，这将导致数据库中的大量series, series cardinality高是许多数据库高内存使用的主要原因。因为这些数据都是存储在内存里，会导致OOM (理解series概念)。

3. IfluxDB的查询会合并属于同一measurement范围内的数据，用tag区分数据比使用详细的measurement名字更好。

4. 时间戳
建议使用最粗糙的精度，因为这样可以显着提高压缩率。 Influxdb并不要求时间戳唯一，不同的tag, 相同的时间戳可以写入一条新的记录。也就是说对于普通的采集，以毫秒为单位完全可以满足需求。

https://jasper-zhang1.gitbooks.io/influxdb/content/Write_protocols/line_protocol.html

```
> select * from cnc2
name: cnc2
time                datasource device value
----                ---------- ------ -----
1434055562000000000 pa                30
1434055562000000001 pa                30
1434055562000000001 pa1               30
1434055562000000001 pa1        d1     30
1434055562000000001 pa1        d2     30
```

## 2.2 数据模型设计

### 2.2.1 数据举例

| 采集时间                       | 设备      |数据源        |  数据        |   类型   |
| :---------------------------- | :-------- | :--------   | :----------- | :------- |
| 2018-11-15T05:40:46.3592112Z  | CNC       |  温度        |  10.5       | float    |
| 2018-11-15T05:41:41.9896781Z  | CNC       |  设备状态    |  run        | String    |
| 2018-11-15T05:42:02.8402281Z  | CNC       |  湿度        |  10         | int      |

### 2.2.2 measurement
1个设备作为1个measurement，用于存放一个设备的所有测量指标。
没有选择数据源作为measurement， 因为数据源太多，influxdb没有对measurement进一步抽象的方式。并且influxdb推荐使用tag，而不是创建很多measurement。

### 2.2.3 tag
数据源作为tag， 方便根据数据源进行查询，聚合，group等操作。

### 2.2.4 field
- 数据： <数据源名称, 采集数据> 作为field的键值对。因为一个键值对应的类型必须唯一，所以每个数据源单独作为field的键值。

- type： 数据类型，预留，后续如果需要，可以使用

### 2.2.5 timestamp
采集时间作为timestamp， 单位ms。

## 2.3 数据建模方案 
### 2.3.1 方案一
只有一个measurement

| 业务字段         | influxdb类型  |
| :-------------- | :------------ |
| 采集时间         | timestamp     |
| 设备名称         | tag           |
| 数据源           | tag           |
| 采集数据         | field value   |
| 数据类型         | field value   |
| 入库时间         | field value   |

### 2.3.2 方案二
每类指标一个measurement

| 业务字段         | influxdb类型  |
| :-------------- | :------------ |
| 采集时间         | timestamp     |
| 设备名称         | tag           |
| 采集数据         | field value   |
| 数据类型         | field value   |
| 入库时间         | field value   |

### 2.3.3 方案三
每个设备一个measurement

| 业务字段         | influxdb类型  |
| :-------------- | :------------ |
| 采集时间         | timestamp     |
| 数据源           | tag           |
| 采集数据         | field value   |
| 数据类型         | field value   |
| 入库时间         | field value   |

根据测试聚合查询测试结果确定最终方案。 考虑查询的方便性，采用方案三。

## 2.4 InfluxDb中存储方式

```
> select * from cnc
name: cnc
time          humidity status tag         temperature type
----          -------- ------ ---         ----------- ----
1542260446359          run    status                  string
1542260501989 10              humidity                int
1542260522840                 temperature 10.5        float
```

## 2.5 使用场景
> 1. 查询主体： 设备
> 2. 查询条件： 
> - 起止时间 （针对采集时间）
> - 数据源   （可选， 没有选择数据源， 查询设备对应的所有的数据源）


- InfluxQL语法连接地址：[InfluxQL 语法](https://jasper-zhang1.gitbooks.io/influxdb/content/Query_language/)

### 2.5.1 查询设备的所有采集数据

查询cnc设备的所有采集数据

```
> select * from cnc
name: cnc
time                humidity status tag         temperature type
----                -------- ------ ---         ----------- ----
1542260356489000000                 temperature 10
1542260356489448300 20              humidity
1542260384285675600          run    status
1542260446359211200          run    status                  string
1542260501989678100 10              humidity                int
1542260522840228100                 temperature 10.5        float
``` 

### 2.5.2 根据时间和数据源查询采集数据

查询1542260316489ms到当前时间所有“温度”和“湿度”的采集数据
```
> select "temperature","humidity" from "cnc" where time > 1542260316489ms AND time < now()

name: cnc
time                temperature humidity
----                ----------- --------
1542260356489000000 10
1542260356489448300             20
1542260501989678100             10
1542260522840228100 10.5
```

### 2.5.3 数据运算-最大值，最小值，平均值

查询1542260316489ms到当前时间所有temperature的最大值
```
> select MAX("temperature") from "cnc" where time > 1542260316489ms AND time < now()

name: cnc
time                max
----                ---
1542260522840228100 10.5
```

### 2.5.4 多数据源关联处理
例如查询温度和湿度同时满足: (温度> 50度) 和（湿度 > 80%）

目前无法直接通过InfluxDB直接查询解决，因为采集数据不一定是同时采集，数据不在同一行，无法直接查询。
- 数据汇聚提供合并功能。
- 特殊的功能应用自己对数据处理。

数据汇聚提供2个维度的数据合并，将2个维度作为基础功能，多个维度应用服务自己处理，也可以多次调用合并服务处理。

# 3 如何应对磁盘容量

对于非字符串的情况，我们一条记录预计需呀5字节。 每秒写10万条记录，24小时会占用43.2G内存。

工业采集的数量非常巨大, 并且数据持续增长对查询性能和存储空间带来了挑战。

对于数据持续增长的情况，主要通过3种方法解决：

- 无效的数据直接删除
- 降低数据的采样频率
- 通过分库，分表，多服务器进行扩容

## 3.1 数据彻底删除
对于如下数据：
- 操作工的操作记录
- 日志
- 过期的数据(如汽车追溯的数据，已经过质保，车子已经报废了，这些数据应该也是可以删除的)

过期且没有意义的数据可以通过设置保留策略（Retention Policies），到期自动删除数据。保留策略用于决定数据存放在influxdb中的时长，缺省是永远不会被删除的。尽早根据使用场景和需求确定数据的RP是很重要的。

## 3.2 降低数据的采样率
存放长时间的原始数据对于查询性能和磁盘空间是一个挑战。如果可能的话，需要考虑降低采样率和对数据进行聚合。

下面以机器的产能举例说明：

如果工厂认为机器的产能，过往太久的历史数据是没有用处的，所以可以创建如下RP：
- default/30天
缺省的RP保存30天的全量数据，没有聚合的产能数据可以用于明确产能是否退化和其他的问题。

- 2个月/60天
2个月的RP是第一层的数据汇总策略，数据会被保存60天。我们会从default RP策略中，计算每10分钟产能的平均值，并且保存计算的平均值。这样我们的工厂的管理者能够review过去2个月内10分钟精度的数据。

- six_months / 个月
6个月的RP是第二层的数据汇总策略，数据会被保存60天。我们会从two_month RP策略中，计算每30分钟产能的平均值，并且保存计算的平均值。这样我们的工厂管理者能够review过去180天之内30分钟精度的数据。

- historical/历史
历史的RP是最后的汇总策略，数据会被永久保存。我们会从six_month RP策略中，计算每60分钟产能的平均值，并且永久保存计算的平均值。这样我们的工厂管理者能够review过去60分钟精度的数据。可以用于查看历史的产能。

可以通过influxdb的连续查询 (Continuous Queries) / kapacitor来降低数据的采样， 此处的典型目的是将一个RP的数据进行聚合和降低采样后写入另一个RP。

**通过降低数据采样后，如果有1000台设备，每台设备10个数据源，每条记录5Byte计算，1年最终保存的数据只有438M，大大降低了存储成本**。

## 3.3 通过分库/分表进行扩容
对于不能采用保留策略和降低数据采样的场景，如追溯（数据还没有到达废弃的时间），需要influxdb具有扩容的能力。开源版本的influxdb没有集群的功能，也没有类似mysql mycat的分库分表成熟的中间件。

目前influx-proxy离我们的需求最靠近，2000行左右的代码量，整体看了代码，可以掌控，计划基于influx-proxy实现满足我们influxdb的分库功能。

流程如下：
```
        ┌─────────────────┐
        │writes & queries │
        └─────────────────┘
                 │
                 ▼
         ┌───────────────┐
         │               │
         │InfluxDB Proxy │
         |  (only http)  |
         │               │         
         └───────────────┘       
          |              |       
        ┌─┼──────────────┘       
        │ └──────────────┐       
        ▼                ▼       
  ┌──────────┐      ┌──────────┐  
  │          │      │          │  
  │ InfluxDB │      │ InfluxDB │
  │          │      │          │
  └──────────┘      └──────────┘
```
Influx proxy 通过手动配置measurement和Influxdb后端的关系，完成measurement的映射。 查询和写入时， influx-proxy根据映射写入对应的Influxdb后端，并且一个后端只对应一个数据库，只支持按照measurement粒度进行分库。

但是对于我们的应用场景，手动指定是不行的，如果现场有几千台设备，我们手动指定会疯掉的。 我们需要支持按照时间建库，如每年1个库。

满足我们的需求，还需要如下功能：
- InfluxDb proxy 自动分配measurement到对应的InfluxDB （按照measurement数量等比例分配, 根据采集频率等比例分配，根据设置比例进行分配）
- InfluxDb Proxy 记录对应关系到关系型数据库
- 每个influxdb的实例支持多个数据库
- 基于配置的时间自动分库


## 3.4 总结

对于存储空间，提前做好规划是前提。只有做好规划，才能确定最终的方案。数据是否可以删除，降低数据采样都是需要根据客户的需求来定，但是将无用的数据删除是一种最好的方式，客户可以节约成本，我们的软件运维和部署也会简单。

对于通过Influx-proxy进行分库的方案，理论上不仅可以满足扩大存储空间，同时可以提高存储的性能。

# 4 性能

## 4.1 Series 规模很重要

series 是共享tag, measurement, retention policy的集合。

举例说明：
使用InfluxDb作为记录响应时间的数据库，同时包含一些其他的指标。每隔相应指标多有下面五个条目：

- 客户端的IP地址
- 应用服务的IP地址（假设运行了多台服务器)
- 运行服务的版本号
- 请求的响应时间
- 请求返回的Http Response Code

在存储数据到InfluxDB之前，我们需要设计哪个字段作为tag, 那个字段作为field。 每一个series在内存中存储了一个反向索引(也叫倒排索引，给定关键词，找出包含关键词的文档)， 这就表明series的规模决定了计算机的配置。

- Tags 在内存中索引，提供快速的查询和分组功能。缺点是如果有太多不同的tag, 需要的内存资源会不断攀升。
- Fields 在内存中没有索引， 但是有类型，可以进行数学运算，并且不影响series的规模。

我们需要genuine下面5点确定是tag还是field：

- 数值的规模很大，那就是field
- 如果要作为where的条件，那应该作为tag。 field可以作为条件，但是效率很差。
- 如果要作为group by的条件，那需要作为tag, field不能进行group by。
- 如果需要做数学运算(如mean, percentile, stddev), 那必须是field。 tag的值不能进行数学运算。
- 如果需要存储数据的类型(int, float, string, boolean), 必须是filed. tag只能是字符串。

总结一下， 数据的规模很大，需要进行数学运算，或者需要存储为特定的类型(boolean, int, float等等)，作为field。 如果数据需要进行group by, 或者在where条件中使用，那么存储为tag。

现在基于我们上面对tag和field的理解，我们设计一下上面的例子。

客户端的ip地址
由谁是客户端的决定，规模几乎是不确定的（比如facebook）， 由于这个条目规模很大，其他条件都不用考虑了，我们将它作为field存储。

服务的IP地址
服务的IP地址规模是可以确定，假设有10台服务器。由于规模很小，没有必要作为field

## 4.2 批量写入
建议每批写5000 point开始， 然后根据机器配置和应用调整。

## 4.3 问题分析工具
监控信息

## 4.4 块独立的磁盘
wal和data文件夹需要在存储设备上分开，并且只给influxdb使用。当系统处于大量写入负载下时，此优化可显着减少磁盘争用。 如果写入负载高度变化，这是一个重要的考虑因素。

将data, wal独立磁盘后，查询10000条记录的时间从270ms左右减少到170ms左右。

参考文档: https://docs.influxdata.com/influxdb/v1.7/guides/hardware_sizing/

## 4.5 关闭多余的log

搜索所有的 query-log-enabled，修改为false

```conf
query-log-enabled = false
```

https://community.influxdata.com/t/disable-influxd-logging/429

# 5 数据安全

使用数据库自带的备份方式进行备份。

- 支持本地备份
- 远程备份
- 整个数据库备份
- 指定时间段进行备份

# 6 硬件指南

## 6.1 配置

- CPU：4~6核
- 内存：8~32GB
- IOPS：1000+

## 6.2 SSD硬盘

InfluxDB被设计运行在SSD上，InfluxData团队不会在HDD和网络存储上测试InfluxDB，所以不太建议在生产上这么去使用。在机械磁盘上性能会下降一个数量级甚至在中等负载下系统都可能死掉。为了最好的结果，InfluxDB至少需要磁盘提供1000 IOPS的性能。

## 6.3 块独立的磁盘

wal和data文件夹需要在存储设备上分开，并且只给influxdb使用。当系统处于大量写入负载下时，此优化可显着减少磁盘争用。 如果写入负载高度变化，这是一个重要的考虑因素。

参考文档: https://docs.influxdata.com/influxdb/v1.7/guides/hardware_sizing/
