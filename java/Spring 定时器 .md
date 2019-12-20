# Spring 定时器 
1. 设置xml：
```
 xmlns:task="http://www.springframework.org/schema/task"
 xsi:schemaLocation="http://www.springframework.org/schema/task http://www.springframework.org/schema/task/spring-task-4.0.xsd"
 
 
 
 <task:annotation-driven scheduler="myScheduler" />
 <task:scheduler id="myScheduler" pool-size="5"/>  
```

2. 编写Class:
```
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
@Component
public class DoSomethingTask {
    @Scheduled(cron="0 * * * * *")
    public void doSomething() {
        System.out.println("do something");
    }
}
```

3. 表达式：
```
Cron表达式由6~7项组成，中间用空格分开。从左到右依次是：秒、分、时、日、月、周几、年（可省略）。值可以是数字，也可以是以下符号：
*：所有值都匹配
?：无所谓，不关心，通常放在“周几”里
,：或者
/：增量值
-：区间

下面举几个例子，看了就知道了：
0 5 * * * ?： 每个小时的第五分钟
0 * * * * *：每分钟（当秒为0的时候）
0 0 * * * *：每小时（当秒和分都为0的时候）
*/10 * * * * *：每10秒
0 5/15 * * * *：每小时的5分、20分、35分、50分
0 0 9,13 * * *：每天的9点和13点
0 0 8-10 * * *：每天的8点、9点、10点
0 0/30 8-10 * * *：每天的8点、8点半、9点、9点半、10点
0 0 9-17 * * MON-FRI：每周一到周五的9点、10点…直到17点（含）
0 0 0 25 12 ?：每年12约25日圣诞节的0点0分0秒（午夜）
0 30 10 * * ? 2016：2016年每天的10点半
```
