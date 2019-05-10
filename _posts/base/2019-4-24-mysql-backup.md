---
layout:     post
title:      "数据库备份"
subtitle:   "Mysql数据库备份的方法"
author:     Sun Jianjiao
header-img: "/img/bg/railway-station-1363771_1280.jpg"
catalog: true
tags:
    - 数据库

---

说到数据库备份，那么一定要说数据恢复，因为一旦数据出现问题，只有最好的备份系统是没有用的，还需要一个强大的恢复系统。 

规划备份策略时需要考虑：

- 可以容忍丢失多少数据？
- 备份时间，复制备份到目的地需要多久？
- 备份负载，在备份复制到目的地对服务器的性能影响有多大？
- 恢复时间，把备份从存储位置复制到Mysql服务器，重放二进制日志等，需要多久？


# 1. 备份方案

《高性能mysql》的备份建议:

- 在生产实践中，对于大多数数据库来说，物理备份是必须的；逻辑备份太慢并受到资源限制，从逻辑备份中恢复需要很长时间。基于快照的备份，例如Percona XtraBrackup和Mysql Enterprise Backup是最好的选择。对于较小的数据库，逻辑备份也可以很好的胜任。
- 保留多分备份
- 定期从备份中抽数数据进行恢复测试
- 保存二进制日志用于基于故障时间点的恢复。

## 1.1 逻辑备份还是物理备份

- 逻辑备份，也叫导出，将数据包含在一种Mysql能够解析的格式中，如SQL。最大的缺点是从mysql中导出数据和通过SQL语句将其加载回去的开销。
- 物理备份，直接复制原始文件。通常物理备份更加高效，但是物理备份更容易出错。

尽量不要完全依赖物理备份，至少每隔一段时间还是要做一次逻辑备份。混合使用逻辑备份和物理备份。先做物理复制，以此数据启动mysql实例，并且运行mysqlcheck。然后周期性的使用mysqldump执行逻辑备份。这样做可以获得两种方法的优点，不会使生产服务器在导出时有过度负担。

## 1.2 增量备份

- 使用Percona XtraBackup或者Mysql Enterprise backup中的增量备份特性。
- 备份二进制日志。可以在每次备份后使用FLUSH LOGS来开始一个新的二进制日志。这样就只需要备份新的二进制日志。
- 某些数据不需要备份，例如从其他数据构建大的数据仓库。可以备份构建仓库的数据，而不是数据仓库本身。及时从源数据重建数仓的“恢复”时间较长，避免非分可以节约更多的总时间开销。

增量备份的缺点增加了恢复的复杂性，额外的风险，以及更长的恢复时间。如果可以做全备，考虑到简便性，建议尽量做全备。

不管如何，还是需要经常做全被的——至少一周一次。使用一个月的增量数据进行恢复会带来更多的工作和风险。

## 1.3 管理和备份二进制文件
服务器的二进制日志是备份的最重要因素之一。他们对于基于时间点的复制恢复是必须的，并且通常比数据要小，所以更容易进行频繁的备份。

经常备份二进制日志是一个好主意。如果不能承受丢失超过30分钟数据的丢失，至少要每30分钟备份一次。也可以用一个配置--log_slave_updat的只读备库，这样可以获得额外的安全性。

Mysql 5.6版本的mysqlbinlog有一个非常方便的特性，可连接到服务器上来实时对二进制进行做镜像。

## 1.4 总结

每个人都知道需要备份，但是每个人更需要意识到需要的是可恢复的备份。

《高性能Mysql》中提到最喜欢的2种备份方式，一种是通过文件系统或者SAN快种中直接复制数据文件，或者使用Percona XtraBackup做热备份。

同时他也建议备份二进制日志，并且尽可能久的保留多份备份数据和二进制文件。

# 2. Percona XtraBackup

