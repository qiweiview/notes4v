# Ubuntu安装Hadoop

[安装例子地址](https://wangchangchung.github.io/2017/09/28/Ubuntu-16-04%E4%B8%8A%E5%AE%89%E8%A3%85Hadoop%E5%B9%B6%E6%88%90%E5%8A%9F%E8%BF%90%E8%A1%8C/)

[配置例子地址](https://blog.csdn.net/shuoyu816/article/details/90574003)

## 创建Hadoop用户（可以不走这步骤）
如果你是在已有的一个用户存在下， 想安装Hadoop 那么需要创建一个Hadoop 用户，毕竟创建一个新的用户，配置环境相对更加干净一些。
那么打开终端，输入下面的命令创建新的用户：
```
$sudo useradd -m hadoop -s /bin/bash
```
这个的命令的意思是： 创建一个hadoop 用户，并使用 /bin/bash作为shell

## 设置密码（可以不走这步骤）
然后，接着上面的操作， 再对这个用户设置密码，可以简单设置为 hadoop(可以设置成你想设置的), 注意两次设置为相同的密码。
```
$sudo passwd hadoop
```


## 增加管理员权限（可以不走这步骤）
为了我们后续的操作方便。我们这里对之前添加的Hadoop 用户添加管理员的权限。
```
$sudo adduser hadoop sudo
```
这样我们就成功的设置了该用户的管理员权限。

最后我们用Hadoop 用户登录我们的电脑了，所以我们注销当前用户，注销后，在登录的界面中使用刚刚创建的Hadoop 用户登录。


## 安装jdk
```
apt install default-jdk
```
配置环境变量
```
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

```


## 安装Hadoop
Hadoop 的安装包从这里可以下载: http://mirror.bit.edu.cn/apache/hadoop/common/
一般选择下载最新的稳定版本，即下载 “stable” 下的 hadoop-2.x.y.tar.gz 这个格式的文件，这是编译好的，另一个包含 src 的则是 Hadoop 源代码，需要进行编译才可使用。这里我下载稳定版本的2.7.4。


下载好了之后，在你想安装的路径下进行解压， 这里选择将Hadoop 安装到/usr/local/中:

```
$ sudo tar -zxf ~/下载/hadoop-2.7.4.tar.gz -C /usr/local    # 解压到/usr/local中
$ cd /usr/local/
$ sudo mv ./hadoop-2.7.4/ ./hadoop            # 将文件夹名改为hadoop
$ sudo chown -R hadoop ./hadoop       # 修改文件权限
```

解压后，可以用如下的命令查看，我们解压的Hadoop是否是可用的：
```
$ cd /usr/local/hadoop # 进入Hadoop 目录下
$ ./bin/hadoop version  # 在该目录下执行该命令
```


## hadoop启动时提示root@localhost's password: localhost: Permission denied,

设置下ssh免密码登陆
```
ssh-keygen -t rsa // 一路回车键
cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
```


## JAVA_HOME找不到
* 11的javax包移动了所以会跑不起来
```
vim hadoop-3.2.0/etc/hadoop/hadoop-env.sh
加入export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```

## 基础配置

### hdfs-site.xml
```
<property>
<name>dfs.replication</name>
<value>1</value>
</property>
<property>
<name>dfs.permissions.enabled</name>
<value>false</value>
</property>
<property>
<name>dfs.namenode.name.dir</name>
<value>/home/hadoop/data_dir</value>
</property>
<property>
<name>fs.checkpoint.dir</name>
<value>/home/hadoop/data_d</value>
</property>
<property>
<name>fs.checkpoint.edits.dir</name>
<value>/home/hadoop/data_dir</value>
</property>
<property>
<name>dfs.datanode.data.dir</name>
<value>/D:/develop/hadoop/data/datanode</value>
</property>
```

### core-site.xml
```
<property>
<name>fs.defaultFS</name>
<value>hdfs://localhost:9000</value>
</property>
<property>
<name>hadoop.tmp.dir</name>
<value>/home/hadoop/tmp</value>
</property>
<property>
<name>fs.trash.interval</name>
<value>1440</value>
</property>
```

### yarn-site.xml
```
<property>
<name>yarn.nodemanager.aux-services</name>
<value>mapreduce_shuffle</value>
</property>
<property>
<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
<value>org.apache.hadoop.mapred.ShuffleHandler</value>
</property>
```

## 启动所有和关闭所有
```
start-all.sh
stop-all.sh
```


## 访问首页
```
http://localhost:9870/

http://localhost:8088/cluster
```



## HDFS使用
### 必须创建一个输入目录。
```
$ $HADOOP_HOME/bin/hadoop fs -mkdir /user/input 
```
### 传输并使用本地系统put命令，Hadoop文件系统中存储的数据文件。
```
$ $HADOOP_HOME/bin/hadoop fs -put /home/file.txt /user/input 
```
### 可以使用ls命令验证文件。
```
$ $HADOOP_HOME/bin/hadoop fs -ls /user/input 
```

### 最初，使用cat命令来查看来自HDFS的数据。
```
$ $HADOOP_HOME/bin/hadoop fs -cat /user/output/outfile 
```

### 从HDFS得到文件使用get命令在本地文件系统。
```
$ $HADOOP_HOME/bin/hadoop fs -get /user/output/ /home/hadoop_tp/ 
```


### 可以使用下面的命令关闭HDFS。
```
$ stop-dfs.sh
```

## 





