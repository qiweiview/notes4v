# spring-mybatis 教程

## 实例代码
```
package test4v;

import org.apache.ibatis.datasource.pooled.PooledDataSourceFactory;
import org.apache.ibatis.session.Configuration;
import org.apache.ibatis.session.ExecutorType;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.SqlSessionTemplate;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import javax.sql.DataSource;
import java.util.Properties;


@org.springframework.context.annotation.Configuration
@MapperScan(basePackages = "test4v")
public class TestApplicationStart {

  private String resource = "test4v/mybatis-config.xml";

  public static void main(String[] args){
    String s = TestApplicationStart.class.getResource("Beans.xml").toString();
    ApplicationContext context = new ClassPathXmlApplicationContext(s);
    SqlTest sqlTest = context.getBean(SqlTest.class);
    sqlTest.delOne();
  }




  @Bean(name = "transactionManager")
  public DataSourceTransactionManager getDataSourceTransactionManager() {
    return new DataSourceTransactionManager(getDataSource());
  }

  @Bean
  @Primary
  public SqlSessionTemplate getSqlSessionTemplate() throws Exception {
    SqlSessionTemplate sqlSessionTemplate = new SqlSessionTemplate(getSqlSessionFactoryBySqlSessionFactoryBean());
    return sqlSessionTemplate;
  }


  @Bean(name="batchSqlSessionTemplate")
  public SqlSessionTemplate getBatchSqlSessionTemplate() throws Exception {
    SqlSessionTemplate sqlSessionTemplate = new SqlSessionTemplate(getSqlSessionFactoryBySqlSessionFactoryBean(), ExecutorType.BATCH);
    return sqlSessionTemplate;
  }

  @Bean
  public SqlSessionFactory getSqlSessionFactoryBySqlSessionFactoryBean() throws Exception {
    SqlSessionFactoryBean factoryBean = new SqlSessionFactoryBean();
    factoryBean.setDataSource(getDataSource());
    SqlSessionFactory object = factoryBean.getObject();
    return object;
  }


  @Bean
  public DataSource getDataSource() {
    Properties properties = new Properties();
    properties.setProperty("driver", "com.mysql.cj.jdbc.Driver");
    properties.setProperty("url", "jdbc:mysql://localhost:3306/test4work?useUnicode=true&characterEncoding=UTF-8&allowMultiQueries=true&serverTimezone=Asia/Shanghai");
    properties.setProperty("username", "root");
    properties.setProperty("password", "xxxxx");
    PooledDataSourceFactory pooledDataSourceFactory = new PooledDataSourceFactory();
    pooledDataSourceFactory.setProperties(properties);
    DataSource dataSource = pooledDataSourceFactory.getDataSource();
    return dataSource;
  }


}

```


## 获取数据源
```
public static DataSource getDataSource() {
    Properties properties = new Properties();
    properties.setProperty("driver", "com.mysql.cj.jdbc.Driver");
    properties.setProperty("url", "jdbc:mysql://localhost:3306/test4work?useUnicode=true&characterEncoding=UTF-8&allowMultiQueries=true&serverTimezone=Asia/Shanghai");
    properties.setProperty("username", "root");
    properties.setProperty("password", "xxx");
    PooledDataSourceFactory pooledDataSourceFactory = new PooledDataSourceFactory();
    pooledDataSourceFactory.setProperties(properties);
    DataSource dataSource = pooledDataSourceFactory.getDataSource();
    return dataSource;
  }
```

## 获取SessionFactory
* 创建SessionFactory调用的也是SqlSessionFactoryBuilder
* 通过获取Configuration来注册Mapper,不注册Mapper后面会找不到（或者用@MapperScan扫描）
```
public static SqlSessionFactory getSqlSessionFactoryBySqlSessionFactoryBean() throws Exception {
    SqlSessionFactoryBean factoryBean = new SqlSessionFactoryBean();
    factoryBean.setDataSource(getDataSource());
    SqlSessionFactory object = factoryBean.getObject();
    Configuration configuration = object.getConfiguration();
    configuration.addMapper(UserMapper2.class);
    return object;
  }
```

## 获取SqlSessionTemplate
* 得传入一个SqlSessionFactory
```
public  static SqlSessionTemplate getSqlSessionTemplate() throws Exception {
    SqlSessionTemplate sqlSessionTemplate=new SqlSessionTemplate(getSqlSessionFactoryBySqlSessionFactoryBean());
    return sqlSessionTemplate;
  }
```

* 除了get mapper还可以直接调用
```
List<Object> objects = sqlSessionTemplate.selectList("test4v.UserMapper2.selectAllUsere");
```
* 获取批量操作的template

不能存在使用不同 ExecutorType 的进行中的事务。要么确保对不同 ExecutorType 的 SqlSessionTemplate 的调用处在不同的事务中，要么完全不使用事务
```
@Bean(name="batchSqlSessionTemplate")
  public SqlSessionTemplate getBatchSqlSessionTemplate() throws Exception {
    SqlSessionTemplate sqlSessionTemplate = new SqlSessionTemplate(getSqlSessionFactoryBySqlSessionFactoryBean(), ExecutorType.BATCH);
    return sqlSessionTemplate;
  }
```

## 事物
* 一个使用 MyBatis-Spring 的其中一个主要原因是它允许 MyBatis 参与到 Spring 的事务管理中

* MyBatis-Spring 借助了 Spring 中的 DataSourceTransactionManager 来实现事务管理

* 在事务处理期间，一个单独的 SqlSession 对象将会被创建和使用。当事务完成时，这个 session 会以合适的方式提交或回滚

* 为事务管理器指定的 DataSource 必须和用来创建 SqlSessionFactoryBean 的是同一个数据源，否则事务管理器就无法工作了（重要）

* Spring 总是为你处理了事务，你不能在 Spring 管理的 SqlSession 上调用 SqlSession.commit()，SqlSession.rollback() 或 SqlSession.close() 方法。如果这样做了，就会抛出 UnsupportedOperationException 异常

* 无论 JDBC 连接是否设置为自动提交，调用 SqlSession 数据方法或在 Spring 事务之外调用任何在映射器中方法，事务都将会自动被提交

## SqlSession
* 使用 MyBatis-Spring 之后，你不再需要直接使用 SqlSessionFactory 了，因为你的 bean 可以被注入一个线程安全的 SqlSession（mybatis中是线程不安全的），它能基于 Spring 的事务配置来自动提交、回滚、关闭 session
* SqlSessionTemplate 是 MyBatis-Spring 的核心。作为 SqlSession 的一个实现，这意味着可以使用它无缝代替你代码中已经在使用的 SqlSession。SqlSessionTemplate 是线程安全的，可以被多个 DAO 或映射器所共享使用

## 映射器

* MapperFactoryBean注册映射器
* 使用 <mybatis:scan/> 元素发现映射器
* 使用 @MapperScan 注解发现映射器
