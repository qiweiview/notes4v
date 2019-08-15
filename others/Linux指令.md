# Linux指令
### 递归删除
```
rm -rf /home/test
```

### 查看端口
```
//UDP类型的端口
netstat -nupl

//TCP类型的端口
netstat -ntpl
```

### 查看指定端口
```
 netstat -ap | grep 81
 
 lsof -i:81
 
 netstat -pan|grep 81
```

### 开启端口
```
firewall-cmd --zone=public --add-port=81/tcp --permanent;firewall-cmd --reload;
```


## 查看内存使用前10
```
ps auxw|head -1;ps auxw|sort -rn -k4|head -10 
```

### CPU占用最多的前10个进程： 
```
ps auxw|head -1;ps auxw|sort -rn -k3|head -10 
```
