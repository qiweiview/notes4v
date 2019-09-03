# Spring编程式事务

## PlatformTransactionManager事务管理器
```
KafkaTransactionManager kafkaTransactionManager = new KafkaTransactionManager(this.defaultKafkaProducerFactory);//子类
```

## TransactionTemplate事务模板
```
TransactionTemplate transactionTemplate = new TransactionTemplate(kafkaTransactionManager);
```

* 模板执行，异常setRollbackOnly()执行回滚
```
transactionTemplate.execute((transactionStatus) -> {

            try {
                checkBlank(collection, onSuccess);
                Iterator<? extends MqMesssage> iterator = collection.iterator();
                while (iterator.hasNext()) {
                    MqMesssage next = iterator.next();
                    ProducerRecord<Integer, String> producerRecord = new ProducerRecord(next.getRouteTopic(), next.getTopicParameter().get(KafkaMessage.MESSAGE_KEY), next.getTopicParameter().get(KafkaMessage.MESSAGE_VALUE));
                    kafkaTemplate.send(producerRecord);
                }
                onSuccess.apply(collection);
            } catch (Exception e) {
                transactionStatus.setRollbackOnly();
                onError.apply(collection,e);
            }
            return "suc";
        });
```
