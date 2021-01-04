
# ZooKeeper教程

## 通信协议

### 请求报文





|length_head|xid|type|length_body|body|
| ------------- | ------------- | ------------- | ------------- | ------------- |
|4|4|4|4|n|

### 请求协议头
```
 class RequestHeader {
        int xid;//xid用于记录客户端请求发起的先后序号，用来确保单个客户端请求的响应顺序
        int type;//type代表请求的操作类型，如创建节点（OpCode.create）、删除节点（OpCode.delete）、获取节点数据（OpCode.getData）
    }
    
```

### 请求请求体
* 不同请求请求体不一样
* 类都在org.apache.zookeeper.proto包下


### 响应报文
|length_head|xid|xxid|err|length_body|
| ------------- | ------------- | ------------- | ------------- | ------------- |
|4|4|8|4|4|

### 响应头
```
 class ReplyHeader {
        int xid;
        long zxid; //zxid表示Zookeeper服务器上当前最新的事务ID
        int err; //err则是一个错误码，表示当请求处理过程出现异常情况时，就会在错误码中标识出来，常见的包括处理成功（Code.OK）、节点不存在（Code.NONODE）、没有权限（Code.NOAUTH）
    }
```

### 响应体
* 不同响应响应体不一样



## 添加监听器 3.6版本后特性
* ERSISTENT是不监听子孙节点
* PERSISTENT_RECURSIVE是递归监听子孙节点

```
        ZooKeeper zk = new ZooKeeper("127.0.0.1:2181", 2 * 1000, watcher);

        zk.addWatch(key,x->{
            Stat stat = new Stat();
            try {
                byte[] data = zk.getData(x.getPath(), false, stat);
                System.out.println(x.getPath()+"发生变化："+" 值变更为："+new String(data));
            } catch (KeeperException e) {
                e.printStackTrace();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }


        },AddWatchMode.PERSISTENT_RECURSIVE);

```



## ======================= 笔记分割线 ===========================

## 设置jmx监控
* 修改ZOOMAIN块
```
if [ "x$JMXDISABLE" = "x" ] || [ "$JMXDISABLE" = 'false' ]
then
  echo "ZooKeeper JMX enabled by default" >&2
  if [ "x$JMXPORT" = "x" ]
  then
    # for some reason these two options are necessary on jdk6 on Ubuntu
    #   accord to the docs they are not necessary, but otw jconsole cannot
    #   do a local attach
    #ZOOMAIN="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.local.only=$JMXLOCALONLY org.apache.zookeeper.server.quorum.QuorumPeerMain"
    ZOOMAIN="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.local.only=false
    -Dcom.sun.management.jmxremote.port=8088
    -Dcom.sun.management.jmxremote.rmi.port=8088
    -Dcom.sun.management.jmxremote.authenticate=false
    -Dcom.sun.management.jmxremote.ssl=false
    -Djava.rmi.server.hostname=111.111.111.111
    org.apache.zookeeper.server.quorum.QuorumPeerMain"

```

## 启动
```
/bin/zkServer.sh start
```

## 依赖
官方jar包：zookeeper-3.5.4-beta.jar

## znode节点
### 有四种类型的znode：
* PERSISTENT-持久化目录节点
客户端与zookeeper断开连接后，该节点依旧存在
* PERSISTENT_SEQUENTIAL-持久化顺序编号目录节点
客户端与zookeeper断开连接后，该节点依旧存在，只是Zookeeper给该节点名称进行顺序编号，会追加数字后缀
* EPHEMERAL-临时目录节点
客户端与zookeeper断开连接后，该节点被删除，主节点是临时的话，就不能构建其子节点
* EPHEMERAL_SEQUENTIAL-临时顺序编号目录节点
客户端与zookeeper断开连接后，该节点被删除，只是Zookeeper给该节点名称进行顺序编号，会追加数字后缀
 
## ACL
每个znode被创建时都会带有一个ACL列表，用于决定谁可以对它执行何种操作。

## ZooKeeper Watcher 特性总结

* ***注册只能确保一次消费***
无论是服务端还是客户端，一旦一个 Watcher 被触发，ZooKeeper 都会将其从相应的存储中移除。因此，开发人员在 Watcher 的使用上要记住的一点是需要反复注册。这样的设计有效地减轻了服务端的压力。如果注册一个 Watcher 之后一直有效，那么针对那些更新非常频繁的节点，服务端会不断地向客户端发送事件通知，这无论对于网络还是服务端性能的影响都非常大。

