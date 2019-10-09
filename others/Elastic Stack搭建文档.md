# Elastic Stack搭建文档

* Logstash和Elasticsearch以及Kibana处于Elastic Stack的中心，不需要每个业务系统都进行部署
* Beat(我们使用的是FileBeat)作为日志的采集者，采集并发送日志给logstash服务器。需要在每个业务系统部署，并配置指向日志文件输出路径

## 数据收集流向示意
![](https://i.loli.net/2019/09/04/OrDlVHLqMtx3kyK.png)


## 1. Elasticsearch 搭建
### [下载对应版本](https://www.elastic.co/cn/downloads/elasticsearch)

### 解压，目录结构
![](https://i.loli.net/2019/09/04/BtGgQ1ELFXhZx4A.png)

### 修改配置
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

### 问题
* max file descriptors [4096] for elasticsearch process is too low, increase to at least [65535]
```
添加下面配置：
vm.max_map_count=655360
并执行命令：
sysctl -p
```
* max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
```
找到文件 /etc/security/limits.conf，编辑，在文件的最后追加如下配置：

es soft nofile 65535

es hard nofile 65537

soft nofile表示软限制，hard nofile表示硬限制，

上面两行语句表示，es用户的软限制为65535，硬限制为65537，

即表示es用户能打开的最大文件数量为65537，不管它开启多少个shell。

硬限制是严格的设定，必定不能超过这个设定的数值。

软限制是警告的设定，可以超过这个设定的值，但是若超过，则有警告信息。

在设定上，通常soft会比hard小，举例来说，sofr可以设定为80，而hard设定为100，那么你可以使用到90（因为没有超过100），但介于80~100之间时，系统会有警告信息。

修改了limits.conf，不需要重启，重新登录即生效。
```
* the default discovery settings are unsuitable for production use; at least one of [discovery.seed_hosts, discovery.seed_providers, cluster.initial_master_nodes] must be configured
```
配置没有修改成单节点
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

## 2. Kibana  搭建
### [下载对应版本](https://www.elastic.co/cn/downloads/kibana)

### 解压，目录结构
![](https://s2.ax1x.com/2019/09/04/nZCMin.png)

### 运行
#### windows:
```
/bin/kibana.bat
```

#### linux
```
/bin/kibana
```

## 3. Filebeat 搭建
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

#### filebeat.inputs
* type: log 指定一个监控目录，多个目录使用多个数组对象
* enable 配置当前输入可用
* paths 配置监控的目录，可以使用*来模糊指定

#### output.logstash
* hosts 发送的logstash地址



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
nohup filebeat -e -c filebeat.yml -d "publish" &
```



## 4. Logstash  搭建
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
	#file {
        #path => "D:\log\output\otp"
    #}
}
```
* beats 配置接收日志的端口
* grok 提取统一的日志信息
* date 转换统一日期格式



### 后台运行logstash
* --config.reload.automatic参数申明配置热加载
```
nohup bin/logstash -f config/first-pipeline.conf --config.reload.automatic &
```



