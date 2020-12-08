# Java Nio教程


## Demo
```
   ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();
        serverSocketChannel.bind(new InetSocketAddress(888));
        serverSocketChannel.configureBlocking(false);
        while (true){
            SocketChannel accept = serverSocketChannel.accept();
           if (accept==null){
               continue;
           }else {
               ByteBuffer allocate = ByteBuffer.allocate(1024 * 1024);
               int read = accept.read(allocate);
               allocate.flip();
               byte[] bytes=new byte[read];
               allocate.get(bytes,0,read);
               new String(bytes);
           }
        }


```

## Buffer缓冲区
```
public abstract class Buffer｛
    private int mark = -1;//标志位
    private int position = 0;//下一个要读或要写的位置，位置会自动由相应的get()和put()函数更新
    private int limit;//缓冲区第一个不能被读或写的元素，缓冲区现存元素的计数
    private int capacity;//缓冲区能够容纳数据元素的最大数量，这一变量在缓冲区创建时被设定，并永远不能改变
｝
```

* put运算如果导致超出limit会抛出BufferOverflowException
* get不小于limit会抛出BufferUnderflowException

### flip()
```
public Buffer flip() {
        limit = position;
        position = 0;
        mark = -1;
        return this;
    }
```

### rewind()
```
public Buffer rewind() {
        position = 0;
        mark = -1;
        return this;
    }
```

### hasRemaining()
```
public final boolean hasRemaining() {
        return position < limit;
    }
```

### remaining()
```
public final int remaining() {
        return limit - position;
    }
```

### clear() 
```
public Buffer clear() {
        position = 0;
        limit = capacity;
        mark = -1;
        return this;
    }
```

### compact()
```
public ByteBuffer compact() {
        System.arraycopy(hb, ix(position()), hb, ix(0), remaining());
        position(remaining());
        limit(capacity());
        discardMark();
        return this;
    }
```

### mark()
```
public Buffer mark() {
        mark = position;
        return this;
    }
```

### reset()
```
public Buffer reset() {
        int m = mark;
        if (m < 0)
            throw new InvalidMarkException();
        position = m;
        return this;
    }
```

### equals(Object ob)
* 缓冲区剩余内容相同则返回true(即position到limit元素相同，之外的元素不同也返回true)
* 两个对象类型要相同
```
 public boolean equals(Object ob) {
        if (this == ob)
            return true;
        if (!(ob instanceof ByteBuffer))
            return false;
        ByteBuffer that = (ByteBuffer)ob;
        if (this.remaining() != that.remaining())
            return false;
        return BufferMismatch.mismatch(this, this.position(),
                                       that, that.position(),
                                       this.remaining()) < 0;
    }
```

### compareTo(ByteBuffer that)以词典排序方式比较
* 返回负整数，0，正整数
* 不允许不同对象类型进行比较
* compareTo不能交换
```
 public int compareTo(ByteBuffer that) {
        int i = BufferMismatch.mismatch(this, this.position(),
                                        that, that.position(),
                                        Math.min(this.remaining(), that.remaining()));
        if (i >= 0) {
            return compare(this.get(this.position() + i), that.get(that.position() + i));
        }
        return this.remaining() - that.remaining();
    }
```

### get(byte[] dst)批量获取
* 传入的数组长度大于剩余可读取长度抛出异常，不会有数据被传输
```
 public ByteBuffer get(byte[] dst) {
        return get(dst, 0, dst.length);
    }
```

### get(byte[] dst, int offset, int length)
```
public ByteBuffer get(byte[] dst, int offset, int length) {
        checkBounds(offset, length, dst.length);
        if (length > remaining())
            throw new BufferUnderflowException();
        int end = offset + length;
        for (int i = offset; i < end; i++)
            dst[i] = get();
        return this;
    }
```

### put(byte[] src)批量写入
* 传入的数据长度大于剩余空间抛出异常
```
public final ByteBuffer put(byte[] src) {
        return put(src, 0, src.length);
    }
```

### put(byte[] src, int offset, int length)
```
public ByteBuffer put(byte[] src, int offset, int length) {
        checkBounds(offset, length, src.length);
        if (length > remaining())
            throw new BufferOverflowException();
        int end = offset + length;
        for (int i = offset; i < end; i++)
            this.put(src[i]);
        return this;
    }
```

### allocate(int capacity)创建一个指定大小的缓冲区
```
public static ByteBuffer allocate(int capacity) {
        if (capacity < 0)
            throw createCapacityException(capacity);
        return new HeapByteBuffer(capacity, capacity);
    }
```

### wrap(byte[] array)自定义数组创建缓冲区
```
 public static ByteBuffer wrap(byte[] array) {
        return wrap(array, 0, array.length);
    }
```

### wrap(byte[] array,int offset, int length)
* position: offset
* limit: offset+length<array.length
```
public static ByteBuffer wrap(byte[] array,int offset, int length)
    {
        try {
            return new HeapByteBuffer(array, offset, length);
        } catch (IllegalArgumentException x) {
            throw new IndexOutOfBoundsException();
        }
    }
```

### duplicate()复制缓冲区
*  位置独立，数据共享
```
 public ByteBuffer duplicate() {
        return new HeapByteBuffer(hb,
                                        this.markValue(),
                                        this.position(),
                                        this.limit(),
                                        this.capacity(),
                                        offset);
    }
```

