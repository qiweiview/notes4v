## Mysql内容

## mysql 8 修改密码
```
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'wdwdwd';
```
* 允许远程访问
```
use mysql

update user set host='%' where user ='root';

FLUSH PRIVILEGES;

GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'WITH GRANT OPTION;
```

## 链接编码和时区
```
?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC
```

## DELETE和TRUNCATE区别
* DML(Data Manipulation Language)数据操纵语言
* DDL(Data Definition Language)数据定义语言
### DELETE

* DELETE是DML命令。
* DELETE语句是使用行锁执行的，表中的每一行都被锁定以进行删除。
* 我们可以在where子句中指定过滤器
* 如果存在条件，则删除指定的数据。
* 删除可激活触发器，因为该操作是单独记录的。
* 比TRUNCATE慢，因为它保留日志。
* 可以回滚。

### TRUNCATE

* TRUNCATE是DDL命令。
* TRUNCATE TABLE始终锁定表和页面，但不锁定每一行。
* 不能使用Where条件。
* 删除所有数据。
* TRUNCATE TABLE无法激活触发器，因为该操作不会记录单个行的删除。
* 在性能上更快，因为它不保留任何日志。
* 可以回滚。


## 死锁事务处理
```
SELECT * FROM `information_schema`.`innodb_trx` ORDER BY `trx_started`
```
* 找到死锁事务的 trx_mysql_thread_id 
```
KILL trx_mysql_thread_id;
```

* ***踏坑 limit 可能会影响索引的选择***


## sql分析
* explain
```
explain select * from xxx
```
* show profile
```
show profiles
show profile for query 102
```
* 分析结果
```
starting	0.000242
checking permissions	0.000030
Opening tables	0.000130
init	0.000043
System lock	0.000027
optimizing	0.000025
optimizing	0.000042
statistics	0.001707
preparing	0.000079
Sorting result	0.000030
statistics	0.000029
preparing	0.000029
executing	0.000050
Sending data	0.000039
executing	0.000024
Sending data	70.696065
end	0.000151
query end	0.000032
closing tables	0.000025
removing tmp table	0.000038
closing tables	0.000052
freeing items	0.000109
logging slow query	0.000160
cleaning up	0.000634
```

## 格式化日期
```
DATE_FORMAT(belongDate,'%Y-%m-%d')
```
* 字符串转日期
```
str_to_date(date,'%Y-%m-%d') 
str_to_date(date,'%Y-%m-%d %H:%i:%s')
```

## delete in select 
```
DELETE 
FROM
	app_message_record_bind 
WHERE
	id IN (
	SELECT
		* 
	FROM
	( SELECT amrb.id FROM app_message_record_bind amrb LEFT JOIN app_message am ON amrb.mId = am.id WHERE am.id IS NULL ) n 
	)
```

## 添加表字段
```
ALTER TABLE auth_company_profile ADD COLUMN codeType VARCHAR(50) DEFAULT NULL COMMENT '结算码，电子凭证' ;
ALTER TABLE auth_company_profile ADD COLUMN medicalType VARCHAR(50) DEFAULT NULL COMMENT '就医渠道(40药店，20住院，10门诊)';
```

## 表拼接
* ![图片](https://i.stack.imgur.com/VQ5XP.png)

###  mysql 没有 full join


## 生成日期参照表

* 生成参照表
```
	
-- 数字表（使用后删除）
CREATE TABLE num ( i INT );

-- 插入数字
INSERT INTO num ( i )
VALUES
	( 0 ),
	( 1 ),
	( 2 ),
	( 3 ),
	( 4 ),
	( 5 ),
	( 6 ),
	( 7 ),
	( 8 ),
	( 9 );
	

	
-- 时间模板表	
CREATE TABLE  date_model ( date datetime,time_stamp int(15),index (date),index (time_stamp));
	
-- 插入	
INSERT INTO date_model ( date,time_stamp ) 
select date.date date,ROUND(UNIX_TIMESTAMP(date.date),0) time_stamp
from (
SELECT
ADDDATE( ( DATE_FORMAT( '2017-01-01 00:00:00', '%Y-%m-%d 00:00:00' ) ), numlist.id ) AS `date` 
FROM
	(
	SELECT
		n1.i + n10.i * 10 + n100.i * 100 + n1000.i * 1000 AS id 
	FROM
		num n1
		CROSS JOIN num AS n10
		CROSS JOIN num AS n100
	CROSS JOIN num AS n1000 
	) AS numlist) as date
	where date<'2038-01-20 00:00:00'
	
	
	
```
* 使用范例
```
SELECT
	a.date,
	IFNULL( b.count, 0 ) count 
FROM
	(
	SELECT
		CAST( date AS DATE ) date 
	FROM
		date_model 
	WHERE
		date >= DATE_SUB( curdate( ), INTERVAL 7 DAY ) 
		AND date <= curdate( ) 
	) a
	LEFT JOIN (
	SELECT
		count( * ) count,
		CAST( updateDate AS DATE ) date 
	FROM
		unfinished_task 
	WHERE
		updateUser = 'view' 
	GROUP BY
		CAST( updateDate AS DATE ) 
	) b ON a.date = b.date 
ORDER BY
	a.date
```


## 字符串转日期 
```
SELECT STR_TO_DATE('2017-01-06 10:20:30','%Y-%m-%d %H:%i:%s') AS result;
```
### 创建数据库指定编码
```
CREATE DATABASE `mydb` CHARACTER SET utf8 COLLATE utf8_general_ci;
```

### 输出json对象
```
 json_object(keyName,value,...)

 select json_object(uuid(),t.json) as json2  from(select json_object('price',price,'description',description)as json  from Bill) t limit 2;
```

### 导出到磁盘
```
select * from Bill INTO OUTFILE '/var/lib/mysql-files/newJson.txt';

```

### 查询默认地址（导出有个默认允许地址，导出到其他地方需要配置文件修改）
```
show variables like '%secure%';
```



### 分组统计
```
1）按天统计：

select DATE_FORMAT(start_time,'%Y%m%d') days,count(product_no) count from test group by days; 

2）按周统计：

select DATE_FORMAT(start_time,'%Y%u') weeks,count(product_no) count from test group by weeks; 

3）按月统计:

select DATE_FORMAT(start_time,'%Y%m') months,count(product_no) count from test group bymonths; 
```

### if使用
mysql的if函数，例如：IF(expr1,expr2,expr3) 
说明：如果 expr1是TRUE，则IF()的返回值为expr2; 否则返回值则为expr3
实例场景：如果video_id为null，则直接返回空字符，避免不必要的查询影响效率：
```
SELECT

IF (
	isnull(sum(trade.cost_amount)),
	0,
	sum(trade.cost_amount)
) AS getTotalOutpatientAmount
FROM
	auth_trade trade
WHERE
	trade.cost_time > curdate()
AND trade.state = '-1'
```
