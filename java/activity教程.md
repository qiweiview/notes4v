# activity教程


## 相关表结构划分
```
#通用数据(act_ge_)
act_ge_bytearray	二进制数据表，存储通用的流程定义和流程资源。
act_ge_property	系统相关属性，属性数据表存储整个流程引擎级别的数据，初始化表结构时，会默认插入三条记录。

# 历史流程表(act_hi_)
act_hi_actinst	历史节点表
act_hi_attachment	历史附件表
act_hi_comment	历史意见表
act_hi_detail	历史详情表，提供历史变量的查询
act_hi_identitylink	历史流程用户信息表
act_hi_procinst	历史流程实例表
act_hi_taskinst	历史任务实例表
act_hi_varinst	历史变量表


#流程定义表(act_re_)
act_re_deployment	部署信息表
act_re_model	流程设计模型部署表
act_re_procdef	流程定义数据表

#运行实例表(act_ru_)
act_ru_deadletter_job	作业死亡信息表，作业失败超过重试次数
act_ru_event_subscr	运行时事件表
act_ru_execution	运行时流程执行实例表
act_ru_identitylink	运行时用户信息表
act_ru_integration	运行时积分表
act_ru_job	运行时作业信息表
act_ru_suspended_job	运行时作业暂停表
act_ru_task	运行时任务信息表
act_ru_timer_job	运行时定时器作业表
act_ru_variable	运行时变量信息表

#其他
act_evt_log	流程引擎的通用事件日志记录表
act_procdef_info	流程定义的动态变更信息
```