* ***客户端串行执行***
客户端 Watcher 回调的过程是一个串行同步的过程，这为我们保证了顺序，同时，需要开发人员注意的一点是，千万不要因为一个 Watcher 的处理逻辑影响了整个客户端的 Watcher 回调。

* ***轻量级设计***
WatchedEvent 是 ZooKeeper 整个 Watcher 通知机制的最小通知单元，这个数据结构中只包含三部分的内容：通知状态、事件类型和节点路径。也就是说，Watcher 通知非常简单，只会告诉客户端发生了事件，而不会说明事件的具体内容。例如针对 NodeDataChanged 事件，ZooKeeper 的 Watcher 只会通知客户指定数据节点的数据内容发生了变更，而对于原始数据以及变更后的新数据都无法从这个事件中直接获取到，而是需要客户端主动重新去获取数据，这也是 ZooKeeper 的 Watcher 机制的一个非常重要的特性。


* 可以设置观察的操作：exists,getChildren,getData 

* 可以触发观察的操作：create,delete,setData




## 基本添加监控实例Demo
```
package com.test;

import org.apache.zookeeper.*;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.lang.management.ManagementFactory;
import java.util.List;

public class ZookeeperTest2 {

    private static String membershipRoot = "/Members";
    private ZooKeeper zk = null;


    /**
     * 创建客户端
     *
     * @return
     */
    private ZooKeeper baseClient() {
        if (zk != null) {
            return zk;
        }
        try {
            zk = new ZooKeeper("127.0.0.1:2181", 2 * 1000, (event) -> {
                System.out.println("创建客户端");
            });
            return zk;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    @Test
    public void getManager() {

        ZooKeeper zooKeeper = baseClient();
        getChildren(zooKeeper);
        checkValue(zooKeeper);
        while (true) {

        }
    }

    @Test
    public void addSonNodeClient() throws KeeperException, InterruptedException {
        ZooKeeper zooKeeper = baseClient();
        String name = ManagementFactory.getRuntimeMXBean().getName();
        String processId = name.substring(0, name.indexOf('@'));
        zooKeeper.create(membershipRoot + '/' + processId, processId.getBytes(), ZooDefs.Ids.OPEN_ACL_UNSAFE, CreateMode.EPHEMERAL);
        while (true) {

        }
    }


    public void getChildren(ZooKeeper zooKeeper) {
        try {
            List<String> children = zooKeeper.getChildren(membershipRoot, (event) -> {
                System.out.println("type:" + event.getType());
                if (event.getType() == Watcher.Event.EventType.NodeChildrenChanged) {
                    getChildren(zooKeeper);
                }

            });
            System.out.println("子节点:" + children);
        } catch (KeeperException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

    }

    public void checkValue(ZooKeeper zooKeeper) {
        try {
            byte[] data = zooKeeper.getData(membershipRoot, (event) -> {
                checkValue(zooKeeper);
            }, null);
            System.out.println("数值：" + new String(data));
        } catch (KeeperException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }


}

```

## 分布式锁Demo

* 使用EPHEMERAL会引出一个风险：在非正常情况下，网络延迟比较大会出现session timeout，zookeeper就会认为该client已关闭，从而销毁其id标示，竞争资源的下一个id就可以获取锁。这时可能会有两个process同时拿到锁在跑任务，所以设置好session timeout很重要。
* 同样使用PERSISTENT同样会存在一个死锁的风险，进程异常退出后，对应的竞争资源id一直没有删除，下一个id一直无法获取到锁对象。


