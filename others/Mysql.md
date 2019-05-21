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
