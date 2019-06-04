# redis操作

## 键值基本操作

### 连接远程redis服务器
```
redis-cli -h 106.12.111.159 -p 6379 -a qwqwqwererer
```

### 切换库
```
SELECT 0
```

### 移动键到其他库
```
move key 1
```

### 搜索键
```
keys auth*
```

### 删除键
```
del key
```

### 序列化值
```
dump key
```

### 判断存在
```
exists key
```

### 使用键过期(单位秒)
```
expire key 5
```

### 使用键过期在固定时间戳(单位秒)
```
expireat key 1559612959
```

### 使用键过期(单位毫秒)
```
pexpire key 5000
```

### 使用键过期在固定时间戳(单位毫秒)
```
pexpireat key 1559612959000
```

### 获取剩余过期时间（毫秒）
```
pttl key
```

### 获取剩余过期时间（秒）
```
ttl key
```

### 删除键的过期
```
persist key
```



### 随机获取一个key
```
randomkey
```

### 重命名键(会覆盖)
```
rename key new_key
```


覆盖例子
```
set view 123
set hello 666
rename hello view
get view //666
```

### 重命名(不覆盖)
```
renamenx
```
操作失败返回0，操作成功返回1

### 获取键类型
```
type client_id_to_access:auth
```

## 字符串基本操作

### 设置值(会覆盖)
```
set key value
```

### key不存在时设置 key 的值(不会覆盖)
```
setnx key value
```
key值存在设置失败返回0，设置成功返回1


### 设置key值并将 key 的过期时间设为 seconds (以秒为单位)。
```
setex key second value
```

### 设置key值并将 key 的过期时间设为 milliseconds (以毫秒为单位)。
```
psetex key milliseconds value
```

### 从偏移量开始设置key的值
```
setrange key offset value
```

示例
```
set long '123456789'
setrange long 6 view
get long //123456view
```

### 获取存储数据长度
```
strlen key
```

### 设置多对数据
```
mset  key1 value1  key2 value2  key3 value3
```

### 同时设置一个或多个 key-value 对，当且仅当所有给定 key 都不存在
```
msetnx key1 value1  key2 value2  key3 value3
```

只要有一个key是重复的就设置失败返回0

### 获取值
```
get key
```

### 获取值的固定长度
```
getrange key start end
```

### 设置值并返回旧值
```
getset key value
```

设置一个没有设置过的值返回的（旧值）是nil

### 对储存的字符串值，设置或清除指定偏移量上的位(bit)。（这个不是很理解作用）
```
setbit key offset value
```

### 对 key 所储存的字符串值，获取指定偏移量上的位(bit) （这个不是很理解作用）
```
getbit key offset
```

### 获取多个值
```
mget key1 key2 key3
```

### key值自增1
```
incr key
```
* 返回自增后的数字
* 对于非integer报"ERR value is not an integer or of range"

### key值自增固定数increment
```
incrby key increment
```
* 返回自增后的数字
* 对于非integer报"ERR value is not an integer or of range"

### key值自增固定浮点数increment
```
incrbyfloat key increment
```
* 返回自增后的数字
* 对于字符串会报"ERR value is not an integer or of range"



### key值自减1
```
decr key
```
* 返回自减后的数字
* 对于非integer报"ERR value is not an integer or of range"

### key值自减固定数increment
```
decrby key increment
```
* 返回自减后的数字
* 对于非integer报"ERR value is not an integer or of range"


### 数值末尾追加content
```
append key content
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

