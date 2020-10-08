# Netty


## Channel的生命周期
* ChannelUnregistered：Channel 已经被创建，但还未注册到 EventLoop
* ChannelRegistered：Channel 已经被注册到了 EventLoop
* ChannelActive：Channel 处于活动状态（已经连接到它的远程节点）。它现在可以接收和发送数据了
* ChannelInactive：Channel 没有连接到远程节点

## ChannelHandler的生命周期
* handlerAdded：当把 ChannelHandler 添加到 ChannelPipeline 中时被调用
* handlerRemoved：当从 ChannelPipeline 中移除 ChannelHandler 时被调用
* exceptionCaught：当处理过程中在 ChannelPipeline 中有错误产生时被调用

## ChannelInboundHandler的生命周期
* channelRegistered：当 Channel 已经注册到它的 EventLoop 并且能够处理I/O时被调用
* channelUnregistered：当 Channel 从它的 EventLoop 注销并且无法处理任何I/O时被调用
* channelActive：当 Channel 处于活动状态时被调用； Channel 已经连接/绑定并且已经就绪
* channelInactive：当 Channel 离开活动状态并且不再连接它的远程节点时被调用
* channelReadComplete：当 Channel 上的一个读操作完成时被调用 [1]
* channelRead：当从 Channel 读取数据时被调用
* ChannelWritabilityChanged：当 Channel 的可写状态发生改变时被调用。用户可以确保写操作不会完成得太快（以避免发生 OutOfMemoryError ）或者可以在 Channel 变为再次可写时恢复写入。可以通过调用 Channel 的 isWritable() 方法来检测 Channel 的可写性。与
可写性相关的阈值可以通过 Channel.config(). setWriteHighWaterMark() 和 Channel.config().setWriteLowWater-
Mark() 方法来设置
* userEventTriggered：当 ChannelnboundHandler.fireUserEventTriggered() 方法被调用时被调用，因为一个POJO被传经了 ChannelPipeline

## ChannelOutboundHandler类

```
ChannelOutboundHandler 中的大部分方法都需要一个 ChannelPromise 参数，以便在操作完成时得到通知。 ChannelPromise 是
ChannelFuture 的一个子类
```

* bind(ChannelHandlerContext,SocketAddress,ChannelPromise)：当请求将 Channel 绑定到本地地址时被调用
* connect(ChannelHandlerContext,SocketAddress,SocketAddress,ChannelPromise)：当请求将 Channel 连接到远程节点时被调用
* disconnect(ChannelHandlerContext,ChannelPromise)：当请求将 Channel 从远程节点断开时被调用
* close(ChannelHandlerContext,ChannelPromise)：当请求关闭 Channel 时被调用
* deregister(ChannelHandlerContext,ChannelPromise)：当请求将 Channel 从它的 EventLoop 注销时被调用
* read(ChannelHandlerContext)：当请求从 Channel 读取更多的数据时被调用
* flush(ChannelHandlerContext)：当请求通过 Channel 将入队数据冲刷到远程节点时被调用
* write(ChannelHandlerContext,Object,ChannelPromise)：当请求通过 Channel 将数据写到远程节点时被调用

