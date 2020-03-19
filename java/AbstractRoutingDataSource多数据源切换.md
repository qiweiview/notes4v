# AbstractRoutingDataSource多数据源切换

* 抽象方法

## 核心方法
* getConnection
```
 public Connection getConnection() throws SQLException {
        return this.determineTargetDataSource().getConnection();
    }
```

* determineTargetDataSource
* 会通过determineCurrentLookupKey()拿到key,用key从map里取连接池
```
protected DataSource determineTargetDataSource() {
        Assert.notNull(this.resolvedDataSources, "DataSource router not initialized");
        Object lookupKey = this.determineCurrentLookupKey();
        DataSource dataSource = (DataSource)this.resolvedDataSources.get(lookupKey);
        if (dataSource == null && (this.lenientFallback || lookupKey == null)) {
            dataSource = this.resolvedDefaultDataSource;
        }

        if (dataSource == null) {
            throw new IllegalStateException("Cannot determine target DataSource for lookup key [" + lookupKey + "]");
        } else {
            return dataSource;
        }
    }
```

* determineCurrentLookupKey是抽象方法，由继承类实现返回
