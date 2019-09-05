# Log4j使用

## 依赖
```
<dependency>
            <groupId>log4j</groupId>
            <artifactId>log4j</artifactId>
            <version>1.2.17</version>
</dependency>
```

## 配置文件 log4j.properties
```properties
# Global logging configuration
log4j.rootLogger=DEBUG, stdout,F
# MyBatis logging configuration...
log4j.logger.com.bean.UserSimpleMapper=DEBUG
# Console output...
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=[%d{yyyy-MM-dd HH:mm:ss}][log4j_app][172.0.0.100][%p][%m]%n


log4j.appender.F = org.apache.log4j.DailyRollingFileAppender
log4j.appender.F.File = D:\\log3\\log4j.log
log4j.appender.F.Append = true
log4j.appender.F.Threshold = DEBUG 
log4j.appender.F.layout = org.apache.log4j.PatternLayout
log4j.appender.F.layout.ConversionPattern =[%d{yyyy-MM-dd HH:mm:ss}][log4j_app][172.0.0.100][%p][%m]%n
```

## 调用代码
```java
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.apache.log4j.NDC;

public class AppTest {
    private static Logger log = LogManager.getLogger(AppTest.class);

    public static void main(String[] args) {

        NDC.push("127.0.0.1");//通过DNC输出部署ip,可以不要
        log.error("hi guys");
        log.info("hi guys");
        log.debug("hi guys");

    }
}

```