# Service使用

## 要把一个程序注册成系统服务，首先得给出一个供service命令调用的脚本文件放到目录/etc/rc.d/init.d/中去

```
service httpd 等价 /etc/rc.d/init.d/httpd

service httpd start 等价 /etc/rc.d/init.d/httpd  start

service httpd stop 等价 /etc/rc.d/init.d/httpd  stop
```