### asReadOnlyBuffer()复制只读缓冲区（带R的）
* put方法会报异常
```
public ByteBuffer asReadOnlyBuffer() {

        return new HeapByteBufferR(hb,
                                     this.markValue(),
                                     this.position(),
                                     this.limit(),
                                     this.capacity(),
                                     offset);



    }
```

### slice()分割剩余缓冲区
```
 public ByteBuffer slice() {
        return new HeapByteBuffer(hb,
                                        -1,
                                        0,
                                        this.remaining(),
                                        this.remaining(),
                                        this.position() + offset);
    }
```

## 通道Channel



### FileChannel
* 只能通过RandomAccessFile，FileInputStream，FileOutputStream获取
```
 FileChannel channel = randomAccessFile.getChannel();
```

```
truncate(long size)//会砍掉指定size外的所有数据，文件position会被设置成size位
```

lock(范例没有成功)
```
lock()//在整个文件上请求
lock(0L,Integer.MAX_VLUE,false)//方法均返回一个FileLock对象
```
* FileChannel是线程安全的

连接通道，通道和通道之间传输
```
transferTo()
transferFrom()
```

### SocketChannel

tcp请求
```
 SocketChannel localhost = SocketChannel.open(new InetSocketAddress("qw607.com", 80));
```

### ServerSocketChannel
tcp服务器
```
public static void openTcpServer() throws IOException {


        ByteBuffer response = getResponse();
        response.limit();
        response.put("".getBytes());
        ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();
        serverSocketChannel.bind(new InetSocketAddress(80));
        serverSocketChannel.configureBlocking(false);

        System.out.println("服务器启动");
        ByteBuffer byteBuffer = ByteBuffer.allocate(1024);
        while (true) {
            SocketChannel accept = serverSocketChannel.accept();
            if (accept == null) {
            
            } else {
                try {
                    accept.read(byteBuffer);
                    byteBuffer.rewind();
                    System.out.println("request:" + new String(byteBuffer.array()));
                    accept.write(response);
                } catch (IOException e) {
                    System.out.println(e.getMessage());
                } finally {
                    response.rewind();
                    accept.close();
                }
            }
        }
    }
```
 
### DatagramChannel
udp请求
```
        ByteBuffer allocate = ByteBuffer.wrap("".getBytes());
        DatagramChannel open = DatagramChannel.open();
        int localhost = open.send(allocate, new InetSocketAddress("127.0.0.1", 1234));
```
udp服务器
```
public static void openUdpServer() throws IOException {
        ByteBuffer allocate = ByteBuffer.allocate(1024);
        DatagramChannel open = DatagramChannel.open();
        DatagramChannel localhost = open.bind(new InetSocketAddress("localhost", 80));
        localhost.configureBlocking(false);

        while (true) {
            InetSocketAddress receive = (InetSocketAddress) localhost.receive(allocate);
            if (receive != null) {
                System.out.println(receive.getHostString() + ":" + receive.getPort() + "====>" + new String(allocate.rewind().array()));
            }
        }
    }
```


## 选择器

### 开启服务器
```
        ByteBuffer writeBuffer = ByteBuffer.allocate(2*1024);
        ByteBuffer readBuffer = ByteBuffer.allocate(1024);

        ServerSocketChannel ssc = ServerSocketChannel.open();
        ssc.socket().bind(new InetSocketAddress("127.0.0.1", 80));
        ssc.configureBlocking(false);

        Selector selector = Selector.open();
        ssc.register(selector, SelectionKey.OP_ACCEPT);
        System.out.println("服务器启动...");


        while (true) {
            int readyNum = selector.select();
            if (readyNum == 0) {
                continue;
            }

            Set<SelectionKey> selectedKeys = selector.selectedKeys();
            Iterator<SelectionKey> it = selectedKeys.iterator();

            while (it.hasNext()) {
                SelectionKey key = it.next();

                if (key.isAcceptable()) {
                    ServerSocketChannel serverSocketChannel = (ServerSocketChannel) key.channel();
                    SocketChannel socketChannel = serverSocketChannel.accept();
                    socketChannel.configureBlocking(false);
                    socketChannel.register(selector, SelectionKey.OP_READ);

                    // 接受连接
                } else if (key.isReadable()) {
                    SocketChannel socketChannel = (SocketChannel) key.channel();

                    int read = socketChannel.read(readBuffer);
                    num++;
                    System.out.println(num);
                    socketChannel.register(selector, SelectionKey.OP_WRITE);
                    // 通道可读
                } else if (key.isWritable()) {
                    SocketChannel socketChannel = (SocketChannel) key.channel();
                    writeBuffer.clear();
                    String response="HTTP/1.1 200 OK\n\r" +
                            "Date: Sat, 31 Dec 2019 23:59:59 GMT\n\r" +
                            "Content-Type: text/html;charset=UTF-8\n\r" +
                            "Content-Length: 122\n\r" +
                            "Set-Cookie: ZD_ENTRY=google; path=/; domain=.vv.com\n\r"+
                            "\n\r" +
                            "123456789";
                    writeBuffer.put(response.getBytes());
                    writeBuffer.flip();
                    socketChannel.write(writeBuffer);
                    socketChannel.close();
                    // 通道可写
                }

                it.remove();
            }
        }
```