```
package com.test;

import org.apache.zookeeper.CreateMode;
import org.apache.zookeeper.KeeperException;
import org.apache.zookeeper.ZooDefs;
import org.apache.zookeeper.ZooKeeper;
import org.junit.jupiter.api.Test;

import java.io.IOException;

public class ZookeeperTest3 {

    private static String clockPath = "/Clock";
    private static String clockSon = "/Clock/Son";
    private ZooKeeper zk = null;


    /**
     * 创建客户端
     *
     * @return
     */
    private synchronized ZooKeeper baseClient() {
        if (zk != null) {
            return zk;
        }
        try {
            zk = new ZooKeeper("127.0.0.1:2181", 2 * 1000, (event) -> {
                System.out.println("创建客户端");
            });
            return zk;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }


    /**
     * 注意创建的节点会自动加上编号
     * 分布式锁
     */
    @Test
    public void testClock() {
        for (var i = 0; i < 50; i++) {
            new Thread(() -> {
                ZooKeeper zooKeeper = baseClient();
                try {
                    zooKeeper.create(clockPath, clockPath.getBytes(), ZooDefs.Ids.OPEN_ACL_UNSAFE, CreateMode.PERSISTENT);
                    System.out.println(Thread.currentThread().getName() + "获取了锁");
                } catch (KeeperException e) {
                    System.err.println(Thread.currentThread().getName() + "没有获取锁");
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }).start();
        }
        while (true) {

        }
    }


    /**
     * 并发访问时序
     */
    @Test
    public void testOrder() {

        for (var i = 0; i < 50; i++) {
            new Thread(() -> {
                ZooKeeper zooKeeper = baseClient();
                String name = Thread.currentThread().getName();
                try {
                    zooKeeper.create(clockSon, name.getBytes(), ZooDefs.Ids.OPEN_ACL_UNSAFE, CreateMode.EPHEMERAL_SEQUENTIAL);
                } catch (KeeperException e) {
                    e.printStackTrace();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }).start();
        }

        while (true) {

        }
    }

}

```

## 集群

### 目录结构

```
/zookeeper

        |----zookeeper0/

        |----zookeeper1/

        |----zookeeper2/
```


* 新建目录data：/home/zzl/DataTool/zk34/zookeeper0/data

* 新建目录logs：/home/zzl/DataTool/zk34/zookeeper0/logs

* 新建文件myid：/home/zzl/DataTool/zk34/zookeeper0/data/myid

* myid文件的内容是节点在集群中的编号，zookeeper0节点的编号就写成0，后边的zookeeper1的编号是1，zookeeper2的编号就是2。


###配置文件
```xml
tickTime=2000
initLimit=10
syncLimit=5
dataDir=E:\\zookeeper\\zookeeper1\\data
dataLogDir=E:\\zookeeper\\zookeeper1\\log
clientPort=2181
server.1=localhost:2887:3887
server.2=localhost:2888:3888
server.3=localhost:2889:3889
```

```xml
tickTime=2000
initLimit=10
syncLimit=5
dataDir=E:\\zookeeper\\zookeeper2\\data
dataLogDir=E:\\zookeeper\\zookeeper2\\log
clientPort=2182
server.1=localhost:2887:3887
server.2=localhost:2888:3888
server.3=localhost:2889:3889
```

```xml
tickTime=2000
initLimit=10
syncLimit=5
dataDir=E:\\zookeeper\\zookeeper3\\data
dataLogDir=E:\\zookeeper\\zookeeper3\\log
clientPort=2183
server.1=localhost:2887:3887
server.2=localhost:2888:3888
server.3=localhost:2889:3889
```

## ACL

### 节点权限限制

核心代码
```
        List<ACL> acls = new ArrayList<>();  // 权限列表
        // 第一个参数是权限scheme，第二个参数是加密后的用户名和密码
        Id user1 = new Id("digest", getDigestUserPwd("user1:123456a"));
        Id user2 = new Id("digest", getDigestUserPwd("user2:123456b"));
        acls.add(new ACL(ZooDefs.Perms.ALL, user1));  // 给予所有权限
        acls.add(new ACL(ZooDefs.Perms.READ, user2));  // 只给予读权限
        acls.add(new ACL(ZooDefs.Perms.DELETE | ZooDefs.Perms.CREATE, user2));  // 多个权限的给予方式，使用 | 位运算符
        String result = zooKeeper.create("/testDigestNode", "test data".getBytes(), acls, CreateMode.PERSISTENT); 
```

