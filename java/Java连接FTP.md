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

        boolean b = ftp.storeFile("/daqi/hi2", new ByteArrayInputStream("hi daqi 222".getBytes()));

        System.out.println("store file "+b);

        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();

        boolean b1 = ftp.retrieveFile("/daqi/hi2", byteArrayOutputStream);

        System.out.println("load file "+b1);

        String s = new String(byteArrayOutputStream.toByteArray());

        System.out.println(s);

```
