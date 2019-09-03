# SpringBoot配置logback.md

## 设置配置地址
```yaml
logging:
  config: classpath:logback.xml
```
## 配置文件 logback.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>


    <timestamp key="byDay" datePattern="yyyy-MM-dd" />

    <appender name="FILE" class="ch.qos.logback.core.FileAppender">
        <file>D:\log\appLog-${byDay}.log</file>
        <append>true</append>
        <encoder>
            <pattern>%-4relative [%thread] %-5level %logger{35} - %msg%n</pattern>
        </encoder>
    </appender>


    <root level="INFO">
        <appender-ref ref="FILE"/>
    </root>

</configuration>
```