完整实例
```
package com.test;

import org.apache.zookeeper.CreateMode;
import org.apache.zookeeper.KeeperException;
import org.apache.zookeeper.ZooDefs;
import org.apache.zookeeper.ZooKeeper;
import org.apache.zookeeper.data.ACL;
import org.apache.zookeeper.data.Id;
import org.apache.zookeeper.data.Stat;
import org.apache.zookeeper.server.auth.DigestAuthenticationProvider;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class ZookeeperTest4 {
    private ZooKeeper zk = null;


    /**
     * 创建客户端
     *
     * @return
     */
    private synchronized ZooKeeper baseClient() {
        if (zk != null) {
            return zk;
        }
        try {
            zk = new ZooKeeper("127.0.0.1:2182", 2 * 1000, (event) -> {
                System.out.println("创建客户端");
            });
            return zk;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }


    /**
     * 加密密码
     *
     * @param id
     * @return
     * @throws Exception
     */
    public String getDigestUserPwd(String id) {
        // 加密明文密码
        try {
            return DigestAuthenticationProvider.generateDigest(id);
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * ZooKeeper提供了如下几种验证模式（scheme）：
     * digest：Client端由用户名和密码验证，譬如user:password，digest的密码生成方式是Sha1摘要的base64形式
     * auth：不使用任何id，代表任何已确认用户。
     * ip：Client端由IP地址验证，譬如172.2.0.0/24
     * world：固定用户为anyone，为所有Client端开放权限
     * super：在这种scheme情况下，对应的id拥有超级权限，可以做任何事情(cdrwa）
     * <p>
     * <p>
     * 创建带权限限制的节点
     */
    @Test
    public void addSecreteNode() {

        List<ACL> acls = new ArrayList<>();  // 权限列表
        // 第一个参数是权限scheme，第二个参数是加密后的用户名和密码
        Id user1 = new Id("digest", getDigestUserPwd("user1:123456a"));
        Id user2 = new Id("digest", getDigestUserPwd("user2:123456b"));
        acls.add(new ACL(ZooDefs.Perms.ALL, user1));  // 给予所有权限
        acls.add(new ACL(ZooDefs.Perms.READ, user2));  // 只给予读权限
        acls.add(new ACL(ZooDefs.Perms.DELETE | ZooDefs.Perms.CREATE, user2));  // 多个权限的给予方式，使用 | 位运算符


        ZooKeeper zooKeeper = baseClient();
        try {
            String result = zooKeeper.create("/testDigestNode", "test data".getBytes(), acls, CreateMode.PERSISTENT);
        } catch (KeeperException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        try {
            TimeUnit.SECONDS.sleep(1);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        List<ACL> aclList = null;
        try {
            aclList = zooKeeper.getACL("/testDigestNode", null);
        } catch (KeeperException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        for (ACL acl : aclList) {
            System.out.println("\n-----------------------\n");
            System.out.println("权限scheme id：" + acl.getId());
            System.out.println("权限位：" + acl.getPerms());
        }

        while (true) {

        }
    }


    /**
     * 操作加密的节点
     */
    @Test
    public void getSecreteNode() {
        ZooKeeper zooKeeper = baseClient();
        zooKeeper.addAuthInfo("digest", "user1:123456a".getBytes());
        String result = null;

        /*创建子节点*/
        try {
            Stat exists = zooKeeper.exists("/testDigestNode/testOneNode", false);
            if (exists == null) {
                result = zooKeeper.create("/testDigestNode/testOneNode", "test data".getBytes(), ZooDefs.Ids.CREATOR_ALL_ACL, CreateMode.PERSISTENT);
                System.out.println(result);
            } else {
                System.out.println(exists);
            }

        } catch (KeeperException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        /*获取值*/
        try {
            byte[] data = zooKeeper.getData("/testDigestNode/testOneNode", false, null);
            System.out.println("获取值:" + new String(data));
        } catch (KeeperException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        /*设置值*/
        try {
            zooKeeper.setData("/testDigestNode/testOneNode", "new test data".getBytes(), -1);
        } catch (KeeperException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        while (true) {

        }
    }


  @Test
    public void addIpLimitNode() {
        ZooKeeper zooKeeper = baseClient();

        List<ACL> aclsIP = new ArrayList<ACL>();  // 权限列表
        // 第一个参数是权限scheme，第二个参数是ip地址
        Id ipId1 = new Id("ip", "192.168.190.1");
        aclsIP.add(new ACL(ZooDefs.Perms.ALL, ipId1));  // 给予所有权限

        try {
            String result = zooKeeper.create("/testIpNode", "this is test ip node data".getBytes(), aclsIP, CreateMode.PERSISTENT);
        } catch (KeeperException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        while (true){
            
        }
    }

}

```


## 使用Curator客户端
```
RetryPolicy retryPolicy = new ExponentialBackoffRetry(1000, 3);
        CuratorFramework client =
                CuratorFrameworkFactory.builder()
                        .connectString("127.0.0.1:2181")
                        .sessionTimeoutMs(5000)
                        .connectionTimeoutMs(5000)
                        .retryPolicy(retryPolicy)
                        .build();

        client.start();
```

