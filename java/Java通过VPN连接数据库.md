# Java通过VPN连接数据库

## 操作系统如果有IPV6环境，应用程序会使用IPV6进行连接。如果只希望应用使用ipv4必须指定修改参数为
```
-Djava.net.preferIPv4Stack=true
```