《高性能Mysql》强烈推荐Percona Xtrabackup, 备份过程中服务器的负载没有明显的上升，对于大数据库的备份，Percona xtrabackup是一个不错的选择。[Percona XtraBackup 官方文档](https://www.percona.com/doc/percona-xtrabackup/LATEST/index.html)

## 2.1 安装

[官方文档安装文档](https://www.percona.com/doc/percona-xtrabackup/LATEST/installation/apt_repo.html)

```Shell
wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb

sudo percona-release enable-only tools
sudo apt-get update
sudo apt-get install percona-xtrabackup-80
```
## 2.2 备份
### 2.2.1 全量备份

```shell
mkdir -p data/backups/base
sudo xtrabackup --user=${user} --password=${password} --backup --target-dir=/data/backups/
```

### 2.2.2 增量备份

```shell
mkdir -p data/backups/base
sudo xtrabackup --user=${user} --password=${password} --backup --target-dir=data/backups/base

mkdir -p data/backups/inc1
sudo xtrabackup --user=root --password=abc-123 --backup --target-dir=data/backups/inc1 --incremental-basedir=data/backups/base
```

data/backups/inc1/包含了基于data/backups/base的增量数据。

### 2.2.3 压缩

```shell
sudo xtrabackup --compress --user=${user} --password=${password} --backup --target-dir=data/backups/
```

## 2.3 备份数据处理（Preparing a backup)

通过 --backup 备份后，我们需要通过 prepare 选项对数据进行处理后，才能重新恢复它。否则数据是不一致的，因为他们在不同的时间被拷贝，并且可能在改变的时候正好被复制了。

```shell
xtrabackup prepare --target-dir=/data/backups/
```

如果是增量备份，需要增加 --apply-log-only

```shell
xtrabackup prepare --apply-log-only --target-dir=/data/backups/base

 xtrabackup --prepare --apply-log-only --target-dir=/data/backups/base \
--incremental-dir=/data/backups/inc1
```

## 2.4 数据恢复

### 通过xtrabackup进行恢复

```shell
sudo service mysql stop
sudo xtrabackup --copy-back --target-dir=/data/backups/
sudo chown -R mysql:mysql /var/lib/mysql
sudo service mysql start
```

### 通过rsync 进行恢复
> 如果恢复的机器上没有装xtrabackup, 可以通过rsync进行恢复

```shell
$ sudo service mysql stop
$ sudo rsync -avrP /data/backup/ /var/lib/mysql/
$ sudo chown -R mysql:mysql /var/lib/mysql
$ sudo service mysql start
```

# 3. 二进制日志

## 3.1 基于flush logs方式实现binlog文件切换

通过last_binlog_pos.txt文件记录上一次备份的位置点信息，下一次备份基于该位置点信息进行增量备份。如果是首次备份（last_binlog_pos.txt文件不存在，则全量备份binlog）；通过flush logs的方式强行切换binlog文件（只备份到次新的binlog文件），避免备份binlog过程中，MySQL仍对其进行写入操作；备份每个binlog文件对其生产侧和备份侧的binlog文件md5值进行校验，校验不通过通过配置重传次数$num，超过重传次数仍md5值校验不通过的话，放弃该binlog备份并记录到日志。

## 3.2 实时备份
通过mysqlbinlog的--read-from-remote-server、 --stop-never参数实现异地binlog实时备份。通过while死循环的方式，避免由于网络等异常造成的断连。
查看有哪些日志文件：

```SQL
show binary logs
```

执行远程备份：

```SQL
mysqlbinlog --read-from-remote-server --raw --host=${ip} --port=${port} --user=${user-name} --password=${password} --stop-never binlog.000010
```

- --read-from-remote-server：用于备份远程服务器的binlog。如果不指定该选项，则会查找本地的binlog。
- --raw：binlog日志会以二进制格式存储在磁盘中，如果不指定该选项，则会以文本形式保存。
- --user：复制的MySQL用户，只需要授予REPLICATION SLAVE权限。
- --stop-never：mysqlbinlog可以只从远程服务器获取指定的几个binlog，也可将不断生成的binlog保存到本地。指定此选项，代表只要远程服务器不关闭或者连接未断开，mysqlbinlog就会不断的复制远程服务器上的binlog。

- binlog.000010：代表从哪个binlog开始复制。

## 3.3 总结

第一种方式，可以通过验证md5值的方式确保备份同生产的一致性。备份的逻辑简单，便于理解。
第二种方式，可以实现binlog实时备份功能。
所以，基于以上的优缺点分析，选择哪种备份策略，仍需要根据生产环境的实际需要进行抉择。如果数据安全级别很高，也可以考虑2种方式同时使用。

# 4. 备份到远程的服务器

## 4.1 通过rsync进行备份

```shell
rsync -avr ${user-name}@${ip}:${src-path} ${target-path}
```

### 4.1.1 权限控制
![访问方向](/img/post/base/database-backup/remote-backup.png)

最好是备份服务器通过一个权限比较低的用户，只有只读权限访问备份文件，定时从数据库服务器拉取。

如果是从数据库服务器直接写到备份服务器，那么数据库服务器就有了备份服务器的写权限，如果黑客入侵了数据库服务器，就有了备份服务器的写权限，他可以同时破坏备份的数据。

### 4.1.2 通过cron进行定时执行

```shell
# crontab -e

# m  h  dom mon dow   command  
  30 *   *   *   *    rsync -avr ${user-name}@${ip}:${src-path} ${target-path}
```

每隔30分钟执行一次。也通过cron进行定时备份。

### 4.1.3 通过ssh key免密钥登录

参考文档 [免密码访问ssh远程linux](https://unanao.github.io/2010/10/01/linux/#1-%E5%85%8D%E5%AF%86%E7%A0%81%E8%AE%BF%E9%97%AEssh%E8%BF%9C%E7%A8%8Blinux)

# 5. 总结

通过Percona XtraBackup和binlog的备份，应该可以解决绝大多数情况下需要的数据的备份。