### 创建节点
```
 try {
            client.create()
                    .creatingParentContainersIfNeeded()//创建父节点
                    .withMode(CreateMode.EPHEMERAL)//设置模式
                    .forPath("/fatherT/todayViewMoment","init".getBytes());//设置地址和对应值
        } catch (Exception e) {
            e.printStackTrace();
        }
```

### 删除数据节点

#### 删除一个节点(注意，此方法只能删除叶子节点，否则会抛出异常。)
```
client.delete().forPath("path");
```

#### 删除一个节点，并且递归删除其所有的子节点
```
client.delete().deletingChildrenIfNeeded().forPath("path");
```
#### 删除一个节点，强制指定版本进行删除
```
client.delete().withVersion(10086).forPath("path");
```
#### 删除一个节点，强制保证删除(guaranteed()接口是一个保障措施，只要客户端会话有效，那么Curator会在后台持续进行删除操作，直到删除节点成功。)
```
client.delete().guaranteed().forPath("path");
```


### 读取数据节点

#### 读取一个节点的数据内容(注意，此方法返的返回值是byte[ ])
```
client.getData().forPath("path");
```


#### 读取一个节点的数据内容，同时获取到该节点的stat
```
Stat stat = new Stat();
client.getData().storingStatIn(stat).forPath("path");
```

### 更新数据节点
#### 更新一个节点的数据内容（注意：该接口会返回一个Stat实例）
```
client.setData().forPath("path","data".getBytes());
```

#### 更新一个节点的数据内容，强制指定版本进行更新
```
client.setData().withVersion(10086).forPath("path","data".getBytes());
```
#### 检查节点是否存在
注意：该方法返回一个Stat实例，用于检查ZNode是否存在的操作. 可以调用额外的方法(监控或者后台处理)并在最后调用forPath( )指定要操作的ZNode
```
client.checkExists().forPath("path");
```

#### 获取某个节点的所有子节点路径
注意：该方法的返回值为List<String>,获得ZNode的子节点Path列表。 可以调用额外的方法(监控、后台处理或者获取状态watch, background or get stat) 并在最后调用forPath()指定要操作的父ZNode
```
client.getChildren().forPath("path");
```
### 监听
 
