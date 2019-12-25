# Mybatis教程

## 纯java配置
```
 public static DataSource getDataSource() {
        Properties properties = new Properties();
        properties.setProperty("driver", "com.mysql.jdbc.Driver");
        properties.setProperty("url", "jdbc:mysql://172.28.2.80:3307/xxx?roundRobinLoadBalance=true&autoReconnect=true&useUnicode=true&characterEncoding=UTF-8");
        properties.setProperty("username", "xxx");
        properties.setProperty("password", "xxx");
        PooledDataSourceFactory pooledDataSourceFactory = new PooledDataSourceFactory();
        pooledDataSourceFactory.setProperties(properties);
        DataSource dataSource = pooledDataSourceFactory.getDataSource();
        return dataSource;
    }
    public static SqlSessionFactory getSqlSessionFactoryBySqlSessionFactoryBean() throws Exception {
        SqlSessionFactoryBean factoryBean = new SqlSessionFactoryBean();
        factoryBean.setDataSource(getDataSource());
        SqlSessionFactory object = factoryBean.getObject();
        return object;
    }

    public static void main(String[] args) throws Exception {
        SqlSessionFactory sqlSessionFactoryBySqlSessionFactoryBean = getSqlSessionFactoryBySqlSessionFactoryBean();
        Configuration configuration = sqlSessionFactoryBySqlSessionFactoryBean.getConfiguration();
        configuration.addMappers("com.zoewin.zephyr.paymentplatform.timer.dao");
        SqlSession sqlSession = sqlSessionFactoryBySqlSessionFactoryBean.openSession();
        TestMapper mapper = sqlSession.getMapper(TestMapper.class);
    }
```

## 从 XML 中构建 SqlSessionFactory

读取配置文件
```
 @Bean
    public SqlSessionFactory getSqlSessionFactory() throws IOException {
        String resource = "mybatis-config.xml";
        InputStream inputStream = Resources.getResourceAsStream(resource);
        SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
        return sqlSessionFactory;
    }
```

配置文件mybatis-config.xml
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <environments default="development">
        <environment id="development">
            <transactionManager type="JDBC"/>
            <dataSource type="POOLED">
                <property name="driver" value="com.mysql.cj.jdbc.Driver"/>
                <property name="url"
                          value="jdbc:mysql://localhost/vtest?useUnicode=true&amp;characterEncoding=UTF-8&amp;allowMultiQueries=true&amp;serverTimezone=Asia/Shanghai"/>
                <property name="username" value="root"/>
                <property name="password" value="root"/>
            </dataSource>
        </environment>
    </environments>
    <mappers>
        <mapper resource="com/bean/UserSimpleMapper.xml"/>
    </mappers>
</configuration>
```

## 从 SqlSessionFactory 中获取 SqlSession

```
SqlSession session = sqlSessionFactory.openSession();
try {
  BlogMapper mapper = session.getMapper(BlogMapper.class);
  Blog blog = mapper.selectBlog(101);
} finally {
  session.close();
}
```

Mapper
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.bean.UserSimpleMapper">

    <select id="findAll" parameterType="com.bean.UserSimple" resultType="com.bean.UserSimple">
        select * from user_table
    </select>
</mapper>
```

MyBatis 对所有的命名配置元素（包括语句，结果映射，缓存等）使用了如下的命名解析规则:

* 完全限定名（比如 “com.mypackage.MyMapper.selectAllThings）将被直接用于查找及使用。
* 短名称（比如 “selectAllThings”）如果全局唯一也可以作为一个单独的引用。 如果不唯一，有两个或两个以上的相同名称（比如 “com.foo.selectAllThings” 和 “com.bar.selectAllThings”），那么使用时就会产生“短名称不唯一”的错误，这种情况下就必须使用完全限定名。

## Java注解配置Mapper
对于像 BlogMapper 这样的映射器类来说，还有另一种方法来处理映射。 它们映射的语句可以不用 XML 来配置，而可以使用 Java 注解来配置。比如，上面的 XML 示例可被替换如下：

```
package com.bean;

import org.apache.ibatis.annotations.Select;

import java.util.List;

public interface UserSimpleMapper {
    @Select("select * from user_table")
    List<UserSimple> findAll();
}
```

java注解添加mapper
```
  @Bean
    public SqlSessionFactory getSqlSessionFactory() throws IOException {
        String resource = "mybatis-config.xml";
        InputStream inputStream = Resources.getResourceAsStream(resource);
        SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
        sqlSessionFactory.getConfiguration().addMapper(UserSimpleMapper.class);
        return sqlSessionFactory;
    }
```

xml添加mapper
```xml
 <!-- mybatis-config.xml -->
<mappers>
        <mapper class="com.bean.UserSimpleMapper"/>
</mappers>
```


**如果你需要完成很复杂的事情，那么最好使用 XML 来映射语句**

## 常用对象作用域（Scope）和生命周期


### SqlSessionFactoryBuilder（最佳作用域为方法，创建结束就可以抛弃）
* 这个类可以被实例化、使用和丢弃，一旦创建了SqlSessionFactory，就不再需要它了。因此 SqlSessionFactoryBuilder实例的最佳作用域是方法作用域（也就是局部方法变量）。
* **你可以重用 SqlSessionFactoryBuilder来创建多个SqlSessionFactory实例，但是最好还是不要让其一直存在，以保证所有的XML解析资源可以被释放给更重要的事情。**

