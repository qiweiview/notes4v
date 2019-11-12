## Mysql内容

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
