# Redis教程

## 协议
[参考材料](http://redisdoc.com/topic/protocol.html)

* 客户端和服务器发送的命令或数据一律以 \r\n （CRLF）结尾

### 请求报文
* CRLF是\r\n,十六进制中的 0x 0D0A 


```
* <参数数量> CR LF
$ <参数 1 的字节数量> CR LF
  <参数 1 的数据> CR LF
...
...

$ <参数 N 的字节数量> CR LF
  <参数 N 的数据> CR LF
```
* 例如 set mykey myvalue 的报文
```
"*3\r\n$3\r\nSET\r\n$5\r\nmykey\r\n$7\r\nmyvalue\r\n"

*3   // 3 参数
$3   // 第一个参数，占3字节
SET
$5   // 第二个参数，占5字节
mykey
$7   // 第三个参数，占7字节
myvalue
```

### 回复报文

* 通过检查服务器发回数据的第一个字节， 可以确定这个回复是什么类型：

#### 状态回复（status reply）的第一个字节是 "+"
* 以 "+" 开始、 "\r\n" 结尾的单行字符串

#### 错误回复（error reply）的第一个字节是 "-"
*  错误回复的第一个字节是 "-",错误回复只在某些地方出现问题时发送： 比如说， 当用户对不正确的数据类型执行命令， 或者执行一个不存在的命令
* 一个客户端库应该在收到错误回复时产生一个异常
* 在 "-" 之后，直到遇到第一个空格或新行为止，这中间的内容表示所返回错误的类型

#### 整数回复（integer reply）的第一个字节是 ":"
* 以 ":" 开头， CRLF 结尾的字符串表示的整数
* 整数回复也被广泛地用于表示逻辑真和逻辑假： 比如 EXISTS key 和 SISMEMBER key member 都用返回值 1 表示真， 0 表示假。
* 其他一些命令， 比如 SADD key member [member …] 、 SREM key member [member …] 和 SETNX key value ， 只在操作真正被执行了的时候， 才返回 1 ， 否则返回 0 

#### 批量回复（bulk reply）的第一个字节是 "$"
* 服务器使用批量回复来返回二进制安全的字符串，字符串的最大长度为 512 MB
```
第一字节为 "$" 符号

接下来跟着的是表示实际回复长度的数字值

之后跟着一个 CRLF

再后面跟着的是实际回复数据

最末尾是另一个 CRLF
```

#### 多条批量回复（multi bulk reply）的第一个字节是 "*"
* 多条批量回复的第一个字节为 "*" ， 后跟一个字符串表示的整数值， 这个值记录了多条批量回复所包含的回复数量， 再后面是一个 CRLF
```
服务器： *4
服务器： $3
服务器： foo
服务器： $3
服务器： bar
服务器： $5
服务器： Hello
服务器： $5
服务器： World
```


## 客户端
* jedis: apid和原生近乎相同，但存在线程安全问题
```
        <dependency>
            <groupId>redis.clients</groupId>
            <artifactId>jedis</artifactId>
            <version>3.3.0</version>
        </dependency>

```

* 订阅广播
```
        new Thread(()->{
            Jedis jedis2 = new Jedis("localhost",6379);
            jedis2.auth("123456");
            while (true){
                jedis2.publish("c_1","广播");
            }
        }).start();
        
        Jedis jedis = new Jedis("localhost",6379);
        jedis.auth("123456");
        jedis.subscribe(new MyJedisPubSub(),"c_1");

```

* 列表操作
```
        String key="l_1";
        jedis.rpush(key, UUID.randomUUID().toString());
        List<String> l_1 = jedis.lrange(key, 0, 5);
```

* 哈希操作
```
  Jedis jedis = new Jedis("localhost",6379);
        jedis.auth("123456");
        String key="name_set";
        Map<String,String> map=new HashMap<>();
        map.put("lily", "60");
        map.put("brush", "77");
        jedis.hset(key,map); //低版本不支持多参数
        
        Long view = jedis.hset(key, "view", "88");
        
        jedis.hincrBy(key,"lily",5);//自增
```

* 分布式锁
```
        for (int i = 0; i < 50; i++) {
            final int z=i;
            new Thread(() -> {
                Jedis jedis = new Jedis("localhost", 6379);
                jedis.auth("123456");

                String key = "name_set";

                Long clock = jedis.setnx(key, "clock_"+z);
                System.out.println(clock);

            }).start();
        }

```

### 验证密码是否正确
```
auth password
```

### 异步执行一个 AOF（AppendOnly File） 文件重写操作
``` 
bgrewriteaof
```
* 重写会创建一个当前 AOF 文件的体积优化版本。
* 即使 Bgrewriteaof 执行失败，也不会有任何数据丢失，因为旧的 AOF 文件在 Bgrewriteaof 成功之前不会被修改

### 在后台异步保存当前数据库的数据到磁盘
```
bgsave
```
*命令执行之后立即返回 OK ，然后 Redis fork 出一个新子进程，原来的 Redis 进程(父进程)继续处理客户端请求，而子进程则负责将数据保存到磁盘，然后退出。


### 返回所有连接到服务器的客户端信息和统计数据
```
client list
```

#### 域的含义：
addr ： 客户端的地址和端口
fd ： 套接字所使用的文件描述符
age ： 以秒计算的已连接时长
idle ： 以秒计算的空闲时长
flags ： 客户端 flag
db ： 该客户端正在使用的数据库 ID
sub ： 已订阅频道的数量
psub ： 已订阅模式的数量
multi ： 在事务中被执行的命令数量
qbuf ： 查询缓冲区的长度（字节为单位， 0 表示没有分配查询缓冲区）
qbuf-free ： 查询缓冲区剩余空间的长度（字节为单位， 0 表示没有剩余空间）
obl ： 输出缓冲区的长度（字节为单位， 0 表示没有分配输出缓冲区）
oll ： 输出列表包含的对象数量（当输出缓冲区没有剩余空间时，命令回复会以字符串对象的形式被入队到这个队列里）
omem ： 输出缓冲区和输出列表占用的内存总量
events ： 文件描述符事件
cmd ： 最近一次执行的命令

#### 客户端 flag 可以由以下部分组成：
O ： 客户端是 MONITOR 模式下的附属节点（slave）
S ： 客户端是一般模式下（normal）的附属节点
M ： 客户端是主节点（master）
x ： 客户端正在执行事务
b ： 客户端正在等待阻塞事件
i ： 客户端正在等待 VM I/O 操作（已废弃）
d ： 一个受监视（watched）的键已被修改， EXEC 命令将失败
c : 在将回复完整地写出之后，关闭链接
u : 客户端未被阻塞（unblocked）
A : 尽可能快地关闭连接
N : 未设置任何 flag

#### 文件描述符事件可以是：
r : 客户端套接字（在事件 loop 中）是可读的（readable）
w : 客户端套接字（在事件 loop 中）是可写的（writeable）


### 返回当前服务器时间
```
time
```

* 第一个字符串是当前时间(以 UNIX 时间戳格式表示)，
* 第二个字符串是当前这一秒钟已经逝去的微秒数

### 删除所有数据库的所有key
```
flushall
```

### 删除当前数据库的所有key
```
flushdb
```

### 返回主从实例所属的角色
```
role
```

### 同步保存数据到硬盘
```
save
```


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



### 15. 随机获取一个已存在的key
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
set long '12345678'
setrange long 2 view
get long //12view78
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

### 10. 获取key存储的值的固定长度（从start到end）
```
getrange key start end
```

### 11. 将key的值设置成新值并返回旧值
```
getset key value
```

设置一个没有设置过的值返回的（旧值）是nil

### 12. 对储存的字符串值，设置或清除指定偏移量上的位(bit)
```
setbit key offset value
```
* 在redis中，存储的字符串都是以二级制的进行存在的
* 'a' 的ASCII码是  97二进制是：01100001
* offset的学名叫"偏移" 二进制中的每一位就是offset值啦（offset 0 等于0，offset 1等于1） 

### 13. 对 key 所储存的字符串值，获取指定偏移量上的位(bit)
```
getbit key offset
```

* 在redis中，存储的字符串都是以二级制的进行存在的
* 'a' 的ASCII码是  97二进制是：01100001
* offset的学名叫"偏移" 二进制中的每一位就是offset值啦（offset 0 等于0，offset 1等于1） 

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

### 16. key值自增固定数increment（可以通过负数实现减法）
```
incrby key increment
```
* 返回自增后的数字
* 对于非integer报"ERR value is not an integer or of range"

### 17. key值自增固定浮点数increment（可以接收小数和整数）（可以通过负数实现减法）
```
incrbyfloat key increment
```
* 返回自增后的数字
* 对于字符串会报"ERR value is not an integer or of range"



### 18. key值自减1（可以通过负数实现加法）
```
decr key
```
* 返回自减后的数字
* 对于非integer报"ERR value is not an integer or of range"

### 19. key值自减固定数increment（可以通过负数实现加法）（可以通过负数实现加法）
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

### 12. 获取哈希表key中的所有属性file的名字
```
hkeys key
```

### 13. 获取哈希表key的字段file数量
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

示例
```
redis> RPUSH mylist "Hello"
(integer) 1
redis> RPUSH mylist "World"
(integer) 2
redis> LINSERT mylist BEFORE "World" "There"
(integer) 3
redis> LRANGE mylist 0 -1
1) "Hello"
2) "There"
3) "World"
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

### 1.向集合中添加一个或多个value
```
sadd key value1 value2 value3 value4
```

### 2.获取集合key的数据数
```
scard key
```

### 3.获得多个集合的差集（不知道应用场景）
```
sdiff key1 key2 key3
```
结果来自于第一个集合，第一个集合去掉后面集合出现过的元素

### 4.获得多个集合的差集并存储在daveKey中（会覆盖已存在的同名集合）
```
sdiffstore daveKey key1 key2 key3
```


### 5.获得多个集合的交集
```
sinter key1 key2 key3
```

### 6.获得多个集合的交集并存储在daveKey中（会覆盖已存在的同名集合）
```
sinterstore daveKey key1 key2 key3
```

### 7.判断一个元素value是否是一个集合key的成员
```
sismember key value
```

### 8.返回集合key中的所有成员
```
smembers key
```

### 9.将指定成员 value 元素从 source 集合移动到 destination 集合
```
smove source destination value
```
* SMOVE 是原子性操作。
* 如果 source 集合不存在或不包含指定的 member 元素，则 SMOVE 命令不执行任何操作，仅返回 0 
* 否则， member 元素从 source 集合中被移除，并添加到 destination 集合中去。
* 当 destination 集合已经包含 member 元素时， SMOVE 命令只是简单地将 source 集合中的 member 元素删除。
* 当 source 或 destination 不是集合类型时，返回一个错误

### 10.移除并返回集合中的指定 key 的一个或多个随机元素
```
spop key count
```
count 参数在 3.2+ 版本可用。

### 11.返回集合中的指定 key 的一个或多个随机元素
```
srandmenber key count
```
* 如果 count 为正数，且小于集合基数，那么命令返回一个包含 count 个元素的数组，数组中的元素各不相同。
* 如果 count 大于等于集合基数，那么返回整个集合。
* 如果 count 为负数，那么命令返回一个数组，数组中的元素可能会重复出现多次，而数组的长度为 count 的绝对值。

### 12.移除集合key中一个或多个成员
```
srem key value1 valu2 value3
```
不存在的成员元素会被忽略

### 13.获得多个集合的并集
```
sunion key1 key2 key3
```

### 14.获得多个集合的并集并存储在daveKey中（会覆盖已存在的同名集合）
```
sunionstore daveKey key1 key2 key3
```

### 15.迭代集合中的元素
```
sscan key cursor mathch count
```
* cursor 每次被调用之后， 都会向用户返回一个新的游标， 用户在下次迭代时需要使用这个新游标作为 HSCAN 命令的游标参数
（当cursor被设置为0， 服务器将开始一次新的迭代， 而当服务器向用户返回值为0的游标时， 表示迭代已结束）

* count 让用户告知迭代命令， 在每次迭代中应该从数据集里返回多少元素(10)

*　match 让命令只返回和给定模式相匹配的元素


## redis有序集合
* Redis 有序集合和集合一样也是string类型元素的集合,且不允许重复的成员。
* 不同的是每个元素都会关联一个double类型的分数。redis正是通过分数来为集合中的成员进行从小到大的排序。
* 有序集合的成员是唯一的,但分数(score)却可以重复。
* 集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是O(1)。 集合中最大的成员数为 232 - 1 (4294967295, 每个集合可存储40多亿个成员)。

### 1. 将一个或多个成员元素及其分数值加入到有序集当中
```
zadd key scope1 value1 scope2 value2 scope3 value3
```
* 如果某个成员已经是有序集的成员，那么更新这个成员的分数值，并通过重新插入这个成员元素，来保证该成员在正确的位置上。
* 分数值可以是整数值或双精度浮点数。
* 如果有序集合 key 不存在，则创建一个空的有序集并执行 ZADD 操作。
* 当 key 存在但不是有序集类型时，返回一个错误。

### 2. 获取有序集合key的成员数
```
zcard key
```

### 3. 计算在有序集合中指定区间分数的成员数(区间为scope的值)
```
zcount min max
```

### 4. 有序集合中对指定成员的分数scope加上增量 increment
```
zincrby key  scope value
```
* 可以通过传递一个负数值 increment ，让分数减去相应的值(比如 ZINCRBY key -5 member ，就是让 member 的 score 值减去 5 )
* 当 key 不存在，或分数不是 key 的成员时， ZINCRBY key increment member 等同于 ZADD key increment member 。
* 当 key 不是有序集类型时，返回一个错误。
* scope值可以是整数值或双精度浮点数。

### 5. 计算给定的一个或多个有序集的交集并将结果集存储在新的有序集合nz中
```
zinterstore  nz numkeys   z1 z2 z3
ZINTERSTORE sum_point 2 mid_test fin_test
```
* 其中给定z的数量必须以numkeys(上面有z1 z2 z3那么numkeys为3)参数指定
* 默认情况下，结果集中某个成员的分数值是所有给定集下该成员分数值之和。

### 6. 计算有序集合中指定字典区间内成员数量
```
zlexcount key start end
```
示例
```
redis 127.0.0.1:6379> ZADD myzset 0 a 0 b 0 c 0 d 0 e
(integer) 5
redis 127.0.0.1:6379> ZADD myzset 0 f 0 g
(integer) 2
redis 127.0.0.1:6379> ZLEXCOUNT myzset - +
(integer) 7
redis 127.0.0.1:6379> ZLEXCOUNT myzset [b [f
(integer) 5
```

### 7. 通过索引区间返回有序集合成指定区间内的成员，指定索引区间从start到end范围内成员
```
zrange key start end
```
* 其中成员的位置按分数值递增(从小到大)来排序。
* 具有相同分数值的成员按字典序(lexicographical order )来排列。

示例
```
redis 127.0.0.1:6379> ZRANGE salary 0 -1              # 显示整个有序集成员
1) "jack"
2) "3500"
3) "tom"
4) "5000"
5) "boss"
6) "10086"

