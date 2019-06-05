## java客户端

### 类库

#### Envelope信封
```
public class Envelope {
    private final long _deliveryTag;//交货标签
    private final boolean _redeliver;//重新传输
    private final String _exchange;//交换
    private final String _routingKey;//路由主键
    
    ...
}

```

#### Delivery投递
```
public class Delivery {
    private final Envelope _envelope;//信封
    private final BasicProperties _properties;//基础参数
    private final byte[] _body;//信息体

   ...
```

#### BasicProperties基础参数
```
 public static class BasicProperties extends AMQBasicProperties {
        private String contentType;
        private String contentEncoding;
        private Map<String, Object> headers;
        private Integer deliveryMode;
        private Integer priority;
        private String correlationId;
        private String replyTo;
        private String expiration;
        private String messageId;
        private Date timestamp;
        private String type;
        private String userId;
        private String appId;
        private String clusterId;
        
        ...
```


### 依赖
```
 <dependency>
            <groupId>com.rabbitmq</groupId>
            <artifactId>amqp-client</artifactId>
            <version>5.7.1</version>
        </dependency>
```

### 范例通用类

#### 连接工厂
```
import com.rabbitmq.client.ConnectionFactory;

public class ConnectionFactoryBuilder {
    private static ConnectionFactory factory;


    public static ConnectionFactory getFactory() {
        if (factory == null) {
            initFactory();
        }
        return factory;
    }

    private static void initFactory() {
        ConnectionFactory connectionFactory = new ConnectionFactory();
        connectionFactory.setHost("xxxx");
        connectionFactory.setPort(xxxx);
        connectionFactory.setUsername("xxxx");
        connectionFactory.setPassword("xxxx");
        factory = connectionFactory;
    }
}

```

### 基本队列发送接收(消息会被分配给所有消费者)

示例代码
```
package view.javatest.rabbit2;

import com.rabbitmq.client.Channel;
import com.rabbitmq.client.Connection;
import com.rabbitmq.client.ConnectionFactory;
import com.rabbitmq.client.DeliverCallback;
import view.javatest.rabbit.ConnectionFactoryBuilder;

import java.io.IOException;
import java.util.concurrent.TimeoutException;

public class SendAndReceive {
    private final static String QUEUE_NAME = "hello";


    /**
     * 发送消息
     * @throws Exception
     */
    @Test
    public void sendMessage() throws Exception {
        ConnectionFactory factory = ConnectionFactoryBuilder.getFactory();
        try (Connection connection = factory.newConnection();
             Channel channel = connection.createChannel()) {
            channel.queueDeclare(QUEUE_NAME, false, false, false, null);

          for(var i=0;i<50;i++){
              String message = "Hello World! the:"+i;
              channel.basicPublish("", QUEUE_NAME, null, message.getBytes("UTF-8"));
              System.out.println("发送" + message + "");
          }
        }
    }

    /**
     * 测试方法
     * @param argv
     * @throws Exception
     */
    public static void main(String[] argv) throws Exception {
        SendAndReceive sendAndReceive=new SendAndReceive();
        sendAndReceive.sendMessage();
        sendAndReceive.waitForReceive();
    }

    /**
     * 接收消息
     * @throws IOException
     * @throws TimeoutException
     */
    public void waitForReceive() throws IOException, TimeoutException {
        ConnectionFactory factory = ConnectionFactoryBuilder.getFactory();
        Connection connection = factory.newConnection();
        Channel channel = connection.createChannel();

        channel.queueDeclare(QUEUE_NAME, false, false, false, null);
        System.out.println("等待消息:");

        DeliverCallback deliverCallback = (consumerTag, delivery) -> {
            String message = new String(delivery.getBody(), "UTF-8");
            System.out.println("获取消息:" + message+",consumerTag:"+consumerTag );
        };


        channel.basicConsume(QUEUE_NAME, true, deliverCallback, consumerTag -> {
            System.out.println("consumerTag:"+consumerTag);
        });
    }
}
```


#### 方法：AMQP.Queue.DeclareOk queueDeclare ()申明队列

* 主动声明一个服务器命名的独占，自动删除，非持久队列。 新队列的名称保存在AMQP.Queue.DeclareOk结果的“队列”字段中。


#### 方法：AMQP.Queue.DeclareOk queueDeclare(String queue, boolean durable, boolean exclusive, boolean autoDelete, Map<String,Object> arguments) throws IOException申明队列

* queue  - 队列的名称
* durable  - 如果我们声明一个持久队列（队列将在服务器重启后仍然存在），则为true
* exclusive  - 如果我们声明一个独占队列（仅由一个连接使用，并且该连接关闭时将删除队列），则为true
* autoDelete  - 如果我们声明一个自动删除队列，则为true（服务器将在不再使用时将其删除）
* arguments  - 队列的其他属性（构造参数）



