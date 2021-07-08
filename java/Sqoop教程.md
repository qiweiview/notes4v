# Sqoop教程

## 异常
```
# 异常
Could not find or load main class org.apache.hadoop.hbase.util.GetJavaProperty

# vim /usr/local/hbase/bin/hbase

# CLASSPATH initially contains $HBASE_CONF_DIR
CLASSPATH="${HBASE_CONF_DIR}"
CLASSPATH=${CLASSPATH}:$JAVA_HOME/lib/tools.jar:/usr/local/hbase/lib/*
```

## 安装
* [下载](http://sqoop.apache.org/)
* 配置
```
export HADOOP_COMMON_HOME=/usr/local/hadoop
export HADOOP_MAPRED_HOME=/usr/local/hadoop
export HBASE_HOME=/usr/local/hbase
export HIVE_HOME=/usr/local/hive

export SQOOP_HOME=/usr/local/sqoop
export PATH=$PATH:$SBT_HOME/bin:$SQOOP_HOME/bin
export CLASSPATH=$CLASSPATH:$SQOOP_HOME/lib
```

* 测试
```
sqoop list-databases --connect jdbc:mysql://127.0.0.1:3306/ --username root -P
```
