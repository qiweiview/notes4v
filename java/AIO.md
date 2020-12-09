# AIO
```


        final int port = 888;
        //首先打开一个ServerSocket通道并获取AsynchronousServerSocketChannel实例：
        AsynchronousServerSocketChannel serverSocketChannel = AsynchronousServerSocketChannel.open();
        //绑定需要监听的端口到serverSocketChannel:
        InetSocketAddress inetSocketAddress = new InetSocketAddress(port);
        serverSocketChannel.bind(inetSocketAddress);
        //实现一个CompletionHandler回调接口handler，
        //之后需要在handler的实现中处理连接请求和监听下一个连接、数据收发，以及通信异常。
        CompletionHandler<AsynchronousSocketChannel, Object> handler = new CompletionHandler<AsynchronousSocketChannel, Object>() {
            @Override
            public void completed(final AsynchronousSocketChannel result, final Object attachment) {
                // 继续监听下一个连接请求
                serverSocketChannel.accept(attachment, this);

                try {
                    System.out.println("接受了一个连接：" + result.getRemoteAddress().toString());

                    // 给客户端发送数据并等待发送完成
                    result.write(ByteBuffer.wrap("From Server:Hello i am server".getBytes())).get();

                    ByteBuffer readBuffer = ByteBuffer.allocate(128);
                    // 阻塞等待客户端接收数据
                    result.read(readBuffer).get();
                    System.out.println(new String(readBuffer.array()));

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void failed(final Throwable exc, final Object attachment) {
                System.out.println("出错了：" + exc.getMessage());
            }
        };
        serverSocketChannel.accept(null, handler);
        Thread currentThread = Thread.currentThread();
        synchronized (currentThread) {
            currentThread.wait();
        }


 
```