### SqlSessionFactory（最佳作用域为应用，多次重用，使用单例模式或者静态单例模式）
* SqlSessionFactory 一旦被创建就应该在应用的运行期间**一直存在**，没有任何理由丢弃它或重新创建另一个实例。 
* 使用 SqlSessionFactory 的最佳实践是**在应用运行期间不要重复创建多次**，多次重建 SqlSessionFactory 被视为一种代码“坏味道（bad smell）”。
* 因此 SqlSessionFactory 的最佳作用域是**应用作用域**。 有很多方法可以做到，最简单的就是使用单例模式或者静态单例模式。

### SqlSession（线程不安全）
* **每个线程都应该有它自己的 SqlSession 实例。SqlSession 的实例不是线程安全的，因此是不能被共享的，所以它的最佳的作用域是请求或方法作用域。**
* 绝对不能将 SqlSession 实例的引用放在一个类的静态域，甚至一个类的实例变量也不行
* 也绝不能将 SqlSession 实例的引用放在任何类型的托管作用域中，比如 Servlet 框架中的 HttpSession
* 如果你现在正在使用一种 Web 框架，要考虑 SqlSession 放在一个和 HTTP 请求对象相似的作用域中。 换句话说，每次收到的 HTTP 请求，就可以打开一个 SqlSession，返回一个响应，就关闭它。**这个关闭操作是很重要的，你应该把这个关闭操作放到 finally 块中以确保每次都能执行关闭**
* 下面的示例就是一个确保 SqlSession 关闭的标准模式
```
SqlSession session = sqlSessionFactory.openSession();
try {
  // 你的应用逻辑代码
} finally {
  session.close();
}
```

### 映射器实例(Mapper)
* 映射器接口的实例是从 SqlSession 中获得的
* 从技术层面讲，任何映射器实例的最大作用域是和请求它们的 SqlSession 相同的
* 最佳作用域是方法作用域,也就是说，映射器实例应该在调用它们的方法中被请求，用过之后即可丢弃
* 最好把映射器放在方法作用域内。下面的示例就展示了这个实践:
```
SqlSession session = sqlSessionFactory.openSession();
try {
  BlogMapper mapper = session.getMapper(BlogMapper.class);
  // 你的应用逻辑代码
} finally {
  session.close();
}
```

## 配置

一个配置完整的 settings 元素的示例如下：
```xml
<settings>
  <setting name="cacheEnabled" value="true"/>
  <setting name="lazyLoadingEnabled" value="true"/>
  <setting name="multipleResultSetsEnabled" value="true"/>
  <setting name="useColumnLabel" value="true"/>
  <setting name="useGeneratedKeys" value="false"/>
  <setting name="autoMappingBehavior" value="PARTIAL"/>
  <setting name="autoMappingUnknownColumnBehavior" value="WARNING"/>
  <setting name="defaultExecutorType" value="SIMPLE"/>
  <setting name="defaultStatementTimeout" value="25"/>
  <setting name="defaultFetchSize" value="100"/>
  <setting name="safeRowBoundsEnabled" value="false"/>
  <setting name="mapUnderscoreToCamelCase" value="false"/>
  <setting name="localCacheScope" value="SESSION"/>
  <setting name="jdbcTypeForNull" value="OTHER"/>
  <setting name="lazyLoadTriggerMethods" value="equals,clone,hashCode,toString"/>
</settings>
```

### 类型别名（typeAliases）
类型别名是为 Java 类型设置一个短的名字。 **它只和 XML 配置有关**，存在的意义仅在于用来减少类完全限定名的冗余。例如：
```xml
<typeAliases>
  <typeAlias alias="Author" type="domain.blog.Author"/>
  <typeAlias alias="Blog" type="domain.blog.Blog"/>
  <typeAlias alias="Comment" type="domain.blog.Comment"/>
  <typeAlias alias="Post" type="domain.blog.Post"/>
  <typeAlias alias="Section" type="domain.blog.Section"/>
  <typeAlias alias="Tag" type="domain.blog.Tag"/>
</typeAliases>
```
当这样配置时，Blog 可以用在任何使用 domain.blog.Blog 的地方

也可以指定一个包名，MyBatis 会在包名下面搜索需要的 Java Bean
```
<typeAliases>
  <package name="domain.blog"/>
</typeAliases>
```


* 每一个在包 domain.blog 中的 Java Bean，在没有注解的情况下，会使用 Bean 的首字母小写的非限定类名来作为它的别名。 
* 比如 domain.blog.Author 的别名为 author；若有注解，则别名为其注解值。见下面的例子：
```
@Alias("author")
public class Author {
    ...
}
```

## 类型处理器
无论是 MyBatis 在预处理语句（PreparedStatement）中设置一个参数时，还是从结果集中取出一个值时， 都会用类型处理器将获取的值以合适的方式转换成 Java 类型。下表描述了一些默认的类型处理器。

