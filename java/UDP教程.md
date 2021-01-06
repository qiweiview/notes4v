# UDP教程

* 单包最大65507 byte

```
// 65508>65507会报错:
// SocketException: The message is larger than the maximum supported by the underlying transport: Datagram send failed

 		byte[] bytes2=new byte[65508];
        DatagramPacket datagramPacket2 = new DatagramPacket(bytes2, 0, 			bytes2.length, inetAddress, 889);
```

## 客户端
```
  DatagramSocket socket = new DatagramSocket();
  byte[] bytes = {0x2f,0x1f};
  DatagramPacket datagramPacket1 = new DatagramPacket(bytes, 0, bytes.length, inetAddress, 889);
  socket.send(datagramPacket2);
```

## 服务端
```
        
        DatagramSocket socket = new DatagramSocket(889);
        while (true){
            byte[] bytes2=new byte[64*1024];
            DatagramPacket datagramPacket2 = new DatagramPacket(bytes2, 0, bytes2.length);
            socket.receive(datagramPacket2);
            byte[] bytes = Arrays.copyOfRange(datagramPacket2.getData(), 0, datagramPacket2.getLength());
            System.out.println(Arrays.toString(bytes));
        }

```


##  组播
### 发送
```
  String name= UUID.randomUUID().toString();
        MulticastSocket multicastSocket=new MulticastSocket();
        InetAddress byName = InetAddress.getByName("224.2.2.2");
        multicastSocket.joinGroup(byName);
        while (true){
            byte[] bytes = "hi zubo".getBytes();
            DatagramPacket datagramPacket1 = new DatagramPacket(bytes, bytes.length, byName, 4000);
            multicastSocket.send(datagramPacket1);
            TimeUnit.SECONDS.sleep(2);
            System.out.println("发送");
        }
```

### 接收

```

        MulticastSocket multicastSocket=new MulticastSocket(4000);
        InetAddress byName = InetAddress.getByName("224.2.2.2");
        multicastSocket.joinGroup(byName);



        while (true){
            byte[] bytes2=new byte[64*1024];
            DatagramPacket datagramPacket2 = new DatagramPacket(bytes2, 0, bytes2.length);
            multicastSocket.receive(datagramPacket2);
            System.out.println(new String(datagramPacket2.getData()));
        }

```
