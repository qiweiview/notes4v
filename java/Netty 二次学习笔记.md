# Netty 二次笔记



## 基础篇
### EventLoop组成
[![059NQJ.png](https://s1.ax1x.com/2020/10/14/059NQJ.png)](https://imgchr.com/i/059NQJ)

* ***EventLoop***实现了***OrderedEventExecutor***和***EventLoopGroup***接口
```
public interface EventLoop extends OrderedEventExecutor, EventLoopGroup
```

* ***OrderedEventExecutor***接口继承***EventExecutor***，没用添加任何方法
```
public interface OrderedEventExecutor extends EventExecutor
```
* ***EventExecutor***继承***EventExecutorGroup***接口，拓展了方法
```
public interface EventExecutor extends EventExecutorGroup
```
* ***EventLoopGroup***继承了***EventExecutorGroup***接口，拓展了方法
```
public interface EventLoopGroup extends EventExecutorGroup
```
* ***EventExecutorGroup***继承了类库***ScheduledExecutorService***，***Iterable***接口并拓展了方法
```
public interface EventExecutorGroup extends ScheduledExecutorService, Iterable<EventExecutor>
```
* 每个channel包含一个自己的EventLoop

### ChannelInboundHandler接口执行顺序
```
channelRegistered
👇
channelActive
👇
channelRead
👇
channelReadComplete
👇
channelReadComplete
👇
channelInactive
👇
channelUnregistered
```


## Http服务器篇

### 重定向
```
public static class RedirectHandle extends ChannelInboundHandlerAdapter {
        @Override
        public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
            if (msg instanceof FullHttpRequest) {
                FullHttpResponse defaultHttpResponse = new DefaultFullHttpResponse(HttpVersion.HTTP_1_1, HttpResponseStatus.TEMPORARY_REDIRECT);
                HttpHeaders headers = defaultHttpResponse.headers();
                headers.set(HttpHeaderNames.ACCESS_CONTROL_ALLOW_HEADERS, "x-requested-with,content-type");
                headers.set(HttpHeaderNames.ACCESS_CONTROL_ALLOW_METHODS, "POST,GET");
                headers.set(HttpHeaderNames.ACCESS_CONTROL_ALLOW_ORIGIN, "*");
                headers.set(HttpHeaderNames.CONTENT_LENGTH, defaultHttpResponse.content().readableBytes());
                headers.set(HttpHeaderNames.LOCATION, "http://www.baidu.com"); //重定向URL设置
                ctx.writeAndFlush(defaultHttpResponse).addListener(ChannelFutureListener.CLOSE);
            }
        }
    }
```

### 只使用HttpServerCodec
* 只使用HttpServerCodec
```
 pipeline.addFirst("cdc",new HttpServerCodec());
```
* 那么后续处理器会收到DefaultHttpRequest
* 里面包含请求头
```
DefaultHttpRequest extends DefaultHttpMessage implements HttpRequest
```
* 和LastHttpContent
* 里面包含请求体
```
public interface LastHttpContent extends HttpContent
```


### 使用HttpObjectAggregator进行聚合
* 使用HttpObjectAggregator
```
pipeline.addAfter("cdc","oag",new HttpObjectAggregator(2*1024 * 1024));//限制缓冲最大值为2mb
```
* 那么后续处理器会收到***FullHttpRequest***实现了两个接口
```
FullHttpRequest extends HttpRequest, FullHttpMessage
```
* 而***FullHttpMessage***实现了***LastHttpContent***
```
public interface FullHttpMessage extends HttpMessage, LastHttpContent
```
* 因此可以看出***FullHttpRequest***是对***DefaultHttpRequest***和***LastHttpContent***的整合
* 读取的时候需要以***FullHttpRequest***读取
```
if (msg instanceof FullHttpRequest) {
                FullHttpRequest fullHttpRequest = (FullHttpRequest) msg;
}
```
* 否则要分成两部分判断接收
```
if (msg instanceof DefaultHttpRequest) {
//case change
}

if (msg instanceof LastHttpContent) {
//case change
}
```
---

* 同理,响应也一样要使用***FullHttpResponse***反向才能解析
```
FullHttpResponse defaultHttpResponse = new DefaultFullHttpResponse(HttpVersion.HTTP_1_0, HttpResponseStatus.UNAUTHORIZED,Unpooled.copiedBuffer("未登录".getBytes()));
// 也可以通过这种方式写入
// defaultHttpResponse.content().writeBytes("未登录".getBytes());
```
* 否则没有使用HttpObjectAggregator情况下响应要分开写入
```
            DefaultHttpResponse defaultHttpResponse = new DefaultHttpResponse(HttpVersion.HTTP_1_0, HttpResponseStatus.OK);
            defaultHttpResponse.headers().set(HttpHeaderNames.CONTENT_TYPE, "application/json");
            ctx.write(defaultHttpResponse);
            DefaultHttpContent defaultHttpContent = new DefaultHttpContent(Unpooled.copiedBuffer("未登录".getBytes()));
            ctx.writeAndFlush(defaultHttpContent).addListener(ChannelFutureListener.CLOSE);

```

### 支持Auth Basic
```
HttpHeaders headers = fullHttpRequest.headers();
String s = headers.get(HttpHeaderNames.AUTHORIZATION);
 if (s == null) {//判断包含authorization头是否
 
 FullHttpResponse defaultHttpResponse = new DefaultFullHttpResponse(HttpVersion.HTTP_1_1, HttpResponseStatus.UNAUTHORIZED);//如果不包含写入401
 
 defaultHttpResponse.headers().set(HttpHeaderNames.WWW_AUTHENTICATE, "Basic realm=\"need password\"");//以及www-authenticate头，不写入不弹框
 
 ctx.writeAndFlush(defaultHttpResponse).addListener(ChannelFutureListener.CLOSE);//返回
                } 
```








