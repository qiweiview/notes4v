# Ubuntu 用vsftpd 配置FTP服务器


## ubuntu 安装 vsftpd
```
$ sudo apt-get install vsftpd
```

使用apt安装即可。

配置vsftpd
备份vsftpd.config
```
$ sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.orig
```

编辑vsftpd.config
手动修改配置，根据下方的patch文件改一下。
```
$ sudo vim /etc/vsftpd.config
```

```
--- /etc/vsftpd.conf.orig   2018-02-08 13:39:05.983282023 +0800
+++ /etc/vsftpd.conf    2018-02-10 11:14:15.584088172 +0800
@@ -28,11 +28,11 @@
 local_enable=YES
 #
 # Uncomment this to enable any form of FTP write command.
-#write_enable=YES
+write_enable=YES
 #
 # Default umask for local users is 077. You may wish to change this to 022,
 # if your users expect that (022 is used by most other ftpd's)
-#local_umask=022
+local_umask=022
 #
 # Uncomment this to allow the anonymous FTP user to upload files. This only
 # has an effect if the above global write enable is activated. Also, you will
@@ -67,11 +67,11 @@
 #
 # You may override where the log file goes if you like. The default is shown
 # below.
-#xferlog_file=/var/log/vsftpd.log
+xferlog_file=/var/log/vsftpd.log
 #
 # If you want, you can have your log file in standard ftpd xferlog format.
 # Note that the default log file location is /var/log/xferlog in this case.
-#xferlog_std_format=YES
+xferlog_std_format=YES
 #
 # You may change the default value for timing out an idle session.
 #idle_session_timeout=600
@@ -100,7 +100,7 @@
 #ascii_download_enable=YES
 #
 # You may fully customise the login banner string:
-#ftpd_banner=Welcome to blah FTP service.
+ftpd_banner=Welcome Lincoln Linux FTP Service.
 #
 # You may specify a file of disallowed anonymous e-mail addresses. Apparently
 # useful for combatting certain DoS attacks.
@@ -120,9 +120,9 @@
 # the user does not have write access to the top level directory within the
 # chroot)
 #chroot_local_user=YES
-#chroot_list_enable=YES
+chroot_list_enable=YES
 # (default follows)
-#chroot_list_file=/etc/vsftpd.chroot_list
+chroot_list_file=/etc/vsftpd.chroot_list
 #
 # You may activate the "-R" option to the builtin ls. This is disabled by
 # default to avoid remote users being able to cause excessive I/O on large
@@ -142,7 +142,7 @@
 secure_chroot_dir=/var/run/vsftpd/empty
 #
 # This string is the name of the PAM service vsftpd will use.
-pam_service_name=vsftpd
+pam_service_name=ftp
 #
 # This option specifies the location of the RSA certificate to use for SSL
 # encrypted connections.
@@ -152,4 +152,8 @@

 #
 # Uncomment this to indicate that vsftpd use a utf8 filesystem.
-#utf8_filesystem=YES
+utf8_filesystem=YES
+userlist_enable=YES
+userlist_deny=NO
+userlist_file=/etc/vsftpd.user_list
+allow_writeable_chroot=YES
```

这样就将配置更新了。

## 创建登录用户
```
#先创建ftp目录
$ sudo mkdir /home/ftpdir

## 添加用户
$ sudo useradd -d /home/ftpdir -s /bin/bash ftpuser
## 设置用户密码
$ sudo passwd ftpuser
## 设置ftp目录用户权限
$ sudo chown ftpuser:ftpuser /home/ftpdir

## 添加vsftpd 登录用户
#新建文件/etc/vsftpd.user_list，用于存放允许访问ftp的用户：
$ sudo touch /etc/vsftpd.user_list 
$ sudo vim /etc/vsftpd.user_list
```

## 在/etc/vsftpd.user_list中添加允许登录ftp 的用户 
```
ftpuser

添加vsftpd登录用户对目录树的权限
#新建文件/etc/vsftpd.chroot_list，设置可列出、切换目录的用户：
$ sudo touch /etc/vsftpd.chroot_list 
$ sudo vim /etc/vsftpd.chroot_list
```

## 在/etc/vsftpd.chroot_list 设置可列出、切换目录的用户 

ftpuser

## 重启 vsftpd 服务
```
$ sudo service vsftpd restart
````




## 关于用户访问文件夹限制：

由chroot_local_user、chroot_list_enable、chroot_list_file这三个文件控制：

首先，chroot_list_enable好理解，就是：是否启用chroot_list_file配置的文件，如果为YES表示chroot_list_file配置的文件生效，否则不生效；

第二，chroot_list_file也简单，配置了一个文件路径，默认是/etc/vsftpd.chroot_list，该文件中会填入一些账户名称。但是这些账户的意义不是固定的，是跟配置项chroot_local_user有关的。后一条中说明；

第三，chroot_local_user为YES表示所有用户都*不能*切换到主目录之外其他目录，但是！除了chroot_list_file配置的文件列出的用户。chroot_local_user为NO表示所有用户都*能*切换到主目录之外其他目录，但是！除了chroot_list_file配置的文件列出的用户。也可以理解为，chroot_list_file列出的“例外情况”的用户。
 如果客户端登录时候提示“以pasv模式连接失败”
编辑/etc/vsftpd.conf
最后添加
pasv_promiscuous=YES
然后再重启vsftpd服务。


## 问题：

553：
问题是因为您的文件夹归root，而不是ftpuser。
要解决它运行：
sudo chown -R ftpuser:nogroup /var/www/ftuuserfolder

530：
在进行更改之前备份配置文件;
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.back

然后编辑vsftpd.conf（使用vi或nano）
nano /etc/vsftpd.conf

然后进行以下更改
pam_service_name = ftp
保存更改并重新启动ftp服务器（如果使用nano hit CTRL+ O＆enter保存然后CTRL+ X退出）
sudo service vsftpd restart