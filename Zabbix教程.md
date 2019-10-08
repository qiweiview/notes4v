# Zabbix教程

## 安装Zabbix Server
* [ubuntu安装](https://tecadmin.net/install-zabbix-on-ubuntu)

### 环境
```
sudo apt-get update
sudo apt-get install apache2 libapache2-mod-php
sudo apt-get install mysql-server
sudo apt-get install php php-mbstring php-gd php-xml php-bcmath php-ldap php-mysql
```

### 修改时区
* /etc/php/PHP_VERSION/apache2/php.ini. Like below:
```
[Date]
; http://php.net/date.timezone
date.timezone = 'Asia/Kolkata'
```

### 添加软件源
```
## Ubuntu 18.04 LTS (Bionic):

wget https://repo.zabbix.com/zabbix/4.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.0-3+bionic_all.deb
sudo dpkg -i zabbix-release_4.0-3+bionic_all.deb


## Ubuntu 16.04 LTS (Xenial):

wget https://repo.zabbix.com/zabbix/4.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.0-3+xenial_all.deb
sudo dpkg -i zabbix-release_4.0-3+xenial_all.deb
```

### 安装服务端
```
sudo apt-get update
sudo apt-get install zabbix-server-mysql zabbix-frontend-php zabbix-agent
```


### 创建数据库
```
mysql -u root -p

mysql> CREATE DATABASE zabbixdb character set utf8 collate utf8_bin;
mysql> CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'password';
mysql> GRANT ALL PRIVILEGES ON zabbixdb.* TO 'zabbix'@'localhost' WITH GRANT OPTION;
mysql> FLUSH PRIVILEGES;
```

```
cd /usr/share/doc/zabbix-server-mysql
zcat create.sql.gz | mysql -u zabbix -p zabbixdb
```

### 修改配置文件
* /etc/zabbix/zabbix_server.conf
```
 DBHost=localhost
  DBName=zabbixdb
  DBUser=zabbix
  DBPassword=password
```

### 启动服务
```
sudo service apache2 restart
```
```
sudo service zabbix-server restart
```

### 访问
```
http://host/zabbix/
```

### 配置中文
```
apt-get install language-pack-zh-hant language-pack-zh-hans
```



## 安装zabbix agent
* [ubuntu 安装](https://tecadmin.net/install-zabbix-agent-on-ubuntu-and-debian/)

### 添加库
```
For Ubuntu 18.04 (Bionic):

wget https://repo.zabbix.com/zabbix/4.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.0-3+bionic_all.deb
sudo dpkg -i zabbix-release_4.0-3+bionic_all.deb
For Ubuntu 16.04 (Xenial):

wget https://repo.zabbix.com/zabbix/4.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.0-3+xenial_all.deb
sudo dpkg -i zabbix-release_4.0-3+xenial_all.deb
```

### 安装
```
sudo apt-get update
sudo apt-get install zabbix-agent
```

### 修改配置
```
sudo vi /etc/zabbix/zabbix_agentd.conf
```


### 启动
```
service zabbix-agent start
```
