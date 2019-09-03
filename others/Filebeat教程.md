# Filebeat教程


## 指令	 
* export 将配置，索引模板，ILM策略或仪表板导出到stdout。

* help 显示任何命令的帮助。

* keystore 管理秘密密钥库。

* modules 管理配置的模块。

* run 运行Filebeat。如果在未指定命令的情况下启动Filebeat，则默认使用此命令。

* setup 设置初始环境，包括索引模板，ILM策略和写入别名，Kibana仪表板（如果可用）和机器学习作业（如果可用）。

* test 测试配置。

* version 显示有关当前版本的信息。

## 设置filebeat.yml
* input可以设置多个

```yaml
filebeat.inputs:
- type: log
  include_lines: ['sometext']
  exclude_lines: ['view']
  exclude_files: ['\.gz$']
  enabled: true
  paths:
    - /var/log/*.log
    #- c:\programdata\elasticsearch\logs\*
```


监控多个文件
```yaml
filebeat.inputs:
- type: log
  enable: true
  paths:
    - d:\log2\*
  tags: ["log2"]  

- type: log
  enable: true
  paths:
    - d:\Application\nginx\logs\*
  tags: ["nginx"]  
    
- type: log

  # Change to true to enable this input configuration.
  enabled: true

  # Paths that should be crawled and fetched. Glob based paths.
  paths:
    - d:\log\*
  tags: ["springboot"]
```



### type为log特有属性
* include_lines正则仅发送包含sometext
* exclude_lines正则仅发送不含view
* exclude_files正则匹配要忽略的文件

### 公共参数
```yaml
filebeat.inputs:
- type: log
  . . .
  tags: ["json"]
```

```yaml
filebeat.inputs:
- type: log
  . . .
  fields:
    app_id: query_engine_12
```

## 输出到es设置
```yaml
output.elasticsearch:
  # Array of hosts to connect to.
  hosts: ["localhost:9200"]

  # Optional protocol and basic auth credentials.
  #protocol: "https"
  #username: "elastic"
  #password: "changeme"
```

## 输出到logstash
```yaml
#output.logstash:
  # The Logstash hosts
  #hosts: ["localhost:5044"]

  # Optional SSL. By default is off.
  # List of root certificates for HTTPS server verifications
  #ssl.certificate_authorities: ["/etc/pki/root/ca.pem"]

  # Certificate for SSL client authentication
  #ssl.certificate: "/etc/pki/client/cert.pem"

  # Client Certificate Key
  #ssl.key: "/etc/pki/client/cert.key"

```