| 类型处理器 | 	Java 类型 |	JDBC类型 |
| -- | -- | -- |
| BooleanTypeHandler | 	java.lang.Boolean, boolean  | 	数据库兼容的 BOOLEAN | 
| ByteTypeHandler	 | java.lang.Byte, byte	 | 数据库兼容的 NUMERIC 或 BYTE | 
| ShortTypeHandler | 	java.lang.Short, short | 	数据库兼容的 NUMERIC 或 SMALLINT
| IntegerTypeHandler | 	java.lang.Integer, int | 	数据库兼容的 NUMERIC 或 INTEGER
| LongTypeHandler | 	java.lang.Long, long | 	数据库兼容的 NUMERIC 或 BIGINT
| FloatTypeHandler | 	java.lang.Float, float | 	数据库兼容的 NUMERIC 或 FLOAT
| DoubleTypeHandler | 	java.lang.Double, double | 	数据库兼容的 NUMERIC 或 DOUBLE
| BigDecimalTypeHandler | 	java.math.BigDecimal | 	数据库兼容的 NUMERIC 或 DECIMAL
| StringTypeHandler | 	java.lang.String | 	CHAR, VARCHAR
| ClobReaderTypeHandler | 	java.io.Reader | 	-
| ClobTypeHandler | 	java.lang.String | 	CLOB, LONGVARCHAR
| NStringTypeHandler | 	java.lang.String | 	NVARCHAR, NCHAR
| NClobTypeHandler | 	java.lang.String | 	NCLOB
| BlobInputStreamTypeHandler | 	java.io.InputStream	-
| ByteArrayTypeHandler | 	byte[] | 	数据库兼容的字节流类型
| BlobTypeHandler | 	byte[]	BLOB,  | LONGVARBINARY
| DateTypeHandler | 	java.util.Date	 | TIMESTAMP
| DateOnlyTypeHandler | 	java.util.Date | 	DATE
| TimeOnlyTypeHandler | 	java.util.Date | 	TIME
| SqlTimestampTypeHandler | 	java.sql.Timestamp | 	TIMESTAMP
| SqlDateTypeHandler | 	java.sql.Date | 	DATE
| SqlTimeTypeHandler | 	java.sql.Time | 	TIME
| ObjectTypeHandler | 	Any	OTHER |  或未指定类型
| EnumTypeHandler | 	Enumeration Type | 	VARCHAR 或任何兼容的字符串类型，用以存储枚举的名称（而不是索引值）
| EnumOrdinalTypeHandler | 	Enumeration Type | 	任何兼容的 NUMERIC 或 DOUBLE 类型，存储枚举的序数值（而不是名称）。
| SqlxmlTypeHandler | 	java.lang.String | 	SQLXML
| InstantTypeHandler | 	java.time.Instant | 	TIMESTAMP
| LocalDateTimeTypeHandler | 	java.time.LocalDateTime | 	TIMESTAMP
| LocalDateTypeHandler | 	java.time.LocalDate | 	DATE
| LocalTimeTypeHandler | 	java.time.LocalTime | 	TIME
| OffsetDateTimeTypeHandler | 	java.time.OffsetDateTime | 	TIMESTAMP
| OffsetTimeTypeHandler | 	java.time.OffsetTime | 	TIME
| ZonedDateTimeTypeHandler | 	java.time.ZonedDateTime | 	TIMESTAMP
| YearTypeHandler | 	java.time.Year | 	INTEGER
| MonthTypeHandler | 	java.time.Month	 | INTEGER
| YearMonthTypeHandler | 	java.time.YearMonth	 | VARCHAR 或 LONGVARCHAR
| JapaneseDateTypeHandler | 	java.time.chrono.JapaneseDate | 	DATE


### 你可以重写类型处理器或创建你自己的类型处理器来处理不支持的或非标准的类型
实现 org.apache.ibatis.type.TypeHandler 接口， 或继承一个很便利的类 org.apache.ibatis.type.BaseTypeHandler， 然后可以选择性地将它映射到一个 JDBC 类型。比如：
```
// ExampleTypeHandler.java
@MappedJdbcTypes(JdbcType.VARCHAR)
public class ExampleTypeHandler extends BaseTypeHandler<String> {

  @Override
  public void setNonNullParameter(PreparedStatement ps, int i, String parameter, JdbcType jdbcType) throws SQLException {
    ps.setString(i, parameter);
  }

  @Override
  public String getNullableResult(ResultSet rs, String columnName) throws SQLException {
    return rs.getString(columnName);
  }

  @Override
  public String getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
    return rs.getString(columnIndex);
  }

  @Override
  public String getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
    return cs.getString(columnIndex);
  }
}
```

```xml
<!-- mybatis-config.xml -->
<typeHandlers>
  <typeHandler handler="org.mybatis.example.ExampleTypeHandler"/>
</typeHandlers>
```

* 使用上述的类型处理器将会**覆盖**已经存在的处理 Java 的 String 类型属性和 VARCHAR 参数及结果的类型处理器
* 要注意 MyBatis 不会通过窥探数据库元信息来决定使用哪种类型，所以你必须在参数和结果映射中指明那是 VARCHAR 类型的字段， 以使其能够绑定到正确的类型处理器上。这是因为**MyBatis 直到语句被执行时才清楚数据类型**

## 对象工厂（objectFactory）
MyBatis 每次创建结果对象的新实例时，它都会使用一个对象工厂（ObjectFactory）实例来完成。 默认的对象工厂需要做的仅仅是实例化目标类，要么通过默认构造方法，要么在参数映射存在的时候通过参数构造方法来实例化。 如果想覆盖对象工厂的默认行为，则可以通过创建自己的对象工厂来实现。比如：
```
// ExampleObjectFactory.java
public class ExampleObjectFactory extends DefaultObjectFactory {
  public Object create(Class type) {
    return super.create(type);
  }
  public Object create(Class type, List<Class> constructorArgTypes, List<Object> constructorArgs) {
    return super.create(type, constructorArgTypes, constructorArgs);
  }
  public void setProperties(Properties properties) {
    super.setProperties(properties);
  }
  public <T> boolean isCollection(Class<T> type) {
    return Collection.class.isAssignableFrom(type);
  }}
```