redis 127.0.0.1:6379> ZRANGE salary 1 2               # 显示有序集下标区间 1 至 2 的成员
1) "tom"
2) "5000"
3) "boss"
4) "10086"

redis 127.0.0.1:6379> ZRANGE salary 0 200000          # 测试 end 下标超出最大下标时的情况
1) "jack"
2) "3500"
3) "tom"
4) "5000"
5) "boss"
6) "10086"

redis > ZRANGE salary 200000 3000000                   # 测试当给定区间不存在于有序集时的情况
(empty list or set)
```


### 8. 返回有序集中指定区间内的成员，通过索引，分数从高到底
```
zrevrange key start end
```

### 9. 通过字典区间返回有序集合的成员，指定字典区间从start到end范围内成员
```
zrangebylex key start end
```

范例
```
redis 127.0.0.1:6379> ZADD myzset 0 a 0 b 0 c 0 d 0 e 0 f 0 g
(integer) 7
redis 127.0.0.1:6379> ZRANGEBYLEX myzset - [c
1) "a"
2) "b"
3) "c"
redis 127.0.0.1:6379> ZRANGEBYLEX myzset - (c
1) "a"
2) "b"
redis 127.0.0.1:6379> ZRANGEBYLEX myzset [aaa (g
1) "b"
2) "c"
3) "d"
4) "e"
5) "f"
```

### 10. 通过分数scope区间返回有序集合的成员，指定分数区间从start到end范围内成员
```
zrangebyscore key start end
```

### 11. 返回有序集中指定分数区间内的成员，分数从高到低排序
```
zrevrangebuscore  key start end
```


### 12. 返回有序集合中指定成员的索引
```
zrank key value
```

### 13. 返回有序集合中指定成员的索引，有序集成员按分数值递减(从大到小)排序
```
zrevrank key value
```

### 14. 移除有序集合中的一个或多个成员
```
zrem key value1 value2 value3
```

### 15. 移除有序集合key中给定的字典区间的所有成员
```
zremrangebylex key start end
```

示例
```
redis 127.0.0.1:6379> ZADD myzset 0 foo 0 zap 0 zip 0 ALPHA 0 alpha
(integer) 5
redis 127.0.0.1:6379> ZRANGE myzset 0 -1
1) "ALPHA"
 2) "aaaa"
 3) "alpha"
 4) "b"
 5) "c"
 6) "d"
 7) "e"
 8) "foo"
 9) "zap"
