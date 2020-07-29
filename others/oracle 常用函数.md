# oracle 常用函数



* 字符串变为数字（数字比对时）:
```
to_number
```
* 截取字符串：
```
substr(key,0,4)//截取字符串（截取年份）
```
* 条件判断
```
1.
select
case
when xxx then xxx
when xxx then xxx
end
as
'xxx'
from 'xxxtable'
```
*oracle是不区分大小写的所以不能用常规java格式化规则:
```
to_date('2005-01-01 13:14:20','YYYY-MM-DD HH24:MI:SS')
```
```
to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')
```
* 模糊查询
```
REGEXP_LIKE(xxx,'xxx')
```
* 更新追加内容：
```
update xxx set a=a||#{content}
```
