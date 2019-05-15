## 转换器
1. direct（key-value,数值要完全对上）
2. topic（主题模式 必须是由点分隔的单词列表，如stock.usd.nyse，路由密钥中可以包含任意数量的单词，最多可达255个字节）
3. headers （用的少）
4. fanout （发布与订阅）

使用默认交换器
```
channel.basicPublish("", "hello", null, message.getBytes());
```

spring 队列申明
```
 public Queue(String name, boolean durable, boolean exclusive, boolean autoDelete, Map<String, Object> arguments) {
        Assert.notNull(name, "'name' cannot be null");
        this.name = name;
        this.actualName = StringUtils.hasText(name) ? name : Base64UrlNamingStrategy.DEFAULT.generateName() + "_awaiting_declaration";
        this.durable = durable;
        this.exclusive = exclusive;
        this.autoDelete = autoDelete;
        this.arguments = (Map)(arguments != null ? arguments : new HashMap());
    }
```