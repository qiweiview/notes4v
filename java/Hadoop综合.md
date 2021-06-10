# Hadoop综合

## vim   ~/.bashrc
```
export JAVA_HOME=/usr/local/jdk11
export PATH=$JAVA_HOME/bin:$PATH
export PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin
export HADOOP_HOME=/usr/local/hadoop
```

## 公钥
```
ssh-keygen -t rsa 
```

## 文件权限变更
```
sudo chown -R hadoop /usr/local/hadoop
```

## core-site.xml
```
<configuration>
        <property>
                <name>fs.defaultFS</name>
                <value>hdfs://Master:9000</value>
        </property>
        <property>
                <name>hadoop.tmp.dir</name>
                <value>file:/usr/local/hadoop/tmp</value>
                <description>Abase for other temporary directories.</description>
        </property>
</configuration>
```

## hdfs-site.xml
* 对于Hadoop的分布式文件系统HDFS而言，一般都是采用冗余存储，冗余因子通常为3(dfs.replication)，也就是说，一份数据保存三份副本
```
<configuration>
        <property>
                <name>dfs.namenode.secondary.http-address</name>
                <value>Master:50090</value>
        </property>
        <property>
                <name>dfs.replication</name>
                <value>3</value>
        </property>
        <property>
                <name>dfs.namenode.name.dir</name>
                <value>file:/usr/local/hadoop/tmp/dfs/name</value>
        </property>
        <property>
                <name>dfs.datanode.data.dir</name>
                <value>file:/usr/local/hadoop/tmp/dfs/data</value>
        </property>
</configuration>
```

## mapred-site.xml
```
<configuration>
        <property>
                <name>mapreduce.framework.name</name>
                <value>yarn</value>
        </property>
        <property>
                <name>mapreduce.jobhistory.address</name>
                <value>Master:10020</value>
        </property>
        <property>
                <name>mapreduce.jobhistory.webapp.address</name>
                <value>Master:19888</value>
        </property>
        <property>
                <name>yarn.app.mapreduce.am.env</name>
                <value>HADOOP_MAPRED_HOME=/usr/local/hadoop</value>
        </property>
        <property>
                <name>mapreduce.map.env</name>
                <value>HADOOP_MAPRED_HOME=/usr/local/hadoop</value>
        </property>
        <property>
                <name>mapreduce.reduce.env</name>
                <value>HADOOP_MAPRED_HOME=/usr/local/hadoop</value>
        </property> 
</configuration>
```

## yarn-site.xml
```
<configuration>
        <property>
                <name>yarn.resourcemanager.hostname</name>
                <value>Master</value>
        </property>
        <property>
                <name>yarn.nodemanager.aux-services</name>
                <value>mapreduce_shuffle</value>
        </property>
</configuration>
```

## 上述5个文件全部配置完成以后，需要把Master节点上的“/usr/local/hadoop”文件夹复制到各个节点上


## 格式化
```
hdfs namenode -format
```

## 启动
```
start-dfs.sh
start-yarn.sh
mr-jobhistory-daemon.sh start historyserver
```

## 停止
```
stop-yarn.sh
stop-dfs.sh
mr-jobhistory-daemon.sh stop historyserver
```

## 打包
```
 <build>
        <plugins>


            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-shade-plugin</artifactId>
                <version>3.2.4</version>
                <executions>
                    <execution>
                        <phase>package</phase>
                        <goals>
                            <goal>shade</goal>
                        </goals>
                        <configuration>
                            <transformers>
                                <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                                    <mainClass>com.LogAnalysisRunner</mainClass>
                                </transformer>
                            </transformers>
                        </configuration>
                    </execution>
                </executions>
            </plugin>


        </plugins>
    </build>
```
