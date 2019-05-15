## 数据源和目标媒介
* 文件
* 管道
* 网络连接
* 内存缓存
* System.in, System.out, System.error(注：Java标准输入、输出、错误输出)

## Java IO的类型
1. 输入流：InputStream和Reader
2. 输出流：OutputStream和Writer
![image.png](https://i.loli.net/2019/02/27/5c75e041ec418.png)

## IO类库
### 各类关系
![image.png](https://i.loli.net/2019/02/27/5c75e067354ae.png)
### 类负责媒介
![image.png](https://i.loli.net/2019/02/27/5c75e0af0c0e8.png)

## 用字节流写文件
```
  public static void writeByteToFile() throws IOException{
        String hello= new String( "hello word!");
         byte[] byteArray= hello.getBytes();
        File file= new File( "d:/test.txt");
         //因为是用字节流来写媒介，所以对应的是OutputStream 
         //又因为媒介对象是文件，所以用到子类是FileOutputStream
        OutputStream os= new FileOutputStream( file);
         os.write( byteArray);
         os.close();
  }
```

## 用流读文件
```
  public static void readByteFromFile() throws IOException{
        File file= new File( "d:/test.txt");
         byte[] byteArray= new byte[( int) file.length()];
         //因为是用字节流来读媒介，所以对应的是InputStream
         //又因为媒介对象是文件，所以用到子类是FileInputStream
        InputStream is= new FileInputStream( file);
         int size= is.read( byteArray);
        System. out.println( "大小:"+size +";内容:" +new String(byteArray));
         is.close();
  }
```

## 用字符流读文件
```
  public static void readCharFromFile() throws IOException{
        File file= new File( "d:/test.txt");
         //因为是用字符流来读媒介，所以对应的是Reader
         //又因为媒介对象是文件，所以用到子类是FileReader
        Reader reader= new FileReader( file);
         char [] byteArray= new char[( int) file.length()];
         int size= reader.read( byteArray);
        System. out.println( "大小:"+size +";内容:" +new String(byteArray));
         reader.close();
  }
```

## 用字符流写文件
```
  public static void writeCharToFile() throws IOException{
        String hello= new String( "hello word!");
        File file= new File( "d:/test.txt");
         //因为是用字符流来读媒介，所以对应的是Writer，又因为媒介对象是文件，所以用到子类是FileWriter
        Writer os= new FileWriter( file);
         os.write( hello);
         os.close();
  }
```

## 字节流转换为字符流
```
  public static void convertByteToChar() throws IOException{
        File file= new File( "d:/test.txt");
         //获得一个字节流
        InputStream is= new FileInputStream( file);
         //把字节流转换为字符流，其实就是把字符流和字节流组合的结果。
        Reader reader= new InputStreamReader( is);
         char [] byteArray= new char[( int) file.length()];
         int size= reader.read( byteArray);
        System. out.println( "大小:"+size +";内容:" +new String(byteArray));
         is.close();
         reader.close();
  }
```

## 随机读取File文件RandomAccessFile
### 随机读取文件
```
  public static void randomAccessFileRead() throws IOException {
         // 创建一个RandomAccessFile对象
        RandomAccessFile file = new RandomAccessFile( "d:/test.txt", "rw");
         // 通过seek方法来移动读写位置的指针
         file.seek(10);
         // 获取当前指针
         long pointerBegin = file.getFilePointer();
         // 从当前指针开始读
         byte[] contents = new byte[1024];
         file.read( contents);
         long pointerEnd = file.getFilePointer();
        System. out.println( "pointerBegin:" + pointerBegin + "\n" + "pointerEnd:" + pointerEnd + "\n" + new String(contents));
         file.close();
  }
```

### 随机写入文件

```
  public static void randomAccessFileWrite() throws IOException {
         // 创建一个RandomAccessFile对象
        RandomAccessFile file = new RandomAccessFile( "d:/test.txt", "rw");
         // 通过seek方法来移动读写位置的指针
         file.seek(10);
         // 获取当前指针
         long pointerBegin = file.getFilePointer();
         // 从当前指针位置开始写
         file.write( "HELLO WORD".getBytes());
         long pointerEnd = file.getFilePointer();
        System. out.println( "pointerBegin:" + pointerBegin + "\n" + "pointerEnd:" + pointerEnd + "\n" );
         file.close();
  }
```

## Java IO：管道媒介
***管道主要用来实现同一个虚拟机中的两个线程进行交流。因此，一个管道既可以作为数据源媒介也可作为目标媒介。***
### 读写管道
```
public class PipeExample {
   public static void main(String[] args) throws IOException {
          final PipedOutputStream output = new PipedOutputStream();
          final PipedInputStream  input  = new PipedInputStream(output);
          Thread thread1 = new Thread( new Runnable() {
              @Override
              public void run() {
                  try {
                      output.write( "Hello world, pipe!".getBytes());
                  } catch (IOException e) {
                  }
              }
          });
          Thread thread2 = new Thread( new Runnable() {
              @Override
              public void run() {
                  try {
                      int data = input.read();
                      while( data != -1){
                          System. out.print(( char) data);
                          data = input.read();
                      }
                  } catch (IOException e) {
                  } finally{
                     try {
                                       input.close();
                                } catch (IOException e) {
                                       e.printStackTrace();
                                }
                  }
              }
          });
          thread1.start();
          thread2.start();
      }
}
```

## Java IO：网络媒介

## Java IO：BufferedInputStream和BufferedOutputStream
### 用缓冲流读文件
**关于如何设置buffer的大小，我们应根据我们的硬件状况来确定。对于磁盘IO来说，如果硬盘每次读取4KB大小的文件块，那么我们最好设置成这个大小的整数倍。因为磁盘对于顺序读的效率是特别高的，所以如果buffer再设置的大写可能会带来更好的效率，比如设置成4*4KB或8*4KB。还需要注意一点的就是磁盘本身就会有缓存，在这种情况下，BufferedInputStream会一次读取磁盘缓存大小的数据，而不是分多次的去读。所以要想得到一个最优的buffer值，我们必须得知道磁盘每次读的块大小和其缓存大小，然后根据多次试验的结果来得到最佳的buffer大小。**

```
public static void readByBufferedInputStream() throws IOException {
      File file = new File( "d:/test.txt");
      byte[] byteArray = new byte[( int) file.length()];
      //可以在构造参数中传入buffer大小
      InputStream is = new BufferedInputStream( new FileInputStream(file),2*1024);
      int size = is.read( byteArray);
      System. out.println( "大小:" + size + ";内容:" + new String(byteArray));
      is.close();
}
```
## Java IO：BufferedReader和BufferedWriter
```
public static void readByBufferedReader() throws IOException {
      File file = new File( "d:/test.txt");
      // 在字符流基础上用buffer流包装，也可以指定buffer的大小
      Reader reader = new BufferedReader( new FileReader(file),2*1024);
      char[] byteArray = new char[( int) file.length()];
      int size = reader.read( byteArray);
      System. out.println( "大小:" + size + ";内容:" + new String(byteArray));
      reader.close();
}
```