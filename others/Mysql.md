## Mysql内容
### 输出json对象

json_object(keyName,value,...)
```
 select json_object(uuid(),t.json) as json2  from(select json_object('price',price,'description',description)as json  from Bill) t limit 2;
```

### 导出到磁盘
```
select * from Bill INTO OUTFILE '/var/lib/mysql-files/newJson.txt';

```

查询默认地址（导出有个默认允许地址，导出到其他地方需要配置文件修改）
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