配置ObjectFactory
```
 @Bean
    public SqlSessionFactory getSqlSessionFactory() throws IOException {
        String resource = "mybatis-config.xml";
        InputStream inputStream = Resources.getResourceAsStream(resource);
        SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
        org.apache.ibatis.session.Configuration configuration = sqlSessionFactory.getConfiguration();
        configuration.addMapper(UserSimpleMapper.class);
        configuration.setObjectFactory(new ExampleObjectFactory());
        return sqlSessionFactory;
    }
```

## 插件（plugins）
MyBatis 允许你在已映射语句执行过程中的某一点进行拦截调用。默认情况下，MyBatis 允许使用插件来拦截的方法调用包括：

* Executor (update, query, flushStatements, commit, rollback, getTransaction, close, isClosed)
* ParameterHandler (getParameterObject, setParameters)
* ResultSetHandler (handleResultSets, handleOutputParameters)
* StatementHandler (prepare, parameterize, batch, update, query)

如果你想做的不仅仅是监控方法的调用，那么你最好相当了解要重写的方法的行为
**因为如果在试图修改或重写已有方法的行为的时候，你很可能在破坏 MyBatis 的核心模块。 这些都是更低层的类和方法，所以使用插件的时候要特别当心**

通过 MyBatis 提供的强大机制，使用插件是非常简单的，只需实现 Interceptor 接口，并指定想要拦截的方法签名即可。

## 事务管理器（transactionManager）
在 MyBatis 中有两种类型的事务管理器（也就是 type=”[JDBC|MANAGED]”）：

这两种事务管理器类型都不需要设置任何属性。它们其实是类型别名，换句话说，你可以使用 TransactionFactory 接口的实现类的完全限定名或类型别名代替它们

* JDBC – 这个配置就是直接使用了JDBC的提交和回滚设置，它依**赖于从数据源得到的连接来管理事务作用域。**
* MANAGED – 这个配置几乎没做什么。**它从来不提交或回滚一个连接，而是让容器来管理事务的整个生命周期（比如 JEE 应用服务器的上下文）。** 默认情况下它会关闭连接，然而一些容器并不希望这样，因此需要将 closeConnection 属性设置为 false 来阻止它默认的关闭行为。例如:
```xml
<transactionManager type="MANAGED">
  <property name="closeConnection" value="false"/>
</transactionManager>
```

如果你正在使用 Spring + MyBatis，则没有必要配置事务管理器， 因为 Spring 模块会使用自带的管理器来覆盖前面的配置（见下spring讲解）



## 数据源（dataSource）
dataSource 元素使用标准的 JDBC 数据源接口来配置 JDBC 连接对象的资源
有三种内建的数据源类型（也就是 type=”[UNPOOLED|POOLED|JNDI]”）：

### UNPOOLED
**这个数据源的实现只是每次被请求时打开和关闭连接**。虽然有点慢，但对于在数据库连接可用性方面没有太高要求的简单应用程序来说，是一个很好的选择。 不同的数据库在性能方面的表现也是不一样的，对于某些数据库来说，使用连接池并不重要，这个配置就很适合这种情形。UNPOOLED 类型的数据源仅仅需要配置以下 5 种属性：

* driver – 这是 JDBC 驱动的 Java 类的完全限定名（并不是 JDBC 驱动中可能包含的数据源类）。
* url – 这是数据库的 JDBC URL 地址。
* username – 登录数据库的用户名。
* password – 登录数据库的密码。
* defaultTransactionIsolationLevel – 默认的连接事务隔离级别。
* 作为可选项，你也可以传递属性给数据库驱动。只需在属性名加上“driver.”前缀即可，例如：driver.encoding=UTF8

### POOLED

这种数据源的实现利用“池”的概念将 JDBC 连接对象组织起来，避免了创建新的连接实例时所必需的初始化和认证时间。 这是一种使得并发 Web 应用快速响应请求的流行处理方式。
除了上述提到 UNPOOLED 下的属性外，还有更多属性用来配置 POOLED 的数据源:

* poolMaximumActiveConnections – 在任意时间可以存在的活动（也就是正在使用）连接数量，默认值：10
* poolMaximumIdleConnections – 任意时间可能存在的空闲连接数。
* poolMaximumCheckoutTime – 在被强制返回之前，池中连接被检出（checked out）时间，默认值：20000 毫秒（即 20 秒）
* poolTimeToWait – 这是一个底层设置，如果获取连接花费了相当长的时间，连接池会打印状态日志并重新尝试获取一个连接（避免在误配置的情况下一直安静的失败），默认值：20000 毫秒（即 20 秒）。
* poolMaximumLocalBadConnectionTolerance – 这是一个关于坏连接容忍度的底层设置， 作用于每一个尝试从缓存池获取连接的线程。 如果这个线程获取到的是一个坏的连接，那么这个数据源允许这个线程尝试重新获取一个新的连接，但是这个重新尝试的次数不应该超过 poolMaximumIdleConnections 与 * poolMaximumLocalBadConnectionTolerance 之和。 默认值：3 （新增于 3.4.5）
* poolPingQuery – 发送到数据库的侦测查询，用来检验连接是否正常工作并准备接受请求。默认是“NO PING QUERY SET”，这会导致多数数据库驱动失败时带有一个恰当的错误消息。
* poolPingEnabled – 是否启用侦测查询。若开启，需要设置 poolPingQuery 属性为一个可执行的 SQL 语句（最好是一个速度非常快的 SQL 语句），默认值：false。
* poolPingConnectionsNotUsedFor – 配置 poolPingQuery 的频率。可以被设置为和数据库连接超时时间一样，来避免不必要的侦测，默认值：0（即所有连接每一时刻都被侦测 — 当然仅当 poolPingEnabled 为 true 时适用）。

