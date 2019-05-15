# 第一种方式：通过yum安装
```
直接通过 yum install nginx 肯定是不行的,因为yum没有nginx，所以首先把 nginx 的源加入 yum 中
```
## 流程：
```
1.将nginx放到yum repro库中
[root@localhost ~]# rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm

2.查看nginx信息
[root@localhost ~]# yum info nginx

3.使用yum安装ngnix
[root@localhost ~]# yum install nginx
效果如下：
[root@localhost ~]# yum install nginx
已加载插件：fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: mirrors.usc.edu
 * extras: mirror.raystedman.net
 * updates: mirror.metrocast.net
正在解决依赖关系
--> 正在检查事务
---> 软件包 nginx.x86_64.1.1.10.1-1.el7.ngx 将被 安装
      ······
      ······
正在安装    : 1:nginx-1.10.1-1.el7.ngx.x86_64        
Thanks for using nginx!
Please find the official documentation for nginx here:
* http://nginx.org/en/docs/

Commercial subscriptions for nginx are available on:
* http://nginx.com/products/

----------------------------------------------------------------------
  验证中      : 1:nginx-1.10.1-1.el7.ngx.x86_64                                                                                 1/1 

已安装:
  nginx.x86_64 1:1.10.1-1.el7.ngx                                                                                     
完毕！

4.启动nginx
[root@localhost ~]# service nginx start

5.查看nginx版本
[root@localhost ~]# nginx -v

6.访问nginx，现在你可以通过公网ip (本地可以通过 localhost /或 127.0.0.1 ) 查看nginx 服务返回的信息。
[root@localhost ~]# curl -i localhost
效果如下：
      ······
Welcome to nginx!。
      ······
7.nginx配置文件位置在/etc/nginx/
[root@localhost /]# ll /etc/nginx/
总用量 32
drwxr-xr-x. 2 root root   25 10月 12 13:11 conf.d
-rw-r--r--. 1 root root 1007 5月  31 22:09 fastcgi_params
-rw-r--r--. 1 root root 2837 5月  31 22:09 koi-utf
-rw-r--r--. 1 root root 2223 5月  31 22:09 koi-win
-rw-r--r--. 1 root root 3957 5月  31 22:09 mime.types
lrwxrwxrwx. 1 root root   29 10月 12 13:11 modules -> ../../usr/lib64/nginx/modules
-rw-r--r--. 1 root root  643 5月  31 22:08 nginx.conf
-rw-r--r--. 1 root root  636 5月  31 22:09 scgi_params
-rw-r--r--. 1 root root  664 5月  31 22:09 uwsgi_params
-rw-r--r--. 1 root root 3610 5月  31 22:09 win-utf

8.实践：
目的：修改服务名，接着从外部访问这个服务
操作：
a.修改nginx配置文件
[root@localhost nginx]# vim /etc/nginx/conf.d/default.conf
修改server_name部分：server_name  yytest.com;

b.重载服务
[root@localhost nginx]# /usr/sbin/nginx -s reload 

c.从外部访问nginx服务(192.168.10.11)
如在客户机(192.168.10.10)的浏览器访问：http://yytest.com

d.你发现访问不了，原因1，你没有在hosts文件做映射；原因2，及时你在hosts文件中了映射，由于nginx服务器的80端口堵塞或防火墙没关

e.解决办法：
步骤一：修改客户机(192.168.10.10)的hosts文件，使用SwitchHosts工具添加 192.168.10.11     yytest.com
步骤二：关闭防火墙，具体下文有说明

9.nginx常用操作
启动:
$ /usr/sbin/nginx或任意路径下运行service nginx start(centos7是systemctl start nginx.service )

重启：
$ /usr/sbin/nginx –s reload

停止：
$ /usr/sbin/nginx –s stop

测试配置文件是否正常：
$ /usr/sbin/nginx –t

```
## 可能出现情况：
```
具体情况如下  1。本机能ping通虚拟机  2。虚拟机也能ping通本机  3。虚拟机能访问自己的web  4。本机无法访问虚拟己的web  这个问题的原因是服务器的80端口没有打开或防火墙没有关闭
```
## 解决办法：
```
如果是centos6:
解决方法如下： 
/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT 
然后保存： 
/etc/rc.d/init.d/iptables save 
重启防火墙 
/etc/init.d/iptables restart 

CentOS防火墙的关闭，关闭其服务即可： 
查看CentOS防火墙信息：/etc/init.d/iptables status 
关闭CentOS防火墙服务：/etc/init.d/iptables stop 
永久关闭防火墙： 
chkconfig –level 35 iptables off

如果是centos7（依次运行）
[root@rhel7 ~]# systemctl status firewalld.service

[root@rhel7 ~]# systemctl stop firewalld.service

[root@rhel7 ~]# systemctl disable firewalld.service

[root@rhel7 ~]# systemctl status firewalld.service


```
## 扩展知识：

启动一个服务：systemctl start firewalld.service
关闭一个服务：systemctl stop firewalld.service
重启一个服务：systemctl restart firewalld.service
显示一个服务的状态：systemctl status firewalld.service
在开机时启用一个服务：systemctl enable firewalld.service
在开机时禁用一个服务：systemctl disable firewalld.service

查看服务是否开机启动：systemctl is-enabled firewalld.service;echo $?

查看已启动的服务列表：systemctl list-unit-files|grep enabled



