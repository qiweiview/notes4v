# Java连接FTP



## 依赖
* 依托apache commons-net包
```
 <!-- https://mvnrepository.com/artifact/commons-net/commons-net -->
        <dependency>
            <groupId>commons-net</groupId>
            <artifactId>commons-net</artifactId>
            <version>3.7.2</version>
        </dependency>

```

## 实现
* 默认主动模式
* [模式区别参照](https://github.com/qiweiview/notes4v/blob/master/others/FTP%E7%9A%84%E4%B8%BB%E5%8A%A8%E6%A8%A1%E5%BC%8F%E5%92%8C%E8%A2%AB%E5%8A%A8%E6%A8%A1%E5%BC%8F.md)
```
 final FTPClient ftp = new FTPClient();
        ftp.connect("192.168.216.216", 21);
        int replyCode = ftp.getReplyCode();

        if (!FTPReply.isPositiveCompletion(replyCode)) {
            ftp.disconnect();
            System.err.println("FTP server refused connection.");
            System.exit(1);
        }
        boolean success = ftp.login("test", "test");
        if (success){
            System.out.println("login success");
        }else {
            System.out.println("login fail");

        }
        ftp.setFileType(FTP.BINARY_FILE_TYPE);

        //ftp.enterLocalPassiveMode(); //进入被动模式

        boolean b = ftp.storeFile("/daqi/hi2", new ByteArrayInputStream("hi daqi 222".getBytes()));

        System.out.println("store file "+b);

        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();

        boolean b1 = ftp.retrieveFile("/daqi/hi2", byteArrayOutputStream);

        System.out.println("load file "+b1);

        String s = new String(byteArrayOutputStream.toByteArray());

        System.out.println(s);

```