### JNDI 
 这个数据源的实现是为了能在如EJB或应用服务器这类容器中使用，容器可以集中或在外部配置数据源，然后放置一个 JNDI 上下文的引用。这种数据源配置只需要两个属性
 
* initial_context – 这个属性用来在 InitialContext 中寻找上下文（即，initialContext.lookup(initial_context)）。这是个可选属性，如果忽略，那么将会直接从 InitialContext 中寻找 data_source 属性。
*  data_source – 这是引用数据源实例位置的上下文的路径。提供了 initial_context 配置时会在其返回的上下文中进行查找，没有提供时则直接在 InitialContext 中查找。
和其他数据源配置类似，可以通过添加前缀“env.”直接把属性传递给初始上下文。比如：

* env.encoding=UTF8

## 映射器（Mappers）
Java 在自动查找这方面没有提供一个很好的方法，所以最佳的方式是告诉 MyBatis 到哪里去找映射文件。 你可以使用相对于类路径的资源引用， 或完全限定资源定位符（包括 file:/// 的 URL），或类名和包名等。例如：
```xml
<!-- 使用相对于类路径的资源引用 -->
<mappers>
  <mapper resource="org/mybatis/builder/AuthorMapper.xml"/>
  <mapper resource="org/mybatis/builder/BlogMapper.xml"/>
  <mapper resource="org/mybatis/builder/PostMapper.xml"/>
</mappers>
<!-- 使用完全限定资源定位符（URL） -->
<mappers>
  <mapper url="file:///var/mappers/AuthorMapper.xml"/>
  <mapper url="file:///var/mappers/BlogMapper.xml"/>
  <mapper url="file:///var/mappers/PostMapper.xml"/>
</mappers>
<!-- 使用映射器接口实现类的完全限定类名 -->
<mappers>
  <mapper class="org.mybatis.builder.AuthorMapper"/>
  <mapper class="org.mybatis.builder.BlogMapper"/>
  <mapper class="org.mybatis.builder.PostMapper"/>
</mappers>
<!-- 将包内的映射器接口实现全部注册为映射器 -->
<mappers>
  <package name="org.mybatis.builder"/>
</mappers>
```

## XML 映射文件
* QL 映射文件只有很少的几个顶级元素（按照应被定义的顺序列出）
* cache – 对给定命名空间的缓存配置。
* cache-ref – 对其他命名空间缓存配置的引用。
* resultMap – 是最复杂也是最强大的元素，用来描述如何从数据库结果集中来加载对象。
* parameterMap – ~~已被废弃！老式风格的参数映射。更好的办法是使用内联参数，此元素可能在将来被移除。文档中不会介绍此元素。~~
* sql – 可被其他语句引用的可重用语句块。
* insert – 映射插入语句
* update – 映射更新语句
* delete – 映射删除语句
* select – 映射查询语句

### select
select 元素允许你配置很多属性来配置每条语句的作用细节。
```xml
<select
  id="selectPerson"
  parameterType="int"
  parameterMap="deprecated"
  resultType="hashmap"
  resultMap="personResultMap"
  flushCache="false"<!-- 将其设置为 true 后，只要语句被调用，都会导致本地缓存和二级缓存被清空，默认值：false。 -->
  useCache="true" <!-- 将其设置为 true 后，将会导致本条语句的结果被二级缓存缓存起来，默认值：对 select 元素为 true。 -->
  timeout="10"
  fetchSize="256"
  statementType="PREPARED"<!-- STATEMENT，PREPARED 或 CALLABLE 中的一个。这会让 MyBatis 分别使用 Statement，PreparedStatement 或 CallableStatement，默认值：PREPARED。 -->
  resultSetType="FORWARD_ONLY">
```

### insert, update 和 delete
数据变更语句 insert，update 和 delete 的实现非常接近：
```
<insert
  id="insertAuthor"
  parameterType="domain.blog.Author"
  flushCache="true"
  statementType="PREPARED"
  keyProperty=""
  keyColumn=""
  useGeneratedKeys=""
  timeout="20">

<update
  id="updateAuthor"
  parameterType="domain.blog.Author"
  flushCache="true"
  statementType="PREPARED"
  timeout="20">

<delete
  id="deleteAuthor"
  parameterType="domain.blog.Author"
  flushCache="true"
  statementType="PREPARED"
  timeout="20">
```


首先，如果你的数据库支持自动生成主键的字段（比如 MySQL 和 SQL Server），那么你可以设置 useGeneratedKeys=”true”，然后再把 keyProperty 设置到目标属性上就 OK 了。例如，如果上面的 Author 表已经对 id 使用了自动生成的列类型，那么语句可以修改为：
```
<insert id="insertAuthor" useGeneratedKeys="true"
    keyProperty="id">
  insert into Author (username,password,email,bio)
  values (#{username},#{password},#{email},#{bio})
</insert>
```