#### 方法：String basicConsume(String queue, boolean autoAck, String consumerTag, boolean noLocal, boolean exclusive, Map<String,Object> arguments, DeliverCallback deliverCallback, CancelCallback cancelCallback, ConsumerShutdownSignalCallback shutdownSignalCallback) throws IOException消费
* queue  - 队列的名称
* autoAck  - 如果服务器应该考虑一旦传递确认的消息，则为true; 如果服务器应该期望显式确认，则返回false
* consumerTag  - 客户端生成的消费者标记，用于建立上下文
* noLocal  - 如果服务器不应传递此通道连接上发布的此消费者消息，则为True。 请注意，RabbitMQ服务器不支持此标志。
* exclusive  - 如果这是一个独家消费者，则为true
* arguments  - 消费的一组参数
* deliverCallback  - 传递消息时的回调
* cancelCallback  - 取消消费者时的回调
* shutdownSignalCallback  - 关闭通道/连接时的回调
返回与新消费者相关联的consumerTag



### 工作队列(任务会被分配给所有工人)

示例代码
```
package view.javatest.rabbit2;

import com.rabbitmq.client.*;
import org.testng.annotations.Test;
import view.javatest.rabbit.ConnectionFactoryBuilder;

import java.io.IOException;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

public class SendAndWorker {
    private final String TASK_QUEUE_NAME = "task_queue";

    private String workerName;

    public SendAndWorker() {
        this.workerName = "工人" + UUID.randomUUID();
    }

    /**
     * 测试方法
     *
     * @param argv
     * @throws Exception
     */
    public static void main(String[] argv) throws Exception {
        SendAndWorker sendAndReceive = new SendAndWorker();
//        sendAndReceive.workerReceive(true);
                sendAndReceive.workerReceive(false);
    }


    /**
     * 发送消息
     *
     * @throws Exception
     */

    @Test
    public void sendMessage() throws Exception {
        ConnectionFactory factory = ConnectionFactoryBuilder.getFactory();
        try (Connection connection = factory.newConnection();
             Channel channel = connection.createChannel()) {
            channel.queueDeclare(TASK_QUEUE_NAME, false, false, false, null);

            for (var i = 0; i < 50; i++) {
                String message = "Hello World! the:" + i;
                channel.basicPublish("", TASK_QUEUE_NAME,
                        MessageProperties.PERSISTENT_TEXT_PLAIN,
                        message.getBytes("UTF-8"));
                System.out.println("发送" + message + "");
            }
        }
    }

    /**
     * 接收消息
     *
     * @throws IOException
     * @throws TimeoutException
     */
    public void workerReceive(boolean isSlow) throws IOException, TimeoutException {
        ConnectionFactory factory = ConnectionFactoryBuilder.getFactory();
        Connection connection = factory.newConnection();
        Channel channel = connection.createChannel();
        channel.queueDeclare(TASK_QUEUE_NAME, false, false, false, null);
        channel.basicQos(1);
        System.out.println((isSlow ? "缓慢的工人" : "快速的工人") + "等待消息:");

        DeliverCallback deliverCallback = (consumerTag, delivery) -> {
            String message = new String(delivery.getBody(), "UTF-8");
            System.out.println("获取消息:" + message + ",consumerTag:" + consumerTag);
            try {
                if (isSlow) {
                    doSlowWork();
                } else {
                    doFastWork();
                }

            } finally {
                System.out.println("执行确认ack");
                channel.basicAck(delivery.getEnvelope().getDeliveryTag(), false);//获取交货标签,仅确认提供的交货标签。
            }
        };


        channel.basicConsume(TASK_QUEUE_NAME, false, deliverCallback, consumerTag -> {//这里关闭自动确认
            System.out.println("consumerTag:" + consumerTag);
        });
    }


    private void doFastWork() {
        try {
            TimeUnit.SECONDS.sleep(1);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println(workerName + "完成快速的工作");
    }

    private void doSlowWork() {

        try {
            TimeUnit.SECONDS.sleep(20);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println(workerName + "完成缓慢的工作");
    }
}

```
 #### 方法：channel.basicQos(int prefetchCount)
 * prefetchCount 服务器将传递的最大消息数，如果无限制，则为0
 
 
 #### 方法：void basicAck(long deliveryTag, boolean multiple) throws IOException
确认收到一条或多条收到的消息。 从AMQP.Basic.GetOk或AMQP.Basic.Deliver方法提供deliveryTag，其中包含已确认的已接收消息

* deliveryTag  - 收到的AMQP.Basic.GetOk或AMQP.Basic.Deliver中的标签
* multiple  - 如果确认所有消息，包括提供的交付标签，则为true; false仅确认提供的交货标签。

