# Logstash教程

* Logstash事件处理管道有三个阶段：输入→过滤器→输出

## 运行范例
```
bin/logstash -e 'input { stdin { } } output { stdout {} }'
```
* -e标志使您可以直接从命令行指定配置。
* 通过在命令行指定配置，您可以快速测试配置，而无需在迭代之间编辑文件

## 带配置文件运行
```
bin/logstash -f config/first-pipeline.conf --config.reload.automatic
```

## 测试配置first-pipeline.conf


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
	
}
output {
    stdout { codec => rubydebug }
	elasticsearch {
        hosts => [ "localhost:9200" ]
	index => "logstash4xm-%{+YYYY.MM.dd}"
    }
	file {
        path => "D:\log\output\otp"
    }
}
```

### 输入
* 可以配置多个
* 来自filebeat

### 通过插件grok过滤格式
* [grok语法测试](http://grokdebug.herokuapp.com/)
* grok模式的语法是％{SYNTAX：SEMANTIC}
* SYNTAX是与您的文本匹配的模式的名称。例如，3.44将与NUMBER模式匹配，55.3.244.1将与IP模式匹配。
* SEMANTIC是您为匹配的文本提供的标识符。 例如，3.44可能是事件的持续时间，因此您可以将其称为duration
* 默认情况下，所有语义都保存为字符串
```****
55.3.244.1 GET /index.html 15824 0.043
//对应模板
%{IP:client} %{WORD:method} %{URIPATHPARAM:request} %{NUMBER:bytes} %{NUMBER:duration}
```

* %{COMBINEDAPACHELOG} 是logstash自带的匹配模式，它的grok表达式是：
```
COMMONAPACHELOG %{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "(?:%{WORD:verb} %{NOTSPACE:req
uest}(?: HTTP/%{NUMBER:httpversion})?|%{DATA:rawrequest})" %{NUMBER:response} (?:%{NUMBER:bytes}|-)
COMBINEDAPACHELOG %{COMMONAPACHELOG} %{QS:referrer} %{QS:agent}
```

### 通用参数
```
grok {
		add_field => {"new_field" => "new_static_value"}
		add_tag => [ "foo_%{somefield}" ]
		id => "ABC"
		remove_field => [ "foo_%{somefield}" ]
		remove_tag => [ "foo_%{somefield}" ]
    }
```
* add_field：如果此过滤器成功，则向此事件添加任意字段。
* add_tag：如果此过滤器成功，则向事件添加任意标记
* id：为插件配置添加唯一ID。如果未指定ID，Logstash将生成一个ID。强烈建议在配置中设置此ID。当您有两个或更多相同类型的插件时，这尤其有用，例如，如果您有2个grok过滤器。在这种情况下添加命名ID将有助于在使用监视API时监视Logstash
* remove_field：如果此过滤器成功，请从此事件中删除任意字段。
* remove_tag：如果此过滤器成功，则从事件中删除任意标记

### 通过geoip获取ip
* 添加有关IP地址的地理位置的信息

### 输出
* 输出控制台
* 输出es
* 输出文件



## 测试配置
* --config.test_and_exit选项会解析您的配置文件并报告任何错误。
```
bin/logstash -f first-pipeline.conf --config.test_and_exit
```

## 运行logstash
* --config.reload.automatic选项启用自动配置重新加载，这样您就不必在每次修改配置文件时停止并重新启动Logstash。
```
bin/logstash -f first-pipeline.conf --config.reload.automatic
```

## [API](https://www.elastic.co/guide/en/logstash/current/monitoring.html)
