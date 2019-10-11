# Supervisor教程

* Supervisor 是用Python开发的一套通用的进程管理程序，能将一个普通的命令行进程变为后台daemon，并监控进程状态，异常退出时能自动重启。

## Ubhuntu安装
```
apt-get install supervisor
```

## 离线安装
### 1. [获取supervisor包](https://github.com/Supervisor/supervisor/releases)
* [3.3.1版本](https://files.pythonhosted.org/packages/80/37/964c0d53cbd328796b1aeb7abea4c0f7b0e8c7197ea9b0b9967b7d004def/supervisor-3.3.1.tar.gz)
 

### 2. 解压supervisor-3.3.1.tar.gz 并安装 
```
　　# tar zxvf supervisor-3.3.1.tar.gz 
　　# python setup.py install
```
* [可能碰到缺少meld3](https://github.com/Supervisor/meld3/releases)

* [1.0.1版本](https://codeload.github.com/Supervisor/meld3/tar.gz/1.0.1)
```
　# tar zxvf meld3-1.0.1.tar.gz
　# python setup.py install
```

### 3. 创建配置文件
```
echo_supervisord_conf > /etc/supervisord.conf
```


### 4. 开启supervisord服务
```
supervisord -c /etc/supervisord.conf
```

## 任务文件
* 通过supervisord.conf中配置扫描
```
[include]
files = /etc/supervisor/conf.d/*.conf 
```
* 程序范例
```
[program:echo_time]
command=sh /tmp/echo_time.sh
priority=999                ; the relative start priority (default 999)
autostart=true              ; start at supervisord start (default: true)
autorestart=true            ; retstart at unexpected quit (default: true)
startsecs=10                ; number of secs prog must stay running (def. 10)
startretries=3              ; max # of serial start failures (default 3)
exitcodes=0,2               ; 'expected' exit codes for process (default 0,2)
stopsignal=QUIT             ; signal used to kill process (default TERM)
stopwaitsecs=10             ; max num secs to wait before SIGKILL (default 10)
user=root                 ; setuid to this UNIX account to run the program
log_stdout=true
log_stderr=true             ; if true, log program stderr (def false)
logfile=/tmp/echo_time.log
logfile_maxbytes=1MB        ; max # logfile bytes b4 rotation (default 50MB)
logfile_backups=10          ; # of logfile backups (default 10)
stdout_logfile_maxbytes=20MB  ; stdout 日志文件大小，默认 50MB
stdout_logfile_backups=20     ; stdout 日志文件备份数
stdout_logfile=/tmp/echo_time.stdout.log
```


## 其他指令
```
    更新新的配置到supervisord
　　# supervisorctl update

　　重新启动配置中的所有程序
　　# supervisorctl reload

　　启动某个进程(program_name=你配置中写的程序名称)
　　# supervisorctl start program_name

　　查看正在守候的进程
　　# supervisorctl

　　重启某一进程 (program_name=你配置中写的程序名称)
　　# supervisorctl restart program_name
　　
　　停止全部进程
　　# supervisorctl stop all
　　
　　查看 该程序的日志
　　#supervisorctl tail -f program_name  
