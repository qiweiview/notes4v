# Zabbix教程

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
