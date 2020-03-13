# kafka教程


* Apache Kafka是一个分布式发布 - 订阅消息系统和一个强大的队列
* Kafka消息保留在磁盘上，并在群集内复制以防止数据丢失
* Kafka 设计中将每一个主题分区当作一个具有顺序排列的日志。同处于一个分区中的消息都被设置了一个唯一的偏移量。Kafka 只会保持跟踪未读消息，一旦消息被置为已读状态，Kafka 就不会再去管理它了
* Kafka 的生产者负责在消息队列中对生产出来的消息保证一定时间的占有
* 消费者负责追踪每一个主题 (可以理解为一个日志通道) 的消息并及时获取它们。基于这样的设计，Kafka 可以在消息队列中保存大量的开销很小的数据，并且支持大量的消费者订阅


## 下载
[下载](https://mirror-hk.koddos.net/apache/kafka/2.4.1/kafka_2.11-2.4.1.tgz)

# 词汇概念

## Topics（主题）

* 每条发布到 Kafka 集群的消息都有一个类别，这个类别被称为 Topic。（物理上不同 Topic 的消息分开存储，逻辑上一个 Topic 的消息虽然保存于一个或多个 broker 上，但用户只需指定消息的 Topic 即可生产或消费数据而不必关心数据存于何处）。
* 属于特定类别的消息流称为主题。 数据存储在主题中。
* 主题被拆分成分区。 对于每个主题，Kafka保存一个分区的数据。 每个这样的分区包含不可变有序序列的消息。 
* 分区被实现为具有相等大小的一组分段文件。

	
## Partition（分区）

* Partition 是物理上的概念，每个 Topic 包含一个或多个 Partition。
* 主题可能有许多分区，因此它可以处理任意数量的数据

## Partition offset（分区偏移）

* 每个分区消息具有称为 offset 的唯一序列标识。

## Replicas of partition（分区备份）

* 副本只是一个分区的备份。 副本从不读取或写入数据。 它们用于防止数据丢失。


## Brokers（经纪人）

* Kafka 集群包含一个或多个服务器，这种服务器被称为 broker。
* 代理是负责维护发布数据的简单系统。 每个代理中的每个主题可以具有零个或多个分区。 
* 假设，如果在一个主题和N个代理中有N个分区，每个代理将有一个分区。
* 假设在一个主题中有N个分区并且多于N个代理(n + m)，则第一个N代理将具有一个分区，并且下一个M代理将不具有用于该特定主题的任何分区。
* 假设在一个主题中有N个分区并且小于N个代理(n-m)，每个代理将在它们之间具有一个或多个分区共享。 由于代理之间的负载分布不相等，不推荐使用此方案。

	
## Kafka Cluster（Kafka集群）

* Kafka有多个代理被称为Kafka集群。 可以扩展Kafka集群，无需停机。 这些集群用于管理消息数据的持久性和复制。

## Producers（生产者）

* 负责发布消息到 Kafka broker。
* 生产者是发送给一个或多个Kafka主题的消息的发布者。 
* 生产者向Kafka经纪人(Brokers)发送数据。 每当生产者将消息发布给代理(Brokers)时，代理只需将消息附加到最后一个段文件。 实际上，该消息将被附加到分区。 生产者还可以向他们选择的分区发送消息。

## Consumers（消费者）

* Consumers从经纪人(Brokers)处读取数据。 消费者订阅一个或多个主题，并通过从代理中提取数据来使用已发布的消息。

## 消费者组 (Consumer Group)

* consumer group下可以有一个或多个consumerinstance，consumerinstance可以是一个进程，也可以是一个线程
* group.id是一个字符串，唯一标识一个consumer group
* consumer group下订阅的topic下的每个分区只能分配给某个group下的一个consumer(当然该分区还可以被分配给其他group)

* consumer group是kafka提供的可扩展且具有容错性的消费者机制
* 组内必然可以有多个消费者或消费者实例(consumer instance)，它们共享一个公共的ID，即group ID
* 组内的所有消费者协调在一起来消费订阅主题(subscribed topics)的所有分区(partition)
* 当然，每个分区只能由同一个消费组内的一个consumer来消费

## 消费者位置(consumer position) 
* 消费者在消费的过程中需要记录自己消费了多少数据，即消费位置信息
* 在Kafka中这个位置信息有个专门的术语：位移(offset)。很多消息引擎都把这部分信息保存在服务器端(broker端)。这样做的好处当然是实现简单
* 但会有三个主要的问题：
1. broker从此变成有状态的，会影响伸缩性；
2. 2. 需要引入应答机制(acknowledgement)来确认消费成功。
3. 3. 由于要保存很多consumer的offset信息，必然引入复杂的数据结构，造成资源浪费。
* Kafka选择了不同的方式：每个consumer
* group保存自己的位移信息，那么只需要简单的一个整数表示位置就够了；同时可以引入checkpoint机制定期持久化，简化了应答机制的实现

## Rebalance
* rebalance本质上是一种协议，规定了一个consumer group下的所有consumer如何达成一致来分配订阅topic的每个分区。
* 比如某个group下有20个consumer，它订阅了一个具有100个分区的topic。正常情况下，Kafka平均会为每个consumer分配5个分区。这个分配的过程就叫rebalance。

## Leader（领导者）

 * Leader 是负责给定分区的所有读取和写入的节点。 每个分区都有一个服务器充当Leader。
 
## Follower（追随者）

* 跟随领导者指令的节点被称为Follower。 如果领导失败，一个追随者将自动成为新的领导者
* 跟随者作为正常消费者，拉取消息并更新其自己的数据存储。


## 偏移量提交
* 如果有消费者发生崩溃，或者有新的消费者加入消费者群组的时候，会触发 Kafka 的再均衡。
* 这使得 Kafka 完成再均衡之后，每个消费者可能被会分到新分区中。
* 为了能够继续之前的工作，消费者就需要读取每一个分区的最后一次提交的偏移量，然后从偏移量指定的地方继续处理
* 如果提交的偏移量小于客户端处理的最后一个消息的偏移量，那么处于两个偏移量之间的消息就会被重复处理。
* 如果提交的偏移量大于客户端处理的最后一个消息的偏移量，那么处于两个偏移量之间的消息将会丢失
* KafkaConsumer API 提供了很多种方式来提交偏移量


#工作流程

## 发布 - 订阅消息的工作流程


* 生产者定期向主题（Topics）发送消息。

* Kafka代理存储为该特定主题配置的分区中的所有消息。 它确保消息在分区之间平等共享。 如果生产者发送两个消息并且有两个分区，Kafka将在第一分区中存储一个消息，在第二分区中存储第二消息。

* 消费者订阅特定主题。

* 一旦消费者订阅主题，Kafka将向消费者提供主题的当前偏移，并且还将偏移保存在Zookeeper系综中。

* 消费者将定期请求Kafka(如100 Ms)新消息。

* 一旦Kafka收到来自生产者的消息，它将这些消息转发给消费者。

* 消费者将收到消息并进行处理。

* 一旦消息被处理，消费者将向Kafka代理发送确认。

* 一旦Kafka收到确认，它将偏移更改为新值，并在Zookeeper中更新它。 由于偏移在Zookeeper中维护，消费者可以正确地读取下一封邮件，即使在服务器暴力期间。

* 以上流程将重复，直到消费者停止请求。

* 消费者可以随时回退/跳到所需的主题偏移量，并阅读所有后续消息。



## 队列消息/用户组的工作流（在队列消息传递系统而不是单个消费者中，具有相同组ID 的一组消费者将订阅主题。 简单来说，订阅具有相同 Group ID 的主题的消费者被认为是单个组，并且消息在它们之间共享。 让我们检查这个系统的实际工作流程。）

* 生产者以固定间隔向某个主题发送消息。

* Kafka存储在为该特定主题配置的分区中的所有消息，类似于前面的方案。

* 单个消费者订阅特定主题，假设 Topic-01 为 Group ID 为 Group-1 。

* Kafka以与发布 - 订阅消息相同的方式与消费者交互，直到新消费者以相同的组ID 订阅相同主题 Topic-01  1 。

* 一旦新消费者到达，Kafka将其操作切换到共享模式，并在两个消费者之间共享数据。 此共享将继续，直到用户数达到为该特定主题配置的分区数。

* 一旦消费者的数量超过分区的数量，新消费者将不会接收任何进一步的消息，直到现有消费者取消订阅任何一个消费者。 出现这种情况是因为Kafka中的每个消费者将被分配至少一个分区，并且一旦所有分区被分配给现有消费者，新消费者将必须等待。

* 此功能也称为使用者组。 同样，Kafka将以非常简单和高效的方式提供两个系统中最好的。


# ZooKeeper的作用
* Apache Kafka的一个关键依赖是Apache Zookeeper，它是一个分布式配置和同步服务。
* Zookeeper是Kafka代理和消费者之间的协调接口。 Kafka服务器通过Zookeeper集群共享信息。 
* Kafka在Zookeeper中存储基本元数据，例如关于主题，代理，消费者偏移(队列读取器)等的信息。

* 由于所有关键信息存储在Zookeeper中，并且它通常在其整体上复制此数据，因此Kafka代理/ Zookeeper的故障不会影响Kafka集群的状态。 Kafka将恢复状态，一旦Zookeeper重新启动。 这为Kafka带来了零停机时间。 
* Kafka代理之间的领导者选举也通过使用Zookeeper在领导者失败的情况下完成


# KafkaProducer生产者文档

## 异常说明
```
IllegalStateException  - 如果尚未配置transactional.id

UnsupportedVersionException  - 表示代理不支持事务的致命错误（即，如果其版本低于0.11.0.0）

AuthorizationException  - 致命错误，指示已配置的transactional.id未获得授权。 有关详细信息，请参阅异常

KafkaException  - 如果生产者遇到了先前的致命错误或任何其他意外错误

TimeoutException  - 如果初始化事务所花费的时间超过了max.block.ms。

InterruptException  - 如果线程在被阻塞时被中断
```

## 构造函数
* 支持Map和Properties
* Properties最终也是转化为Map，提供了一个propsToMap方法
```
public KafkaProducer(Map<String,Object> configs,
                     Serializer<K> keySerializer,
                     Serializer<V> valueSerializer)
                     
                     
public KafkaProducer(Properties properties,
                     Serializer<K> keySerializer,
                     Serializer<V> valueSerializer) 
                     
                     
```
### 转化方法
```
private static Map<String, Object> propsToMap(Properties properties) {
        Map<String, Object> map = new HashMap(properties.size());
        Iterator var2 = properties.entrySet().iterator();

        while(var2.hasNext()) {
            Entry<Object, Object> entry = (Entry)var2.next();
            if (!(entry.getKey() instanceof String)) {
                throw new ConfigException(entry.getKey().toString(), entry.getValue(), "Key must be a string.");
            }

            String k = (String)entry.getKey();
            map.put(k, properties.get(k));
        }

        return map;
    }
```


### 插入数据

```
 Properties props = new Properties();
 props.put("bootstrap.servers", "localhost:9092");
 props.put("acks", "all");
 props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
 props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");

 Producer<String, String> producer = new KafkaProducer<>(props);
 for (int i = 0; i < 100; i++)
     producer.send(new ProducerRecord<String, String>("my-topic", Integer.toString(i), Integer.toString(i)));

 producer.close();
```

* 生产者是线程安全的，跨线程共享单个生成器实例通常比拥有多个实例更快。(多个线程环境flush()会立即发送当前缓冲区，后面事物提交时只提交没有flush()过的缓冲区数据，不会完整提交)
```
public static void main(String[] args) {
        ExecutorService executorService = Executors.newFixedThreadPool(5);
        Producer producer = getProducer();
        
        CompletableFuture.runAsync(() -> {
            try {

                producer.initTransactions();
                producer.beginTransaction();
                String value = "你好啊" + LocalTime.now().format(DateTimeFormatter.ofPattern("HH:mm:ss"));
                Future send = producer.send(new ProducerRecord<>("HELLO_KAFKA", value, "一条"), (RecordMetadata recordMetadata, Exception e) -> {
                    //TODO:消息提交回调
                    System.out.println("111message send:" + recordMetadata.hasOffset());

                });
                producer.send(new ProducerRecord<>("HELLO_KAFKA", "你好啊" + LocalTime.now().format(DateTimeFormatter.ofPattern("HH:mm:ss")), "二条"), (RecordMetadata recordMetadata, Exception e) -> {
                    //TODO:消息提交回调
                    System.out.println("111message send:" + recordMetadata.hasOffset());

                });

                CompletableFuture.runAsync(() -> {
                    producer.flush();
                }, executorService);

                try {
                    TimeUnit.SECONDS.sleep(8);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }

                String value2 = "你好啊" + LocalTime.now().format(DateTimeFormatter.ofPattern("HH:mm:ss"));
                Future send2 = producer.send(new ProducerRecord<>("HELLO_KAFKA", value2, "三条"), (RecordMetadata recordMetadata, Exception e) -> {
                    //TODO:消息提交回调
                    System.out.println("222message send:" + recordMetadata.hasOffset());

                });
                producer.commitTransaction();

            } catch (KafkaException e) {
                //中止正在进行的交易。 进行此调用时，将中止任何未刷新的产品消息
                producer.abortTransaction();//中止交易，不会提交
            }
            producer.close();
        }, executorService);



        while (true) {

        }
    }
```


* 生成器包含一个缓冲区空间池，用于保存尚未传输到服务器的记录，以及一个后台I / O线程，负责将这些记录转换为请求并将它们传输到集群。未能在使用后关闭生产者将泄漏这些资源
* send（）方法是异步的。调用时，它会将记录添加到待处理记录发送的缓冲区中并立即返回。这允许生产者将各个记录一起批处理以提高效率
* acks配置控制认为请求完成的标准。我们指定的“all”设置将导致完全提交记录时阻塞，这是最慢但最耐用的设置
* 如果请求失败，则生产者可以自动重试，但由于我们已将重试指定为0，因此不会重试
* 生产者为每个分区维护未发送记录的缓冲区。这些缓冲区的大小由**batch.size**配置指定。使这个值更大可以导致更多的批处理，但需要更多的内存
* 默认情况下，即使缓冲区中有其他未使用的空间，也可以立即发送缓冲区。但是，如果要减少请求数量，可以将**linger.ms**设置为大于0的值。这将指示生产者在发送请求之前等待该毫秒数，希望更多记录到达以填满同一批次。这类似于TCP中的Nagle算法
* **buffer.memory**控制生产者可用于缓冲的总内存量。如果记录的发送速度快于传输到服务器的速度，则此缓冲区空间将耗尽。当缓冲区空间耗尽时，其他发送调用将被阻止。阻塞时间的阈值由**max.block.ms**确定，之后它会抛出TimeoutException
* **key.serializer**和**value.serializer**指示如何将用户提供的键和值对象及其ProducerRecord转换为字节。您可以将包含的ByteArraySerializer或StringSerializer用于简单的字符串或字节类型
* 从Kafka 0.11开始，KafkaProducer支持另外两种模式：幂等(多次操作结果一致)生成器和事务生成器。幂等生产者将卡夫卡的交付语义从至少一次加强到一次交付。特别是生产者重试将不再引入重复。事务生成器允许应用程序以原子方式将消息发送到多个分区（和主题！）
* 要利用幂等生成器，必须避免应用程序级别重新发送，因为这些不能重复数据删除。 因此，**如果应用程序启用幂等性，建议保留重试配置未设置，因为它将默认为Integer.MAX_VALUE**。 此外，如果send（ProducerRecord）即使无限次重试也会返回错误（例如，如果消息在发送之前在缓冲区中到期），则建议关闭生产者并检查上一次生成的消息的内容以确保 它没有重复。 最后，生产者只能保证在单个会话中发送的消息的幂等性。
* 要使用事务生成器和助理API，必须设置**transactional.id**配置属性。如果设置了**transactional.id**，则会自动启用幂等性以及幂等性所依赖的生产者配置。此外，交易中包含的主题应配置为持久性。特别是，replication.factor应该至少为3，并且这些主题的min.insync.replicas应该设置为2.最后，为了从端到端实现事务保证，消费者必须是配置为只读取已提交的消息。
* **transactional.id**的目的是在单个生产者实例的多个会话中启用事务恢复。它通常从分区的有状态应用程序中的分片标识符派生。因此，对于在分区应用程序中运行的每个生产者实例，它应该是唯一的。
* 所有新的事务API都是阻塞的，并且会在失败时抛出异常。下面的示例说明了如何使用新API。它类似于上面的示

### 带事物插入数据（所有100条消息都是单个事务的一部分）
```
 Properties props = new Properties();
 props.put("bootstrap.servers", "localhost:9092");
 props.put("transactional.id", "my-transactional-id");
 Producer<String, String> producer = new KafkaProducer<>(props, new StringSerializer(), new StringSerializer());

 producer.initTransactions();

 try {
     //应该在每个新事务开始之前调用。
     //请注意，在第一次调用此方法之前，必须只调用一次initTransactions（）
     producer.beginTransaction();
     for (int i = 0; i < 100; i++){
         String key = "key" + i;
                String value = "你好啊" + LocalTime.now().format(DateTimeFormatter.ofPattern("HH:mm:ss"));
                //异步的请求所以有返回，可以调用get()阻塞
                //发送到同一分区的记录的回调保证按顺序执行,两个send,第一个回调一定会在第二个前
                //回调通常会在生产者的I / O线程中执行，因此应该相当快
                Future send =producer.send(new ProducerRecord<>(TOPIC_NAME,key,value ),(RecordMetadata recordMetadata, Exception e)->{
                    //TODO:消息提交回调（提交后才会执行，事物成不成功都会执行）
                    //当用作事务的一部分时，没有必要定义回调或检查未来的结果以便检测发送中的错误。如果任何发送调用失败且出现不可恢复的错误，则最终的commitTransaction（）调用将失败并从上次失败的发送中抛出异常。发生这种情况时，您的应用程序应调用abortTransaction（）来重置状态并继续发送数据
                    //recordMetadata.hasOffset()是否分配的偏移量，成功返回true,失败返回false
                });
                if (i==1){
                    throw new ProducerFencedException("kafka");
                }
     }
     //提交正在进行的交易。 在实际提交事务之前，此方法将刷新任何未发送的记录。 
     //此外，如果作为事务一部分的任何send（ProducerRecord）调用遇到不可恢复的错误，则此方法将立即抛出最后收到的异常，并且不会提交事务。
     //因此，事务中的所有send（ProducerRecord）调用必须成功才能使此方法成功。
     //请注意，如果在max.block.ms到期之前无法提交事务，则此方法将引发TimeoutException
     producer.commitTransaction();
 } catch (ProducerFencedException | OutOfOrderSequenceException | AuthorizationException e) {
     //通过调用abortTransaction（）无法解决某些事务性发送错误。特别是，如果事务发送以ProducerFencedException，OutOfOrderSequenceException，UnsupportedVersionException或AuthorizationException结束，那么剩下的唯一选择是调用close（）
     producer.close();//关闭生产者，直接把缓冲区内数据发送到服务器，因此还是会提交
 } catch (KafkaException e) {
     //中止正在进行的交易。 进行此调用时，将中止任何未刷新的产品消息
     producer.abortTransaction();//中止交易，不会提交
 }
 producer.close();
```
* 正如在示例中暗示的那样，每个生产者只能有一个开放交易。在beginTransaction（）和commitTransaction（）调用之间发送的所有消息都将是单个事务的一部分。指定transactional.id时，生产者发送的所有消息都必须是事务的一部分
* 事务生成器使用异常来传递错误状态。特别是，不需要为返回的Future指定producer.send（）或调用.get（）的回调：如果任何producer.send（）或事务调用在期间遇到不可恢复的错误，将抛出KafkaException
* 通过在收到KafkaException时调用producer.abortTransaction（），我们可以确保将任何成功的写入标记为已中止，从而保留事务保证。
此客户端可以与版本0.10.0或更高版本的代理进行通信。较旧或较新的经纪人可能不支持某些客户端功能。例如，事务API需要代理版本0.11.0或更高版本。调用正在运行的代理版本中不可用的API时，您将收到UnsupportedVersionException

### public List<PartitionInfo> partitionsFor(String topic) 
* 获取给定主题的分区元数据
```
public void getDataByTopic(){
        Producer producer = getProducer();
        List<PartitionInfo> list = producer.partitionsFor(TOPIC_NAME);

        list.forEach(x->{
            PartitionInfo partitionInfo = x;
            System.out.println(partitionInfo);
        });
    }
```

### public Map<MetricName,? extends Metric> metrics()
* 获取生产者维护的全套内部指标
```
 Map<MetricName,? extends Metric> metrics = producer.metrics();
```

### public void close()
* 关闭生产者。 此方法将阻塞，直到所有先前发送的请求完成 此方法等效于close（Long.MAX_VALUE，TimeUnit.MILLISECONDS）（这个方法废弃了）
* 如果从Callback调用close（），将记录一条警告消息并将调用close（0，TimeUnit.MILLISECONDS）

### public void close(Duration timeout)
* 此方法等待生产者完成发送所有未完成请求的超时。
* 如果生产者在超时到期之前无法完成所有请求，则此方法将立即使任何未发送和未确认的记录失败。
* 如果尚未完成，它还将中止正在进行的传输
* 如果从Callback中调用，则此方法不会阻塞，并且将等效于close（Duration.ofMillis（0））。 这样做是因为在阻塞生产者的I / O线程时不会发生进一步的发送



# KafkaConsumer消费者文档

* 消费者维护与必要代理的TCP连接以获取数据。 
* 使用后未能关闭消费者将泄漏这些连接。
* 消费者不是线程安全的。 
* Kafka为分区中的每条记录维护一个数字偏移量。此偏移量充当该分区内记录的唯一标识符，并且还表示消费者在分区中的位置。**例如，位于第5位的消费者已经消耗了偏移0到4的记录，并且接下来将接收具有偏移5的记录。**
* 实际上有两个与消费者的用户相关的位置概念：
1. 消费者的位置给出了下一个记录的偏移量。它将比消费者在该分区中看到的最高偏移量大一个。
2. 每次消费者在轮询调用中接收消息时，它会自动前进（持续时间）。
* 提交的位置是安全存储的最后一个偏移量。如果进程失败并重新启动，则这是消费者将恢复到的偏移量。
* 消费者可以定期自动提交偏移;或者它可以选择通过调用其中一个提交API（例如commitSync和commitAsync）手动控制此提交位置
* Kafka使用消费者群体的概念来允许一组流程划分消费和处理记录的工作。这些进程可以在同一台机器上运行，也可以分布在多台机器上，为处理提供可扩展性和容错能力。共享相同group.id的所有使用者实例将属于同一个使用者组
* 组中的每个使用者都可以通过其中一个订阅API动态设置要订阅的主题列表。 Kafka会将订阅主题中的每条消息传递给每个消费者组中的一个进程。这是通过平衡使用者组中所有成员之间的分区来实现的，这样每个分区就可以分配给该组中的一个使用者。因此，如果存在具有四个分区的主题，以及具有两个进程的使用者组，则每个进程将使用两个分区
* 消费者组中的成员资格是动态维护的：如果进程失败，分配给它的分区将被重新分配给同一组中的其他使用者。同样，如果新的使用者加入该组，则分区将从现有使用者移动到新使用者。这被称为**重新平衡该组**，并在下面更详细地讨论。当新分区添加到其中一个订阅主题或创建与订阅正则表达式匹配的新主题时，也会使用组**重新平衡**。该组将通过定期元数据刷新自动检测新分区，并将其分配给该组的成员
* 从概念上讲，您可以将消费者群体视为恰好由多个流程组成的单个逻辑订阅者。作为一个多用户系统，Kafka自然支持在没有重复数据的情况下为给定主题设置任意数量的消费者群体（其他消费者实际上相当便宜）。
* 此外，当组重新分配自动发生时，可以通过ConsumerRebalanceListener通知消费者，这允许他们完成必要的应用程序级逻辑，例如状态清理，手动偏移提交等
* 消费者也可以使用assign（Collection）手动分配特定分区（类似于较旧的“简单”消费者）。在这种情况下，将禁用动态分区分配和使用者组协调
* 订阅一组主题后，当调用poll（Duration）时，使用者将自动加入该组。 poll API旨在确保消费者的活力。只要您继续调用poll，消费者将留在该组中并继续从分配的分区接收消息。在封面下方，消费者会定期向服务器发送心跳。如果消费者在session.timeout.ms的持续时间内崩溃或无法发送心跳，则消费者将被视为已死，并且将重新分配其分区
* 消费者也可能遇到“活锁”情况，即继续发送心跳，但没有取得进展。为防止消费者在这种情况下无限期地占用其分区，我们使用max.poll.interval.ms设置提供活动检测机制。基本上，如果您不至少与配置的最大间隔一样频繁地调用轮询，则客户端将主动离开该组，以便其他使用者可以接管其分区,发生这种情况时，您可能会看到偏移提交失败（由对commitSync（）的调用抛出的CommitFailedException指示,这是一种安全机制，可确保只有组中的活动成员才能提交偏移量。因此，要留在群组中，您必须继续致电民意调查
* max.poll.interval.ms：通过增加预期轮询之间的间隔，您可以为消费者提供更多时间来处理从poll（Duration）返回的一批记录。缺点是增加此值可能会延迟组重新平衡，因为消费者只会加入轮询调用中的重新平衡。您可以使用此设置来限制完成重新平衡的时间，但如果消费者实际上不能经常调用轮询，则可能会导致进度降低。
* max.poll.records：使用此设置可限制从单个调用返回到poll的总记录数。这可以更容易地预测每个轮询间隔内必须处理的最大值。通过调整此值，您可以减少轮询间隔，这将减少组重新平衡的影响。
对于消息处理时间变化不可预测的用例，这些选项都不够。处理这些情况的推荐方法是将消息处理移动到另一个线程，这允许消费者在处理器仍在工作时继续调用poll。必须注意确保承诺的抵消不会超过实际位置。通常，您必须禁用自动提交并仅在线程完成处理后手动提交记录的已处理偏移量（取决于您需要的传递语义）。另请注意，您需要暂停分区，以便在线程处理完之前返回的内容之前，不会从轮询中收到任何新记录。

### 自动消费消息
```
  Properties props = new Properties();
     props.setProperty("bootstrap.servers", "localhost:9092");
     props.setProperty("group.id", "test");
     props.setProperty("enable.auto.commit", "true");
     props.setProperty("auto.commit.interval.ms", "1000");
     props.setProperty("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
     props.setProperty("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
     
     KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);
     consumer.subscribe(Arrays.asList("foo", "bar"));
     while (true) {
         ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
         for (ConsumerRecord<String, String> record : records)
             System.out.printf("offset = %d, key = %s, value = %s%n", record.offset(), record.key(), record.value());
     }
```
* 通过使用configuration> bootstrap.servers指定要联系的一个或多个代理的列表来引导与集群的连接
* 设置enable.auto.commit意味着自动提交偏移量，其频率由config auto.commit.interval.ms控制
* 使用者将订阅主题foo和bar作为一组使用group.id配置的称为test的消费者的一部分
* 解串器设置指定如何将字节转换为对象。例如，通过指定字符串反序列化器，我们说我们的记录的键和值只是简单的字符串

### 手动偏移控制
* 用户还可以控制何时应将记录视为已消耗并因此提交其偏移量，而不是依赖于消费者定期提交消耗的偏移量。

```
  Properties props = new Properties();
     props.setProperty("bootstrap.servers", "localhost:9092");
     props.setProperty("group.id", "test");
     props.setProperty("enable.auto.commit", "false");
     props.setProperty("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
     props.setProperty("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
     KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);
     consumer.subscribe(Arrays.asList("foo", "bar"));
     final int minBatchSize = 200;
     List<ConsumerRecord<String, String>> buffer = new ArrayList<>();
     while (true) {
         ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
         for (ConsumerRecord<String, String> record : records) {
             buffer.add(record);
         }
         if (buffer.size() >= minBatchSize) {
             insertIntoDb(buffer);
             consumer.commitSync();
             buffer.clear();
         }
     }
```

* 在某些情况下，您可能希望通过明确指定偏移量来更好地控制已提交的记录。 在下面的示例中，我们在完成处理每个分区中的记录后提交偏移量
```
try {
         while(running) {
             ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(Long.MAX_VALUE));
             for (TopicPartition partition : records.partitions()) {
                 List<ConsumerRecord<String, String>> partitionRecords = records.records(partition);
                 for (ConsumerRecord<String, String> record : partitionRecords) {
                     System.out.println(record.offset() + ": " + record.value());
                 }
                 long lastOffset = partitionRecords.get(partitionRecords.size() - 1).offset();
                 consumer.commitSync(Collections.singletonMap(partition, new OffsetAndMetadata(lastOffset + 1)));
             }
         }
     } finally {
       consumer.close();
     }
```


### 多线程消费者处理
* Kafka消费者不是线程安全的。 
* 所有网络I / O都发生在进行调用的应用程序的线程中。 用户有责任确保正确同步多线程访问。 未同步的访问将导致ConcurrentModificationException
* 此规则的唯一例外是wakeup（），它可以安全地从外部线程用于中断活动操作。 在这种情况下，将从操作的线程阻塞中抛出WakeupException

```
 public class KafkaConsumerRunner implements Runnable {
     private final AtomicBoolean closed = new AtomicBoolean(false);
     private final KafkaConsumer consumer;

     public KafkaConsumerRunner(KafkaConsumer consumer) {
       this.consumer = consumer;
     }

     public void run() {
         try {
             consumer.subscribe(Arrays.asList("topic"));
             while (!closed.get()) {
                 ConsumerRecords records = consumer.poll(Duration.ofMillis(10000));
                 // Handle new records
             }
         } catch (WakeupException e) {
             // Ignore exception if closing
             if (!closed.get()) throw e;
         } finally {
             consumer.close();
         }
     }

     // Shutdown hook which can be called from a separate thread
     public void shutdown() {
         closed.set(true);
         consumer.wakeup();
     }
 }
```

* 在单独的线程中，可以通过设置关闭标志并唤醒消费者来关闭消费者
```
closed.set(true);
consumer.wakeup();
 
```

## 构造方法
```
public KafkaConsumer(Map<String,Object> configs,
                     Deserializer<K> keyDeserializer,
                     Deserializer<V> valueDeserializer)
```

### subscribe(Collection<String> topics, ConsumerRebalanceListener listener)
* 订阅给定的主题列表以获取动态分配的分区。
* 主题订阅不是增量的。此列表将替换当前分配（如果有）。
* 请注意，无法通过assign（Collection）将主题订阅与组管理与手动分区分配相结合。如果给定的主题列表为空，则将其视为与unsubscribe（）相同。
作为组管理的一部分，消费者将跟踪属于特定组的使用者列表，并在触发以下任何一个事件时触发重新平衡操作：
1. 任何订阅主题的分区数都会发生变化
2. 创建或删除订阅的主题
3. 使用者组的现有成员已关闭或失败
4. 将新成员添加到使用者组
* 触发任何这些事件时，将首先调用提供的侦听器以指示已撤消使用者的分配，然后在收到新分配时再次调用。请注意，重新平衡仅在活动的poll（调用持续时间）调用期间发生，因此在此期间也只会调用回调。提供的侦听器将立即覆盖先前对subscribe的调用中设置的任何侦听器。但是，可以保证通过此接口撤消/分配的分区来自此呼叫中订阅的主题 
```
public void subscribe(Collection<String> topics, ConsumerRebalanceListener listener)
```

### subscribe(Pattern pattern,ConsumerRebalanceListener listener)
* 订阅与指定模式匹配的所有主题以获取动态分配的分区
```
public void subscribe(Pattern pattern,ConsumerRebalanceListener listener)
```

### unsubscribe()
* 取消订阅当前订阅了subscribe（Collection）或订阅（Pattern）的主题。 这也清除了通过assign（Collection）直接分配的任何分区
```

```

### assign(Collection<TopicPartition> partitions)
* 手动为此使用者分配分区列表。 此接口不允许增量分配，并将替换先前的分配（如果有）。
如果给定的主题分区列表为空，则将其视为与unsubscribe（）相同
* 通过此方法分配手动主题不会使用使用者的组管理功能。 因此，当组成员身份或群集和主题元数据更改时，将不会触发重新平衡操作。 请注意，不能同时使用assign（Collection）的手动分区赋值和subscribe（Collection，ConsumerRebalanceListener）的组赋值
```
public void assign(Collection<TopicPartition> partitions)
```

### poll(Duration timeout)
* 获取使用其中一个subscribe / assign API指定的主题或分区的数据
* 在每次轮询时，消费者将尝试使用最后消耗的偏移量作为起始偏移量并按顺序提取。 最后消耗的偏移量可以通过seek（TopicPartition，long）手动设置，也可以自动设置为订阅分区列表的最后一个提交偏移量
* 如果有可用记录，此方法立即返回。 否则，它将等待传递的超时。 如果超时到期，将返回空记录集。 请注意，此方法可能会阻止超出超时，以便执行自定义ConsumerRebalanceListener回调
```
public ConsumerRecords<K,V> poll(Duration timeout)
```


### commitSync()
* 在所有订阅的主题和分区列表的最后一个poll（）上返回的提交偏移量
* 这是一个同步提交，将阻塞，直到提交成功，遇到不可恢复的错误（在这种情况下它被抛出到调用者）
* 这仅对Kafka提供偏移。 使用此API提交的偏移量将在每次重新平衡后以及启动时的第一次提取时使用
```
public void commitSync()
```

### commitSync(Map<TopicPartition,OffsetAndMetadata> offsets)（不是很懂）
```
public void commitSync(Map<TopicPartition,OffsetAndMetadata> offsets)
```


### commitAsync()
* 在所有订阅的主题和分区列表的最后一次轮询（持续时间）上返回的提交偏移量。 与commitAsync（null）相同
```
public void commitAsync()
```

### commitAsync(OffsetCommitCallback callback)
* 这是一个异步调用，不会阻塞。 遇到的任何错误都会传递给回调（如果提供）或被丢弃
* 通过多次调用此API提交的偏移量保证以与调用相同的顺序发送。 相应的提交回调也以相同的顺序调用
```
public void commitAsync(OffsetCommitCallback callback)
```


### seek(TopicPartition partition, long offset)
* 覆盖消费者在下次轮询（超时）时将使用的提取偏移量。
* 如果多次为同一分区调用此API，则将在下一轮询（）上使用最新的偏移量。
* 请注意，如果在消耗过程中任意使用此API，则可能会丢失数据，以重置提取偏移量
```
public void seek(TopicPartition partition, long offset)
```


### seekToBeginning(Collection<TopicPartition> partitions)
* 寻找每个给定分区的第一个偏移量。 此函数懒惰地求值，仅在调用poll（Duration）或position（TopicPartition）时才在所有分区中寻找第一个偏移量
```
public void seekToBeginning(Collection<TopicPartition> partitions)
```


###  position(TopicPartition partition)
* 获取将要获取的下一条记录的偏移量（如果存在具有该偏移量的记录）
```
public long position(TopicPartition partition)
```

### committed(TopicPartition partition)
* 获取给定分区的最后一个提交的偏移量（无论此进程是否发生了提交）
* 此调用将执行远程调用以从服务器获取最新提交的偏移量，并将阻塞，直到成功获取已提交的偏移量
```
public OffsetAndMetadata committed(TopicPartition partition)
```


### close(Duration timeout)
* 尝试在指定的超时内干净地关闭消费者。 此方法等待消费者完成挂起提交并离开组的超时。
* 如果启用了自动提交，则会在超时内尽可能提交当前偏移量。
* 如果消费者无法完成偏移提交并在超时到期之前优雅地离开该组，则强制关闭消费者
```
public void close(Duration timeout)
```


# KafkaStreams流操作文档
* Kafka客户端，允许对来自一个或多个输入主题的输入执行连续计算，并将输出发送到零个，一个或多个输出主题
* 一个KafkaStreams实例可以包含在配置中为处理工作指定的一个或多个线程
* 在内部，KafkaStreams实例包含一个普通的KafkaProducer和KafkaConsumer实例，用于读取输入和写入输出
```
 Properties props = new Properties();
 props.put(StreamsConfig.APPLICATION_ID_CONFIG, "my-stream-processing-application");
 props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
 props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass());
 props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass());

 StreamsBuilder builder = new StreamsBuilder();
 builder.<String, String>stream("my-input-topic").mapValues(value -> String.valueOf(value.length())).to("my-output-topic");

 KafkaStreams streams = new KafkaStreams(builder.build(), props);
 streams.start();
```


# assign VS subscribe
* 在kafka中，正常情况下，同一个group.id下的不同消费者不会消费同样的partition，也即某个partition在任何时刻都只能被具有相同group.id的consumer中的一个消费
* 也正是这个机制才能保证kafka的重要特性：
1. 可以通过增加partitions和consumer来提升吞吐量；
2. 保证同一份消息不会被消费多次。


## 在KafkaConsumer类中（官方API），消费者可以通过assign和subscribe两种方式指定要消费的topic-partition
* KafkaConsumer.subscribe() : 为consumer自动分配partition，有内部算法保证topic-partition以最优的方式均匀分配给同group下的不同consumer。


* KafkaConsumer.assign() : 为consumer手动、显示的指定需要消费的topic-partitions，不受group.id限制，相当与指定的group无效（this method does not use the consumer's group management）。

## 解释范例
```
public class KafkaManualAssignTest {
    private static final Logger logger = LoggerFactory.getLogger(KafkaManualAssignTest.class);

    private static Properties props = new Properties();
    private static KafkaConsumer<String, String> c1, c2;

    private static final String brokerList = "localhost:9092";

    static {
        props.put("bootstrap.servers", brokerList);
        props.put("group.id", "assignTest");
        props.put("auto.offset.reset", "earliest");
        props.put("enable.auto.commit", "true");
        props.put("session.timeout.ms", "30000");
        props.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        props.put("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");

        c1 = new KafkaConsumer<String, String>(props);//相同的group-id
        c2 = new KafkaConsumer<String, String>(props);//相同的group-id
    }

    public static void main(String[] args) {
        TopicPartition tp = new TopicPartition("topic", 0);
        // 采用assign方式显示的为consumer指定需要消费的topic, 具有相同group.id的两个消费者
        // 各自消费了一份数据, 出现了数据的重复消费
        c1.assign(Arrays.asList(tp));
        c2.assign(Arrays.asList(tp));


        // 采用subscribe方式, 利用broker为consumer自动分配topic-partitions,
        // 两个消费者各自消费一个partition, 数据互补, 无交叉.
        // c1.subscribe(Arrays.asList("topic"));
        // c2.subscribe(Arrays.asList("topic"));

       
        }
    }
}

```

# 消息的过期时间
* 我们在使用Kafka存储消息时，如果已经消费过了，再永久存储是一种资源的浪费
* kafka为我们提供了消息文件的过期策略，可以通过配置server.properies来实现
* 修改下面的代码
```
# vi config/server.properies

log.roll.hours=1
log.retention.hours=2
log.segment.delete.delay.ms=0
```
* 重启kafka服务即可，上面表示消息存储时间为２小时。


# offset设置（auto.offset.reset）（这个每个都要好好理解下）

* earliest：当各分区下有已提交的offset时，从提交的offset开始消费；无提交的offset时，从头开始消费 
* latest：当各分区下有已提交的offset时，从提交的offset开始消费；无提交的offset时，消费新产生的该分区下的数据 
* none：topic各分区都存在已提交的offset时，从offset后开始消费；只要有一个分区不存在已提交的offset，则抛出异常


# Producer Configs
待补充填写...

# Consumer Configs
待补充填写...


# spring-kafka

## ContainerProperties
* 容器参数
```
public class ContainerProperties {
    public static final long DEFAULT_POLL_TIMEOUT = 5000L;
    public static final long DEFAULT_SHUTDOWN_TIMEOUT = 10000L;
    public static final int DEFAULT_MONITOR_INTERVAL = 30;
    public static final float DEFAULT_NO_POLL_THRESHOLD = 3.0F;
    private final String[] topics;
    private final Pattern topicPattern;
    private final TopicPartitionInitialOffset[] topicPartitions;
    private ContainerProperties.AckMode ackMode;
    private int ackCount;
    private long ackTime;
    private Object messageListener;
    private volatile long pollTimeout;
    private AsyncListenableTaskExecutor consumerTaskExecutor;
    private long shutdownTimeout;
    private ConsumerRebalanceListener consumerRebalanceListener;
    private OffsetCommitCallback commitCallback;
    private boolean syncCommits;
    private boolean ackOnError;
    private Long idleEventInterval;
    private String groupId;
    private PlatformTransactionManager transactionManager;
    private int monitorInterval;
    private TaskScheduler scheduler;
    private float noPollThreshold;
    private String clientId;
    private boolean logContainerConfig;
    private Level commitLogLevel;
    private boolean missingTopicsFatal;
    private Properties consumerProperties;
```

## ConsumerFactory接口
```
  @Override
    public Consumer createConsumer(String s, String s1, String s2) {
        return null;
    }

    @Override
    public boolean isAutoCommit() {
        return false;
    }
```

## DefaultKafkaConsumerFactory实现类
```
public class DefaultKafkaConsumerFactory<K, V> implements ConsumerFactory<K, V> {
    private final Map<String, Object> configs;//消费者设置是一个HashMap
    private Deserializer<K> keyDeserializer;
    private Deserializer<V> valueDeserializer;
    
    
public DefaultKafkaConsumerFactory(Map<String, Object> configs, @Nullable Deserializer<K> keyDeserializer, @Nullable Deserializer<V> valueDeserializer) {//构造器
        this.configs = new HashMap(configs);
        this.keyDeserializer = keyDeserializer;
        this.valueDeserializer = valueDeserializer;
    }    
```

## AbstractMessageListenerContainer抽象类
```
public abstract class AbstractMessageListenerContainer<K, V> implements GenericMessageListenerContainer<K, V>, BeanNameAware, ApplicationEventPublisherAware {
    public static final int DEFAULT_PHASE = 2147483547;
    protected final Log logger;
    protected final ConsumerFactory<K, V> consumerFactory;
    private final ContainerProperties containerProperties;
    private final Object lifecycleMonitor;
    private String beanName;
    private ApplicationEventPublisher applicationEventPublisher;
    private GenericErrorHandler<?> errorHandler;
    private boolean autoStartup;
    private int phase;
    private AfterRollbackProcessor<? super K, ? super V> afterRollbackProcessor;
    private RecordInterceptor<K, V> recordInterceptor;
    private volatile boolean running;
    private volatile boolean paused;
    
protected AbstractMessageListenerContainer(ConsumerFactory<? super K, ? super V> consumerFactory, ContainerProperties containerProperties) {//构造方法
        this.logger = LogFactory.getLog(this.getClass());
        this.lifecycleMonitor = new Object();
        this.autoStartup = true;
        this.phase = 2147483547;
        this.afterRollbackProcessor = new DefaultAfterRollbackProcessor();
        this.running = false;
        Assert.notNull(containerProperties, "'containerProperties' cannot be null");
        this.consumerFactory = consumerFactory;
        if (containerProperties.getTopics() != null) {
            this.containerProperties = new ContainerProperties(containerProperties.getTopics());
        } else if (containerProperties.getTopicPattern() != null) {
            this.containerProperties = new ContainerProperties(containerProperties.getTopicPattern());
        } else {
            if (containerProperties.getTopicPartitions() == null) {
                throw new IllegalStateException("topics, topicPattern, or topicPartitions must be provided");
            }

            this.containerProperties = new ContainerProperties(containerProperties.getTopicPartitions());
        }

        BeanUtils.copyProperties(containerProperties, this.containerProperties, new String[]{"topics", "topicPartitions", "topicPattern", "ackCount", "ackTime"});
        if (containerProperties.getAckCount() > 0) {
            this.containerProperties.setAckCount(containerProperties.getAckCount());
        }

        if (containerProperties.getAckTime() > 0L) {
            this.containerProperties.setAckTime(containerProperties.getAckTime());
        }

        if (this.containerProperties.getConsumerRebalanceListener() == null) {
            this.containerProperties.setConsumerRebalanceListener(this.createSimpleLoggingConsumerRebalanceListener());
        }

    }
    
public void stop(Runnable callback) {
        synchronized(this.lifecycleMonitor) {
            if (this.isRunning()) {
                this.doStop(callback);//抽象方法doStop()由子类实现
                this.publishContainerStoppedEvent();
            }

        }
    }
    
    
public final void start() {
        this.checkGroupId();
        synchronized(this.lifecycleMonitor) {
            if (!this.isRunning()) {
                Assert.isTrue(this.containerProperties.getMessageListener() instanceof GenericMessageListener, () -> {
                    return "A " + GenericMessageListener.class.getName() + " implementation must be provided";
                });
                this.doStart();//抽象方法doStart()由子类实现
            }

        }
    }
```

## KafkaMessageListenerContainer
* 监听
```
public class KafkaMessageListenerContainer<K, V> extends AbstractMessageListenerContainer<K, V> {
    private static final String UNUSED = "unused";
    private static final int DEFAULT_ACK_TIME = 5000;
    private final AbstractMessageListenerContainer<K, V> container;
    private final TopicPartitionInitialOffset[] topicPartitions;
    private volatile KafkaMessageListenerContainer<K, V>.ListenerConsumer listenerConsumer;
    private volatile ListenableFuture<?> listenerConsumerFuture;
    private String clientIdSuffix;
    private Runnable emergencyStop;//紧急停止
    
    
KafkaMessageListenerContainer(AbstractMessageListenerContainer<K, V> container, ConsumerFactory<? super K, ? super V> consumerFactory, ContainerProperties containerProperties, TopicPartitionInitialOffset... topicPartitions) {//构造方法
        super(consumerFactory, containerProperties);//消费者工厂和容器参数
        this.emergencyStop = () -> {
            this.stop(() -> {
            });//调用超类停止方法
        };//初始化emergencyStop
        Assert.notNull(consumerFactory, "A ConsumerFactory must be provided");
        this.container = (AbstractMessageListenerContainer)(container == null ? this : container);//初始化container
        if (topicPartitions != null) {//初始化topicPartitions
            this.topicPartitions = (TopicPartitionInitialOffset[])Arrays.copyOf(topicPartitions, topicPartitions.length);
        } else {
            this.topicPartitions = containerProperties.getTopicPartitions();
        }

    }
    
protected void doStop(Runnable callback) {
        if (this.isRunning()) {
            this.listenerConsumerFuture.addCallback(new KafkaMessageListenerContainer.StopCallback(callback));
            this.setRunning(false);
            this.listenerConsumer.consumer.wakeup();
        }

    }
    

protected void doStart() {
        if (!this.isRunning()) {
            if (this.clientIdSuffix == null) {
                this.checkTopics();//耗费时间
            }

            ContainerProperties containerProperties = this.getContainerProperties();
            this.checkAckMode(containerProperties);
            Object messageListener = containerProperties.getMessageListener();
            Assert.state(messageListener != null, "A MessageListener is required");
            if (containerProperties.getConsumerTaskExecutor() == null) {
                SimpleAsyncTaskExecutor consumerExecutor = new SimpleAsyncTaskExecutor((this.getBeanName() == null ? "" : this.getBeanName()) + "-C-");
                containerProperties.setConsumerTaskExecutor(consumerExecutor);
            }

            Assert.state(messageListener instanceof GenericMessageListener, "Listener must be a GenericListener");
            GenericMessageListener<?> listener = (GenericMessageListener)messageListener;
            ListenerType listenerType = this.deteremineListenerType(listener);
            this.listenerConsumer = new KafkaMessageListenerContainer.ListenerConsumer(listener, listenerType);//设置消费者
            this.setRunning(true);//设置运行状态
            this.listenerConsumerFuture = containerProperties.getConsumerTaskExecutor().submitListenable(this.listenerConsumer);//设置Future 
        }
    }
    
    
```

```
public void run() {
            this.consumerThread = Thread.currentThread();
            if (this.genericListener instanceof ConsumerSeekAware) {
                ((ConsumerSeekAware)this.genericListener).registerSeekCallback(this);
            }

            if (this.transactionManager != null) {
                ProducerFactoryUtils.setConsumerGroupId(this.consumerGroupId);
            }

            this.count = 0;
            this.last = System.currentTimeMillis();
            this.initAsignedPartitions();

            while(KafkaMessageListenerContainer.this.isRunning()) {
                try {
                    this.pollAndInvoke();
                } catch (WakeupException var3) {
                } catch (NoOffsetForPartitionException var4) {
                    this.fatalError = true;
                    this.logger.error("No offset and no reset policy", var4);
                    break;
                } catch (Exception var5) {
                    this.handleConsumerException(var5);
                } catch (Error var6) {
                    Runnable runnable = KafkaMessageListenerContainer.this.emergencyStop;
                    if (runnable != null) {
                        runnable.run();
                    }

                    this.logger.error("Stopping container due to an Error", var6);
                    this.wrapUp();
                    throw var6;
                }
            }

            this.wrapUp();
        }
```

### ListenerConsumer
* KafkaMessageListenerContainer的内部类
```
 private final class ListenerConsumer implements SchedulingAwareRunnable, ConsumerSeekCallback {
        private static final String UNCHECKED = "unchecked";
        private static final String RAWTYPES = "rawtypes";
        private static final String RAW_TYPES = "rawtypes";
        private final Log logger = LogFactory.getLog(KafkaMessageListenerContainer.ListenerConsumer.class);
        private final ContainerProperties containerProperties = KafkaMessageListenerContainer.this.getContainerProperties();
        private final OffsetCommitCallback commitCallback;
        private final Consumer<K, V> consumer;
        private final Map<String, Map<Integer, Long>> offsets;
        private final GenericMessageListener<?> genericListener;
        private final MessageListener<K, V> listener;
        private final BatchMessageListener<K, V> batchListener;
        private final ListenerType listenerType;
        private final boolean isConsumerAwareListener;
        private final boolean isBatchListener;
        private final boolean wantsFullRecords;
        private final boolean autoCommit;
        private final boolean isManualAck;
        private final boolean isCountAck;
        private final boolean isTimeOnlyAck;
        private final boolean isManualImmediateAck;
        private final boolean isAnyManualAck;
        private final boolean isRecordAck;
        private final BlockingQueue<ConsumerRecord<K, V>> acks;
        private final BlockingQueue<TopicPartitionInitialOffset> seeks;
        private final ErrorHandler errorHandler;
        private final BatchErrorHandler batchErrorHandler;
        private final PlatformTransactionManager transactionManager;
        private final KafkaAwareTransactionManager kafkaTxManager;
        private final TransactionTemplate transactionTemplate;
        private final String consumerGroupId;
        private final TaskScheduler taskScheduler;
        private final ScheduledFuture<?> monitorTask;
        private final LogIfLevelEnabled commitLogger;
        private final Duration pollTimeout;
        private final boolean checkNullKeyForExceptions;
        private final boolean checkNullValueForExceptions;
        private final RecordInterceptor<K, V> recordInterceptor;
        private Map<TopicPartition, KafkaMessageListenerContainer.OffsetMetadata> definedPartitions;
        private volatile Collection<TopicPartition> assignedPartitions;
        private volatile Thread consumerThread;
        private int count;
        private long last;
        private boolean fatalError;
        private boolean taskSchedulerExplicitlySet;
        private boolean consumerPaused;
        private long lastReceive;
        private long lastAlertAt;
        private volatile long lastPoll;
```




## SimpleAsyncTaskExecutor
* 简单的异步任务执行器
```
public class SimpleAsyncTaskExecutor extends CustomizableThreadCreator implements AsyncListenableTaskExecutor, Serializable {
    public static final int UNBOUNDED_CONCURRENCY = -1;
    public static final int NO_CONCURRENCY = 0;
    private final SimpleAsyncTaskExecutor.ConcurrencyThrottleAdapter concurrencyThrottle = new SimpleAsyncTaskExecutor.ConcurrencyThrottleAdapter();
    
public SimpleAsyncTaskExecutor(String threadNamePrefix) {
        super(threadNamePrefix);
    }    
    
private static class ConcurrencyThrottleAdapter extends ConcurrencyThrottleSupport {//内部类，并发节流适配器
        private ConcurrencyThrottleAdapter() {
        }

        protected void beforeAccess() {
            super.beforeAccess();
        }

        protected void afterAccess() {
            super.afterAccess();
        }
    }

```

## CustomizableThreadCreator
* 可定制的线程创建器

```
public class CustomizableThreadCreator implements Serializable {
    private String threadNamePrefix;//线程前缀
    private int threadPriority = 5;
    private boolean daemon = false;//守护进程
```

## ProducerFactory接口
```
   @Override
    public Producer createProducer() {
        return null;
    }
```

## DefaultKafkaProducerFactory
```
public class DefaultKafkaProducerFactory<K, V> implements ProducerFactory<K, V>, ApplicationContextAware, ApplicationListener<ContextStoppedEvent>, DisposableBean {
    private static final int DEFAULT_PHYSICAL_CLOSE_TIMEOUT = 30;
    private static final Log logger = LogFactory.getLog(DefaultKafkaProducerFactory.class);
    private final Map<String, Object> configs;
    private final AtomicInteger transactionIdSuffix;
    private final BlockingQueue<DefaultKafkaProducerFactory.CloseSafeProducer<K, V>> cache;
    private final Map<String, DefaultKafkaProducerFactory.CloseSafeProducer<K, V>> consumerProducers;
    private volatile DefaultKafkaProducerFactory.CloseSafeProducer<K, V> producer;
    private Serializer<K> keySerializer;
    private Serializer<V> valueSerializer;
    private int physicalCloseTimeout;
    private String transactionIdPrefix;
    private ApplicationContext applicationContext;
    private boolean producerPerConsumerPartition;
    
public DefaultKafkaProducerFactory(Map<String, Object> configs, @Nullable Serializer<K> keySerializer, @Nullable Serializer<V> valueSerializer) {
        this.transactionIdSuffix = new AtomicInteger();
        this.cache = new LinkedBlockingQueue();
        this.consumerProducers = new HashMap();
        this.physicalCloseTimeout = 30;
        this.producerPerConsumerPartition = true;
        this.configs = new HashMap(configs);
        this.keySerializer = keySerializer;
        this.valueSerializer = valueSerializer;
    }

```

```
 public Producer<K, V> createProducer() {
        if (this.transactionIdPrefix != null) {//存在前缀
            return this.producerPerConsumerPartition ? this.createTransactionalProducerForPartition() : this.createTransactionalProducer();
        } else {
            if (this.producer == null) {
                synchronized(this) {//这里有个锁，单例
                    if (this.producer == null) {
                        this.producer = new DefaultKafkaProducerFactory.CloseSafeProducer(this.createKafkaProducer());
                    }
                }
            }

            return this.producer;
        }
    }
```

```
protected Producer<K, V> createKafkaProducer() {//返回KafkaProducer，这个类属于kafka客户端的包
        return new KafkaProducer(this.configs, this.keySerializer, this.valueSerializer);
    }
```

## CloseSafeProducer
* DefaultKafkaProducerFactory的内部类
* 持有一个生产者
```
protected static class CloseSafeProducer<K, V> implements Producer<K, V> {
        private final Producer<K, V> delegate;
        private final BlockingQueue<DefaultKafkaProducerFactory.CloseSafeProducer<K, V>> cache;//缓存，是一个阻塞队列
        private final Consumer<DefaultKafkaProducerFactory.CloseSafeProducer<K, V>> removeConsumerProducer;//除去消费生产者操作
        private final String txId;//事物id
        private volatile boolean txFailed;//事物是否失效
        
        
CloseSafeProducer(Producer<K, V> delegate) {
            this(delegate, (BlockingQueue)null, (Consumer)null);
            Assert.isTrue(!(delegate instanceof DefaultKafkaProducerFactory.CloseSafeProducer), "Cannot double-wrap a producer");
        }
        
CloseSafeProducer(Producer<K, V> delegate, @Nullable BlockingQueue<DefaultKafkaProducerFactory.CloseSafeProducer<K, V>> cache, @Nullable Consumer<DefaultKafkaProducerFactory.CloseSafeProducer<K, V>> removeConsumerProducer, @Nullable String txId) {
            this.delegate = delegate;
            this.cache = cache;
            this.removeConsumerProducer = removeConsumerProducer;
            this.txId = txId;
        }
```

```
public Future<RecordMetadata> send(ProducerRecord<K, V> record, Callback callback) {
            return this.delegate.send(record, callback);
        }
```

## KafkaTemplate
```
public class KafkaTemplate<K, V> implements KafkaOperations<K, V> {
    protected final Log logger;
    private final ProducerFactory<K, V> producerFactory;//生产者工厂
    private final boolean autoFlush;
    private final boolean transactional;
    private final ThreadLocal<Producer<K, V>> producers;
    private RecordMessageConverter messageConverter;//消息转换器
    private volatile String defaultTopic;//默认的topic
    private volatile ProducerListener<K, V> producerListener;//生产者监听器


//参数为工厂类的构造方法带入的autoFlush默认为false
public KafkaTemplate(ProducerFactory<K, V> producerFactory, boolean autoFlush) {
        this.logger = LogFactory.getLog(this.getClass());//日志记录
        this.producers = new ThreadLocal();//创建ThreadLocal
        this.messageConverter = new MessagingMessageConverter();//初始化消息转换器
        this.producerListener = new LoggingProducerListener();//初始化生产者监听器
        this.producerFactory = producerFactory;//设置生产者工厂
        this.autoFlush = autoFlush;//设置自动冲刷值
        this.transactional = producerFactory.transactionCapable();//设置是否开启事物，依赖工厂，默认是false
    }
```
```
public void setDefaultTopic(String defaultTopic) {//设置默认的主题
        this.defaultTopic = defaultTopic;
    }
```
```
public ListenableFuture<SendResult<K, V>> sendDefault(K key, @Nullable V data) {//向默认的topic发送消息
        return this.send(this.defaultTopic, key, data);
    }
    
    
public ListenableFuture<SendResult<K, V>> send(String topic, K key, @Nullable V data) {
        ProducerRecord<K, V> producerRecord = new ProducerRecord(topic, key, data);//创建生产者
        return this.doSend(producerRecord);
    }
```
```
protected ListenableFuture<SendResult<K, V>> doSend(ProducerRecord<K, V> producerRecord) {//进行发送
        if (this.transactional) {
            Assert.state(this.inTransaction(), "No transaction is in process; possible solutions: run the template operation within the scope of a template.executeInTransaction() operation, start a transaction with @Transactional before invoking the template method, run in a transaction started by a listener container when consuming a record");
        }

        Producer<K, V> producer = this.getTheProducer();//获取生产者，是一个CloseSafeProducer实现，内部持有一个kafkka 
        if (this.logger.isTraceEnabled()) {
            this.logger.trace("Sending: " + producerRecord);
        }

        //创建可设置可监听Future
        SettableListenableFuture<SendResult<K, V>> future = new SettableListenableFuture();
       
       //调用CloseSafeProducer的send,实质就是调用持有的kafka客户端的send
        producer.send(producerRecord, this.buildCallback(producerRecord, producer, future));
        if (this.autoFlush) {//是否自动刷新
            this.flush();
        }

        if (this.logger.isTraceEnabled()) {
            this.logger.trace("Sent: " + producerRecord);
        }

        return future;
    }
```

```
private Producer<K, V> getTheProducer() {
        if (this.transactional) {//判断事物
            Producer<K, V> producer = (Producer)this.producers.get();//获取当前线程中的生产者
            if (producer != null) {
                return producer;
            } else {//当前线程中不存在生产者
                KafkaResourceHolder<K, V> holder = ProducerFactoryUtils.getTransactionalResourceHolder(this.producerFactory);//这里面会开启事物
                return holder.getProducer();//返回生产者
            }
        } else {
            return this.producerFactory.createProducer();
        }
    }
```

```
public void flush() {
        Producer producer = this.getTheProducer();//获取当前线程中的生产者

        try {
            producer.flush();//调用冲刷
        } finally {
            this.closeProducer(producer, this.inTransaction());//关闭
        }

    }
```

```
private Callback buildCallback(ProducerRecord<K, V> producerRecord, Producer<K, V> producer, SettableListenableFuture<SendResult<K, V>> future) {
        return (metadata, exception) -> {
            try {
                if (exception == null) {
                    future.set(new SendResult(producerRecord, metadata));//没有异常就存放结果
                    if (this.producerListener != null) {
                        this.producerListener.onSuccess(producerRecord, metadata);
                    }

                    if (this.logger.isTraceEnabled()) {
                        this.logger.trace("Sent ok: " + producerRecord + ", metadata: " + metadata);
                    }
                } else {
                    future.setException(new KafkaProducerException(producerRecord, "Failed to send", exception));//异常就存放异常
                    if (this.producerListener != null) {
                        this.producerListener.onError(producerRecord, exception);
                    }

                    if (this.logger.isDebugEnabled()) {
                        this.logger.debug("Failed to send: " + producerRecord, exception);
                    }
                }
            } finally {
                if (!this.transactional) {
                    this.closeProducer(producer, false);//关闭
                }

            }

        };
    }
```

## SettableListenableFuture
* 有一个内部类的变量
* 存放结果用的，确切来说是内部类SettableTask存放
```
public class SettableListenableFuture<T> implements ListenableFuture<T> {
    private static final Callable<Object> DUMMY_CALLABLE = () -> {
        throw new IllegalStateException("Should never be called");
    };
    private final SettableListenableFuture.SettableTask<T> settableTask = new SettableListenableFuture.SettableTask();
    
public boolean set(@Nullable T value) {//向内部类存放结果或者异常
        return this.settableTask.setResultValue(value);
    }
    
public boolean setException(Throwable exception) {
        Assert.notNull(exception, "Exception must not be null");
        return this.settableTask.setExceptionResult(exception);
    }
    
public void addCallback(ListenableFutureCallback<? super T> callback) {
        this.settableTask.addCallback(callback);
    }
```

内部类
```
 private static class SettableTask<T> extends ListenableFutureTask<T> {
        @Nullable
        private volatile Thread completingThread;

 public boolean setResultValue(@Nullable T value) {
            this.set(value);//调用父类FutureTask的set方法
            return this.checkCompletingThread();
        }
        
public boolean setExceptionResult(Throwable exception) {
            this.setException(exception);
            return this.checkCompletingThread();
        }
        
 public void addCallback(ListenableFutureCallback<? super T> callback) {
        this.callbacks.addCallback(callback);
    }
```

## SendResult
* 发送结果
```
public class SendResult<K, V> {
    private final ProducerRecord<K, V> producerRecord;
    private final RecordMetadata recordMetadata;

    public SendResult(ProducerRecord<K, V> producerRecord, RecordMetadata recordMetadata) {
        this.producerRecord = producerRecord;
        this.recordMetadata = recordMetadata;
    }
```

## ProducerFactoryUtils
```
public static <K, V> KafkaResourceHolder<K, V> getTransactionalResourceHolder(ProducerFactory<K, V> producerFactory) {
        Assert.notNull(producerFactory, "ProducerFactory must not be null");
        KafkaResourceHolder<K, V> resourceHolder = (KafkaResourceHolder)TransactionSynchronizationManager.getResource(producerFactory);
        if (resourceHolder == null) {
            Producer producer = producerFactory.createProducer();

            try {
                producer.beginTransaction();
            } catch (RuntimeException var4) {
                producer.close();
                throw var4;
            }

            resourceHolder = new KafkaResourceHolder(producer);
            bindResourceToTransaction(resourceHolder, producerFactory);
        }

        return resourceHolder;
    }
```

## KafkaResourceHolder
* kafka资源持有者
* 持有一个生产者
```
public class KafkaResourceHolder<K, V> extends ResourceHolderSupport {
    private final Producer<K, V> producer;

    public KafkaResourceHolder(Producer<K, V> producer) {//构造方法传入一个生产者
        this.producer = producer;
    }

    public Producer<K, V> getProducer() {
        return this.producer;
    }

    public void commit() {
        this.producer.commitTransaction();//事物提交
    }

    public void close() {
        this.producer.close();//关闭资源，会立即发送缓冲区
    }

    public void rollback() {
        this.producer.abortTransaction();//中断事物，即回滚
    }
}

```

## ProducerRecord
* 生产者消息记录
* 类属于package org.apache.kafka.clients.producer包
```
public class ProducerRecord<K, V> {
    private final String topic;
    private final Integer partition;
    private final Headers headers;
    private final K key;
    private final V value;
    private final Long timestamp;

```


## KafkaAdmin
```
public class KafkaAdmin implements ApplicationContextAware, SmartInitializingSingleton {
    private static final int DEFAULT_CLOSE_TIMEOUT = 10;
    private static final int DEFAULT_OPERATION_TIMEOUT = 30;
    private static final Log logger = LogFactory.getLog(KafkaAdmin.class);
    private final Map<String, Object> config;
    private ApplicationContext applicationContext;
    private int closeTimeout = 10;
    private int operationTimeout = 30;
    private boolean fatalIfBrokerNotAvailable;
    private boolean autoCreate = true;
    private boolean initializingContext;
```

## KafkaAdminClient
* 包含非常多操作方法
```
public class KafkaAdminClient extends AdminClient {
    private static final AtomicInteger ADMIN_CLIENT_ID_SEQUENCE = new AtomicInteger(1);
    private static final String JMX_PREFIX = "kafka.admin.client";
    private static final long INVALID_SHUTDOWN_TIME = -1L;
    static final String NETWORK_THREAD_PREFIX = "kafka-admin-client-thread";
    private final Logger log;
    private final int defaultTimeoutMs;
    private final String clientId;
    private final Time time;
    private final AdminMetadataManager metadataManager;
    private final Metrics metrics;
    private final KafkaClient client;
    private final KafkaAdminClient.AdminClientRunnable runnable;
    private final Thread thread;
    private final AtomicLong hardShutdownTimeMs = new AtomicLong(-1L);
    private final KafkaAdminClient.TimeoutProcessorFactory timeoutProcessorFactory;
    private final int maxRetries;
    private final long retryBackoffMs;
```

# 消息侦听容器
* KafkaMessageListenerContainer 接收在单个线程从所有的主题或分区上的所有消息
* ConcurrentMessageListenerContainer 提供多线程消耗
* 处理流程
1. @KafkaListener注解由KafkaListenerAnnotationBeanPostProcessor类解析
2. 解析步骤里，我们可以获取到所有含有@KafkaListener注解的类，之后这些类的相关信息会被注册到 KafkaListenerEndpointRegistry内
3. 注册完成之后，每个Listener Container会开始工作，会新启一个新的线程，初始化KafkaConsumer，监听topic变更等
4. 监听到数据之后，container会组织消息的格式，随后调用解析得到的@KafkaListener注解标识的方法，将组织后的消息作为参数传入方法，执行用户逻辑

## KafkaListenerEndpointRegistry
```
public class KafkaListenerEndpointRegistry implements DisposableBean, SmartLifecycle, ApplicationContextAware, ApplicationListener<ContextRefreshedEvent> {
    protected final Log logger = LogFactory.getLog(this.getClass());
    private final Map<String, MessageListenerContainer> listenerContainers = new ConcurrentHashMap();//维护多个容器
    private int phase = 2147483547;
    private ConfigurableApplicationContext applicationContext;
    private boolean contextRefreshed;
```
