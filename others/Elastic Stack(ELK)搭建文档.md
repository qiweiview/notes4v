# Elastic Stack(ELK)搭建文档

* Logstash和Elasticsearch以及Kibana处于Elastic Stack的中心，不需要每个业务系统都进行部署
* Beat(我们使用的是FileBeat)作为日志的采集者，采集并发送日志给logstash服务器。需要在每个业务系统部署，并配置指向日志文件输出路径

## 数据收集流向示意
![](https://i.loli.net/2019/09/04/OrDlVHLqMtx3kyK.png)




## 我们将搭建为两部分：
### 一. 主端，负责对日志进行索引，存储，展示（安装[elasticsearch](#elasticsearch搭建),[logstash](#logstash搭建),[kibana](#kibana搭建)）
### 二. 边缘服务器（运行应用所在服务器），通过安装filbeat对日志进行收集并发送给主端的logstash（安装[filebeat](#filebeat搭建)）


## Elasticsearch搭建
### [下载对应版本](https://www.elastic.co/cn/downloads/elasticsearch)

### 解压，目录结构
![](https://i.loli.net/2019/09/04/BtGgQ1ELFXhZx4A.png)

### 可能出现问题
#### 一
* 问题
```
[1]: max file descriptors [65535] for elasticsearch process is too low, increase to at least [65536]
[2]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
```
* 解决
```
sudo vi /etc/sysctl.conf

添加下面配置：

vm.max_map_count=655360 

并执行命令：

sysctl -p

然后，重新启动elasticsearch，即可启动成功。

sudo vi /etc/security/limits.conf

添加如下内容:

* soft nofile 65536

* hard nofile 131072

* soft nproc 2048

* hard nproc 4096
```
#### 二
* 问题
```
[1]: max number of threads [1024] for user [weblogic] is too low, increase to at least [4096]
```
* 解决
```
This can be done by setting ulimit -u 4096 as root before starting Elasticsearch, or by setting nproc to 4096 in /etc/security/limits.conf.
```
#### 三
* 问题
```
[2]: system call filters failed to install; check the logs and fix your configuration or disable system call filters at your own risk
```
* 解决
在elasticsearch.yml中配置
```
bootstrap.memory_lock: false
bootstrap.system_call_filter: false
```

### 单机运行配置
```
cluster.name: my-application
node.name: node-1
network.host: 0.0.0.0
http.port: 9200
discovery.seed_hosts: ["127.0.0.1", "[::1]"]
cluster.initial_master_nodes: ["node-1"]
```

### 运行es

* linux中需要在非root用户下运行es
```

//创建一个es的用户
sudo useradd elasticsearch 
passwd elasticsearch 
chown -R elasticsearch /elasticsearch-7.3.1 
su elasticsearch 

nohup /bin/elasticsearch & 
```


### 服务
* service
```
#processname: elasticsearch-7.3.1

ES_HOME=/home/es/elasticsearch-7.3.1

case "$1" in
status)
   length=`ps -ef | grep elasticsearch-7.3.1/lib | grep -v grep | cut -c 9-15 | wc -L`
   if [ "$length" -gt "0" ];then
    pid=`ps -ef | grep elasticsearch-7.3.1/lib | grep -v grep | cut -c 9-15`
    echo -e "\033[32m elasticsearch is active with pid $pid ----->  \033[0m"
   else
    echo -e "\033[31m elasticsearch is not active  \033[0m"
   fi 
   ;;
start)
   length=`ps -ef | grep elasticsearch-7.3.1/lib | grep -v grep | cut -c 9-15 | wc -L`
   if [ "$length" -gt "0" ];then
    echo "elasticsearch already running..."
    pid=`ps -ef | grep elasticsearch-7.3.1/lib | grep -v grep | cut -c 9-15`
    echo "the pid is $pid"
   else
    su - es  -c "$ES_HOME/bin/elasticsearch -d"
    echo "elasticsearch start..."
   fi
   ;;
stop)
   stop=`ps -ef | grep elasticsearch-7.3.1/lib | grep -v grep | cut -c 9-15 | wc -L`
   if [ "$stop" -gt "0" ];then
    ps -ef | grep  elasticsearch-7.3.1/lib | grep -v grep | cut -c 9-15 | xargs kill -s 9
    echo "elasticsearch stop..."
   else
    echo "elasticsearch is not running..."
   fi
   ;; 

*)

echo "Usage: start|stop|restart|status"

exit 1

;;

 

esac

 

exit 0 


```

* systemctl
```
[Unit]
Description=elasticsearch
[Service]
User=elasticsearch
LimitNOFILE=100000
LimitNPROC=100000
Environment="JAVA_HOME=/usr/local/jdk/jdk1.8.0_231"
ExecStart=/usr/local/elk/elasticsearch-7.3.1/bin/elasticsearch
[Install]
WantedBy=multi-user.target
```

### 测试运行成功
* 默认占用9200端口,访问localhost:9200，类似相应即运行成功
```
{
  "name" : "xtdwfw",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "3iGbjEhiT5iaej6IK8doag",
  "version" : {
    "number" : "7.3.1",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "4749ba6",
    "build_date" : "2019-08-19T20:19:25.651794Z",
    "build_snapshot" : false,
    "lucene_version" : "8.1.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```





## Logstash搭建
### [下载对应版本](https://www.elastic.co/cn/downloads/logstash)

### 解压，目录结构
![nZPpOU.png](https://s2.ax1x.com/2019/09/04/nZPpOU.png)


### 配置文件/conf/first-pipeline.conf(没有则创建)
```
input {
    beats {
        port => "5044"
    }
}
 filter {
    
    grok {
		match => { "message" =>"\[%{DATA:logDate}\]\[%{DATA:appName}\]\[%{DATA:hostName}\]\[%{DATA:logLevel}\]\[%{DATA:logContent}\]"}
    }
	
    date {
        match => ["logDate", "dd/MMM/yyyy:HH:mm:ss Z","yyyy-MM-dd HH:mm:ss"]
		target => "logDate"
    }
	
	if [logLevel] not in ["INFO", "DEBUG", "ERROR"] {
    drop {}
  }
	
}
output {
    stdout { codec => rubydebug }
	elasticsearch {
        hosts => [ "localhost:9200" ]
		index => "logstash4xm-%{+YYYY.MM.dd}"
    }
}
```




### 后台运行logstash
* --config.reload.automatic 参数申明配置热加载
```
nohup ./bin/logstash -f ./config/first-pipeline.conf --config.reload.automatic >/dev/null 2>&1  &
```

### 服务
* service
```
#processname: elasticsearch-7.3.1

LOGSTASH_HOME=/home/es/logstash-7.3.1

case "$1" in
status)
   length=`ps -ef | grep logstash-7.3.1 | grep -v grep | cut -c 9-15 | wc -L`
   if [ "$length" -gt "0" ];then
    pid=`ps -ef | grep logstash-7.3.1 | grep -v grep | cut -c 9-15`
    echo -e "\033[32m logstash is active with pid $pid ----->  \033[0m"
   else
    echo -e "\033[31m logstash is not active  \033[0m"
   fi 
   ;;
start)
   length=`ps -ef | grep logstash-7.3.1 | grep -v grep | cut -c 9-15 | wc -L`
   if [ "$length" -gt "0" ];then
    echo "logstash already running..."
    pid=`ps -ef | grep logstash-7.3.1 | grep -v grep | cut -c 9-15`
    echo "the pid is $pid"
   else
    su - es  -c "nohup $LOGSTASH_HOME/bin/logstash -f $LOGSTASH_HOME/config/default-pipeline.conf --config.reload.automatic >/dev/null 2>&1 &"
    #su - es  -c "nohup $LOGSTASH_HOME/bin/logstash -f $LOGSTASH_HOME/config/default-pipeline.conf --config.reload.automatic >/home/es/lll &"
    echo "logstash start..."
   fi
   ;;
stop)
   stop=`ps -ef | grep logstash-7.3.1 | grep -v grep | cut -c 9-15 | wc -L`
   if [ "$stop" -gt "0" ];then
    ps -ef | grep logstash-7.3.1 | grep -v grep | cut -c 9-15 | xargs kill -s 9
    echo "logstash stop..."
   else
    echo "logstash is not running..."
   fi
   ;; 

*)

echo "Usage: start|stop|restart|status"

exit 1

;;

 

esac

 

exit 0 


```

* systemctl
```
[Unit]
Description=logstash
[Service]
User=elasticsearch
Environment="JAVA_HOME=/usr/local/jdk/jdk1.8.0_231"
ExecStart=/usr/local/elk/logstash-7.3.1/bin/logstash -f /usr/local/elk/logstash-7.3.1/conf/df.con  --config.reload.automatic
LimitNOFILE=100000
LimitNPROC=100000
[Install]
WantedBy=multi-user.target
```

## Kibana搭建
### [下载对应版本](https://www.elastic.co/cn/downloads/kibana)

### 解压，目录结构
![](https://s2.ax1x.com/2019/09/04/nZCMin.png)



### 运行
```
nohup ./bin/kibana >/dev/null 2>&1  &
```

### 服务
* systemctl
```
[Unit]
Description=kibana
[Service]
User=elasticsearch
ExecStart=/usr/local/elk/kibana-7.3.1-linux-x86_64/bin/kibana
LimitNOFILE=100000
LimitNPROC=100000
[Install]
WantedBy=multi-user.target
```


## Filebeat搭建
### [下载对应版本](https://www.elastic.co/cn/downloads/beats/filebeat)

### 解压，目录结构
![nZPKmD.png](https://s2.ax1x.com/2019/09/04/nZPKmD.png)

### 配置filebeat.yml
```
filebeat.inputs:
- type: log
  enable: true
  paths:
    - \usr\local\logs\*.log
    
- type: log
  enable: true
  paths:
    - \home\logs\*.log

output.logstash:
  hosts: ["localhost:5044"]

```





### 测试配置的输出是否可到达
* 指令
```
filebeat test output
```

* 返回
```
logstash: localhost:5044...
  connection...
    parse host... OK
    dns lookup... OK
    addresses: 127.0.0.1, ::1
    dial up... OK
  TLS... WARN secure connection disabled
  talk to server... OK
```


### 后台运行filebeat
```
nohup filebeat  &
```



## 注意
* 所有组件如需提供远程访问，均需修改配置文件绑定本机的IP


## 通过脚本生成配置
### [脚本相关文件下载](https://github.com/qiweiview/notes4v/tree/master/script/elk)

* 运行脚本
```
python  main.py
```
* 脚本将根据demo.yml配置文件，在项目目录下动态生成log4j.properties文件，并创建日志文件夹（存在则不创建），并替换配置的filebeat目录下的配置文件


### demo.yml
```
# logstash服务器地址
logstash_host: 192.168.1.1:5044 
# filebeat目录,将动态生成配置文件替换默认配置文件
filebeat_path: /home/py_script_test
# 当前服务器地址
host: 192.168.1.1

# 项目信息
projects:
# 项目名
 - name: demo
# 项目日志配置文件生成路径（不存在将抛出异常）
   path: /home
# 项目日志文件输出路径（不存在将创建）
   log_path: /home/py_script_test

```

### fast_crate.py
```
# -*- coding: UTF-8 -*-

#
# 脚本依赖yaml和jinja2库
#
import os
import yaml
from jinja2 import Environment, FileSystemLoader




# 解析配置文件
def parseConfig( fileName ):
		f = open(fileName,'r')
		json = yaml.load(f,Loader=yaml.FullLoader)
		for po in json['projects']:
			if(not os.path.exists(po['path'])):
				raise IOError('脚本中断,项目路径'+po['path']+'不存在,无法生成对应配置文件')
  		return json

# 创建日志输出目录
def createLogDirect( log_path ):
		if(not os.path.exists(log_path)):
			os.makedirs(log_path)
			print '\n创建日志输出目录'+log_path
		else:
			print '\n日志出书目录'+log_path+'已存在,不另行创建'   

# 替换项目中的日志配置文件
def createLogConfig( host,appName,log_output,config_output ):
	env = Environment(loader = FileSystemLoader("./template/"))
	template = env.get_template("log4j.properties")
	content = template.render(logDir=log_output, host=host, appName=appName)
	with open(config_output,'w') as fp:
		fp.write(content)
	print '创建替换配置文件:'+config_output

# 替换filebeat配置文件
def createFilebeatConfig( logstash_host,config_output,project_list ):
	project_yml_list=''
        obj_list=[]
	
	for pj in project_list:
		obj_list.append({'type':'log','enable':True,'paths':[ pj['log_path']+'/*.log' ]})
	
	project_yml_list= yaml.dump(obj_list)
        env = Environment(loader = FileSystemLoader("./template/"))
        template = env.get_template("filebeat.yml")
        content = template.render(logstash_host=logstash_host,project_list=project_yml_list)
	with open(config_output,'w') as fp:
                fp.write(content)
       
	print '创建filebeat配置文件:'+config_output

```

### main.py
```
# -*- coding: UTF-8 -*-
import fast_crate

def main():
	print '===脚本开始运行==='
	
	#json=fast_crate.parseConfig('project_info_demo.yml')
        json=fast_crate.parseConfig('demo.yml')
	for project in json['projects']:
		pass

		# 创建日志输出文件夹
		fast_crate.createLogDirect(project['log_path'])
		
		# 创建日志配置文件
		fast_crate.createLogConfig(json['host'],project['name'],project['log_path']+'/log.log',project['path']+'/log4j.properties')

	# 替换filebaeat配置文件
	fast_crate.createFilebeatConfig(json['logstash_host'],json['filebeat_path']+'/filebeat.yml',json['projects'])

	print '===脚本运行完成==='

main()

```