#### 监听客户端连接状态
Curator客户端与zookeeper连接的过程其实是一个异步过程，Curator为我们提供了一个监听器监听连接的状态，根据连接的状态做相应的处理。
```
    private CountDownLatch countDownLatch = new CountDownLatch(1);

    @Test
    public void testClientConnStateListener() throws InterruptedException {
        int retryIntervalMs = 1000;
        RetryPolicy retryPolicy = new RetryForever(retryIntervalMs);
        CuratorFramework testConnStateListenerClient = CuratorFrameworkFactory.builder()
                .connectString(ZookeeperHelper.zkAddress)
                .sessionTimeoutMs(ZookeeperHelper.sessionTimeout)
                .retryPolicy(retryPolicy)
                .build();

        //添加监听器
        testConnStateListenerClient.getConnectionStateListenable().addListener(new ConnectionStateListener() {
            @Override
            public void stateChanged(CuratorFramework client, ConnectionState newState) {
                if (newState == ConnectionState.CONNECTED) {
                    try {
                        System.out.println("connected established");
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    countDownLatch.countDown(); //释放锁
                } else {
                    System.out.println("connection state : " + newState.name());
                }
            }
        });
        testConnStateListenerClient.start();
        //加锁，暂不往下执行
        countDownLatch.await();

        testConnStateListenerClient.close();
    }
```    
#### NodeCache
* 可以监到当前节点数据的变化
```
 @Test
    public void testNodeDataListener() throws Exception {
        String node_to_listen = "/listened_node";

        client.create()
                .creatingParentContainersIfNeeded() //自动递归创建父节点
                .withMode(CreateMode.PERSISTENT)
                .forPath(node_to_listen);

        NodeCache nodeCache = new NodeCache(client, node_to_listen, false);
        nodeCache.getListenable().addListener(new NodeCacheListener() {
            @Override
            public void nodeChanged() throws Exception {
                System.out.println("Node data is changed, new data: " +
                        new String(nodeCache.getCurrentData().getData()));
            }
        });
        nodeCache.start();

        Thread.sleep(1000);

        client.setData()
                .forPath(node_to_listen, "new data".getBytes());//更新节点的数据

        Thread.sleep(1000);

        nodeCache.close();

        client.delete().deletingChildrenIfNeeded().forPath(node_to_listen);
    }
```    
#### PathChildrenCache
* 可以监听到当前节点下的孩子节点的变化，但是孩子节点下面的孩子节点的事情不能监听。 （2）可以监听到的事件：节点创建、节点数据的变化、节点删除等
```
 @Test
    public void testChildrenNodeListener() throws Exception {
        String parent_node = "/parent_node";
        String child_node = parent_node + "/child";

        PathChildrenCache pathChildrenCache = new PathChildrenCache(client, parent_node, false);
        PathChildrenCacheListener pathChildrenCacheListener = new PathChildrenCacheListener() {
            @Override
            public void childEvent(CuratorFramework client, PathChildrenCacheEvent event) throws Exception {
                switch (event.getType()) {
                    case CHILD_ADDED: //子节点被添加
                        System.out.println("CHILD_ADDED: " + event.getData().getPath());
                        break;
                    case CHILD_REMOVED: //子节点被删除
                        System.out.println("CHILD_REMOVED: " + event.getData().getPath());
                        break;
                    case CHILD_UPDATED: //子节点数据变化
                        System.out.println("CHILD_UPDATED: " + event.getData().getPath());
                        break;
                    default:
                        break;
                }
            }
        };
        pathChildrenCache.getListenable().addListener(pathChildrenCacheListener);
        pathChildrenCache.start();

        client.create()
                .creatingParentContainersIfNeeded()
                .withMode(CreateMode.PERSISTENT)
                .forPath(child_node);

        Thread.sleep(1000);

        client.setData()
                .forPath(child_node, "new data".getBytes());//更新节点的数据

        Thread.sleep(1000);

        pathChildrenCache.close();

        client.delete().deletingChildrenIfNeeded().forPath(parent_node);
    }
```

#### TreeCache
* 可以监听到指定节点下所有节点的变化。比如当前节点是”/node”，添加了TreeCacheListener后，不仅可以监听节点 "/node/child" 节点的变化，还能监听孙子节点 "/node/child/grandson"的变化。
* 可以监听到的事件：节点创建、节点数据的变化、节点删除等
```
@Test
    public void testTreeListener() throws Exception {
        String parent_path = "/tree_node_parent";
        client.create()
                .creatingParentContainersIfNeeded()
                .withMode(CreateMode.PERSISTENT)
                .forPath(parent_path);

        Thread.sleep(1000);

        TreeCache treeCache = new TreeCache(client, parent_path);
        treeCache.start();
        treeCache.getListenable().addListener(new TreeCacheListener() {
            @Override
            public void childEvent(CuratorFramework curatorFramework, TreeCacheEvent event) throws Exception {
                switch (event.getType()) {
                    case NODE_ADDED:
                        System.out
                                .println("TreeNode added: " + event.getData()
                                        .getPath() + " , data: " + new String(event.getData().getData()));
                        break;
                    case NODE_UPDATED:
                        System.out
                                .println("TreeNode updated: " + event.getData()
                                        .getPath() + " , data: " + new String(event.getData().getData()));
                        break;
                    case NODE_REMOVED:
                        System.out
                                .println("TreeNode removed: " + event.getData()
                                        .getPath());
                        break;
                    default:
                        break;
                }
            }
        });


        //创建孩子节点
        String child_path = parent_path + "/child";
        client.create()
                .creatingParentContainersIfNeeded()
                .withMode(CreateMode.PERSISTENT)
                .forPath(child_path);

        Thread.sleep(1000);

        //创建孙子节点
        String grandson_path = child_path + "/grandson";
        client.create()
                .creatingParentContainersIfNeeded()
                .withMode(CreateMode.PERSISTENT)
                .forPath(grandson_path);

        Thread.sleep(1000);

        //更新孙子节点数据
        client.setData().forPath(grandson_path, "new_data".getBytes());

        Thread.sleep(1000);

        //删除孙子节点
        client.delete().deletingChildrenIfNeeded().forPath(grandson_path);

        Thread.sleep(1000);

        treeCache.close();

        client.delete().deletingChildrenIfNeeded().forPath(parent_path);
    }
```

