# Hadoop综合

## 查看文件block信息
```
hdfs fsck  fileName
```

## 伸缩

* 查看节点状态
```
hdfs dfsadmin -report
yarn node -list
```
### 添加节点
* 修改vim /usr/local/hadoop/etc/hadoop/workers 文件，添加节点域名
* 节点上启动DataNode和NodeManager
```
hdfs --daemon start datanode
yarn --daemon start nodemanager
```


* 刷新节点
```
hdfs dfsadmin -refreshNodes
start-balancer.sh
```



### 删除节点
* 修改vim /usr/local/hadoop/etc/hadoop/workers 文件，删除节点域名
* 停止节点
```
hdfs --daemon stop datanode
yarn --daemon stop nodemanager
```

* 刷新节点
```
hdfs dfsadmin -refreshNodes
start-balancer.sh
```
## HDFS读取文件

* 依赖
```
    <properties>
        <hadoop.version>3.3.0</hadoop.version>
    </properties>

        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-hdfs</artifactId>
            <version>${hadoop.version}</version>
            <scope>test</scope>
        </dependency>



        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-common</artifactId>
            <version>${hadoop.version}</version>
        </dependency>
```
* 程序
```

        FileSystem fs = FileSystem.get(new URI("hdfs://Master:9000"), new Configuration());
        FSDataInputStream open = fs.open(new Path("/hd_input/data"));
        byte[] bytes=new byte[1024*1024];
        int read = open.read(bytes);
        byte[] rs = Arrays.copyOf(bytes, read);
```

## windows 安装
* 依赖替换
[hadoop-hdfs-3.2.1.jar](https://github.com/FahaoTang/big-data/blob/master/hadoop-hdfs-3.2.1.jar)
```
D:\Application\hadoop-3.2.1\share\hadoop\hdfs
```
* 路径
```
<property>
                <name>dfs.namenode.name.dir</name>
                <value>/D:/Application/hadoop-3.2.1/tmp/dfs/name</value>
</property>
```

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

## map reduce
* Mapper
```

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;


import java.util.ArrayList;

import java.util.List;


public class TaskMapper extends Mapper<LongWritable, Text, Text, LongWritable> {

    private List<String> stringSet = new ArrayList<>();

    public TaskMapper() {
        stringSet.add("黛玉");
        stringSet.add("宝钗");
        stringSet.add("元春");
        stringSet.add("探春");
        stringSet.add("湘云");
        stringSet.add("迎春");
        stringSet.add("惜春");
        stringSet.add("熙凤");
        stringSet.add("巧姐");
        stringSet.add("李纨");
        stringSet.add("可卿");


    }

    @Override
    protected void map(LongWritable key, Text value, Context context) {
        System.out.println("do mapper...");
        String s = value.toString();

        stringSet.forEach(x -> {
            if (s.indexOf(x) != -1) {
                try {
                    context.write(new Text(x), key);
                } catch (Exception e) {
                    throw new RuntimeException("mapper失败" + e.getMessage());
                }
            }
        });
    }
}
```

* Reduce
```

import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;


import java.util.HashMap;
import java.util.Map;


public class TaskReduce extends Reducer<Text, LongWritable, Text, LongWritable> {

    @Override
    protected void reduce(Text key, Iterable<LongWritable> values, Context context) {
        System.out.println("do reduce...");

        HBaseExecutor defaultInstance = HBaseExecutor.getInstance();

        //循环行
        values.forEach(x -> {
            try {
                long l = System.currentTimeMillis();
                byte[] bytes = Bytes.toBytes(l);
                Map<String, String> valueMaps = new HashMap<>();
                valueMaps.put("r_name", key.toString());
                valueMaps.put("r_number", x.toString());
                defaultInstance.insertValues("red", bytes, "r_count", valueMaps);
                // context.write(key, x);
            } catch (Exception e) {
                throw new RuntimeException("reduce失败" + e.getMessage());
            }
        });
    }
}
```

* 主程序
```
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;


public class AppStart {
    public static void main(String[] args) throws Exception {

        Configuration conf = new Configuration();

        Job job = Job.getInstance(conf, "demo map reduce");
        job.setJarByClass(AppStart.class);

        job.setMapperClass(TaskMapper.class);
        job.setReducerClass(TaskReduce.class);

        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(LongWritable.class);

        FileInputFormat.addInputPath(job, new Path("hdfs://Master:9000/hd_input/data"));

        String yyyyMMddHHmmss = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy_MM_dd_HH_mm"));
        FileOutputFormat.setOutputPath(job, new Path("hdfs://Master:9000/hd_output/" + yyyyMMddHHmmss));

        System.exit(job.waitForCompletion(true) ? 0 : 1);

    }
}
```

* 执行任务
```
hadoop jar ./map_reduce_task-1.0-SNAPSHOT.jar  com.map_reduce.AppStart
```