如果你的数据库还支持多行插入, 你也可以传入一个 Author 数组或集合，并返回自动生成的主键。
```
<insert id="insertAuthor" useGeneratedKeys="true"
    keyProperty="id">
  insert into Author (username, password, email, bio) values
  <foreach item="item" collection="list" separator=",">
    (#{item.username}, #{item.password}, #{item.email}, #{item.bio})
  </foreach>
</insert>
```

对于不支持自动生成类型的数据库或可能不支持自动生成主键的 JDBC 驱动，MyBatis 有另外一种方法来生成主键。

这里有一个简单（甚至很傻）的示例，它可以生成一个随机 ID（你最好不要这么做，但这里展示了 MyBatis 处理问题的灵活性及其所关心的广度）：
```
<insert id="insertAuthor">
  <selectKey keyProperty="id" resultType="int" order="BEFORE">
    select CAST(RANDOM()*1000000 as INTEGER) a from SYSIBM.SYSDUMMY1
  </selectKey>
  insert into Author
    (id, username, password, email,bio, favourite_section)
  values
    (#{id}, #{username}, #{password}, #{email}, #{bio}, #{favouriteSection,jdbcType=VARCHAR})
</insert>
```

在上面的示例中，selectKey 元素中的语句将会首先运行，Author 的 id 会被设置，然后插入语句会被调用。这可以提供给你一个与数据库中自动生成主键类似的行为，同时保持了 Java 代码的简洁。
selectKey 元素描述如下：
```xml
<selectKey
  keyProperty="id"
  resultType="int"
  order="BEFORE"
  statementType="PREPARED">
```

|属性 |	描述 |
|  -- | -- |
|keyProperty | 	selectKey 语句结果应该被设置的目标属性。如果希望得到多个生成的列，也可以是逗号分隔的属性名称列表。 | 
|keyColumn | 	匹配属性的返回结果集中的列名称。如果希望得到多个生成的列，也可以是逗号分隔的属性名称列表。 | 
|resultType | 	结果的类型。MyBatis 通常可以推断出来，但是为了更加精确，写上也不会有什么问题。MyBatis 允许将任何简单类型用作主键的类型，包括字符串。如果希望作用于多个生成的列，则可以使用一个包含期望属性的 Object 或一个 Map。 | 
|order | 	这可以被设置为 BEFORE 或 AFTER。如果设置为 |  BEFORE，那么它会首先生成主键，设置 keyProperty 然后执行插入语句。如果设置为 AFTER，那么先执行插入语句，然后是 selectKey 中的语句 - 这和 Oracle 数据库的行为相似，在插入语句内部可能有嵌入索引调用。
|statementType | 	与前面相同，MyBatis 支持 STATEMENT，PREPARED 和 CALLABLE 语句的映射类型，分别代表 PreparedStatement 和 CallableStatement 类型。 | 

### sql
这个元素可以被用来定义可重用的 SQL 代码段，这些 SQL 代码可以被包含在其他语句中。它可以（在加载的时候）被静态地设置参数。 在不同的包含语句中可以设置不同的值到参数占位符上。比如：
```
<sql id="userColumns"> ${alias}.id,${alias}.username,${alias}.password </sql>
<!-- 这个 SQL 片段可以被包含在其他语句中，例如：-->

<select id="selectUsers" resultType="map">
  select
    <include refid="userColumns"><property name="alias" value="t1"/></include>,
    <include refid="userColumns"><property name="alias" value="t2"/></include>
  from some_table t1
    cross join some_table t2
</select>
```

属性值也可以被用在 include 元素的 refid 属性里或 include 元素的内部语句中，例如：
```
<sql id="sometable">
  ${prefix}Table
</sql>

<sql id="someinclude">
  from
    <include refid="${include_target}"/>
</sql>

<select id="select" resultType="map">
  select
    field1, field2, field3
  <include refid="someinclude">
    <property name="prefix" value="Some"/>
    <property name="include_target" value="sometable"/>
  </include>
</select>
```

### 参数
像 MyBatis 的其他部分一样，参数也可以指定一个特殊的数据类型。
```xml
#{property,javaType=int,jdbcType=NUMERIC}
```

像 MyBatis 的其它部分一样，javaType 几乎总是可以根据参数对象的类型确定下来，除非该对象是一个 HashMap。这个时候，你需要显式指定 javaType 来确保正确的类型处理器（TypeHandler）被使用

对于数值类型，还有一个小数保留位数的设置，来指定小数点后保留的位数。
```
#{height,javaType=double,jdbcType=NUMERIC,numericScale=2}
```

尽管所有这些选项很强大，但大多时候你只须简单地指定属性名，其他的事情 MyBatis 会自己去推断，顶多要为可能为空的列指定 jdbcType。
```
#{firstName}
#{middleInitial,jdbcType=VARCHAR}
#{lastName}
```

### 字符串替换

默认情况下,使用 #{} 格式的语法会导致 MyBatis 创建 PreparedStatement 参数占位符并安全地设置参数（就像使用?一样）。这样做更安全，更迅速，通常也是首选做法。
不过有时你就是想直接在 SQL 语句中插入一个不转义的字符串。 比如，像 ORDER BY，你可以这样来使用(这里 MyBatis 不会修改或转义字符串)：
```
ORDER BY ${columnName}
```

