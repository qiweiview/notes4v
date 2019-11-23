# Service使用

## 要把一个程序注册成系统服务，首先得给出一个供service命令调用的脚本文件放到目录/etc/rc.d/init.d/中去

```
service httpd 等价 /etc/rc.d/init.d/httpd

service httpd start 等价 /etc/rc.d/init.d/httpd  start

service httpd stop 等价 /etc/rc.d/init.d/httpd  stop
```

## 脚本范例
```
#processname: elasticsearch-7.3.1

ES_HOME=/usr/local/elk/elasticsearch-7.3.1

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
    su - elasticsearch  -c "$ES_HOME/bin/elasticsearch -d"
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
