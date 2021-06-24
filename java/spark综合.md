# spark


## 权限归属
```
sudo chown -R hadoop ./spark
```

## 配置
```
# 复制配置
cp ./conf/spark-env.sh.template ./conf/spark-env.sh

# 配置脚本
vim spark-env.sh
export SPARK_DIST_CLASSPATH=$(/usr/local/hadoop/bin/hadoop classpath)
```

## 测试
```
# 测试启动
run-example SparkPi 2>&1 | grep "Pi is"

# shell
spark-shell
```


## java应用

* 测试demo
```
import org.apache.spark.api.java.*;
import org.apache.spark.api.java.function.Function;
import org.apache.spark.SparkConf;

public class SimpleApp {
    public static void main(String[] args) {
        String logFile = "file:///usr/local/spark/README.md"; // Should be some file on your system
       SparkConf conf = new SparkConf().setAppName("Test").setMaster("spark://Master:7077");
        JavaSparkContext sc=new JavaSparkContext(conf);
        JavaRDD<String> logData = sc.textFile(logFile).cache();
        long numAs = logData.filter((Function<String, Boolean>) s -> s.contains("a")).count();
        long numBs = logData.filter((Function<String, Boolean>) s -> s.contains("b")).count();
        System.out.println("Lines with a: " + numAs + ", lines with b: " + numBs);
    }
}
```


### setMaster不同值
* local	Run Spark locally with one worker thread (i.e. no parallelism at all).
* local[K]	Run Spark locally with K worker threads (ideally, set this to the number of cores on your machine).
* local[K,F]	Run Spark locally with K worker threads and F maxFailures (see spark.task.maxFailures for an explanation of this variable)
* local[*]	Run Spark locally with as many worker threads as logical cores on your machine.
* local[*,F]	Run Spark locally with as many worker threads as logical cores on your machine and F maxFailures.
* spark://HOST:PORT	Connect to the given Spark standalone cluster master. The port must be whichever one your master is configured to use, which is 7077 by default.
* spark://HOST1:PORT1,HOST2:PORT2	Connect to the given Spark standalone cluster with standby masters with Zookeeper. The list must have all the master hosts in the high availability cluster set up with Zookeeper. The port must be whichever each master is configured to use, which is 7077 by default.
* mesos://HOST:PORT	Connect to the given Mesos cluster. The port must be whichever one your is configured to use, which is 5050 by default. Or, for a Mesos cluster using ZooKeeper, use mesos://zk://.... To submit with --deploy-mode cluster, the HOST:PORT should be configured to connect to the MesosClusterDispatcher.
* yarn	Connect to a YARN cluster in client or cluster mode depending on the value of --deploy-mode. The cluster location will be found based on the HADOOP_CONF_DIR or YARN_CONF_DIR variable.
* k8s://HOST:PORT	Connect to a Kubernetes cluster in client or cluster mode depending on the value of --deploy-mode. The HOST and PORT refer to the Kubernetes API Server. It connects using TLS by default. In order to force it to use an unsecured connection, you can use k8s://http://HOST:PORT.


## spark任务执行

* 本地执行
```
spark-submit --class "com.spark.SimpleApp" /home/hadoop/map_reduce_task-1.0-SNAPSHOT.jar  2>&1 | grep "Lines with a"
```
###  集群执行
* 涉及hdfs则设备需要安装并启动hdfs
```
# 集群执行
/usr/local/spark/bin/spark-submit --class com.AppStart --master spark://Master:7077 --deploy-mode cluster  hdfs://Master:9000/spark_app/spark_app-1.0-SNAPSHOT.jar
```

* 集群启动
```
# 启动master
/sbin/start-master.sh

# 访问ui
http://Master:8080

# 启动worker
./start-worker.sh spark://Master:7077

spark-class org.apache.spark.deploy.worker.Worker spark://Master:7077
```


