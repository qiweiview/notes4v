## Mysql获取今天明天昨天时间

```
1、当前日期
select DATE_SUB(curdate(),INTERVAL 0 DAY) ;


2、明天日期
select DATE_SUB(curdate(),INTERVAL -1 DAY) ;


3、昨天日期

select DATE_SUB(curdate(),INTERVAL 1 DAY) ;


4、前一个小时时间

select date_sub(now(), interval 1 hour);


5、后一个小时时间

select date_sub(now(), interval -1 hour);


6、前30分钟时间

select date_add(now(),interval -30 minute)


7、后30分钟时间

select date_add(now(),interval 30 minute)
```