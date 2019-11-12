# Shell 使用.md

## 范例
* 读取外部文件，循环，判断
```
if [ ! -f "$1" ]; then
        echo "缺少参数,正确调用方式logfile.sh [datafile]"
else
        while IFS= read -r project_name; do
                #地址在不同设备上需要修改
                base_dir="/home/weblogic/web_root/""$project_name""/WEB-INF/classes/"
                log_dir=$base_dir"log4j.properties"
                if [ -f "$log_dir" ]; then
                        /bin/cp -rf $log_dir $base_dir"logconfig.backup"
                        echo "存在"$log_dir",备份原有配置文件到logconfig.backup"
                else
                        rm -rf  $log_dir
                        echo "log4j.rootLogger=DEBUG,F

log4j.appender.F = org.apache.log4j.DailyRollingFileAppender
log4j.appender.F.File = /bea/app_logs/"$project_name"
log4j.appender.F.Append = true
log4j.appender.F.Threshold = DEBUG
log4j.appender.F.layout = org.apache.log4j.PatternLayout
log4j.appender.F.layout.ConversionPattern =[%d{yyyy-MM-dd HH:mm:ss}]["$project_name"][172.28.2.80][%p][%m]%n" >>$log_dir
                        echo "创建"$log_dir
                fi

        done <"$1"
fi
```

## 根据名字返回PID
* 并调用java
```
if [ ! -n "$1" ]; then
                echo "缺少参数,正确调用方式logfile.sh [datafile]"
        else
                port=$(ps -ef | grep $1 | grep -v grep | cut -c 9-15 | xargs)
                $(javac XmlProducer.java)
                command="java XmlProducer $port"
                eval $command
fi

```
