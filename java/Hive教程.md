# Hive教程

## 基础
### hive默认使用^A作为分隔符
* 数据
```
1 xiapi 
2 xiaoxue 
3 qingqing
```

* 创建表并指定分隔符
```
create table if not exists hive.stu(id int,name string) 
row format delimited 
fields terminated by ' '
lines terminated by '\n' 

```

## 常见错误
```
【错误1】
java.lang.NoSuchMethodError: com.google.common.base.Preconditions.checkArgument

【解决1】
hadoop中guava.jar版本不匹配，取最高版本

【错误2】
jdk不匹配，使用jdk8

【错误3】
org.datanucleus.store.rdbms.exceptions.MissingTableException: Required table missing : “VERSION” in Catalog “” Schema “”. DataNucleus requires this table to perform its persistence operations.

【解决3】
/bin/schematool -dbType mysql -initSchema
```

## 配置
* 变量
```
export HIVE_HOME=/usr/local/hive
export PATH=$PATH:$HIVE_HOME/bin
export HADOOP_HOME=/usr/local/hadoop
```
* 配置文件
```
mv hive-default.xml.template hive-default.xml
```

## 将元数据存储在mysql（Hive默认存储在derby）
* vim hive-site.xml
```
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:mysql://localhost:3306/hive?createDatabaseIfNotExist=true</value>
    <description>JDBC connect string for a JDBC metastore</description>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>com.mysql.jdbc.Driver</value>
    <description>Driver class name for a JDBC metastore</description>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>hive</value>
    <description>username to use against metastore database</description>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionPassword</name>
    <value>hive</value>
    <description>password to use against metastore database</description>
  </property>
</configuration>
```

## 启动
```
/usr/local/hive/bin/hive
```

## java连接范例
```

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class HiveConnectExample {

    private static String driverName = "org.apache.hive.jdbc.HiveDriver";

    public static void main(String[] args) {
        try {
            Class.forName(driverName);
            Connection con = DriverManager.getConnection("jdbc:hive2://Master:10000/hive");
            PreparedStatement preparedStatement = con.prepareStatement("select * from hive.stu");
            ResultSet resultSet = preparedStatement.executeQuery();
            while (resultSet.next()) {
                String string = resultSet.getString("id");
                String string1 = resultSet.getString("name");
                System.out.println(string + " " + string1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```
