## Mysql内容

## 表拼接


* ![](https://i.stack.imgur.com/VQ5XP.png)

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
