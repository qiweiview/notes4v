# chkconfig教程

## service xxxx does not support chkconfig
* 在脚本的开头添加下面两行即可：
```
#chkconfig: - 85 15
#description: nginx is a World Wide Web server. It is used to serve
```

## 指令
```
chkconfig --list             #列出所有的系统服务。
chkconfig --add httpd        #增加httpd服务。
chkconfig --del httpd        #删除httpd服务。
chkconfig --level httpd 2345 on        #设置httpd在运行级别为2、3、4、5的情况下都是on（开启）的状态。
chkconfig --list               #列出系统所有的服务启动情况。
chkconfig --list mysqld        #列出mysqld服务设置情况。
chkconfig --level 35 mysqld on #设定mysqld在等级3和5为开机运行服务，--level 35表示操作只在等级3和5执行，on表示启动，off表示关闭。
chkconfig mysqld on            #设定mysqld在各等级为on，“各等级”包括2、3、4、5等级。
```
