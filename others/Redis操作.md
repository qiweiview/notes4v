# redis操作


### 连接远程redis服务器
```
redis-cli -h 106.12.111.159 -p 6379 -a qwqwqwererer
```
### 搜索键

```
keys auth*
```

### 获取键类型
```
type client_id_to_access:auth
```

## 发布与订阅

### 订阅
```
SUBSCRIBE sub //订阅sub队列
```

### 模糊订阅
```
Psubscribe my*//订阅所有my开头的队列
```

### 发布
```
PUBLISH sub "hello world"//向sub队列推送消息
```

### 查看当前存在队列
```
PUBSUB CHANNELS
```

