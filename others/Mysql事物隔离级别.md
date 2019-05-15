


![image.png](https://i.loli.net/2019/02/12/5c622967364a5.png)




查看当前 ***会话*** 事物隔离级别
```
select @@tx_isolation;
```

查看当前 ***系统*** 事物隔离级别
```
select @@global.tx_isolation;
```


## 创建测试表
![image.png](https://i.loli.net/2019/02/12/5c621968c7665.png)


##  1. read uncommitted（读取未提交数据）

#### 用户A
```
set session transaction isolation level read uncommitted；
start transaction;
select * from act;
```

#### 用户B
```
set session transaction isolation level read uncommitted；
start transaction;
update actset set act=act+200 where id = 1;
```

### 结论

***我们将事务隔离级别设置为read uncommitted，即便是事务没有commit，但是我们仍然能读到未提交的数据，这是所有隔离级别中最低的一种。***


## 2. read committed（可以读取其他事务提交的数据）---大多数数据库默认的隔离级别
#### 将用户B所在的会话当前事务隔离级别设置为read committed
```
set session transaction isolation level read committed;
start transaction;
select * from act;
```

#### 将用户A所在的会话当前事务隔离级别设置为read committed
```
set session transaction isolation level read committed;
start transaction;
update act set act=888 where id =1
```

#### 在B中执行查询，发现数据未变化
```
select * from act;
```

#### 在A中执行查询，发现数据已变化
```
select * from act;
```

#### A中进行事物提交，B中数据变化
```
commit;
```

### 结论

***当我们将当前会话的隔离级别设置为read committed的时候，当前会话只能读取到其他事务提交的数据，未提交的数据读不到。***

### 3. repeatable read（可重读）---MySQL默认的隔离级别

#### 将用户B所在的会话当前事务隔离级别设置为repeatable read
```
set session transaction isolation level repeatable read;
start transaction;
select * from act;
```

#### 将用户A所在的会话当前事务隔离级别设置为repeatable read,并开启一个事物插入一条数据并提交事物；
```
set session transaction isolation level repeatable read;
start transaction;
insert into act values(2,666)
commit;
```
![image.png](https://i.loli.net/2019/02/12/5c622470cd99e.png)


### B中查询表
```
select * from act;
```
![image.png](https://i.loli.net/2019/02/12/5c622492a682b.png)

### B中插入id为2的数据,显示已存在
```
insert into act values(2,888)
```
![image.png](https://i.loli.net/2019/02/12/5c6224becd58f.png)

### 结论
***当我们将当前会话的隔离级别设置为repeatable read的时候，当前会话可以重复读，就是每次读取的结果集都相同，而不管其他事务有没有提交。***

### 4. serializable（串行化）

#### 将用户B所在的会话当前事务隔离级别设置为serializable并执行查询
```
set session transaction isolation level serializable;
start transaction;
select * from act;
```

#### 在A会话中进行插入操作
```
insert into atc values(3,555)
```
操作会进入等待（直到表和其他用户的事物被commit）
![image.png](https://i.loli.net/2019/02/12/5c62274d46e00.png)
![image.png](https://i.loli.net/2019/02/12/5c62274470eb7.png)

超时会报错（超时时间可以配置）
![image.png](https://i.loli.net/2019/02/12/5c6226e1bcac3.png)

### 结论
***当我们将当前会话的隔离级别设置为serializable的时候，其他会话对该表的写操作将被挂起。可以看到，这是隔离级别中最严格的，但是这样做势必对性能造成影响。所以在实际的选用上，我们要根据当前具体的情况选用合适的***


