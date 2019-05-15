# 基于FRP搭建内网穿透

## 架构

![FLogWd.png](https://s2.ax1x.com/2019/01/09/FLogWd.png)

## 操作流程
***将 frps 及 frps.ini 放到具有公网 IP 的机器上。***

***将 frpc 及 frpc.ini 放到处于内网环境的机器上。***

frp的github链接：https://github.com/fatedier/frp

下载地址：https://github.com/fatedier/frp/releases

文档：https://github.com/fatedier/frp/blob/master/README_zh.md

查看cpu架构下载对应包
```
arch
```

## 解压压缩包
```
tar -zxvf frp_0.14.1_linux_amd64.tar.gz
```

## 解压出文件目录
```
frpc //客户端软件
frpc_full.ini
frpc.ini //客户端配置文件
frps //服务端软件
frps_full.ini
frps.ini //服务端配置文件
LICENSE
```

## 服务器端设置
1. 配置frps_full.ini:
```
vi frps.ini
```

2. 配置文件
```
[common]
bind_port = 7000
privilege_token = 3qyangmanqiu
max_pool_count = 5
vhost_http_port = 8088




```

3. 启动服务
```
./frps -c ./frps.ini
```

说明:

* bind_port frps:工具占用的端口号
* privilege_token: 相当于密钥一类的东西，服务端和客户端要保持一致
* vhost_http_port:启动http转发后，通过域名访问内网http服务的新端口号，本例中用http://pengpengzuiqiang.club:8088/即可访问内网http服务


## 客户端设置
1. 配置frpc.ini
```
vim frpc.ini
```
2. 配置文件
```
[common]
server_addr = 123.206.212.68
server_port = 7000
privilege_token = 3qyangmanqiu
login_fail_exit = false

[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 6000

[web]
type = http
local_port = 8000
custom_domains = pengpengzuiqiang.club

[my_static_file]
type = tcp
local_ip = 127.0.0.1
remote_port = 6215
plugin = static_file
plugin_local_path = E:\FrpSpace
#plugin_strip_prefix = static
plugin_http_user = admin
plugin_http_passwd = admin
```

3. 启动服务
```
./frpc -c ./frpc.ini
```
说明:

* server_addr: 公网IP
* server_port: 服务器端口
* local_port: 本地要替换的端口
* remote_port: 替换端口（ssh连接时候改成这个端口）
* local_port: 本地http服务的端口号
* custom_domains: 有公网IP服务器的域名(必须有域名，否则无法实现http)
