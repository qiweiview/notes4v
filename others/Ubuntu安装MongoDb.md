## Ubuntu安装MongoDb

1. 添加mongodb签名到APT
```
$ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
```
2. 创建/etc/apt/sources.list.d/mongodb-org-3.2.list文件并执行
```
$ echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
```
3. 更新软件源列表
```
$ sudo apt-get update
```
4. 安装mongodb（默认是安装稳定版）
```
$ sudo apt-get install  mongodb
```

5. 手动启动
```
mongod //服务端
mongo //客户端
```

6. 基础命令
```
启动: sudo service mongod start
停止: sudo service mongod stop
重启: sudo service mongod restart
```