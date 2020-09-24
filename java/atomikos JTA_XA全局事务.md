# atomikos JTA/XA全局事务

## Atomikos公司官方网址为：https://www.atomikos.com/。其旗下最著名的产品就是事务管理器。产品分两个版本：

* TransactionEssentials：开源的免费产品

* ExtremeTransactions：上商业版，需要收费。


## 使用TransactionEssentials的API
在maven项目的pom文件中引入以下依赖：
```
<dependency>
    <groupId>com.atomikos</groupId>
    <artifactId>transactions-jdbc</artifactId>
    <version>4.0.6</version>
</dependency>
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>5.1.39</version>
</dependency>
```

## 代码范例
```

import com.atomikos.icatch.jta.UserTransactionImp;
import com.atomikos.jdbc.AtomikosDataSourceBean;

import javax.transaction.SystemException;
import javax.transaction.UserTransaction;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Properties;

public class AtomikosExample {

    private static AtomikosDataSourceBean createAtomikosDataSourceBean(String dbName) {
        // 连接池基本属性
        Properties p = new Properties();
        p.setProperty("url", "jdbc:mysql://192.168.216.237:3306/" + dbName);
        p.setProperty("user", "root");
        p.setProperty("password", "123456");

        // 使用AtomikosDataSourceBean封装com.mysql.jdbc.jdbc2.optional.MysqlXADataSource
        AtomikosDataSourceBean ds = new AtomikosDataSourceBean();
        //atomikos要求为每个AtomikosDataSourceBean名称，为了方便记忆，这里设置为和dbName相同
        ds.setUniqueResourceName(dbName);
        ds.setXaDataSourceClassName("com.mysql.jdbc.jdbc2.optional.MysqlXADataSource");
        ds.setXaProperties(p);
        return ds;
    }

    public static void main(String[] args) {

        AtomikosDataSourceBean ds1 = createAtomikosDataSourceBean("zephyr-api");
        AtomikosDataSourceBean ds2 = createAtomikosDataSourceBean("zephyr-api-new");

        Connection conn1 = null;
        Connection conn2 = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;

        UserTransaction userTransaction = new UserTransactionImp();
        try {
            // 开启事务
            userTransaction.begin();

            // 执行db1上的sql
            conn1 = ds1.getConnection();
            ps1 = conn1.prepareStatement("INSERT into test_user(name) VALUES (?)", Statement.RETURN_GENERATED_KEYS);
            ps1.setString(1, "little_lily_fk");
            ps1.executeUpdate();
            ResultSet generatedKeys = ps1.getGeneratedKeys();
            int userId = -1;
            while (generatedKeys.next()) {
                userId = generatedKeys.getInt(1);// 获得自动生成的userId
            }

            // 模拟异常 ，直接进入catch代码块，2个都不会提交
            int i = 1 / 0;

            // 执行db2上的sql
            conn2 = ds2.getConnection();
            ps2 = conn2.prepareStatement("INSERT into test_user(name) VALUES (?)");
            ps2.setString(1, "little_lily_fk");
            ps2.executeUpdate();

            // 两阶段提交
            userTransaction.commit();
        } catch (Exception e) {
            try {
                e.printStackTrace();
                userTransaction.rollback();//回滚
            } catch (SystemException e1) {
                e1.printStackTrace();
            }
        } finally {
            try {
                ps1.close();
                ps2.close();
                conn1.close();
                conn2.close();
                ds1.close();
                ds2.close();
            } catch (Exception ignore) {
            }
        }
    }
}

```
