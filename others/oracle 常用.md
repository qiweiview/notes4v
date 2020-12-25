# oracle 常用

## 表死锁

* 查询哪些对象被锁：
```
select object_name,machine,s.sid,s.serial#
 from v$locked_object l,dba_objects o ,v$session s
 where l.object_id　=　o.object_id and l.session_id=s.sid;
```

* 杀死一个进程：
```
alter system kill session '24,111'; //(其中24,111分别是上面查询出的sid,serial#)
```

## char 类型定长
```
RPAD(idCard,19) -- 右边补齐
LPAD(idCard,19) -- 左边补齐
```

* 数据恢复
```
insert into AG_WORKER_RANDOM_RULE

select * from AG_WORKER_RANDOM_RULE as of timestamp  TO_TIMESTAMP('2020-10-22 15:40:00', 'yyyy-mm-dd hh24:mi:ss') where main_rule_id='0d7911d119134d5c8aa47dcb1167a058'
```

* 修改密码
```
alter user xxa identified  by  123456 account unlock; ----不用换新密码
```

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
