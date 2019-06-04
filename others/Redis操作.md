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

## redis列表基本操作

* Redis列表是简单的字符串列表，按照插入顺序排序。你可以添加一个元素到列表的头部（左边）或者尾部（右边）

* 一个列表最多可以包含 232 - 1 个元素 (4294967295, 每个列表超过40亿个元素)。

### 1. 向列表key尾部插入一个或多个数据,若列表不存在则会创建后再插入
```
rpush key value1 value2 value3
```

### 2. 向列表key头部插入一个或多个数据,若列表不存在则会创建后再插入
```
lpush key value1 value2 value3
```

### 3. 向列表key尾部插入一个数据(没有多个),若列表不存在则返回0
```
rpushx key value
```
### 4. 向列表key头部插入一个数据(没有多个),若列表不存在则返回0
```
lpushx key value
```

### 5. 在列表key的pivot元素前或者后插入元素value
```
linsert key before/after pivot value
```

### 6. 通过索引（下标）设置列表元素的值
```
lset key index value 
```

### 7. 通过索引（下标）获取列表中的元素
```
lindex key index
```

### 8. 根据参数count的值，移除列表key中与参数value相等的元素
```
lrem key count value 
```

* count > 0 : 从表头开始向表尾搜索，移除与value相等的元素，数量为count
* count < 0 : 从表尾开始向表头搜索，移除与value相等的元素，数量为count的绝对值。
* count = 0 : 移除表中所有与 VALUE 相等的值。

### 9. 获取列表key指定范围start到to内的元素
```
lrange key start end
```
 0表示列表的第一个元素1表示列表的第二个元素，以此类推
 -1表示列表的最后一个元素-2 表示列表的倒数第二个元素，以此类推

### 10. 获取列表长度
```
llen key
```

### 11. 移除并获取列表key第一个元素
```
lpop key 
```

### 12. 移除并获取列表key最后一个元素
```
rpop key 
```

### 13. 移出并获取列表的第一个元素， 如果列表没有元素会阻塞列表直到等待超时或发现可弹出元素为止(timeout单位为秒)
```
blpop key timeout 
```

### 14. 移出并获取列表的第一个元素， 如果列表没有元素会阻塞列表直到等待超时或发现可弹出元素为止(timeout单位为秒)
```
brpop key timeout 
```

### 15. 对一个列表进行修剪(trim)，就是说，让列表只保留指定区间start到end内的元素，不在指定区间之内的元素都将被删除。
```
ltrim key start end
```
 0 表示列表的第一个元素，以 1 表示列表的第二个元素，以此类推 
-1 表示列表的最后一个元素， -2 表示列表的倒数第二个元素，以此类推

### 16. 移除列表的key最后一个元素，并将该元素添加到另一个列表nkey的头并返回
```
rpoplpush key nkey
```

### 17. 移除列表的key最后一个元素，并将该元素添加到另一个列表nkey的头并返回, 如果列表没有元素会阻塞列表直到等待超时或发现可弹出元素为止(timeout单位为秒)
```
brpoplpush key nkey second
```
## redis集合基本操作

* Redis 的 Set 是 String 类型的无序集合。集合成员是唯一的，这就意味着集合中不能出现重复的数据。
* Redis 中集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是 O(1)。

### 向集合中添加一个或多个value
```
sadd key value1 value2 value3 value4
```

### 获取集合key的数据数
```
scard key
```

### 获得多个集合的差集（不知道应用场景）
```
sdiff key1 key2 key3
```
结果来自于第一个集合，第一个集合去掉后面集合出现过的元素

### 获得多个集合的差集并存储在daveKey中（会覆盖已存在的同名集合）
```
sdiffstore daveKey key1 key2 key3
```


### 获得多个集合的交集
```
sinter key1 key2 key3
```

### 获得多个集合的交集并存储在daveKey中（会覆盖已存在的同名集合）
```
sinterstore daveKey key1 key2 key3
```

### 判断一个元素value是否是一个集合key的成员
```
sismember key value
```

### 返回集合key中的所有成员
```
smembers key
```

### 将指定成员 value 元素从 source 集合移动到 destination 集合
```
smove source destination value
```
* SMOVE 是原子性操作。
* 如果 source 集合不存在或不包含指定的 member 元素，则 SMOVE 命令不执行任何操作，仅返回 0 
* 否则， member 元素从 source 集合中被移除，并添加到 destination 集合中去。
* 当 destination 集合已经包含 member 元素时， SMOVE 命令只是简单地将 source 集合中的 member 元素删除。
* 当 source 或 destination 不是集合类型时，返回一个错误

### 移除并返回集合中的指定 key 的一个或多个随机元素
```
spop key count
```
count 参数在 3.2+ 版本可用。

### 返回集合中的指定 key 的一个或多个随机元素
```
srandmenber key count
```
* 如果 count 为正数，且小于集合基数，那么命令返回一个包含 count 个元素的数组，数组中的元素各不相同。
* 如果 count 大于等于集合基数，那么返回整个集合。
* 如果 count 为负数，那么命令返回一个数组，数组中的元素可能会重复出现多次，而数组的长度为 count 的绝对值。

### 移除集合key中一个或多个成员
```
srem key value1 valu2 value3
```
不存在的成员元素会被忽略

### 获得多个集合的并集
```
sunion key1 key2 key3
```

### 获得多个集合的并集并存储在daveKey中（会覆盖已存在的同名集合）
```
sunionstore daveKey key1 key2 key3
```

### 迭代集合中的元素
```
sscan key cursor mathch count
```
## redis有序集合
* Redis 有序集合和集合一样也是string类型元素的集合,且不允许重复的成员。
* 不同的是每个元素都会关联一个double类型的分数。redis正是通过分数来为集合中的成员进行从小到大的排序。
* 有序集合的成员是唯一的,但分数(score)却可以重复。
* 集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是O(1)。 集合中最大的成员数为 232 - 1 (4294967295, 每个集合可存储40多亿个成员)。


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

