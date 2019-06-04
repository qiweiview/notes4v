## redis键值基本操作

### 1. 连接远程redis服务器
```
redis-cli -h 106.12.111.159 -p 6379 -a qwqwqwererer
```

### 2. 切换库
```
SELECT 0
```

### 3. 移动键到其他库
```
move key 1
```

### 4. 搜索键
```
keys auth*
```

### 5. 删除键
```
del key
```

### 6. 序列化值
```
dump key
```

### 7. 判断存在
```
exists key
```

### 8. 使用键过期(单位秒)
```
expire key 5
```

### 9. 使用键过期在固定时间戳(单位秒)
```
expireat key 1559612959
```

### 10. 使用键过期(单位毫秒)
```
pexpire key 5000
```

### 11. 使用键过期在固定时间戳(单位毫秒)
```
pexpireat key 1559612959000
```

### 12. 获取剩余过期时间（毫秒）
```
pttl key
```

### 13. 获取剩余过期时间（秒）
```
ttl key
```

### 14. 删除键的过期
```
persist key
```



### 15. 随机获取一个key
```
randomkey
```

### 16. 重命名键(会覆盖)
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

### 17. 重命名(不覆盖)
```
renamenx
```
操作失败返回0，操作成功返回1

### 18. 获取键类型
```
type client_id_to_access:auth
```

### 19. 遍历数据
```
scan  cursor match count
```

* cursor 每次被调用之后， 都会向用户返回一个新的游标， 用户在下次迭代时需要使用这个新游标作为 HSCAN 命令的游标参数
（当cursor被设置为0， 服务器将开始一次新的迭代， 而当服务器向用户返回值为0的游标时， 表示迭代已结束）

* count 让用户告知迭代命令， 在每次迭代中应该从数据集里返回多少元素(10)

*　match 让命令只返回和给定模式相匹配的元素

## 字符串基本操作

### 1. 设置值(会覆盖)
```
set key value
```

### 2. key不存在时设置 key 的值(不会覆盖)
```
setnx key value
```
key值存在设置失败返回0，设置成功返回1


### 3. 设置key值并将 key 的过期时间设为 seconds (以秒为单位)。
```
setex key second value
```

### 4. 设置key值并将 key 的过期时间设为 milliseconds (以毫秒为单位)。
```
psetex key milliseconds value
```

### 5. 从偏移量开始设置key的值
```
setrange key offset value
```

示例
```
set long '123456789'
setrange long 6 view
get long //123456view
```

### 6. 获取存储数据长度
```
strlen key
```

### 7. 设置多对数据
```
mset  key1 value1  key2 value2  key3 value3
```

### 8. 同时设置一个或多个 key-value 对，当且仅当所有给定 key 都不存在
```
msetnx key1 value1  key2 value2  key3 value3
```

只要有一个key是重复的就设置失败返回0

### 9. 获取值
```
get key
```

### 10. 获取值的固定长度
```
getrange key start end
```

### 11. 设置值并返回旧值
```
getset key value
```

设置一个没有设置过的值返回的（旧值）是nil

### 12. 对储存的字符串值，设置或清除指定偏移量上的位(bit)。（这个不是很理解作用）
```
setbit key offset value
```

### 13. 对 key 所储存的字符串值，获取指定偏移量上的位(bit) （这个不是很理解作用）
```
getbit key offset
```

### 14. 获取多个值
```
mget key1 key2 key3
```

### 15. key值自增1
```
incr key
```
* 返回自增后的数字
* 对于非integer报"ERR value is not an integer or of range"

### 16. key值自增固定数increment
```
incrby key increment
```
* 返回自增后的数字
* 对于非integer报"ERR value is not an integer or of range"

### 17. key值自增固定浮点数increment（可以接收小数和整数）
```
incrbyfloat key increment
```
* 返回自增后的数字
* 对于字符串会报"ERR value is not an integer or of range"



### 18. key值自减1
```
decr key
```
* 返回自减后的数字
* 对于非integer报"ERR value is not an integer or of range"

### 19. key值自减固定数increment
```
decrby key increment
```
* 返回自减后的数字
* 对于非integer报"ERR value is not an integer or of range"


### 20. 数值末尾追加content
```
append key content
```

## redis哈希基本操作
* Redis hash 是一个string类型的field和value的映射表，hash特别适合用于存储对象。
* Redis 中每个 hash 可以存储 232 - 1 键值对（40多亿）

### 1. 将哈希表key字段 field 的值设为 value
```
hset key filed value
```

### 2. 为哈希表key 设置多个属性对
```
hmset key filed1 value1 filed2 value2 filed3 value3 filed4 value4
```

### 3. 当属性file不存在的时候才设置为value
```
hsetnx key field value 
```

设置失败返回0，成功返回1

### 4. 使哈希表key的filed属性增加increment
```
hincrby key field increment 
````

### 5. 使哈希表key的filed属性增加浮点数increment（可以接收小数和整数）
```
hincrbyfloat key field increment 
```

### 6. 删除哈希表key的属性filed
```
hdel key field1 
```


### 7. 获取哈希表key中的所有file对应的value值
```
hvals key
```

### 8. 查看哈希表key中指定属性file是否存在
```
hexists key file
```

存在返回1，不存在返回0

### 9. 获取哈希表key中的属性file的值
```
hget key file
```

### 10. 获取哈希表key中的多个file值
```
hmget key file1 file2 file3
```


### 11. 获取哈希表key中所有的属性file和值value
```
hgetall key
```

### 12. 获取哈希表key中的所有属性file
```
hkeys key
```

### 13. 获取哈希表key的字段数量
```
hlen key
```

### 14. 遍历哈希表key
```
hscan key cursor match count
```

* cursor 每次被调用之后， 都会向用户返回一个新的游标， 用户在下次迭代时需要使用这个新游标作为 HSCAN 命令的游标参数
（当cursor被设置为0， 服务器将开始一次新的迭代， 而当服务器向用户返回值为0的游标时， 表示迭代已结束）

* count 让用户告知迭代命令， 在每次迭代中应该从数据集里返回多少元素(10)

*　match 让命令只返回和给定模式相匹配的元素




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

