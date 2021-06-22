# hbase教程


## 权限归属
```
sudo chown -R hadoop ./hbase
```

## 配置文件
```
# 启动脚本
vim /usr/local/hbase/conf/hbase-env.sh

export JAVA_HOME=/usr/local/jdk11
export HBASE_MANAGES_ZK=true 
export HBASE_CLASSPATH=/usr/local/hbase/conf

# 配置文件
vim /usr/local/hbase/conf/hbase-site.xml

# 磁盘存储
<configuration>
        <property>
                <name>hbase.rootdir</name>
                <value>file:///usr/local/hbase/hbase-tmp</value>
        </property>
</configuration>

# hsfs存储（集群0
<configuration>
        <property>
                <name>hbase.rootdir</name>
                <value>hdfs://localhost:9000/hbase</value>
        </property>
        <property>
                <name>hbase.cluster.distributed</name>
                <value>true</value>
        </property>
        <property>
        <name>hbase.unsafe.stream.capability.enforce</name>
        <value>false</value>
    </property>
</configuration>
```

## 启动
```
start-hbase.sh
hbase shell
```
