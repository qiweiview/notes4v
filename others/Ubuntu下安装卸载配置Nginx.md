
## nginx安装
使用apt
```
apt-get install nginx
#一路回车
```
## 配置
Nginx可以配置多种类型的虚拟主机：

1. 基于IP的虚拟主机：Linux操作系统允许添加IP别名（IP别名指在一块物理网卡上绑定多个IP地址）。
2. 基于域名的虚拟主机
3. 基于端口的虚拟主机

安装完的nginx在etc/nginx/nginx.conf 配置文件中会有如下配置：
```
http {
    ......
    ##
    # Virtual Host Configs
    ##

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
#这表明默认情况下 nginx 会自动包含 /etc/nginx/conf.d/*.conf 和 /etc/nginx/sites-enabled/*
#默认情况下，在 /etc/nginx/sites-enabled 下有一个默认站点，这个站点也就是 nginx 安装之后的默认站点：
```
### 创建自己的虚拟主机
在 /etc/nginx/sites-enabled/ 下新建 basiccloud.net 文件，内容如下：
```
server {
       listen 80;

       server_name basiccloud.net www.basiccloud.net;

       root /var/www/basiccloud.net;
       index index.html;
}
```
在 /var/www/basiccloud.net目录下建立文件夹并创建对应的index.html文件
```
nginx -t #检测配置正常
nginx -s reload #重新读取配置
```

### 卸载nginx

0. 首先需要停止nginx的服务
```
sudo service nginx stop
```

1. 删除nginx，–purge包括配置文件
```
sudo apt-get --purge remove nginx
```
2. 自动移除全部不使用的软件包
```
sudo apt-get autoremove
```
3. 列出与nginx相关的软件 并删除显示的软件
```
dpkg --get-selections|grep nginx
```
可能包含下面的其中几个：
```
sudo apt-get --purge remove nginx
sudo apt-get --purge remove nginx-common
sudo apt-get --purge remove nginx-core
```

4. 再次执行
```
dpkg --get-selections|grep nginx

which nginx # 不在显示nginx
```
5.这样就可以完全卸载掉nginx包括配置文件 