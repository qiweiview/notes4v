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