条件查询多列
```
@Select("select * from user where id = #{id}")
User findById(@Param("id") long id);

@Select("select * from user where name = #{name}")
User findByName(@Param("name") String name);

@Select("select * from user where email = #{email}")
User findByEmail(@Param("email") String email);
```

可以写成一句
```
@Select("select * from user where ${column} = #{value}")
User findByColumn(@Param("column") String column, @Param("value") String value);
```
其中 ${column} 会被直接替换，而 #{value} 会被使用 ? 预处理。

因此你就可以像下面这样来达到上述功能：
```java
User userOfId1 = userMapper.findByColumn("id", 1L);
User userOfNameKid = userMapper.findByColumn("name", "kid");
User userOfEmail = userMapper.findByColumn("email", "noone@nowhere.com");
```

## 结果映射

ResultMap 的设计思想是，对于简单的语句根本不需要配置显式的结果映射，而对于复杂一点的语句只需要描述它们的关系就行了

ResultMap 最优秀的地方在于，虽然你已经对它相当了解了，但是根本就不需要显式地用到他们。 上面这些简单的示例根本不需要下面这些繁琐的配置。 但出于示范的原因，让我们来看看最后一个示例中，如果使用外部的 resultMap 会怎样，这也是解决列名不匹配的另外一种方式。
```
<resultMap id="userResultMap" type="User">
  <id property="id" column="user_id" />
  <result property="username" column="user_name"/>
  <result property="password" column="hashed_password"/>
</resultMap>
```
而在引用它的语句中使用 resultMap 属性就行了（注意我们去掉了 resultType 属性）。比如:
```
<select id="selectUsers" resultMap="userResultMap">
  select user_id, user_name, hashed_password
  from some_table
  where id = #{id}
</select>
```

## 动态 SQL
如果希望通过“title”和“author”两个参数进行可选搜索该怎么办呢？首先，改变语句的名称让它更具实际意义；然后只要加入另一个条件即可。
```
<select id="findActiveBlogLike"
     resultType="Blog">
  SELECT * FROM BLOG WHERE state = ‘ACTIVE’
  <if test="title != null">
    AND title like #{title}
  </if>
  <if test="author != null and author.name != null">
    AND author_name like #{author.name}
  </if>
</select>
```

提供了“title”就按“title”查找，提供了“author”就按“author”查找的情形，若两者都没有提供，就返回所有符合条件的 BLOG（实际情况可能是由管理员按一定策略选出 BLOG 列表，而不是返回大量无意义的随机结果）。
```
<select id="findActiveBlogLike"
     resultType="Blog">
  SELECT * FROM BLOG WHERE state = ‘ACTIVE’
  <choose>
    <when test="title != null">
      AND title like #{title}
    </when>
    <when test="author != null and author.name != null">
      AND author_name like #{author.name}
    </when>
    <otherwise>
      AND featured = 1
    </otherwise>
  </choose>
</select>
```

```
<select id="findActiveBlogLike"
     resultType="Blog">
  SELECT * FROM BLOG
  <where>
    <if test="state != null">
         state = #{state}
    </if>
    <if test="title != null">
        AND title like #{title}
    </if>
    <if test="author != null and author.name != null">
        AND author_name like #{author.name}
    </if>
  </where>
</select>
```
where 元素只会在至少有一个子元素的条件返回 SQL 子句的情况下才去插入“WHERE”子句。而且，若语句的开头为“AND”或“OR”，where 元素也会将它们去除。


如果 where 元素没有按正常套路出牌，我们可以通过自定义 trim 元素来定制 where 元素的功能。比如，和 where 元素等价的自定义 trim 元素为：
```
<trim prefix="WHERE" prefixOverrides="AND |OR ">
  ...
</trim>
```

类似的用于动态更新语句的解决方案叫做 set。set 元素可以用于动态包含需要更新的列，而舍去其它的。比如：
```
<update id="updateAuthorIfNecessary">
  update Author
    <set>
      <if test="username != null">username=#{username},</if>
      <if test="password != null">password=#{password},</if>
      <if test="email != null">email=#{email},</if>
      <if test="bio != null">bio=#{bio}</if>
    </set>
  where id=#{id}
</update>
```

### foreach
动态 SQL 的另外一个常用的操作需求是对一个集合进行遍历，通常是在构建 IN 条件语句的时候。比如：
```
<select id="selectPostIn" resultType="domain.blog.Post">
  SELECT *
  FROM POST P
  WHERE ID in
  <foreach item="item" index="index" collection="list"
      open="(" separator="," close=")">
        #{item}
  </foreach>
</select>
```

## 日志
Mybatis 的内置日志工厂提供日志功能，内置日志工厂将日志交给以下其中一种工具作代理：

* SLF4J
* Apache Commons Logging
* Log4j 2
* Log4j
* JDK logging
MyBatis 内置日志工厂基于运行时自省机制选择合适的日志工具。它会使用第一个查找得到的工具（按上文列举的顺序查找）。如果一个都未找到，日志功能就会被禁用。

如果你决定要调用以上某个方法，请在调用其它 MyBatis 方法之前调用它。另外，仅当运行时类路径中存在该日志工具时，调用与该日志工具对应的方法才会生效，否则 MyBatis 一概忽略。如你环境中并不存在 Log4J，你却调用了相应的方法，MyBatis 就会忽略这一调用，转而以默认的查找顺序查找日志工具。


## MyBatis-Spring整合
在 MyBatis-Spring 中，可使用 SqlSessionFactoryBean来创建 SqlSessionFactory