10) "zip"
redis 127.0.0.1:6379> ZREMRANGEBYLEX myzset [alpha [omega
(integer) 6
```

### 16. 移除有序集合中给定的排名区间(下标索引)的所有成员
```
zremrangeburank key start end
```

### 17. 移除有序集合中给定的分数区间的所有成员
```
zremrangebuscore key start end
```

### 18. 返回有序集中，成员的分数值
```
zscore key value
```

### 19. 计算给定的一个或多个有序集的并集，并存储在新的 key 中
```
zunionstore nzu numkeys key1 key2 key3
```

### 20. 迭代有序集合中的元素（包括元素成员和元素分值）
```
zscan key cursor match count
```

## HyperLogLog基础命令

### 1. 添加指定元素到 HyperLogLog 中
```
pfadd key value1 value2 value3
```

### 2. 返回给定 HyperLogLog 的基数估算值(不是很理解用法)
```
pfcount key1 key2
```

### 3.将多个 HyperLogLog 合并为一个 HyperLogLog
```
pfmerge nh  key1 key2 key3
```
* 将多个 HyperLogLog 合并为一个 HyperLogLog ，合并后的 HyperLogLog 的基数估算值是通过对所有 给定 HyperLogLog 进行并集计算得出的。




## Redis 发布订阅

### 1. 订阅一个或多个符合给定模式的频道
```
psubscribe channel1 channel2 channel3
```
每个模式以 * 作为匹配符
* it* 匹配所有以 it 开头的频道( it.news 、 it.blog 、 it.tweets 等等)
* news.* 匹配所有以 news. 开头的频道( news.it 、 news.global.today 等等)

### 2. 订阅给定的一个或多个频道的信息
```
subscribe channel1 channel2 channel3
```

### 3. 将信息发送到指定的频道(只能发一个)
```
publish channel message
```

### 4. 退订所有给定模式的频道。(不知道怎么尝试)
```
punsubsribe channel1
```

每个模式以 * 作为匹配符
* it* 匹配所有以 it 开头的频道( it.news 、 it.blog 、 it.tweets 等等)
* news.* 匹配所有以 news. 开头的频道( news.it 、 news.global.today 等等)

### 5. 指退订给定的频道。(不知道怎么尝试)
```
unsubsribe channel1
```

### 6. 查看订阅与发布系统状态。(不懂这个使用)
```
pubsub channel
```


## 事物
* DISCARD取消事物
* 以 MULTI 开始一个事务， 然后将多个命令入队到事务中， 最后由 EXEC 命令触发事务， 一并执行事务中的所有命令

示例
```
redis 127.0.0.1:6379> MULTI
OK

redis 127.0.0.1:6379> SET book-name "Mastering C++ in 21 days"
QUEUED

redis 127.0.0.1:6379> GET book-name
QUEUED

redis 127.0.0.1:6379> SADD tag "C++" "Programming" "Mastering Series"
QUEUED

redis 127.0.0.1:6379> SMEMBERS tag
QUEUED

redis 127.0.0.1:6379> EXEC
1) OK
2) "Mastering C++ in 21 days"
3) (integer) 3
4) 1) "Mastering Series"
   2) "C++"
   3) "Programming"
```

* 单个 Redis 命令的执行是原子性的，但 Redis 没有在事务上增加任何维持原子性的机制，所以 Redis 事务的执行并不是原子性的。
* 事务可以理解为一个打包的批量执行脚本，但批量指令并非原子化的操作，中间某条指令的失败不会导致前面已做指令的回滚，也不会造成后续的指令不做。

示例
```
redis 127.0.0.1:7000> multi
OK
redis 127.0.0.1:7000> set a aaa
QUEUED
redis 127.0.0.1:7000> set b bbb
QUEUED
redis 127.0.0.1:7000> set c ccc
QUEUED
redis 127.0.0.1:7000> exec
1) OK
2) OK
3) OK
如果在 set b bbb 处失败，set a 已成功不会回滚，set c 还会继续执行。
```

### 监视一个(或多个) key ，如果在事务执行之前这个(或这些) key 被其他命令所改动，那么事务将被打断。
```
watch key1 key2 key3
```

### 取消 WATCH 命令对所有 key 的监视。
```
unwatch key1 key2
```
