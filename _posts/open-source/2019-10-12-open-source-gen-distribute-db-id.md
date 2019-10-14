---
layout:     post
title:      "分布式系统中生成数据库ID"  
subtitle:   "不需要单独部署生成ID服务"
author:     Sun Jianjiao
header-img: "img/bg/default-bg.jpg"
catalog: true
tags:
    - open source

---

本文介绍的是一个分布式系统中生成数据库ID的方法，服务只需要应用这个jar包就可以生成不重复的ID。不需要单独的ID生成服务器，也不需要分布式锁服务。

每个表的数据库ID递增，为了较少开销，每次批量分配多个ID保存在服务内部。当然这样就有一个缺点，如果服务重启，未消费的ID就浪费了。

# 1 实现方法详解

```Java
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.DependsOn;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

/**
 *  We use database as the distribute lock, if the database update successfully.
 *  After the service get the assigned database ID, the assigned id is only for the service,
 *  We should only make service itself is thread safe.
 */

@Data
@AllArgsConstructor
@NoArgsConstructor
class IdAssign {
    private final static int NOT_ASSIGN = 0;

    long currentId = 1;         // id start from 1
    long assigned = NOT_ASSIGN;          // 0 means not assigned yet

    protected boolean isAssigned() {
        return assigned == NOT_ASSIGN ? false : true;
    }

}

@Component
@Slf4j
@DependsOn("liquibase")
@Order(Ordered.HIGHEST_PRECEDENCE)
public class DbIdService {
    @Value("${dbId.assignEachTime ?: 64}")
    @Getter
    private long assign_num;

    @Resource
    private DbIdDao dao;


    ConcurrentHashMap<String, IdAssign> dbIdMap = new ConcurrentHashMap<>();

    /**
     * If the service is restart, the last assigned ids is deprecated
     * We should assign new id
     */
//    @PostConstruct
    public void init() {
        List<DbIdEntity> idEntityList = dao.listAll();
        for (DbIdEntity dbIdEntity : idEntityList) {
            IdAssign idAssign = new IdAssign();
            updateAssignId(dbIdEntity.getTableName(), idAssign);

            dbIdMap.put(dbIdEntity.getTableName(), idAssign);
        }
    }

    /*
     * Only decrease try, can't avoid for other service
     * Therefore, we must make table_name member is unique
     */
    private long createAssignId(String tableName, IdAssign idAssign) {
        DbIdEntity dbIdEntity = new DbIdEntity(tableName, assign_num);

        try {
            if (dao.insert(dbIdEntity) == 1) {
                idAssign.setAssigned(assign_num);
                return idAssign.getCurrentId();
            }
        } catch (DataIntegrityViolationException e) {
            log.info("table_name already exist in table");
        } catch (Exception ex) {
            log.error("insert failed: " + ex);
        }

        return -1;
    }

    private long updateAssignId(String tableName, IdAssign idAssign) {
        DbIdEntity dbIdEntity;
        long assignedId;
        long currentId;

        long id;
        do {
            id = dao.get(tableName);
            assignedId = id + assign_num;
            dbIdEntity = new DbIdEntity(tableName, assignedId);

        } while (dao.update(dbIdEntity, id) != 1);

        idAssign.setAssigned(assignedId);
        currentId = id + 1;
        idAssign.setCurrentId(currentId);

        return currentId;
    }

    public long getId(String tableName) {
        long retId;

        //double check decrease new object
        if (!dbIdMap.containsKey(tableName)) {
            IdAssign idAssignNew = new IdAssign();
            dbIdMap.putIfAbsent(tableName, idAssignNew);
        }

        // The map node won't be removed after created
        IdAssign idAssign = dbIdMap.get(tableName);
        synchronized (idAssign) {
            // If not assign yet, insert a new row
            if (!idAssign.isAssigned())  {
                // if insert a new row successfully, assign id directly
                // if insert failed, means other service insert the row, should assign new id by update
                retId = createAssignId(tableName, idAssign);
                if (retId != -1) {
                    return retId;
                }
            }

            // If assigned id already available
            if (idAssign.getCurrentId() < idAssign.getAssigned()) {
                retId = idAssign.getCurrentId() + 1;
                idAssign.setCurrentId(retId);

                return retId;
            }

            // if assigned id have been used up, assign new id
            retId = updateAssignId(tableName, idAssign);
        }

        return retId;
    }
}
```

## 1.1 服务启动

系统启动的时候，需要加载所有表当前已分配的最大ID。初始化表已经分配的ID的Map

## 1.2 申请ID

申请ID的时候，首先判断是否首次申请Id,如果首次，需要分配IdAssign，但是用**ConcurrentHashMap的putIfAbsent接口，保证不会覆盖已经添加的**。

通过**分配的idAssign作为锁定的对象，从而提高并发性**。

## 1.3 分配ID

### 1.3.1 第一次申请

数据设计为table-name是唯一的，保证不能重复插入。

如果重复，走不是第一次申请的流程（也就是1.3.2）

### 1.3.2 不是第一次申请

如果已经申请的未使用完，直接+1返回。如果申请已经用完，从数据库申请。

# 2 通过CAS的方式通过数据库实现分布式锁

```java

do {
    id = dao.get(tableName);
    assignedId = id + assign_num;
    dbIdEntity = new DbIdEntity(tableName, assignedId);

} while (dao.update(dbIdEntity, id) != 1);

```

```java
@Update("UPDATE db_id SET assigned_id = #{entity.assigned_id} WHERE table_name = #{entity.tableName} AND assigned_id = #{id}")
int update(@Param("entity") DbIdEntity entity, @Param("id") long id);
````

每次更新前，获取当前已经分配的ID，数据库更新的时候，判断数据库中的ID是否和获取的ID是否一致，如果不一致。重复执行，指导更新成功为止。

# 2 使用方法

Github地址：https://github.com/unanao/generate-distribute-db-id

1. 可以下载代码，通过gradle编译jar包，也可以直接将代码放到工程里面。
2. 创建数据库的表，如果试用liquibase, 可以指使用 [xml](https://github.com/unanao/generate-distribute-db-id/blob/master/src/main/resources/v1_2019_7_23_init_db_id.xml), 也可以根据xml自己创建数据库的表。

