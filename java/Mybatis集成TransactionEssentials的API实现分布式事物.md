# Mybatis集成TransactionEssentials的API实现分布式事物

## 依赖
```
<dependency>
            <groupId>com.atomikos</groupId>
            <artifactId>transactions-jdbc</artifactId>
            <version>4.0.6</version>
</dependency>

<dependency>
            <groupId>javax.transaction</groupId>
            <artifactId>jta</artifactId>
            <version>1.1</version>
</dependency>
```

## spring 事物注释
```
 <tx:annotation-driven transaction-manager="getJtaTransactionManager"/>
```

## 配置多个mapper扫描
```xml
<bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
        <property name="basePackage" value="com.config.db.mapper" />
        <property name="sqlSessionFactory" ref="mybatisPlusFactory1"></property>
</bean>

<bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
        <property name="basePackage" value="com.config.db.mapper2" />
        <property name="sqlSessionFactory" ref="mybatisPlusFactory2"></property>
</bean>
```

## 配置多个数据源
```
  public DataSource getDataSource() {
        Properties properties=new Properties();
        properties.put("url","jdbc:mysql://192.168.216.237:3306/zephyr-api?roundRobinLoadBalance=true&autoReconnect=true&useUnicode=true&characterEncoding=UTF-8");
        properties.put("user","root");
        properties.put("password","123456");
        properties.put("pinGlobalTxToPhysicalConnection",true);
        AtomikosDataSourceBean dataSource = new AtomikosDataSourceBean();
        dataSource.setUniqueResourceName("d1");
        dataSource.setXaDataSourceClassName("com.mysql.jdbc.jdbc2.optional.MysqlXADataSource");
        dataSource.setXaProperties(properties);
        return dataSource;
    }


    public DataSource getDataSource2() {
        Properties properties=new Properties();
        properties.put("url","jdbc:mysql://192.168.216.237:3306/zephyr-api-new?roundRobinLoadBalance=true&autoReconnect=true&useUnicode=true&characterEncoding=UTF-8");
        properties.put("user","root");
        properties.put("password","123456");
        properties.put("pinGlobalTxToPhysicalConnection",true);
        AtomikosDataSourceBean dataSource = new AtomikosDataSourceBean();
        dataSource.setUniqueResourceName("d2");
        dataSource.setXaDataSourceClassName("com.mysql.jdbc.jdbc2.optional.MysqlXADataSource");
        dataSource.setXaProperties(properties);
        return dataSource;
    }
```


## 配置事物管理器
```
 @Bean
    public JtaTransactionManager getJtaTransactionManager() {
        JtaTransactionManager jtaTransactionManager = new JtaTransactionManager();
        jtaTransactionManager.setTransactionManager(getUserTransactionManager());
        return jtaTransactionManager;
    }

    @Bean
    public UserTransactionManager getUserTransactionManager() {
        UserTransactionManager userTransactionManager = new UserTransactionManager();
        userTransactionManager.setForceShutdown(true);
        return userTransactionManager;
    }
```

## 配置多个SqlSessionFactory
```
 @Bean(name = "mybatisPlusFactory1")
    public SqlSessionFactory mybatisPlusFactory() throws Exception {
        MybatisSqlSessionFactoryBean mybatisSqlSessionFactoryBean = new MybatisSqlSessionFactoryBean();
        mybatisSqlSessionFactoryBean.setDataSource(getDataSource());
        Resource[] resources = new PathMatchingResourcePatternResolver().getResources("classpath*:mapper/db2/*.xml");
        mybatisSqlSessionFactoryBean.setMapperLocations(resources);
        return mybatisSqlSessionFactoryBean.getObject();
    }

    @Bean(name = "mybatisPlusFactory2")
    public SqlSessionFactory mybatisPlusFactory2() throws Exception {
        MybatisSqlSessionFactoryBean mybatisSqlSessionFactoryBean = new MybatisSqlSessionFactoryBean();
        mybatisSqlSessionFactoryBean.setDataSource(getDataSource2());
        Resource[] resources = new PathMatchingResourcePatternResolver().getResources("classpath*:mapper/db2/*.xml");
        mybatisSqlSessionFactoryBean.setMapperLocations(resources);
        return mybatisSqlSessionFactoryBean.getObject();
    }
```


## 业务调用
```
 @Transactional
    public void saveData() {

        TestUser x = TestUser.init("小D");

        testMapper.insert(x);
        testMapper2.insert(x);
       throw new RuntimeException("");
    }
```
