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

## 启动
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

* 启动
```
spark-submit --class "com.spark.SimpleApp" ./map_reduce_task-1.0-SNAPSHOT.jar  2>&1 | grep "Lines with a"
```