### 发布与订阅(所有订阅者都会接收到消息)
* RabbitMQ中消息传递模型的核心思想是生产者永远不会将任何消息直接发送到队列。实际上，生产者通常甚至不知道消息是否会被传递到任何队列。
* 相反，生产者只能向交易（exchange）所发送消息。交换(exchange)是一件非常简单的事情。一方面，它接收来自生产者的消息(messages)，另一方面将它们推送到队列(queues)。交易所(exchange)必须确切知道如何处理它收到的消息。它应该附加到特定队列吗？它应该附加到许多队列吗？或者它应该被丢弃。其规则由交换类型(exchange type)定义 。

#### 交换类型
* direct
* topic
* headers
* fanout

枚举型
```
public enum BuiltinExchangeType {
    DIRECT("direct"),
    FANOUT("fanout"),
    TOPIC("topic"),
    HEADERS("headers");

    private final String type;

    private BuiltinExchangeType(String type) {
        this.type = type;
    }

    public String getType() {
        return this.type;
    }
}
```

示例代码
```
package view.javatest.rabbit2;

import com.rabbitmq.client.Channel;
import com.rabbitmq.client.Connection;
import com.rabbitmq.client.ConnectionFactory;
import com.rabbitmq.client.DeliverCallback;
import org.testng.annotations.Test;
import view.javatest.rabbit.ConnectionFactoryBuilder;

import java.io.IOException;
import java.util.UUID;
import java.util.concurrent.TimeoutException;

public class LogAndLogReceive {

    private final String EXCHANGE_NAME = "logs";
    private String workerName;


    public LogAndLogReceive() {
        this.workerName = "工人" + UUID.randomUUID();
    }


    /**
     * 发送消息
     *
     * @throws Exception
     */
    @Test
    public void sendMessage() throws Exception {
        ConnectionFactory factory = ConnectionFactoryBuilder.getFactory();
        try (Connection connection = factory.newConnection();
             Channel channel = connection.createChannel()) {
            channel.exchangeDeclare(EXCHANGE_NAME, "fanout");

            for (var i = 0; i < 2; i++) {
                String message = i % 3 == 0 ? "info: Hello World!" : "";
                channel.basicPublish(EXCHANGE_NAME, "", null, message.getBytes("UTF-8"));
                System.out.println("发送" + message + "");
            }

        }
    }

    /**
     * 测试方法
     *
     * @param argv
     * @throws Exception
     */
    public static void main(String[] argv) throws Exception {
        LogAndLogReceive logAndLogReceive = new LogAndLogReceive();
        logAndLogReceive.waitForLogReceive();
    }

    /**
     * 接收消息
     *
     * @throws IOException
     * @throws TimeoutException
     */
    public void waitForLogReceive() throws IOException, TimeoutException {

        ConnectionFactory factory = ConnectionFactoryBuilder.getFactory();
        Connection connection = factory.newConnection();
        Channel channel = connection.createChannel();

        channel.exchangeDeclare(EXCHANGE_NAME, "fanout");//定义交换器
        String queueName = channel.queueDeclare().getQueue();//主动声明一个服务器命名的独占，自动删除，非持久队列。 新队列的名称保存在AMQP.Queue.DeclareOk结果的“队列”字段中。
        channel.queueBind(queueName, EXCHANGE_NAME, "");//队列和交换器绑定

        System.out.println(this.workerName+"等待消息:");

        DeliverCallback deliverCallback = (consumerTag, delivery) -> {
            String message = new String(delivery.getBody(), "UTF-8");
            System.out.println(this.workerName+"获取消息:" + message+",consumerTag:"+consumerTag );
        };
        channel.basicConsume(queueName, true, deliverCallback, consumerTag -> { });//这里设置了自动确认
    }
}

```

#### 方法：void basicPublish(String exchange, String routingKey, boolean mandatory, boolean immediate, AMQP.BasicProperties props, byte[] body) throws IOException发布消息
发布到不存在的交换将导致通道级协议异常，从而关闭通道。 如果资源驱动的警报生效，Channel＃basicPublish的调用最终将被阻止。

* exchange  - 将消息发布到的交换
* routingKey  - 路由密钥
* mandatory  - 如果要设置'mandatory'标志，则为true
* immediate  - 如果要设置'immediate'标志，则为true。 请注意，RabbitMQ服务器不支持此标志。
* props  - 消息的其他属性 - 路由标题等
* body - 消息体

### 路由

* 绑定是交换和队列之间的关系。这可以简单地理解为：队列对来自此交换的消息感兴趣。

```
```

#### 方法：AMQP.Queue.BindOk queueBind(String queue, String exchange, String routingKey, Map<String,Object> arguments) throws IOException队列绑定交换器

* queue  - 队列的名称
* exchange  - 交换器的名称
* routingKey  - 用于绑定的路由密钥
* arguments  - 其他属性（绑定参数）

