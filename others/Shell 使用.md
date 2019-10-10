# Shell 使用.md

### 范例
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
                        rm $log_dir
                        echo "备份原有配置文件到logconfig.backup"
                else
                        echo "log4j.rootLogger=DEBUG,F

log4j.appender.F = org.apache.log4j.DailyRollingFileAppender
log4j.appender.F.File = /bea/app_logs/"$project_name"
log4j.appender.F.Append = true
log4j.appender.F.Threshold = DEBUG
log4j.appender.F.layout = org.apache.log4j.PatternLayout
log4j.appender.F.layout.ConversionPattern =[%d{yyyy-MM-dd HH:mm:ss}]["$project_name"][172.28.2.81][%p][%m]%n" >>$log_dir
                        echo "创建"$log_dir
                fi

        done <"$1"
fi
```