## ChannelHandler适配器类
* 使 用 ChannelInboundHandlerAdapter 和ChannelOutboundHandlerAdapter 类作为自己的ChannelHandler 的起始点。
* 这两个适配器分别提供了ChannelInboundHandler 和ChannelOutboundHandler 的基本实现。
* 通过扩展抽象类ChannelHandlerAdapter，它们获得了它们共同的超接口ChannelHandler 的方法
* [![wOFcgU.png](https://s1.ax1x.com/2020/09/22/wOFcgU.png)](https://imgchr.com/i/wOFcgU)
* 在 ChannelInboundHandlerAdapter 和 ChannelOutboundHandlerAdapter中所提供的方法体调用了其相关联的ChannelHandlerContext上的等效方法，从而将事件转发到了ChannelPipeline 中的下一个ChannelHandler 中


## ChannelPipeline类
* 是一个拦截流经Channel 的入站和出站事件的ChannelHandler 实例链
* **每一个新创建的Channel 都将会被分配一个新的ChannelPipeline 。这项关联是永久性的；Channel 既不能附加另外一个ChannelPipeline ，也不能分离其当前的(这是一项固定的操作，不需要开发人员的任何干预)**
* 事件将会被ChannelInboundHandler或者ChannelOutboundHandler 处理。随后，通过调用ChannelHandlerContext 实现，它将被转发给同一超类型的下一个ChannelHandler
* ChannelHandler 可以通知其所属的ChannelPipeline 中的下一个ChannelHandler，甚至可以动态修改它所属的ChannelPipeline(排序)
* ![wOYXp8.png](https://s1.ax1x.com/2020/09/22/wOYXp8.png)
* 当你完成了通过调用ChannelPipeline.add*() 方法将入站处理器（ChannelInboundHandler ）和出站处
理器（ChannelOutboundHandler ）混合添加到ChannelPipeline 之后，每一个ChannelHandler 从头部到尾
端的顺序位置正如同我们方才所定义它们的一样。因此，如果你将图6-3中的处理器（ChannelHandler ）从左到右
进行编号，那么第一个被入站事件看到的ChannelHandler 将是1，而第一个被出站事件看到的ChannelHandler
将是5
* 在ChannelPipeline 传播事件时，它会测试ChannelPipeline 中的下一个ChannelHandler的类型是否和事件的运动方向相匹 配。如果不匹配，ChannelPipeline 将跳过该ChannelHandler并前进到下一个，直到它找到和该事件所期望的方向相匹配的为止。（当然，ChannelHandler也可以同时实现ChannelInboundHandler 接口和ChannelOutboundHandler 接口
* ChannelHandler 可以通过添加、删除或者替换其他的ChannelHandler来实时地修改ChannelPipeline的布局。（它也可以将它自己从ChannelPipeline 中移除。）

```
AddFirstaddBefore/addAfteraddLast
将一个 ChannelHandler 添加到 ChannelPipeline 中
remove
将一个 ChannelHandler 从 ChannelPipeline 中移除
replace
将 ChannelPipeline 中的一个 ChannelHandler 替换为另一个 Channel- Handler
```
* 通常ChannelPipeline 中的每一个ChannelHandler都是通过它的EventLoop（I/O线程）来处理传递给它的事件的。所以至关重要的是不要阻塞这个线程，因为这会对整体的I/O处理产生负面的影响

```
get 
通过类型或者名称返回 ChannelHandler
context
返回和 ChannelHandler 绑定的 ChannelHandlerContext
names 
返回 ChannelPipeline 中所有 ChannelHandler 的名称
```

* ChannelPipeline入站操作
```
fireChannelRegistered
调用 ChannelPipeline 中下一个 ChannelInboundHandler 的 channelRegistered(ChannelHandlerContext) 方法
fireChannelUnregistered
调用 ChannelPipeline 中下一个 ChannelInboundHandler 的 channelUnregistered(ChannelHandlerContext) 方法
fireChannelActive
调用 ChannelPipeline 中下一个 ChannelInboundHandler 的 channelActive(ChannelHandlerContext) 方法
fireChannelInactive
调用 ChannelPipeline 中下一个 ChannelInboundHandler 的 channelInactive(ChannelHandlerContext) 方法
fireExceptionCaught
调用 ChannelPipeline 中下一个 ChannelInboundHandler 的 exceptionCaught(ChannelHandlerContext, Throwable) 方
法
fireUserEventTriggered
调用 ChannelPipeline 中下一个 ChannelInboundHandler 的 userEventTriggered(ChannelHandlerContext, Object) 方
法
fireChannelRead
调用 ChannelPipeline 中下一个 ChannelInboundHandler 的 channelRead(ChannelHandlerContext, Object msg) 方法
fireChannelReadComplete
调用 ChannelPipeline 中下一个 ChannelInboundHandler 的 channelReadComplete(ChannelHandlerContext) 方法
fireChannelWritability - Changed
调用 ChannelPipeline 中下一个 ChannelInboundHandler 的 channelWritabilityChanged(ChannelHandlerContext)方 法
```

* ChannelPipeline出站操作
```
bind
将 Channel 绑 定 到 一 个 本 地 地 址， 这 将 调 用 ChannelPipeline 中 的 下 一 个 ChannelOutboundHandler 的
bind(ChannelHandlerContext, Socket- Address, ChannelPromise) 方法
connect
将 Channel 连 接 到 一 个 远 程 地 址， 这 将 调 用 ChannelPipeline 中 的 下 一 个 ChannelOutboundHandler 的
connect(ChannelHandlerContext, Socket- Address, ChannelPromise) 方法
disconnect
将 Channel 断 开 连 接。 这 将 调 用 ChannelPipeline 中 的 下 一 个 ChannelOutbound- Handler 的
disconnect(ChannelHandlerContext, Channel Promise) 方法
close
将 Channel 关闭。这将调用 ChannelPipeline 中的下一个 ChannelOutbound- Handler 的 close(ChannelHandlerContext,
ChannelPromise) 方法
deregister
将 Channel 从它先前所分配的 EventExecutor （即 EventLoop ）中注销。这将调用 ChannelPipeline 中的下一个
ChannelOutboundHandler 的 deregister (ChannelHandlerContext, ChannelPromise) 方法
flush
冲 刷 Channel 所 有 挂 起 的 写 入。 这 将 调 用 ChannelPipeline 中 的 下 一 个 Channel- OutboundHandler 的
flush(ChannelHandlerContext) 方法
write
将 消 息 写 入 Channel 。 这 将 调 用 ChannelPipeline 中 的 下 一 个 Channel- OutboundHandler 的
write(ChannelHandlerContext, Object msg, Channel- Promise) 方法。注意：这并不会将消息写入底层的 Socket ，
而只会将它放入队列中。要将它写入 Socket ，需要调用 flush() 或者 writeAndFlush() 方法
writeAndFlush
这是一个先调用 write() 方法再接着调用 flush() 方法的便利方法
read
请 求 从 Channel 中 读 取 更 多 的 数 据。 这 将 调 用 ChannelPipeline 中 的 下 一 个 ChannelOutboundHandler 的
read(ChannelHandlerContext) 方法
```

* ChannelPipeline总结：
1. ChannelPipeline 保存了与Channel 相关联的ChannelHandler ；
2. ChannelPipeline 可以根据需要，通过添加或者删除ChannelHandler 来动态地
修改；
3. ChannelPipeline 有着丰富的API用以被调用，以响应入站和出站事件。

## ChannelHandlerContext
* 打印ChannelHandlerContext链工具
```

import io.netty.channel.Channel;
import io.netty.channel.ChannelPipeline;

import java.lang.reflect.Field;


/**
 * 打印ChannelHandlerContext链工具，仅调试使用
 * 非常影响性能
 */
public class ContextPrinter {

   
    public static void print(Channel channel) {
        print(channel.pipeline());
    }

    public static void print(ChannelPipeline channelPipeline) {
        Class<? extends ChannelPipeline> aClass = channelPipeline.getClass();
        try {
            Field head = aClass.getDeclaredField("head");
            head.setAccessible(true);
            Object headData = head.get(channelPipeline);
            parseAbstractChannelHandlerContext(headData);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    private static void parseAbstractChannelHandlerContext(Object headData) throws Exception {
        System.out.println(0+"--->"+printName(headData));
        parsePre(headData,0);
        parseNext(headData,0);

    }

    private static void parsePre(Object headData,Integer index) throws Exception {
        Class<?> aClass = headData.getClass();
        Field prev = aClass.getSuperclass().getDeclaredField("prev");
        prev.setAccessible(true);
        Object o = prev.get(headData);
        if (o!=null){
            Integer integer = --index;
            System.out.println(integer+"--->"+printName(o));
            parsePre(o,integer);
        }

    }

    private static void parseNext(Object headData,Integer index) throws Exception {
        Class<?> aClass = headData.getClass();
        Field prev = aClass.getSuperclass().getDeclaredField("next");
        prev.setAccessible(true);
        Object o = prev.get(headData);
        if (o!=null){
            Integer integer = ++index;
            System.out.println(integer+"--->"+printName(o));
            parseNext(o,integer);
        }
    }

    public static String   printName (Object headData)throws Exception{
        Class<?> aClass = headData.getClass();
        Field prev = aClass.getSuperclass().getDeclaredField("name");
        prev.setAccessible(true);
        Object o = prev.get(headData);
        return o.toString();
    }
}

```

* ChannelHandlerContext 代表了ChannelHandler 和ChannelPipeline 之间的 关 联
* 每 当 有 ChannelHandler 添 加 到 ChannelPipeline 中 时， 都 会 创 建ChannelHandlerContext 。
* ChannelHandlerContext 的主要功能是管理它所关联的ChannelHandler 和在同一个ChannelPipeline 中的其他ChannelHandler 之间
的交互
* ChannelHandlerContext 有很多的方法，其中一些方法也存在于Channel 和Channel- Pipeline 本身上，但是有一点重要的不同。如果调用Channel 或者ChannelPipeline 上的这些方法，它们将沿着整个ChannelPipeline 进行传播。而调用位 于 ChannelHandlerContext 上 的 相 同 方 法， 则 将 从 当 前 所 关 联 的ChannelHandler开始，**并且只会传播给位于该ChannelPipeline 中的下一个 能够处理该事件的ChannelHandler**
```
alloc
返回和这个实例相关联的 Channel 所配置的 ByteBufAllocator
bind
绑定到给定的 SocketAddress ，并返回 ChannelFuture
channel
返回绑定到这个实例的 Channel
close
关闭 Channel ，并返回 ChannelFuture
connect
连接给定的 SocketAddress ，并返回 ChannelFuture
deregister
从之前分配的 EventExecutor 注销，并返回 ChannelFuture
disconnect
从远程节点断开，并返回 ChannelFuture
executor
返回调度事件的 EventExecutor
fireChannelActive
触发对下一个 ChannelInboundHandler 上的 channelActive() 方法（已连接）的调用
fireChannelInactive
触发对下一个 ChannelInboundHandler 上的 channelInactive() 方法（已关闭）的调用
fireChannelRead
触发对下一个 ChannelInboundHandler 上的 channelRead() 方法（已接收的消息）的调用
fireChannelReadComplete
触发对下一个 ChannelInboundHandler 上的 channelReadComplete() 方法的调用
fireChannelRegistered
触发对下一个 ChannelInboundHandler 上的 fireChannelRegistered() 方法的调用
fireChannelUnregistered
触发对下一个 ChannelInboundHandler 上的 fireChannelUnregistered() 方法的调用
fireChannelWritabilityChanged
触发对下一个 ChannelInboundHandler 上的 fireChannelWritabilityChanged() 方法的调用
fireExceptionCaught
触发对下一个 ChannelInboundHandler 上的 fireExceptionCaught(Throwable) 方法的调用
fireUserEventTriggered
触发对下一个 ChannelInboundHandler 上的 fireUserEventTriggered(Object evt) 方法的调用
handler
返回绑定到这个实例的 ChannelHandler
isRemoved
如果所关联的 ChannelHandler 已经被从 ChannelPipeline中 移除则返回 true
name
返回这个实例的唯一名称
pipeline
返回这个实例所关联的 ChannelPipeline
read
将数据从 Channel 读取到第一个入站缓冲区；如果读取成功则触发 [5] 一个 channelRead 事件，并（在最后一个消息被读
取完成后）通知 ChannelInboundHandler的channelReadComplete (ChannelHandlerContext)方法
write
通过这个实例写入消息并经过 ChannelPipeline
writeAndFlush
通过这个实例写入并冲刷消息并经过 ChannelPipeline
```

* 重点
1. ChannelHandlerContext 和ChannelHandler 之间的关联（绑定）是永远不会
改变的，所以缓存对它的引用是安全的；
2. 如同我们在本节开头所解释的一样，相对于其他类的同名方法，ChannelHandler
Context 的方法将产生更短的事件流，应该尽可能地利用这个特性来获得最大的性
能


```
ChannelHandlerContext ctx = ..;
Channel channel = ctx.channel(); ← -- 获取到与ChannelHandlerContext相关联的Channel 的引用
channel.write(Unpooled.copiedBuffer("Netty in Action",CharsetUtil.UTF_8));//　← -- 通过Channel 写入缓冲区
//方法将会导致写入事件从尾端到头部地流经ChannelPipeline
```

```
ChannelHandlerContext ctx = ..;
ChannelPipeline pipeline = ctx.pipeline(); ← -- 获取到与ChannelHandlerContext相关联的ChannelPipeline 的引用
pipeline.write(Unpooled.copiedBuffer("Netty in Action",　CharsetUtil.UTF_8));//　← -- 通过ChannelPipeline写入缓冲区
//方法将会导致写入事件从尾端到头部地流经ChannelPipeline　
```

[![wXLui4.png](https://s1.ax1x.com/2020/09/23/wXLui4.png)](https://imgchr.com/i/wXLui4)


```
ChannelHandlerContext ctx = ..; ← -- 获取到ChannelHandlerContext的引用
ctx.write(Unpooled.copiedBuffer("Netty in Action", CharsetUtil.UTF_8));　← -- write()方法将把缓冲
//消息将从下一个 ChannelHandler 开始流经ChannelPipeline ，绕过了所有前面的ChannelHandler 
```
![wOwRfI.png](https://s1.ax1x.com/2020/09/22/wOwRfI.png)


* 关系:一个和ChannelHandler有一个属于自己的ChannelHandlerContext实例
[![wOaMAs.png](https://s1.ax1x.com/2020/09/22/wOaMAs.png)](https://imgchr.com/i/wOaMAs)


## EventLoop和线程模型
* 每个EventLoop 都有它自已的任务队列，独立于任何其他的EventLoop 。图7-3展示了EventLoop 用于调度任务的执行逻辑。这是Netty线程模型的关键组成部分
* [![0SFC4J.md.png](https://s1.ax1x.com/2020/09/24/0SFC4J.md.png)](https://imgchr.com/i/0SFC4J)
* 我们之前已经阐明了不要阻塞当前I/O线程的重要性。我们再以另一种方式重申一
次：“永远不要将一个长时间运行的任务放入到执行队列中，因为它将阻塞需要在同一线程
上执行的任何其他任务。”如果必须要进行阻塞调用或者执行长时间运行的任务，我们建议
使 用 一 个 专 门 的 EventExecutor
## EventLoop/线程的分配
* 服务于Channel 的I/O和事件的EventLoop 包含在EventLoopGroup 中。根据不同
的传输实现，EventLoop 的创建和分配方式也不同

### 异步传输
* 异步传输实现只使用了少量的EventLoop （以及和它们相关联的Thread ），而且在
当前的线程模型中，它们可能会被多个Channel 所共享。这使得可以通过尽可能少量的
Thread 来支撑大量的Channel ，而不是每个Channel 分配一个Thread 
* 图7-4显示了一个EventLoopGroup，它 具有3个固定大小的EventLoop （每个EventLoop 都由一个Thread支撑）。在创建EventLoopGroup 时就直接分配了EventLoop （以及支撑它们的Thread ），以确保在需要时它们是可用的
* [![0SFfPJ.md.png](https://s1.ax1x.com/2020/09/24/0SFfPJ.md.png)](https://imgchr.com/i/0SFfPJ)
* EventLoopGroup 负责为每个新创建的Channel 分配一个EventLoop 。在当前实
现中，使用顺序循环（round-robin）的方式进行分配以获取一个均衡的分布，***并且相同的
EventLoop 可能会被分配给多个Channel 。（这一点在将来的版本中可能会改变。）***
* 一旦一个Channel 被分配给一个EventLoop ，它将在它的整个生命周期中都使用这
个EventLoop （以及相关联的Thread ）。请牢记这一点，因为它可以使你从担忧你的
Channel- Handler 实现中的线程安全和同步问题中解脱出来
* 另外，需要注意的是，EventLoop 的分配方式对ThreadLocal 的使用的影响。因为
一个EventLoop 通常会被用于支撑多个Channel ，所以对于所有相关联的Channel 来
说，ThreadLocal 都将是一样的。这使得它对于实现状态追踪等功能来说是个糟糕的选
择。然而，在一些无状态的上下文中，它仍然可以被用于在多个Channel 之间共享一些重
度的或者代价昂贵的对象，甚至是事件


### 阻塞传输
* 这里每一个Channel 都将被分配给一个EventLoop （以及它的Thread ）。如果你
开发的应用程序使用过java.io 包中的阻塞I/O实现，你可能就遇到过这种模型
* [![0SAiOx.md.png](https://s1.ax1x.com/2020/09/24/0SAiOx.md.png)](https://imgchr.com/i/0SAiOx)
* 但是，正如同之前一样，得到的保证是每个Channel 的I/O事件都将只会被一个
Thread （用于支撑该Channel 的EventLoop 的那个Thread ）处理。这也是另一个
Netty设计一致性的例子，它（这种设计上的一致性）对Netty的可靠性和易用性做出了巨大
贡献。


## 引导Bootstrapping

### Bootstrap 类的API
```
Bootstrap group(EventLoopGroup)
设置用于处理 Channel 所有事件的 EventLoopGroup

Bootstrap channel(Class<? extends C>)
Bootstrap channelFactory(ChannelFactory<? extends C>)
channel() 方法指定了 Channel 的实现类。如果该实现类没提供默认的构造函数 [7] ，可以通过调用 channel- Factory()方法来指定一个工厂类，它将会被 bind() 方法调用

Bootstrap localAddress(SocketAddress)
指定 Channel 应该绑定到的本地地址。如果没有指定，则将由操作系统创建一个随机的地址。或者，也可以通过 
bind()或者 connect() 方法指定 localAddress

<T> Bootstrap option(ChannelOption<T> option,T value)
设置 ChannelOption ，其将被应用到每个新创建的 Channel 的 ChannelConfig 。这些选项将会通过 bind() 或者 connect()方法设置到 Channel ，不管哪个先被调用。这个方法在 Channel已经被创建后再调用将不会有任何的效果。支持的ChannelOption 取决于使用的 Channel 类型。参见8.6节以及 ChannelConfig 的API文档，了解所使用的 Channel 类型

<T> Bootstrap attr(Attribute<T> key, T value)
指定新创建的 Channel 的属性值。这些属性值是通过 bind() 或者 connect() 方法设置到 Channel 的，具体取决于谁最先被调用。这个方法在 Channel 被创建后将不会有任何的效果。参见8.6节

Bootstrap handler(ChannelHandler)
设置将被添加到 ChannelPipeline 以接收事件通知的 ChannelHandler

Bootstrap clone()
创建一个当前 Bootstrap 的克隆，其具有和原始的 Bootstrap 相同的设置信息

Bootstrap remoteAddress(SocketAddress)
设置远程地址。或者，也可以通过 connect() 方法来指定它

ChannelFuture connect()
连接到远程节点并返回一个 ChannelFuture ，其将会在连接操作完成后接收到通知

ChannelFuture bind()
绑定 Channel 并返回一个 ChannelFuture ，其将会在绑定操作完成后接收到通知，在那之后必须调用 Channel.
connect() 方法来建立连接
```


### 引导客户端,Bootstrap 类负责为客户端和使用无连接协议的应用程序创建Channel ，如图8-2所
示:
[![0Smxk6.md.png](https://s1.ax1x.com/2020/09/24/0Smxk6.md.png)](https://imgchr.com/i/0Smxk6)

* 引导客户端范例
```
import io.netty.bootstrap.Bootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.nio.NioSocketChannel;

import java.net.InetSocketAddress;

public class BootTest {
    public static void main(String[] args) {
        EventLoopGroup group = new NioEventLoopGroup();
        Bootstrap bootstrap = new Bootstrap(); //← -- 创建一个Bootstrap类的实例以创建和连接新的客户端Channel
        bootstrap.group(group)//← -- 设置EventLoopGroup，提供用于处理Channel事件的EventLoop
                .channel(NioSocketChannel.class)//← -- 指定要使用的Channel 实现
                .handler(new SimpleChannelInboundHandler<ByteBuf>() {

                    @Override
                    protected void channelRead0(
                            ChannelHandlerContext channelHandlerContext,
                            ByteBuf byteBuf) throws Exception {
                        System.out.println("Received data");
                    }
                });
        ChannelFuture future = bootstrap.connect(new InetSocketAddress("www.baidu.com", 80)); //← -- 连接到远程主机

        future.addListener(new ChannelFutureListener() {
            @Override
            public void operationComplete(ChannelFuture channelFuture)
                    throws Exception {
                if (channelFuture.isSuccess()) {
                    System.out.println("Connection established");
                } else {
                    System.err.println("Connection attempt failed");
                    channelFuture.cause().printStackTrace();
                }
            }
        });
    }
}

```

* 包不能混合用,否则会抛出IllegalStateException
```
channel
├───nio
│　　　　NioEventLoopGroup
├───oio
│　　　　OioEventLoopGroup
└───socket
　　├───nio
　　│　　　　NioDatagramChannel
　　│　　　　NioServerSocketChannel
　　│　　　　NioSocketChannel
　　└───oio
　　　　　　　OioDatagramChannel
　　　　　　　OioServerSocketChannel
　　　　　　　OioSocketChannel
```
* 在引导的过程中，在调用bind() 或者connect() 方法之前，必须调用以下方法来设置所需的组件：
```group()```
```channel() / channelFactory()```
```handler()```
如果不这样做，则将会导致IllegalStateException 。对handler() 方法的调用尤其重要，因为它需要配置
好ChannelPipeline

### 引导服务器
### ServerBootstrap API
```
group
设置 ServerBootstrap 要用的 EventLoopGroup 。这个 EventLoopGroup 将用于 ServerChannel 和被接受的子 Channel 的I/O处理

channel
设置将要被实例化的 ServerChannel 类

channelFactory
如果不能通过默认的构造函数 [8] 创建 Channel ，那么可以提供一个 Channel- Factory

localAddress
指定 ServerChannel 应该绑定到的本地地址。如果没有指定，则将由操作系统使用一个随机地址。或者，可以通过bind() 方法来指定该 localAddress

option
指定要应用到新创建的 ServerChannel 的 ChannelConfig 的 Channel- Option 。这些选项将会通过 bind() 方法设置到Channel 。在 bind() 方法被调用之后，设置或者改变 ChannelOption都不会有任何的效果。所支持的 ChannelOption 取决于所使用的 Channel 类型。参见正在使用的 ChannelConfig 的API文档

childOption
指定当子 Channel 被接受时，应用到子 Channel 的 ChannelConfig 的 ChannelOption 。所支持的 ChannelOption 取决于所使用的 Channel 的类型。参见正在使用的 ChannelConfig 的API文档

attr
指定 ServerChannel 上的属性，属性将会通过 bind() 方法设置给 Channel 。在调用 bind()方法之后改变它们将不会有任何的效果

childAttr
将属性设置给已经被接受的子 Channel 。接下来的调用将不会有任何的效果

handler
设置被添加到 ServerChannel 的 ChannelPipeline 中的 ChannelHandler 。更加常用的方法参见 childHandler()

childHandler
设置将被添加到已被接受的子 Channel 的 ChannelPipeline 中的 Channel- Handler 。 handler() 方法和 childHandler()方法之间的区别是：前者所添加的 ChannelHandler 由接受子 Channel 的 ServerChannel处理，而 childHandler() 方法所添加的 ChannelHandler 将由已被接受的子 Channel处理，其代表一个绑定到远程节点的套接字

clone
克隆一个设置和原始的 ServerBootstrap 相同的 ServerBootstrap

bind
绑定 ServerChannel 并且返回一个ChannelFuture，其将会在绑定操作完成后收到通知（带着成功或者失败的结果）
```

*  ServerBootstrap 在 bind() 方 法 被 调 用 时 创 建 了 一 个ServerChannel ，并且该ServerChannel 管理了多个子Channel


### 从Channel引导客户端
* 假设你的服务器正在处理一个客户端的请求，这个请求需要它充当第三方系统的客户
端。当一个应用程序（如一个代理服务器）必须要和组织现有的系统（如Web服务或者数
据库）集成时，就可能发生这种情况。在这种情况下，将需要从已经被接受的子Channel
中引导一个客户端Channel
* 你可以按照8.2.1节中所描述的方式创建新的Bootstrap 实例，但是这并不是最高效
的解决方案，因为它将要求你为每个新创建的客户端Channel 定义另一个EventLoop 。
这会产生额外的线程，以及在已被接受的子Channel 和客户端Channel 之间交换数据时
不可避免的上下文切换
[![0SgduF.md.png](https://s1.ax1x.com/2020/09/24/0SgduF.md.png)](https://imgchr.com/i/0SgduF)

```

import io.netty.bootstrap.Bootstrap;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelFutureListener;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.channel.socket.nio.NioSocketChannel;
import io.netty.util.CharsetUtil;

import java.net.InetSocketAddress;

public class ShareChannel {
    public static void main(String[] args) {
        ServerBootstrap bootstrap = new ServerBootstrap(); //← -- 创建ServerBootstrap 以创建ServerSocketChannel，并绑定它
        bootstrap.group(new NioEventLoopGroup(), new NioEventLoopGroup())//← -- 设置EventLoopGroup，其将提供用以处理Channel 事件的EventLoop
                .channel(NioServerSocketChannel.class)//← -- 指定要使用的Channel 实现
                .childHandler(//← -- 设置用于处理已被接受的子Channel 的I/O 和数据的ChannelInboundHandler
                        new SimpleChannelInboundHandler<ByteBuf>() {
                            ChannelFuture connectFuture;

                            @Override
                            public void channelActive(ChannelHandlerContext ctx)
                                    throws Exception {
                                Bootstrap bootstrap = new Bootstrap();//← -- 创建一个Bootstrap类的实例以连接到远程主机
                                bootstrap.channel(NioSocketChannel.class).handler( //← -- 指定Channel的实现
                                        new SimpleChannelInboundHandler<ByteBuf>() { //← -- 为入站I/O 设置ChannelInboundHandler
                                            @Override
                                            protected void channelRead0(ChannelHandlerContext ctx, ByteBuf in) throws Exception {
                                                System.out.println("Received data");
                                            }
                                        });
                                bootstrap.group(new NioEventLoopGroup());//← -- 使用与分配给已被接受的子Channel 相同的EventLoop
                                connectFuture = bootstrap.connect(new InetSocketAddress("qw607.com", 80)).sync(); //← -- 连接到远程节点
                            }

                            @Override
                            protected void channelRead0(ChannelHandlerContext channelHandlerContext, ByteBuf byteBuf) throws Exception {
                                if (connectFuture.isDone()) {
                                    System.out.println(byteBuf.toString(CharsetUtil.UTF_8));
                                }
                            }
                        });

        ChannelFuture future = bootstrap.bind(new InetSocketAddress(80));//← -- 通过配置好的ServerBootstrap绑定该Server-SocketChannel
        future.addListener(new ChannelFutureListener() {
            @Override
            public void operationComplete(ChannelFuture channelFuture)
                    throws Exception {
                if (channelFuture.isSuccess()) {
                    System.out.println("Server bound");
                } else {
                    System.err.println("Bind attempt failed");
                    channelFuture.cause().printStackTrace();
                }
            }
        });
    }
}
```

## 在引导过程中添加多个ChannelHandler
* Netty提供了一个特殊的ChannelInboundHandlerAdapter
子类：
```
public abstract class ChannelInitializer<C extends Channel> extends ChannelInboundHandlerAdapter
```
它定义了下面的方法：
```
protected abstract void initChannel(C ch) throws Exception;
```
* 方法提供了一种将多个ChannelHandler 添加到一个ChannelPipeline 中的
简便方法，只需向Bootstrap 或ServerBootstrap 的实例提供你的
Channel-Initializer 实现即可，并且一旦Channel 被注册到了它的EventLoop 之
后，就会调用你的initChannel() 版本。在该方法返回之后，ChannelInitializer
的实例将会从Channel-Pipeline 中移除它自己


### 使用Netty的ChannelOption和属性
* 在每个Channel 创建时都手动配置它可能会变得相当乏味。幸运的是，你不必这样
做。相反，你可以使用option() 方法来将ChannelOption 应用到引导 。你所提供的值
将会被自动应用到引导 所创建的所有Channel 。可用的ChannelOption 包括了底层连
接的详细信息，如keep-alive 或者超时属性以及缓冲区设置
```
AttributeKey<Integer> id = AttributeKey.valueOf("ID");//← -- 创建一个AttributeKey以标识该属性
Bootstrap bootstrap = new Bootstrap();//← -- 创建一个Bootstrap 类的实例以创建客户端Channel 并连接它们
bootstrap.group(new NioEventLoopGroup())//← -- 设置EventLoopGroup，其提供了用以处理Channel事件的EventLoop
                .channel(NioSocketChannel.class)//← -- 指定Channel的实现
                .handler(new MySimpleChannelInboundHandler());
bootstrap
                .option(ChannelOption.SO_KEEPALIVE, true)
                .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 5000);
bootstrap.attr(id, 123456);//← -- 存储该id 属性

Integer idValue = ctx.channel().attr(id).get();//← -- 使用AttributeKey 检索属性以及它的值
```

## 引导DatagramChannel
```

        Bootstrap bootstrap = new Bootstrap();// 创建一个Bootstrap 的实例以创建和绑定新的数据报Channel
        bootstrap.group(new OioEventLoopGroup()).channel( // 设置EventLoopGroup，其提供了用以处理Channel 事件的EventLoop
                OioDatagramChannel.class).handler(// 指定Channel的实现
                new SimpleChannelInboundHandler<DatagramPacket>() {// 设置用以处理Channel 的I/O 以及数据的Channel-InboundHandler
                    @Override
                    public void channelRead0(ChannelHandlerContext ctx, DatagramPacket msg) throws Exception {
// Do something with the packet
                        System.out.println(msg);
                    }
                }
        );
        ChannelFuture future = bootstrap.bind(new InetSocketAddress(7001)); // 调用bind()方法，因为该协议是无连接的
        future.addListener(new ChannelFutureListener() {
            @Override
            public void operationComplete(ChannelFuture channelFuture)
                    throws Exception {
                if (channelFuture.isSuccess()) {
                    System.out.println("Channel bound");
                } else {
                    System.err.println("Bind attempt failed");
                    channelFuture.cause().printStackTrace();
                }
            }
        });
```

## 关闭
* 需要关闭EventLoopGroup ，它将处理任何挂起的事件和任务，并
且随后释放所有活动的线程。这就是调用EventLoopGroup.shutdownGracefully()
方法的作用。这个方法调用将会返回一个Future ，这个Future 将在关闭完成时接收到
通知。
* 需要注意的是，shutdownGracefully() 方法也是一个异步的操作，所以你需要
阻塞等待直到它完成，或者向所返回的Future 注册一个监听器以在关闭完成时获得通
知


* 代码清单8-9符合优雅关闭的定义。代码清单8-9　优雅关闭
```
EventLoopGroup group = new NioEventLoopGroup(); ← -- 创建处理I/O 的EventLoopGroup
Bootstrap bootstrap = new Bootstrap();　← -- 创建一个Bootstrap类的实例并配置它
bootstrap.group(group)
　　.channel(NioSocketChannel.class);
...
Future<?> future = group.shutdownGracefully();　← -- shutdownGracefully()方法将释放所有的资源，并且关闭所有的当前正在使用中的Channel
// block until the group has shutdown
future.syncUninterruptibly();
```
* 或者，你也可以在调用EventLoopGroup.shutdownGracefully() 方法之前，显
式地在所有活动的Channel 上调用Channel.close() 方法。但是在任何情况下，都请
记得关闭EventLoopGroup 本身

## 单元测试EmbeddedChannel
```
writeInbound(Object... msgs)
将入站消息写到 EmbeddedChannel 中。如果可以通过 readInbound() 方法从 EmbeddedChannel 中读取数据，则返回 true

readInbound()
从 EmbeddedChannel 中读取一个入站消息。任何返回的东西都穿越了整个 ChannelPipeline。如果没有任何可供读取的，则返回 null

writeOutbound(Object... msgs)
将出站消息写到 EmbeddedChannel 中。如果现在可以通过 readOutbound() 方法从 EmbeddedChannel中读取到什么东西，则返回 true

readOutbound()
从 EmbeddedChannel 中读取一个出站消息。任何返回的东西都穿越了整个 ChannelPipeline。如果没有任何可供读取的，则返回 null

finish()
将 EmbeddedChannel 标记为完成，并且如果有可被读取的入站数据或者出站数据，则返回 true。这个方法还将会调用EmbeddedChannel 上的 close() 方法
```
* 入站数据由ChannelInboundHandler 处理，代表从远程节点读取的数据。
* 出站数据由ChannelOutboundHandler 处理，代表将要写到远程节点的数据。
* 根据你要测试的Channel-Handler ，你将使用*Inbound() 或者*Outbound() 方法对，或者兼而有之

* 图9-1展示了使用EmbeddedChannel 的方法，数据是如何流经ChannelPipeline
的。 你 可 以 使 用 writeOutbound() 方 法 将 消 息 写 到 Channel 中， 并 通 过
ChannelPipeline 沿着出站的方向传递。随后，你可以使用readOutbound() 方法来
读取已被处理过的消息，以确定结果是否和预期一样。 类似地，对于入站数据，你需要使
用writeInbound() 和readInbound() 方法。
* [![09qwh6.md.png](https://s1.ax1x.com/2020/09/25/09qwh6.md.png)](https://imgchr.com/i/09qwh6)


## 编码解码
* 将字节解码为消息——ByteToMessageDecoder 和ReplayingDecoder ；
* 将一种消息类型解码为另一种——MessageToMessageDecoder 。

### 抽象类ByteToMessageDecoder
```
decode(ChannelHandlerContext ctx,ByteBuf in,List<Object> out)
这是你必须实现的唯一抽象方法。 decode() 方法被调用时将会传入一个包含了传入数据的 ByteBuf，以及一个用来添加解码消息的List。对这个方法的调用将会重复进行，直到确定没有新的元素被添加到该 List ，或者该 ByteBuf 中没有更多可读取的字节时为止。然后，如果该List不为空，那么它的内容将会被传递给 ChannelPipeline 中的下一个ChannelInboundHandler

decodeLast(ChannelHandlerContext ctx,ByteBuf in,List<Object> out)
Netty提供的这个默认实现只是简单地调用了decode()方法。当Channel的状态变为非活动时，这个方法将会被调用一次。可以重写该方法以提供特殊的处理 [1]
```

* 解码器
```
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.ByteToMessageDecoder;


import java.util.List;

public class ToIntegerDecoder extends ByteToMessageDecoder { // 扩展ByteToMessage-Decoder 类，以将字节解码为特定的格式
    @Override
    public void decode(ChannelHandlerContext ctx, ByteBuf in, List<Object> out) throws Exception {
        if (in.readableBytes() >= 4) {// 检查是否至少有4字节可读（一个int的字节长度）
            byte[] bytes=new byte[4];
            in.readBytes(bytes);
            out.add(bytes); // 从入站ByteBuf 中读取一个int，并将其添加到解码消息的List 中
            System.out.println("满足4字节执行：");
        }else {
            System.out.println("不足4字节跳过");
        }
    }
}
```

* 下一个处理器
```
 ChannelInitializer channelInitializer = new ChannelInitializer() {
            @Override
            protected void initChannel(Channel channel) throws Exception {
                ChannelPipeline pipeline = channel.pipeline();
                pipeline.addFirst("decoder", new ToIntegerDecoder());
                pipeline.addAfter("decoder", "inb",new MyChannelInboundHandler());
            }

        };
```

* 持续发送客户端
```
import java.io.IOException;
import java.io.OutputStream;
import java.net.Socket;


public class SimpleClient {
    public static void main(String[] args) throws IOException {
        Socket serverSocket=new Socket("127.0.0.1",80);
        OutputStream outputStream = serverSocket.getOutputStream();
        while (true){
            outputStream.write('a');
        }
    }
}

```

### 抽象类ReplayingDecoder
* 并不是所有的ByteBuf 操作都被支持，如果调用了一个不被支持的方法，将会抛出
一个UnsupportedOperationException ；
* ReplayingDecoder 稍慢于ByteToMessageDecoder
* 不用判断
```
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.ReplayingDecoder;

import java.util.List;

public class MyReplayingDecoder extends ReplayingDecoder {
    @Override
    protected void decode(ChannelHandlerContext channelHandlerContext, ByteBuf byteBuf, List<Object> list) throws Exception {
        byte[] bytes=new byte[4];
        byteBuf.readBytes(bytes);
        list.add(bytes);
    }
}
```

### 抽象类MessageToMessageDecoder
* [![0miGwD.md.png](https://s1.ax1x.com/2020/09/29/0miGwD.md.png)](https://imgchr.com/i/0miGwD) 


```
  ChannelInitializer channelInitializer = new ChannelInitializer() {
            @Override
            protected void initChannel(Channel channel) throws Exception {
                ChannelPipeline pipeline = channel.pipeline();
                pipeline.addFirst("1", new MyReplayingDecoder());
                pipeline.addAfter("1","2", new MyMessageToMessageDecoder());
                pipeline.addAfter("2","3",new MyChannelInboundHandler());
            }

        };
```

* 消息转换
```

import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.MessageToMessageDecoder;

import java.util.List;

public class MyMessageToMessageDecoder extends MessageToMessageDecoder<byte[]> {
    @Override
    protected void decode(ChannelHandlerContext channelHandlerContext, byte[] bytes, List<Object> list) throws Exception {
        list.add(new String(bytes));
    }
}
```

## TooLongFrameException类
* 由于Netty是一个异步框架，所以需要在字节可以解码之前在内存中缓冲它们。因此，
不能让解码器缓冲大量的数据以至于耗尽可用的内存。为了解除这个常见的顾虑，Netty提
供了TooLongFrameException 类，其将由解码器在帧超出指定的大小限制时抛出
* 代 码 清 单 10-4 展 示 了 ByteToMessageDecoder 是 如 何 使 用
TooLongFrameException 来通知ChannelPipeline 中的其他ChannelHandler 发
生了帧大小溢出的。需要注意的是，***如果你正在使用一个可变帧大小的协议，那么这种保
护措施将是尤为重要的***

```

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.ByteToMessageDecoder;
import io.netty.handler.codec.TooLongFrameException;

import java.util.List;

public class SafeByteToMessageDecoder extends ByteToMessageDecoder { // 扩展ByteToMessageDecoder以将字节解码为消息
    private static final int MAX_FRAME_SIZE = 1024;

    @Override
    public void decode(ChannelHandlerContext ctx, ByteBuf in, List<Object> out) throws Exception {
        int readable = in.readableBytes();
        if (readable > MAX_FRAME_SIZE) {// 检查缓冲区中是否有超过MAX_FRAME_SIZE个字节
            in.skipBytes(readable);// 跳过所有的可读字节，抛出TooLongFrame-Exception 并通知ChannelHandler
            throw new TooLongFrameException("Frame too big!");
        }
// do something

    }
}
```


## 编码器

## 抽象类MessageToByteEncoder
```
encode(ChannelHandlerContext ctx,I msg,ByteBuf out)
```
* 你可能已经注意到了，这个类只有一个方法，而解码器有两个。原因是解码器通常需
要在Channel 关闭之后产生最后一个消息（因此也就有了decod eLast()方法）。这显然不
适用于编码器的场景——在连接被关闭之后仍然产生一个消息是毫无意义的

* 编码器
```

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.MessageToByteEncoder;

public class StringToByteEncoder extends MessageToByteEncoder<String> { // 扩展了MessageToByteEncoder
    
    @Override
    public void encode(ChannelHandlerContext ctx, String msg, ByteBuf out) throws Exception {
        String s = msg + "code before:";//添加固定头
        out.writeBytes(s.getBytes());
    }
}
```

* 调用
```
 ChannelInitializer channelInitializer = new ChannelInitializer() {
            @Override
            protected void initChannel(Channel channel) throws Exception {
                ChannelPipeline pipeline = channel.pipeline();
                pipeline.addFirst("0", new SafeByteToMessageDecoder());
                pipeline.addAfter("0","1", new MyReplayingDecoder());
                pipeline.addAfter("1","2", new MyMessageToMessageDecoder());
                pipeline.addAfter("2","3",new MyChannelInboundHandler());
                pipeline.addAfter("3","4",new StringToByteEncoder());
            }

        };
```


## 抽象类MessageToMessageEncoder
* 转换器
```
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.MessageToMessageEncoder;

import java.util.List;

public class StringToIntegerEncoder  extends MessageToMessageEncoder<String> {
    @Override
    protected void encode(ChannelHandlerContext channelHandlerContext, String s, List<Object> list) throws Exception {
        channelHandlerContext.write(123);
    }
}
```

* 执行
```

        ChannelInitializer channelInitializer = new ChannelInitializer() {
            @Override
            protected void initChannel(Channel channel) throws Exception {
                ChannelPipeline pipeline = channel.pipeline();
                pipeline.addFirst("0", new SafeByteToMessageDecoder());
                pipeline.addAfter("0","1", new MyReplayingDecoder());
                pipeline.addAfter("1","2", new MyMessageToMessageDecoder());
                pipeline.addAfter("2","3",new MyChannelInboundHandler());
                pipeline.addAfter("3","4",new IntegerToByteEncoder());//这里进不去
                pipeline.addAfter("4","5",new StringToIntegerEncoder());//如果这个不转换
              //  pipeline.addAfter("5","6",new StringToByteEncoder());
            }

        };
```

## 抽象的编解码器类ByteToMessageCodec

```
decode(ChannelHandlerContext ctx,ByteBuf in,List<Object>)
只要有字节可以被消费，这个方法就将会被调用。它将入站 ByteBuf 转换为指定的消息格式，并将其转发给
ChannelPipeline 中的下一个 ChannelInboundHandler

decodeLast(ChannelHandlerContext ctx,ByteBuf in,List<Object> out)
这个方法的默认实现委托给了decode()方法。它只会在Channel的状态变为非活动时被调用一次。它可以被重写以实现特殊的处理

encode(ChannelHandlerContext ctx,I msg,ByteBuf out)
对于每个将被编码并写入出站 ByteBuf 的（类型为 I 的）消息来说，这个方法都将会被调用
```


## 抽象类MessageToMessageCodec
```
protected abstract decode(ChannelHandlerContext ctx,INBOUND_IN msg,List<Object> out)
这个方法被调用时会被传入 INBOUND_IN 类型的消息。它将把它们解码为 OUTBOUND_IN类型的消息，这些消息将被转发给 ChannelPipeline 中的下一个 Channel- InboundHandler

protected abstract encode(ChannelHandlerContext ctx,OUTBOUND_IN msg,List<Object> out)
对于每个 OUTBOUND_IN 类型的消息，这个方法都将会被调用。这些消息将会被编码为 INBOUND_IN 类型的消息，然后被转发给 ChannelPipeline 中的下一个 ChannelOutboundHandler
```

## 预置的ChannelHandler和编解码器

### 通过SSL/TLS保护Netty应用程序
* Netty通过一个名为SslHandler 的ChannelHandler 实现利用了这个API，其中SslHandler 在内部使用SSLEngine 来完成实际的工作

### SslHandler
```
setHandshakeTimeout (long,TimeUnit)
setHandshakeTimeoutMillis (long)
getHandshakeTimeoutMillis()
设置和获取超时时间，超时之后，握手 ChannelFuture 将会被通知失败

setCloseNotifyTimeout (long,TimeUnit)
setCloseNotifyTimeoutMillis (long)
getCloseNotifyTimeoutMillis()
设置和获取超时时间，超时之后，将会触发一个关闭通知并关闭连接。这也将会导致通知该 ChannelFuture 失败

handshakeFuture()
返回一个在握手完成后将会得到通知的 ChannelFuture 。如果握手先前已经执行过了，则返回一个包含了先前的握手结
果的 ChannelFuture

close()
close(ChannelPromise)
close(ChannelHandlerContext,ChannelPromise)
发送 close_notify 以请求关闭并销毁底层的 SslEngine
```

### HTTP解码器、编码器和编解码器
* [![0wruz6.md.png](https://s1.ax1x.com/2020/10/08/0wruz6.md.png)](https://imgchr.com/i/0wruz6)

* [![0wrQsO.md.png](https://s1.ax1x.com/2020/10/08/0wrQsO.md.png)](https://imgchr.com/i/0wrQsO)

如图11-2和图11-3所示，一个HTTP请求/响应可能由多个数据部分组成，并且它总是以
一个LastHttpContent 部分作为结束。
* FullHttpRequest 和FullHttpResponse 消息 是 特 殊 的 子 类 型， 分 别 代 表 了 完 整 的 请 求 和 响 应。 
* 所 有 类 型 的 HTTP 消 息（FullHttpRequest 、LastHttpContent以及代码清单11-2中展示的那些）都实现了
HttpObject 接口


### 一个http服务器demo

* ChannelInitializer
```

import com.utils.ContextPrinter;
import io.netty.channel.Channel;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelPipeline;
import io.netty.handler.codec.http.HttpRequestDecoder;
import io.netty.handler.codec.http.HttpRequestEncoder;
import io.netty.handler.codec.http.HttpResponseDecoder;
import io.netty.handler.codec.http.HttpResponseEncoder;

public class HttpPipelineInitializer extends ChannelInitializer<Channel> {
    private final boolean client;

    public HttpPipelineInitializer(boolean client) {
        this.client = client;
    }

    @Override
    protected void initChannel(Channel ch) throws Exception {
        ChannelPipeline pipeline = ch.pipeline();
        if (client) { // 如果是客户端，则添加HttpResponseDecoder 以处理来自服务器的响应
            pipeline.addLast("decoder", new HttpResponseDecoder());
            pipeline.addLast("encoder", new HttpRequestEncoder());// 如果是客户端，则添加HttpRequestEncoder以向服务器发送请求
        } else {
            pipeline.addLast("decoder", new HttpRequestDecoder()); // 如果是服务器，则添加HttpRequestDecoder以接收来自客户端的请求

            pipeline.addLast("encoder", new HttpResponseEncoder()); // 如果是服务器，则添加HttpResponseEncoder以向客户端发送响应

            pipeline.addAfter("encoder","bb",new BusinessChannelInboundHandlerAdapter());
        }
        //System.out.println(ch);
        ContextPrinter.print(ch);
    }
}

```

* ChannelInboundHandlerAdapter
```

import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelFutureListener;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInboundHandlerAdapter;
import io.netty.handler.codec.http.*;

public class BusinessChannelInboundHandlerAdapter  extends ChannelInboundHandlerAdapter {

    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {

        if (msg instanceof HttpRequest) {
            HttpRequest request = (HttpRequest) msg;
            FullHttpResponse  defaultHttpResponse = new DefaultFullHttpResponse(HttpVersion.HTTP_1_1, HttpResponseStatus.OK);
            defaultHttpResponse.content().writeBytes("<html><body>hi view </body></html>".getBytes());
            ctx.writeAndFlush(defaultHttpResponse).addListener(ChannelFutureListener.CLOSE);
        }
    }
}

```

* 在ChannelInitializer 将ChannelHandler 安装到ChannelPipeline 中之
后，你便可以处理不同类型的HttpObject 消息了。但是由于HTTP的请求和响应可能由
许多部分组成，因此你需要聚合它们以形成完整的消息。
* 为了消除这项繁琐的任务，Netty提 供 了 一 个 聚 合 器， 它 可 以 将 多 个 消 息 部 分 合 并 为 FullHttpRequest 或 者FullHttpResponse 消息。通过这样的方式，你将总是看到完整的消息内容
* 由 于 消 息 分 段 需 要 被 缓 冲， 直 到 可 以 转 发 一 个 完 整 的 消 息 给 下 一 个
ChannelInbound-Handler ，所以这个操作有轻微的开销。其所带来的好处便是你不必
关心消息碎片了
* 引 入 这 种 自 动 聚 合 机 制 只 不 过 是 向 ChannelPipeline 中 添 加 另 外 一 个
ChannelHandler 罢了

