## Ubuntu安装Mysql

```
#命令1
sudo apt-get update
#命令2
sudo apt-get install mysql-server
```

运行快捷配置
```
mysql_secure_installation
```

查看运行状态
```
systemctl status mysql.service
```


### 配置远程登录
```
mysql -uroot -p
```

以root进入mysql后也可用命令给root设置密码：
```
GRANT ALL PRIVILEGES ON *.* TO root@localhost IDENTIFIED BY "123456";
```

进行远程访问或控制配置
```
##1 允许root用户可以从任意机器上登入mysql
GRANT ALL PRIVILEGES ON *.* TO root@"%" IDENTIFIED BY "654321"; 
```

修改配置文件，注释绑定的本地回旋地址
```
bind_address=127.0.0.1
```