```
@Bean
    public SqlSessionFactory getSqlSessionFactory() throws Exception {
        SqlSessionFactoryBean factoryBean = new SqlSessionFactoryBean();
        factoryBean.setDataSource(getDataSource());
        SqlSessionFactory sqlSessionFactory = factoryBean.getObject();
        org.apache.ibatis.session.Configuration configuration = sqlSessionFactory.getConfiguration();
        configuration.addMappers("com.bean");
        /*configuration.addMapper(UserSimpleMapper.class);*/
        return sqlSessionFactory;
    }
```
SqlSessionFactory 有一个唯一的必要属性：用于 JDBC 的 DataSource。这可以是任意的 DataSource 对象，它的配置方法和其它 Spring 数据库连接是一样的。


### 事务
一个使用 MyBatis-Spring 的其中一个主要原因是它允许 MyBatis **参与**到 Spring 的事务管理中。而不是给 MyBatis 创建一个新的专用事务管理器，MyBatis-Spring 借助了 Spring 中的 DataSourceTransactionManager 来实现事务管理。

一旦配置好了 Spring 的事务管理器，你就可以在 Spring 中按你平时的方式来配置事务。并且支持 @Transactional 注解和 AOP 风格的配置。在事务处理期间，一个单独的 SqlSession 对象将会被创建和使用。当事务完成时，这个 session 会以合适的方式提交或回滚。

@EnableTransactionManagement启用事物
```
/**
 * excludeFilters属性使得spring在组件扫描时排除指定的类。这里之所以要排除带有@EnableMVC注解和@Controller注解的类，是因为
 * <p>
 * 带有@EnableMVC注解的类会通过钦点的方式加载
 * 而带有@Controller注解的类会在另一个文件中进行加载
 */
@Configuration
@ComponentScan(basePackages = {"com"},
        excludeFilters = {
                @ComponentScan.Filter(type = FilterType.ANNOTATION, value = EnableWebMvc.class),
                @ComponentScan.Filter(type = FilterType.ANNOTATION, value = Controller.class)
        })
@EnableTransactionManagement//启用事物
public class RootConfig {
}
```

配置事物管理器
```
 /**
     * 事物管理
     *
     * @return
     */
    @Bean
    public DataSourceTransactionManager getDataSourceTransactionManager() {
        return new DataSourceTransactionManager(getDataSource());
    }
```

#### 使用 SqlSession
* 在 MyBatis 中，你可以使用 SqlSessionFactory 来创建 SqlSession。一旦你获得一个 session 之后，你可以使用它来执行映射了的语句，提交或回滚连接，最后，当不再需要它的时候，你可以关闭 session。使用 MyBatis-Spring 之后，你不再需要直接使用 SqlSessionFactory 了，因为你的 bean 可以被注入一个线程安全的 SqlSession，它能基于 Spring 的事务配置来自动提交、回滚、关闭 session。

* SqlSessionTemplate 是 MyBatis-Spring 的核心。作为 SqlSession 的一个实现，这意味着可以使用它无缝代替你代码中已经在使用的 SqlSession。SqlSessionTemplate 是线程安全的，可以被多个 DAO 或映射器所共享使用

* 当调用 SQL 方法时（包括由 getMapper() 方法返回的映射器中的方法），SqlSessionTemplate 将会保证使用的 SqlSession 与当前 Spring 的事务相关。此外，它管理 session 的生命周期，包含必要的关闭、提交或回滚操作。另外，它也负责将 MyBatis 的异常翻译成 Spring 中的 DataAccessExceptions。

* 由于模板可以参与到 Spring 的事务管理中，并且由于其是线程安全的，可以供多个映射器类使用，你应该总是用 SqlSessionTemplate 来替换 MyBatis 默认的 DefaultSqlSession 实现。在同一应用程序中的不同类之间混杂使用可能会引起数据一致性的问题。

使用 SqlSessionFactory 作为构造方法的参数来创建 SqlSessionTemplate 对象。
```
@Bean
public SqlSessionTemplate sqlSession() throws Exception {
  return new SqlSessionTemplate(sqlSessionFactory());
}
```

现在，这个 bean 就可以直接注入到你的 DAO bean 中了。你需要在你的 bean 中添加一个 SqlSession 属性，就像下面这样：
```
public class TransactionService {
    @Autowired
    SqlSession sqlSession;

    public void testUpdate() {
    //xxxxx
    }
    }
```


SqlSessionTemplate 还有一个接收 ExecutorType 参数的构造方法。这允许你使用如下 Spring 配置来批量创建对象，例如批量创建一些 SqlSession：
```
@Bean
public SqlSessionTemplate sqlSession() throws Exception {
  return new SqlSessionTemplate(sqlSessionFactory(), ExecutorType.BATCH);
}
```

现在所有的映射语句可以进行批量操作了，可以在 DAO 中编写如下的代码
```
public void insertUsers(List<User> users) {
  for (User user : users) {
    sqlSession.insert("org.mybatis.spring.sample.mapper.UserMapper.insertUser", user);
  }
}
```


#### 发现映射器

1. 注解
```
@Configuration
@MapperScan("com.bean")
```
2. java配置
```
  org.apache.ibatis.session.Configuration configuration = sqlSessionFactory.getConfiguration();
        configuration.addMappers("com.bean");//添加包名
       configuration.addMapper(UserSimpleMapper.class); //添加单个
```
