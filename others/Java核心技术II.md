# Java核心技术II

## 流

* 流不存储元素
* 流不改变元素
* 流惰性执行
### 创建流
```
Stream<Integer> integerStream = Stream.of(1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
List<Integer> list=new ArrayList<>();
Stream<Integer> stream = list.stream();
Stream<Integer> integerStream1 = list.parallelStream();//并行流
Stream<Object> empty = Stream.empty();
Stream<String> generate = Stream.generate(() -> { return "hello";});//无限流
Stream<BigInteger> iterate = Stream.iterate(BigInteger.ZERO, n -> n.add(BigInteger.ONE));//无限流
Stream<String> lines = Files.lines(Paths.get(""));//包含文件所有行的流
```

### 过滤流
```
Stream<T> filter(Predicate<? super T> predicate);
```

### 映射流
* 函数映射到每个元素上
```
<R> Stream<R> map(Function<? super T, ? extends R> mapper);
```

### 跳过流
* 丢弃前n个元素
```
Stream<T> skip(long n);
```

### 连接流
```
Stream.concat(stream1,stream2)
```

### 剔除重复
```
Stream<T> distinct();
```

### 对流进行排序
* 接收一个比较器
```
Stream<T> sorted();
```

### 返回流本身但会执行函数
```
Stream<T> peek(Consumer<? super T> action);
```

### 约简操作
```
Optional<T>  max(Comparator c)
Optional<T>  min(Comparator c)
Optional<T>  findFirst()
Optional<T>  findAny()
boolean anyMatch(Predicate<? super T> predicate);
boolean allMatch(Predicate<? super T> predicate);
boolean noneMatch(Predicate<? super T> predicate);
```

### Optional
* 见源码分析

### 收集结果
```
void forEach(Consumer<? super T> action);//迭代执行函数，存在异步

void forEachOrdered(Consumer<? super T> action);//按顺序迭代函数

Object[] toArray();//返回数组

<A> A[] toArray(IntFunction<A[]> generator);//传入数组构造器，返回对应类型数组

<R, A> R collect(Collector<? super T, A, R> collector);//返回集合，通过Collectors类生成公共收集器

List<String> list = lines.collect(Collectors.toList());
Set<String> set = lines.collect(Collectors.toSet());
Map<String, String> map = lines.collect(Collectors.toMap(x -> x, y -> y));
```

# IO
* 两部分：InputStream和OutputStream
* 对于Unicode使用Reader和Writer
* 对于实现Closeable接口的类可以使用try()catch自动关闭
* 通过装饰者模式嵌套添加多重功能


#网络

## 打开服务器
```
 try (ServerSocket serverSocket = new ServerSocket(8189);) {
            while (true) {
                System.out.println("等待请求");
                Socket accept = serverSocket.accept();//无请求阻塞
                work(accept);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
```

### 请求
```
try (Socket socket = new Socket("127.0.0.1", 8189); InputStream inputStream = socket.getInputStream(); OutputStream outputStream = socket.getOutputStream();) {
            outputStream.write("im view ".getBytes());
            socket.shutdownOutput();
            byte[] bytes = inputStream.readAllBytes();
            System.out.println(new String(bytes));
        }
```






