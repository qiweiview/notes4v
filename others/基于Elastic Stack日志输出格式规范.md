# 基于Elastic Stack日志输出格式规范


## 统一日志输出格式
```
[日志记录时间][应用名][部署服务器][日志等级][日志内容]
```



#### 在收集后分别对应
* logDate-日志记录时间
* appName-应用名
* hostName-部署服务器
* logLevel-日志等级
* logContent-日志内容


## Nginx部署应用配置
* 修改/conf/nginx.conf
```
http{
log_format  access4logstash   '[$time_local][应用名][部署服务器][INFO][$request]';
access_log  logs/access.log  access4logstash;
}
```

* 日志输出示例
```
[05/Sep/2019:14:34:52 +0800][公共平台][10.16.0.102][INFO][GET /111.html HTTP/1.1]
```


* 语法使用说明
```
$remote_addr             客户端地址                                  
$remote_user             客户端用户名称                             
$time_local              访问时间和时区               
$request                 请求的URI和HTTP协议                      
$http_host               请求地址，即浏览器中你输入的地址（IP或域名） 
$status                  HTTP请求状态                           
$upstream_status         upstream状态                              
$body_bytes_sent         发送给客户端文件内容大小                      
$http_referer            url跳转来源                                 
$http_user_agent         用户终端浏览器等信息                          
$ssl_protocol            SSL协议版本                                 
$ssl_cipher              交换数据中的算法                             
$upstream_addr           后台upstream的地址，即真正提供服务的主机地址    
$request_time            整个请求的总时间                           
$upstream_response_time  请求过程中，upstream响应时间               
```


## Tomcat部署应用配置

* 配置/conf/server.xml
```xml
<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log" suffix=".txt"
               pattern="%t[应用名][部署服务器][INFO][%s %U]" />
```

* 日志输出示例
```
[05/Sep/2019:14:54:32 +0800][tomcat][127.0.0.1][INFO][503 /jenkins/]
```


* 语法使用说明
```
%a - 远程IP地址
%A - 本地IP地址
%b - 发送的字节数(Bytes sent), 不包括HTTP headers的字节，如果为0则展示'-'
%B - 发送的字节数(Bytes sent), 不包括HTTP headers的字节
%h - 远程主机名称(如果resolveHosts为false则展示IP)
%H - 请求协议
%l - 远程用户名，始终为'-'(Remote logical username from identd)
%m - 请求的方法(GET, POST等)
%p - 接受请求的本地端口
%q - 查询字符串，如果存在，有一个前置的'?'
%r - 请求的第一行(包括请求方法和请求的URI)
%s - response的HTTP状态码(200,404等)
%S - 用户的session ID
%t - 日期和时间，Common Log Format格式
%u - 被认证的远程用户, 不存在则展示'-'
%U - 请求URL路径
%v - 本地服务名
%D - 处理请求的时间，单位为毫秒
%T - 处理请求的时间，单位为秒
%I - 当前请求的线程名(can compare later with stacktraces)
```


## Log4j框架输出配置

### 配置文件
* log4j.properties
```
log4j.rootLogger=DEBUG,F

log4j.appender.F = org.apache.log4j.DailyRollingFileAppender
#设置后缀，按天分割日志
log4j.appender.F.DatePattern=yyyy-MM-dd'_backup'
log4j.appender.F.File = /bea/log.log
#log4j.appender.F.Append = true
log4j.appender.F.Threshold = DEBUG 
log4j.appender.F.layout = org.apache.log4j.PatternLayout
log4j.appender.F.layout.ConversionPattern =[%d{yyyy-MM-dd HH:mm:ss}][应用名][部署服务器][%p][%m]%n
```

* 日志输出示例
```
[2019-09-05 15:19:28][服务平台][10.16.0.102][ERROR][日志测试666]
```

* 语法使用说明
```
%c 列出logger名字空间的全称，如果加上{<层数>}表示列出从最内层算起的指定层数的名字空间
%C 列出调用logger的类的全名（包含包路径）
%d 显示日志记录时间，{<日期格式>}使用ISO8601定义的日期格式
%F 显示调用logger的源文件名
%l 输出日志事件的发生位置，包括类目名、发生的线程，以及在代码中的行数
%L 显示调用logger的代码行
%m 显示输出消息
%M 显示调用logger的方法名
%n 当前平台下的换行符
%p 显示该条日志的优先级
%r 显示从程序启动时到记录该条日志时已经经过的毫秒数
%t 输出产生该日志事件的线程名
%x 按NDC（Nested Diagnostic Context，线程堆栈）顺序输出日志

```

## Logback框架输出配置

### 配置文件

* application.yml
```yaml
logging:
  config: classpath:logback.xml
```

* logback.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>

    <appender name="FILE" class="ch.qos.logback.core.FileAppender">
        <file>your log path</file>
        <append>true</append>
        <encoder>
            <pattern>[%d{yyyy-MM-dd HH:mm:ss}][应用名][部署服务器][%level][%m]%n</pattern>
        </encoder>
    </appender>


    <root level="INFO">
        <appender-ref ref="FILE"/>
    </root>

</configuration>
```

* 日志输出示例
```
[2019-09-03 15:36:44][服务平台][10.16.0.102][ERROR][日志输出测试]
```

```
%m 输出代码中指定的消息
%p 输出优先级，即DEBUG，INFO，WARN，ERROR，FATAL
%r 输出自应用启动到输出该log信息耗费的毫秒数
%c 输出所属的类目，通常就是所在类的全名
%t 输出产生该日志事件的线程名
%n 输出一个回车换行符，Windows平台为“\r\n”，Unix平台为“\n”
%d 输出日志时间点的日期或时间，默认格式为ISO8601，也可以在其后指定格式，比如：%d{yyy MMM dd HH:mm:ss,SSS}，
%l 输出日志事件的发生位置，包括类目名、发生的线程，以及在代码中的行数。举例：Testlog4.main(TestLog4.java:10)
```

## Weblogic部署配置
```

```




