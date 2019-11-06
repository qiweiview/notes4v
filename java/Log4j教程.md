# Log4j教程

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

## 代码配置
```
 /*控制台部分*/
        ConsoleAppender console = new ConsoleAppender(); //create appender

        console.setLayout(new PatternLayout("[%d{yyyy-MM-dd HH:mm:ss}][%p][%m]%n"));
        console.setThreshold(Level.DEBUG);
        console.activateOptions();
        //add appender to any Logger (here is root)
        Logger.getRootLogger().addAppender(console);


        /*文件部分*/
        DailyRollingFileAppender fa = new DailyRollingFileAppender();
        fa.setName("FileLogger");
        fa.setFile(logPath + File.separator + "log.log");
        fa.setDatePattern("yyyy-MM-dd'_backup'");
        fa.setLayout(new PatternLayout("[%d{yyyy-MM-dd HH:mm:ss}][%p][%m]%n"));
        fa.setThreshold(Level.INFO);
        fa.setAppend(true);
        fa.activateOptions();
        Logger.getRootLogger().addAppender(fa);
```
