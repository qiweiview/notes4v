# mysql主从复制
## 配置主节点
```
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
server-id=10
log-bin=mysql-bin
relay-log=mysql-relay-bin
replicate-wild-ignore-table=mysq.%
```
## 在主服务器上建立帐户并授权slave
```
mysql>GRANT REPLICATION SLAVE ON *.*  TO sqlsync@10.33.133.162 IDENTIFIED BY '123456';
mysql>FLUSH PRIVILEGES;
```

## 登录主服务器的mysql，查询master的状态
```
 mysql>show master status;
   +------------------+----------+--------------+------------------+
   | File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
   +------------------+----------+--------------+------------------+
   | mysql-bin.000001 |      517 |              |                  |
   +------------------+----------+--------------+------------------+
   1 row in set (0.00 sec)
```

## 配置从节点
```
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
server-id=21
log-bin=mysql-bin
replicate-wild-ignore-table=mysql.%
```

## 配置从服务器Slave：
```
 mysql>change master to master_host='10.33.133.160',master_user='sqlsync',master_password='123456',master_log_file='mysql-bin.000001',master_log_pos=517;
```

## 启动从服务器复制功能
```
Mysql>start slave;    //启动从服务器复制功能
```
## 检查从服务器复制功能状态：
```
 mysql> show slave status\G

   *************************** 1. row ***************************

              Slave_IO_State: Waiting for master to send event
              Master_Host: 10.33.133.160  //主服务器地址
              Master_User: sqlsync   //授权帐户名，尽量避免使用root
              Master_Port: 3306    //数据库端口，部分版本没有此行
              Connect_Retry: 60
              Master_Log_File: mysql-bin.000001
              Read_Master_Log_Pos: 822    //#同步读取二进制日志的位置，大于等于Exec_Master_Log_Pos
              Relay_Log_File: ddte-relay-bin.000001
              Relay_Log_Pos: 251
              Relay_Master_Log_File: mysql-bin.000001
              Slave_IO_Running: Yes    //此状态必须YES
              Slave_SQL_Running: Yes     //此状态必须YES
                    ......

注：Slave_IO及Slave_SQL进程必须正常运行，即YES状态，否则都是错误的状态(如：其中一个NO均属错误)。
```

## 查看主节点的master状态
```
show master status;
```
