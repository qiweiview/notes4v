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
        SparkConf conf=new SparkConf().setMaster("local").setAppName("SimpleApp");
        JavaSparkContext sc=new JavaSparkContext(conf);
        JavaRDD<String> logData = sc.textFile(logFile).cache();
        long numAs = logData.filter((Function<String, Boolean>) s -> s.contains("a")).count();
        long numBs = logData.filter((Function<String, Boolean>) s -> s.contains("b")).count();
        System.out.println("Lines with a: " + numAs + ", lines with b: " + numBs);
    }
}
```

## spark任务执行

* 本地执行
```
spark-submit --class "com.spark.SimpleApp" /home/hadoop/map_reduce_task-1.0-SNAPSHOT.jar  2>&1 | grep "Lines with a"
```
* 集群执行
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
```
