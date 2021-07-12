# oracle 常用

## 删表并释放空间
```
truncate table  test1 DROP STORAGE;
```

## where 最近一周
```
to_date(t.yysj,'yyyy-mm-dd')-trunc(sysdate) between -7 and 7
```

## 数据库备份
```
exp xx/xxfull=y file=/home/data/database.dmp log=/home/data/database.log
```

## 表空间使用查看与设置
```
SELECT
	a.tablespace_name "表空间名",
	a.bytes / 1024 / 1024 "表空间大小(M)",
	( a.bytes - b.bytes ) / 1024 / 1024 "已使用空间(M)",
	b.bytes / 1024 / 1024 "空闲空间(M)",
	round((( a.bytes - b.bytes ) / a.bytes ) * 100, 2 ) "使用比" 
FROM
	( SELECT tablespace_name, sum( bytes ) bytes FROM dba_data_files GROUP BY tablespace_name ) a,
	( SELECT tablespace_name, sum( bytes ) bytes, max( bytes ) largest FROM dba_free_space GROUP BY tablespace_name ) b 
WHERE
	a.tablespace_name = b.tablespace_name 
ORDER BY
	(( a.bytes - b.bytes ) / a.bytes ) DESC
```


## 扩展表空间文件
```
# 新增
create tablespace ZD_CRMF  datafile '/data/oracle_space/tbs_data_04.dbf'    size 500M autoextend on next 5M maxsize unlimited; 

alert tablespace ZD_CRMF add datafile '/data/oracle_space/tbs_data_04.dbf'  size 50M autoextend on next 5M maxsize unlimited; 
```

* 查看指定的表空间是否为自动扩展

```
select file_name,autoextensible,increment_by from dba_data_files where tablespace_name = '表空间名'; 
```

* 改为自动扩展的话需要操作

```
alter database datafile '/u01/app/oracle/oradata/XXX/XXXX01.dbf' autoextend on;
```


* 关闭自动扩展
```
alter database datafile '/u01/app/oracle/oradata/XXX/XXXX01.dbf' autoextend off;
```

## 修改字段类型
```
alter table SYNC_DATA modify(BATCH_NO VARCHAR2(32));
```

## 增加列
```
ALTER TABLE APP_WIDGET_PACKAGE ADD (
	EFFECTIVE_DATE_FORMAL DATE,
	EXPIRATION_DATE_FORMAL DATE,
VALIDITY_PERIOD_FORMAL NUMBER 
)
```

## 修改字段名
```
alter table AUTH_INFO_SERV_TOP5 rename column SUCC_RATE_0X12 to SUCC_RATE_0X06;
```


## 工具登录
```
sqlplus system/oracle
```

## ORA-12514异常
* 服务未被监听
```
# 检索当前监听的服务
select value from v$parameter where name='service_names'
```
* 修改连接的服务名


## ORA-00972异常
```
列字段超过oracle默认的长度30
```

## 表死锁

* 查询哪些对象被锁：
```
SELECT
	object_name,
	machine,
	s.sid,
	s.serial # 
FROM
	v$locked_object l,
	dba_objects o,
	v$session s 
WHERE
	l.object_id　 =　 o.object_id 
	AND l.session_id = s.sid;
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
