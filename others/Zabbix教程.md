# Zabbix教程

## Centos6.9安装

### 引导zabbix3.4的yum源
```
rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/6/x86_64/zabbix-release-3.4-1.el6.noarch.rpm
```

###  安装php5.6和Apache服务
```
# rpm -ivh http://repo.webtatic.com/yum/el6/latest.rpm
```

* 安装下面所有的包：
```
yum -y install httpd php56w php56w-gd php56w-mysqlnd php56w-bcmath php56w-mbstring php56w-xml php56w-ldap
```

* 编辑php的ini文件（vim /etc/php.ini）并修改一下内容，注意date.timezone一定要写对，否则在配置完zabbix后，显示的界面全部报错
```
# vim /etc/php.ini

post_max_size = 16M

max_execution_time = 300

max_input_time = 300

date.timezone = Asia/Shanghai

always_populate_raw_post_data = -1
```

* 配置/etc/httpd/conf/httpd.conf，修改以下内容
```
# vim /etc/httpd/conf/httpd.conf

DocumentRoot "/var/www/html/zabbix"

<Directory "/var/www/html/zabbix">

ServerName 192.168.0.125

DirectoryIndex index.html index.html.var index.php
```

* 创建zabbix用户和组
```
# groupadd zabbix

# useradd -g zabbix zabbix
```

* 安装zabbix server:
```
# yum install zabbix zabbix-get zabbix-server zabbix-server-mysql zabbix-sender -y
```
* 安装zabbix web server:
```
# yum install zabbix-web zabbix-web-mysql -y
```

* 往数据库中导入一些数据
```
# zcat /usr/share/doc/zabbix-server-mysql-3.4.8/create.sql.gz | mysql -uzabbix -pzabbix zabbix
```
* 修改zabbix配置
```
# vim /etc/zabbix/zabbix_server.conf

DBHost=192.168.0.125
```
* 设置数据库用户名和密码，可自己在数据库中设置用户和密码
```
DBUser=zabbix

DBPassword=zabbix
```
* 复制zabbix到站点目录下
```
# \cp -R /usr/share/zabbix/ /var/www/html/
```

* 修改zabbix.conf.ph 文件
```
# cd /var/www/html/zabbix/

# cp zabbix.conf.php.example zabbix.conf.php

# vim zabbix.conf.php

 

<?php

// Zabbix GUI configuration file.

global $DB, $HISTORY;

 

$DB['TYPE']                             = 'MYSQL';

$DB['SERVER']                   = '192.168.0.125';

$DB['PORT']                             = '3306';

$DB['DATABASE']                 = 'zabbix';

$DB['USER']                             = 'zabbix';

$DB['PASSWORD']                 = 'zabbix';

// Schema name. Used for IBM DB2 and PostgreSQL.

$DB['SCHEMA']                   = '';

 

$ZBX_SERVER                             = '192.168.0.125';

$ZBX_SERVER_PORT                = '10051';

$ZBX_SERVER_NAME                = '';

 

$IMAGE_FORMAT_DEFAULT   = IMAGE_FORMAT_PNG;
```

* 添加到系统服务
```
# chkconfig --add httpd

# chkconfig --add /etc/init.d/zabbix-server
```
设置开机自启
```
# chkconfig httpd on

# chkconfig zabbix-server on
```
* 启动服务
```
# service httpd start

# service zabbix-server start
```

## JMX配置

### 安装java-gateway
```
apt-get install zabbix-java-gateway
```

### 配置java-gateway服务
```
egrep -v '#|^$' /etc/zabbix/zabbix_java_gateway.conf
LISTEN_IP="0.0.0.0"
LISTEN_PORT=10052
PID_FILE="/var/run/zabbix/zabbix_java.pid"
START_POLLERS=5
TIMEOUT=3
systemctl start zabbix-java-gateway
systemctl enable zabbix-java-gateway
```
### 修改zabbix server配置
* 添加以下三行，这里配置的StartJavaPollers值要小于之前java_gateway中的START_POLLERS
```
tail -n 3 /etc/zabbix/zabbix_server.conf 
JavaGateway=127.0.0.1
JavaGatewayPort=10052     
StartJavaPollers=3
```

* 修改zabbix_server.conf后重启服务
```
systemctl restart zabbix-server
```

## 自动发现
* 设置自动发现规则
* 设置自动发现动作

# Ubuntu

## 安装Zabbix Server
* [ubuntu安装](https://www.zabbix.com/download?zabbix=4.4&os_distribution=ubuntu&os_version=18.04_bionic&db=mysql)



### a. Install Zabbix repository
documentation
```
# wget https://repo.zabbix.com/zabbix/4.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.4-1+bionic_all.deb
# dpkg -i zabbix-release_4.4-1+bionic_all.deb
# apt update
```
### b. Install Zabbix server, frontend, agent
```
# apt -y install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent
```
### c. Create initial database
documentation
```
# mysql -uroot -p
password
mysql> create database zabbix character set utf8 collate utf8_bin;
mysql> grant all privileges on zabbix.* to zabbix@localhost identified by 'password';
mysql> quit;
```
Import initial schema and data. You will be prompted to enter your newly created password.
```
# zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix
```
### d. Configure the database for Zabbix server
Edit file /etc/zabbix/zabbix_server.conf
```
DBPassword=password
```
### e. Configure PHP for Zabbix frontend
Edit file /etc/zabbix/apache.conf, uncomment and set the right timezone for you.
```
# php_value date.timezone Europe/Riga
```
### f. Start Zabbix server and agent processes
Start Zabbix server and agent processes and make it start at system boot:
```
# systemctl restart zabbix-server zabbix-agent apache2
# systemctl enable zabbix-server zabbix-agent apache2
```
Now your Zabbix server is up and running!

## 安装Client
### 文件安装优先
[下载](https://www.zabbix.com/download_agents)

### 运行以下命令以安装 Zabbix agent ：
```
# apt install zabbix-agent
```
### 修改配置

```
vim /etc/zabbix/zabbix_agentd.conf
```

```
EnableRemoteCommands=1
Server=192.168.216.136
ServerActive=192.168.216.136
Hostname=zabbix 135
UnsafeUserParameters=1
```

### 运行以下命令以启动 Zabbix agent：
```
# service zabbix-agent start
```

# Centos

## 服务端
```
跑离线包
```

## 客户端
```
# 安装 example.rpm 包并在安装过程中显示正在安装的文件信息及安装进度
rpm -ivh example.rpm 

# 修改配置
vim /etc/zabbix/zabbix_agentd.conf

EnableRemoteCommands=1
Server=192.168.216.136
ServerActive=192.168.216.136
Hostname=zabbix 135
UnsafeUserParameters=1
```


