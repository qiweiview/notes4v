# quartz教程

## 依赖
```
   <dependency>
            <groupId>org.quartz-scheduler</groupId>
            <artifactId>quartz</artifactId>
            <version>2.3.2</version>
        </dependency>

```

## 需要明白 Quartz 的几个核心概念，这样理解起 Quartz 的原理就会变得简单了。

* Job 表示一个工作，要执行的具体内容。此接口中只有一个方法，如下：
```
void execute(JobExecutionContext context) 
```
* JobDetail 表示一个具体的可执行的调度程序，Job 是这个可执行程调度程序所要执行的内容，另外 JobDetail 还包含了这个任务调度的方案和策略。
* Trigger 代表一个调度参数的配置，什么时候去调。（一个JobDetail可以有多个Trigger，但是一个Trigger只能对应一个JobDetail）
* Scheduler 代表一个调度容器，一个调度容器中可以注册多个 JobDetail 和 Trigger。当 Trigger 与 JobDetail 组合，就可以被 Scheduler 容器调度了。

## 范例：运行一个job对应一个trigger
```
// 1. 创建 SchedulerFactory
        SchedulerFactory factory = new StdSchedulerFactory();
        // 2. 从工厂中获取调度器实例
        Scheduler scheduler = factory.getScheduler();
        scheduler.start();

        // 3. 引进作业程序
        JobDetail jobDetail = JobBuilder.newJob()
                .ofType(JobTest.class)
                //.storeDurably(true) 如果要使用addJob就必须设置这个为true
                .withDescription("this is a ram job1") //job的描述
                .withIdentity(JobKey.jobKey("jb1"))
                .build();

        Trigger trigger = TriggerBuilder.newTrigger()
                .withDescription("this is a cronTrigger1")
                .withIdentity(TriggerKey.triggerKey("tk"))
                //.withSchedule(SimpleScheduleBuilder.simpleSchedule())
                .withSchedule(CronScheduleBuilder.cronSchedule("0/1 * * * * ?")) //两秒执行一次
                .build();
        scheduler.scheduleJob(jobDetail,trigger);
```
* 也可以手动触发
```
# 要设置.storeDurably(true) 
scheduler.addJob(jobDetail,true);
scheduler.triggerJob(jobDetail.getKey());
```
* 一个job可以绑定多个trigger
```
#
HashSet<Trigger> triggers=new HashSet<>();
triggers.add(trigger);
triggers.add(trigger2);
scheduler.scheduleJob(jobDetail,triggers,true);
```
* 可以暂停/恢复其中一个trigger
```
scheduler.pauseTrigger(trigger.getKey());
scheduler.resumeTrigger(trigger.getKey());
```

* 解除trigger的绑定
```
scheduler.unscheduleJob(trigger.getKey());
```
* 重新绑定trIgger
```
 scheduler.rescheduleJob(triggerKey, trigger);
```
## JDBC存储作业

表名称 | 说明
---- | ---
qrtz_blob_triggers | Trigger作为Blob类型存储(用于Quartz用户用JDBC创建他们自己定制的Trigger类型，JobStore 并不知道如何存储实例的时候)
qrtz_calendars | 以Blob类型存储Quartz的Calendar日历信息， quartz可配置一个日历来指定一个时间范围
qrtz_cron_triggers | 存储Cron Trigger，包括Cron表达式和时区信息。
qrtz_fired_triggers |   存储与已触发的Trigger相关的状态信息，以及相联Job的执行信息
qrtz_job_details | 存储每一个已配置的Job的详细信息
qrtz_locks |    存储程序的非观锁的信息(假如使用了悲观锁)
qrtz_paused_trigger_graps |     存储已暂停的Trigger组的信息
qrtz_scheduler_state |  存储少量的有关 Scheduler的状态信息，和别的 Scheduler 实例(假如是用于一个集群中)
qrtz_simple_triggers     | 存储简单的 Trigger，包括重复次数，间隔，以及已触的次数
qrtz_triggers    | 存储已配置的 Trigger的信息
qrzt_simprop_triggers    | 
