# Mybatis源码学习


# 创建SqlSessionFactory并执行查询

# xml方式加载配置

## 流程
```
        String resource = "test4v/mybatis-config.xml";
        InputStream inputStream = null;
        try {
            inputStream = Resources.getResourceAsStream(resource);
        } catch (IOException e) {
            e.printStackTrace();
        }
        SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
        SqlSession sqlSession = sqlSessionFactory.openSession();
        try {
            UserMapper mapper = sqlSession.getMapper(UserMapper.class);
            List<Map> maps = mapper.selectAllUser();
            System.out.println(maps);
        } finally {
            sqlSession.close();
        }
```

### 工厂核心，通过一切方法转换到build(Configuration config)
```
public SqlSessionFactory build(Configuration config) {
    return new DefaultSqlSessionFactory(config);
  }
```




### Configuration构造方法
* Configuration类里面有Environment对象属性
```
  public Configuration(Environment environment) {
    this();
    this.environment = environment;
  }
```


### Environment类
* 存放着编号，事物工厂和数据源三个属性
```
public final class Environment {
  private final String id;
  private final TransactionFactory transactionFactory;
  private final DataSource dataSource;
  
  
  public Environment(String id, TransactionFactory transactionFactory, DataSource dataSource) {
    if (id == null) {
      throw new IllegalArgumentException("Parameter 'id' must not be null");
    }
    if (transactionFactory == null) {
      throw new IllegalArgumentException("Parameter 'transactionFactory' must not be null");
    }
    this.id = id;
    if (dataSource == null) {
      throw new IllegalArgumentException("Parameter 'dataSource' must not be null");
    }
    this.transactionFactory = transactionFactory;
    this.dataSource = dataSource;
  }
  
}

```

### 创建一个数据源DataSource
```
        Properties properties = new Properties();
        properties.setProperty("driver", "com.mysql.cj.jdbc.Driver");
        properties.setProperty("url", "jdbc:mysql://localhost:3306/test4work?useUnicode=true&characterEncoding=UTF-8&allowMultiQueries=true&serverTimezone=Asia/Shanghai");
        properties.setProperty("username", "root");
        properties.setProperty("password", "xxx");
        PooledDataSourceFactory pooledDataSourceFactory = new PooledDataSourceFactory();
        pooledDataSourceFactory.setProperties(properties);
        
        DataSource dataSource = pooledDataSourceFactory.getDataSource();
```




## 获取SqlSession
* return 返回的是DefaultSqlSession
* 请注意，DefaultSqlSession不是线程安全的


```
 SqlSession sqlSession = sqlSessionFactory.openSession();
```

### DefaultSqlSessionFactory类
* 通过SqlSessionFactoryBuilder获取的
```
public class DefaultSqlSessionFactory implements SqlSessionFactory {

  private final Configuration configuration;
  
  
  @Override
  public SqlSession openSession(boolean autoCommit) {
    return openSessionFromDataSource(configuration.getDefaultExecutorType(), null, autoCommit);
  }


private SqlSession openSessionFromDataSource(ExecutorType execType, TransactionIsolationLevel level, boolean autoCommit) {
    Transaction tx = null;
    try {
      final Environment environment = configuration.getEnvironment();
      final TransactionFactory transactionFactory = getTransactionFactoryFromEnvironment(environment);
      tx = transactionFactory.newTransaction(environment.getDataSource(), level, autoCommit);
      final Executor executor = configuration.newExecutor(tx, execType);
      return new DefaultSqlSession(configuration, executor, autoCommit);
    } catch (Exception e) {
      closeTransaction(tx); // may have fetched a connection so lets call close()
      throw ExceptionFactory.wrapException("Error opening session.  Cause: " + e, e);
    } finally {
      ErrorContext.instance().reset();
    }
  }
```



### DefaultSqlSession类
```
public class DefaultSqlSession implements SqlSession {

  private final Configuration configuration;
  private final Executor executor;

  private final boolean autoCommit;
  private boolean dirty;
  private List<Cursor<?>> cursorList;
  
  
  public DefaultSqlSession(Configuration configuration, Executor executor, boolean autoCommit) {
    this.configuration = configuration;
    this.executor = executor;
    this.dirty = false;
    this.autoCommit = autoCommit;
  }
  
  @Override
  public <E> List<E> selectList(String statement, Object parameter) {
    return this.selectList(statement, parameter, RowBounds.DEFAULT);
  }
  
   @Override
  public <E> List<E> selectList(String statement, Object parameter, RowBounds rowBounds) {
    try {
      MappedStatement ms = configuration.getMappedStatement(statement);
      return executor.query(ms, wrapCollection(parameter), rowBounds, Executor.NO_RESULT_HANDLER);//走的是CachingExecutor
    } catch (Exception e) {
      throw ExceptionFactory.wrapException("Error querying database.  Cause: " + e, e);
    } finally {
      ErrorContext.instance().reset();
    }
  }
```

### MappedStatement类
* 在XMLStatementBuilder的parseStatementNode（）中构建(XML)
* 在MapperAnnotationBuilder的parseStatement（）中构建(JAVA)
```
public final class MappedStatement {

  private String resource;
  private Configuration configuration;
  private String id;
  private Integer fetchSize;
  private Integer timeout;
  private StatementType statementType;
  private ResultSetType resultSetType;
  private SqlSource sqlSource;
  private Cache cache;
  private ParameterMap parameterMap;
  private List<ResultMap> resultMaps;
  private boolean flushCacheRequired;
  private boolean useCache;
  private boolean resultOrdered;
  private SqlCommandType sqlCommandType;
  private KeyGenerator keyGenerator;
  private String[] keyProperties;
  private String[] keyColumns;
  private boolean hasNestedResultMaps;
  private String databaseId;
  private Log statementLog;
  private LanguageDriver lang;
  private String[] resultSets;
```

### CachingExecutor 执行器类
```
public class CachingExecutor implements Executor {

  private final Executor delegate;
  private final TransactionalCacheManager tcm = new TransactionalCacheManager();
  
   @Override
  public <E> List<E> query(MappedStatement ms, Object parameterObject, RowBounds rowBounds, ResultHandler resultHandler) throws SQLException {
    BoundSql boundSql = ms.getBoundSql(parameterObject);//获取绑定的sql
    CacheKey key = createCacheKey(ms, parameterObject, rowBounds, boundSql);
    return query(ms, parameterObject, rowBounds, resultHandler, key, boundSql);
  }
  
  
  @Override
  public <E> List<E> query(MappedStatement ms, Object parameterObject, RowBounds rowBounds, ResultHandler resultHandler, CacheKey key, BoundSql boundSql)
      throws SQLException {
    Cache cache = ms.getCache();
    if (cache != null) {
      flushCacheIfRequired(ms);
      if (ms.isUseCache() && resultHandler == null) {
        ensureNoOutParams(ms, boundSql);
        @SuppressWarnings("unchecked")
        List<E> list = (List<E>) tcm.getObject(cache, key);
        if (list == null) {
          list = delegate.query(ms, parameterObject, rowBounds, resultHandler, key, boundSql);
          tcm.putObject(cache, key, list); // issue #578 and #116
        }
        return list;
      }
    }
    return delegate.query(ms, parameterObject, rowBounds, resultHandler, key, boundSql);
  }
```



## 获取Mapper

### MapperRegistry类
* Configuration对象中包含一个mapperRegistry参数
*  MapperRegistry类包含Configuration和一个代理工厂的HashMap

```
@Override
  public <T> T getMapper(Class<T> type) {
    return configuration.getMapper(type, this);//里面调用的是mapperRegistry.getMapper(type, sqlSession)
  }
```


### MapperRegistry类
```
public class MapperRegistry {

  private final Configuration config;
  private final Map<Class<?>, MapperProxyFactory<?>> knownMappers = new HashMap<>();
  
  
  @SuppressWarnings("unchecked")
  public <T> T getMapper(Class<T> type, SqlSession sqlSession) {//获取Mapper
    final MapperProxyFactory<T> mapperProxyFactory = (MapperProxyFactory<T>) knownMappers.get(type);
    if (mapperProxyFactory == null) {
      throw new BindingException("Type " + type + " is not known to the MapperRegistry.");
    }
    try {
      return mapperProxyFactory.newInstance(sqlSession);
    } catch (Exception e) {
      throw new BindingException("Error getting mapper instance. Cause: " + e, e);
    }
  }
  
   public <T> void addMapper(Class<T> type) {//添加Mapper
    if (type.isInterface()) {
      if (hasMapper(type)) {//已存在，那么在这一步就会抛出存在的异常
        throw new BindingException("Type " + type + " is already known to the MapperRegistry.");
      }
      boolean loadCompleted = false;
      try {
      
        //存入对应类型的工厂
        //MapperProxyFactory构造函数this.mapperInterface = mapperInterface;
        knownMappers.put(type, new MapperProxyFactory<>(type));
        
        
        //在运行解析器之前添加类型非常重要，
        //否则映射器解析器可能会自动尝试绑定。 如果类型已知，则不会尝试。
        MapperAnnotationBuilder parser = new MapperAnnotationBuilder(config, type);
        parser.parse();//解析注解
        loadCompleted = true;//解析状态置位
      } finally {
        if (!loadCompleted) {//解析过程中出现异常，没解析完成就移除Mapper
          knownMappers.remove(type);
        }
      }
    }
  }
  
  
```

### MapperAnnotationBuilder类
* 用于解析mapper注解
```
public class MapperAnnotationBuilder {

  private static final Set<Class<? extends Annotation>> SQL_ANNOTATION_TYPES = new HashSet<>();
  private static final Set<Class<? extends Annotation>> SQL_PROVIDER_ANNOTATION_TYPES = new HashSet<>();

  private final Configuration configuration;
  private final MapperBuilderAssistant assistant;
  private final Class<?> type;

  static {
    SQL_ANNOTATION_TYPES.add(Select.class);
    SQL_ANNOTATION_TYPES.add(Insert.class);
    SQL_ANNOTATION_TYPES.add(Update.class);
    SQL_ANNOTATION_TYPES.add(Delete.class);

    SQL_PROVIDER_ANNOTATION_TYPES.add(SelectProvider.class);
    SQL_PROVIDER_ANNOTATION_TYPES.add(InsertProvider.class);
    SQL_PROVIDER_ANNOTATION_TYPES.add(UpdateProvider.class);
    SQL_PROVIDER_ANNOTATION_TYPES.add(DeleteProvider.class);
  }
  
  public void parse() {
    String resource = type.toString();
    if (!configuration.isResourceLoaded(resource)) {//先确认这个mapper有没有被加载过，通过Set<String> loadedResources
      loadXmlResource();//加载xml资源
      configuration.addLoadedResource(resource);//添加加载资源
      assistant.setCurrentNamespace(type.getName());//设置当前命名空间
      parseCache();//处理缓存
      parseCacheRef();//处理缓存引用
      Method[] methods = type.getMethods();//获取Mapper类的所有方法
      for (Method method : methods) {
        try {
          // issue #237
          if (!method.isBridge()) {//如果不是桥接方法
            parseStatement(method);//解析声明，这里面会初始化MappedStatement
          }
        } catch (IncompleteElementException e) {
          configuration.addIncompleteMethod(new MethodResolver(this, method));
        }
      }
    }
    parsePendingMethods();//解析待定方法
  }
  
  
   private void loadXmlResource() {
    //Spring可能不知道真正的资源名称所以我们检查一个标志以防止再次加载资源两次
    //确认资源是否被加载过，通过Set<String> loadedResources
    if (!configuration.isResourceLoaded("namespace:" + type.getName())) {//如果资源没有加载过
      String xmlResource = type.getName().replace('.', '/') + ".xml";
      // #1347
      InputStream inputStream = type.getResourceAsStream("/" + xmlResource);
      if (inputStream == null) {
        // 搜索不在模块中但在类路径中的XML映射器
        try {
          inputStream = Resources.getResourceAsStream(type.getClassLoader(), xmlResource);
        } catch (IOException e2) {
          // 忽略，不需要资源
        }
      }
      if (inputStream != null) {//如果都搜索不到
        XMLMapperBuilder xmlParser = new XMLMapperBuilder(inputStream, assistant.getConfiguration(), xmlResource, configuration.getSqlFragments(), type.getName());
        xmlParser.parse();
      }
      
    }
  }
  
```



### MapperProxyFactory类
* mapper接口类
* 以Method为key的ConcurrentHashMap
```
public class MapperProxyFactory<T> {

  private final Class<T> mapperInterface;
  private final Map<Method, MapperMethod> methodCache = new ConcurrentHashMap<>();
  
  public T newInstance(SqlSession sqlSession) {
    final MapperProxy<T> mapperProxy = new MapperProxy<>(sqlSession, mapperInterface, methodCache);
    return newInstance(mapperProxy);
  }
  
  
  @SuppressWarnings("unchecked")//返回了mapper的代理类
  protected T newInstance(MapperProxy<T> mapperProxy) {
  //获取的是mapperInterface的类加载器
    return (T) Proxy.newProxyInstance(mapperInterface.getClassLoader(), new Class[] { mapperInterface }, mapperProxy);
  }
  
```

### MapperProxy<T>类
* 这是一个代理调用处理程序
```
public class MapperProxy<T> implements InvocationHandler, Serializable {

  private static final long serialVersionUID = -6424540398559729838L;
  private final SqlSession sqlSession;
  private final Class<T> mapperInterface;
  private final Map<Method, MapperMethod> methodCache;
  
  @Override//核心调用方法
  public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
    try {
      if (Object.class.equals(method.getDeclaringClass())) {
        return method.invoke(this, args);
      } else if (isDefaultMethod(method)) {
        return invokeDefaultMethod(proxy, method, args);
      }
    } catch (Throwable t) {
      throw ExceptionUtil.unwrapThrowable(t);
    }
    //一般会进到这里
    final MapperMethod mapperMethod = cachedMapperMethod(method);
    return mapperMethod.execute(sqlSession, args);
  }
  
  private MapperMethod cachedMapperMethod(Method method) {
    return methodCache.computeIfAbsent(method, k -> new MapperMethod(mapperInterface, method, sqlSession.getConfiguration()));//不存在则计算新的值并赋进去，然后返回新值
  }

```

### MapperMethod类
```
public class MapperMethod {

  private final SqlCommand command;
  private final MethodSignature method;
  
  public Object execute(SqlSession sqlSession, Object[] args) {//执行查询方法
    Object result;
    switch (command.getType()) {
      case INSERT: {
        Object param = method.convertArgsToSqlCommandParam(args);
        result = rowCountResult(sqlSession.insert(command.getName(), param));
        break;
      }
      case UPDATE: {
        Object param = method.convertArgsToSqlCommandParam(args);
        result = rowCountResult(sqlSession.update(command.getName(), param));
        break;
      }
      case DELETE: {
        Object param = method.convertArgsToSqlCommandParam(args);
        result = rowCountResult(sqlSession.delete(command.getName(), param));
        break;
      }
      case SELECT:
        if (method.returnsVoid() && method.hasResultHandler()) {
          executeWithResultHandler(sqlSession, args);
          result = null;
        } else if (method.returnsMany()) {
          result = executeForMany(sqlSession, args);
        } else if (method.returnsMap()) {
          result = executeForMap(sqlSession, args);
        } else if (method.returnsCursor()) {
          result = executeForCursor(sqlSession, args);
        } else {
          Object param = method.convertArgsToSqlCommandParam(args);
          result = sqlSession.selectOne(command.getName(), param);
          if (method.returnsOptional()
              && (result == null || !method.getReturnType().equals(result.getClass()))) {
            result = Optional.ofNullable(result);
          }
        }
        break;
      case FLUSH:
        result = sqlSession.flushStatements();
        break;
      default:
        throw new BindingException("Unknown execution method for: " + command.getName());
    }
    if (result == null && method.getReturnType().isPrimitive() && !method.returnsVoid()) {
      throw new BindingException("Mapper method '" + command.getName()
          + " attempted to return null from a method with a primitive return type (" + method.getReturnType() + ").");
    }
    return result;
  }
  
  
  
  
  private <E> Object executeForMany(SqlSession sqlSession, Object[] args) {
    List<E> result;
    Object param = method.convertArgsToSqlCommandParam(args);//将Args转换为Sql命令参数,这里返回的是一个map
    if (method.hasRowBounds()) {
      RowBounds rowBounds = method.extractRowBounds(args);
      result = sqlSession.selectList(command.getName(), param, rowBounds);
    } else {
      result = sqlSession.selectList(command.getName(), param);
    }
    // issue #510 Collections & arrays support
    if (!method.getReturnType().isAssignableFrom(result.getClass())) {
      if (method.getReturnType().isArray()) {
        return convertToArray(result);
      } else {
        return convertToDeclaredCollection(sqlSession.getConfiguration(), result);
      }
    }
    return result;
  }
  
```

### SqlCommand类
```
public static class SqlCommand {

    private final String name;
    private final SqlCommandType type;
```

### SqlCommandType枚举类型
```
public enum SqlCommandType {
  UNKNOWN, INSERT, UPDATE, DELETE, SELECT, FLUSH;
}
```

### MethodSignature类
* 方法签名类
```
public static class MethodSignature {


    private final boolean returnsMany;
    private final boolean returnsMap;
    private final boolean returnsVoid;
    private final boolean returnsCursor;
    private final boolean returnsOptional;
    private final Class<?> returnType;
    private final String mapKey;
    private final Integer resultHandlerIndex;
    private final Integer rowBoundsIndex;
    private final ParamNameResolver paramNameResolver;
```


# 注解方式加载配置

## 流程
```
public static void buildFactoryByJava() {

        Properties properties = new Properties();
        properties.setProperty("driver", "com.mysql.cj.jdbc.Driver");
        properties.setProperty("url", "jdbc:mysql://localhost:3306/test4work?useUnicode=true&characterEncoding=UTF-8&allowMultiQueries=true&serverTimezone=Asia/Shanghai");
        properties.setProperty("username", "root");
        properties.setProperty("password", "qwqwqwasasas");
        PooledDataSourceFactory pooledDataSourceFactory = new PooledDataSourceFactory();
        pooledDataSourceFactory.setProperties(properties);
        DataSource dataSource = pooledDataSourceFactory.getDataSource();


        TransactionFactory transactionFactory = new JdbcTransactionFactory();


        Environment environment = new Environment("development", transactionFactory, dataSource);


        Configuration configuration = new Configuration(environment);
        configuration.addMapper(UserMapper2.class);
        SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(configuration);
        SqlSession sqlSession = sqlSessionFactory.openSession();
        try {
            UserMapper2 mapper = sqlSession.getMapper(UserMapper2.class);
            List<Map> maps = mapper.selectAllUserWhere("123");
            System.out.println(maps);
        } finally {
            sqlSession.close();
        }

    }
```

### 添加带注解的Mapper
* 是与xml区别的核心
```
public <T> void addMapper(Class<T> type) {
    mapperRegistry.addMapper(type);
  }
  //详细在上面的MapperRegistry类里
```

# 查询操作

### 
* 方式一
```
  Object o = sqlSession.selectOne("test4v.UserMapper.selectAllUserId", 123);
```
* 方式二
```
  UserMapper2 mapper = sqlSession.getMapper(UserMapper2.class);
  List<Map> maps = mapper.selectAllUserWhere("123");
```

* 核心都在于DefaultSqlSession的selectList
```
 @Override
  public <E> List<E> selectList(String statement, Object parameter, RowBounds rowBounds) {
    try {
      MappedStatement ms = configuration.getMappedStatement(statement);
      return executor.query(ms, wrapCollection(parameter), rowBounds, Executor.NO_RESULT_HANDLER);
    } catch (Exception e) {
      throw ExceptionFactory.wrapException("Error querying database.  Cause: " + e, e);
    } finally {
      ErrorContext.instance().reset();
    }
  }
```

# 命名空间（Namespaces）
## 命名解析：
为了减少输入量，MyBatis 对所有的命名配置元素（包括语句，结果映射，缓存等）使用了如下的命名解析规则。

* 完全限定名（比如 “com.mypackage.MyMapper.selectAllThings）将被直接用于查找及使用。
* 短名称（比如 “selectAllThings”）如果全局唯一也可以作为一个单独的引用。 如果不唯一，有两个或两个以上的相同名称（比如 “com.foo.selectAllThings” 和 “com.bar.selectAllThings”），那么使用时就会产生“短名称不唯一”的错误，这种情况下就必须使用完全限定名。

# 生命周期
## SqlSessionFactoryBuilder
* 这个类可以被实例化、使用和丢弃，一旦创建了 SqlSessionFactory，就不再需要它了。
* 因此 SqlSessionFactoryBuilder 实例的最佳作用域是方法作用域（也就是局部方法变量）。 你可以重用 SqlSessionFactoryBuilder 来创建多个 SqlSessionFactory 实例，但是最好还是不要让其一直存在，以保证所有的 XML 解析资源可以被释放给更重要的事情。

## SqlSessionFactory
* SqlSessionFactory 一旦被创建就应该在应用的运行期间一直存在，
* 没有任何理由丢弃它或重新创建另一个实例。 使用 SqlSessionFactory 的最佳实践是在应用运行期间不要重复创建多次，多次重建 SqlSessionFactory 被视为一种代码“坏味道（bad smell）”。因此 SqlSessionFactory 的最佳作用域是应用作用域。 有很多方法可以做到，最简单的就是使用单例模式或者静态单例模式。

## SqlSession(线程不安全)
* 每个线程都应该有它自己的SqlSession实例。SqlSession的实例不是线程安全的，因此是不能被共享的，所以它的最佳的作用域是请求或方法作用域。 
* 绝对不能将 SqlSession 实例的引用放在一个类的静态域，甚至一个类的实例变量也不行。 
* 也绝不能将 SqlSession 实例的引用放在任何类型的托管作用域中，比如 Servlet 框架中的 HttpSession。
* 如果你现在正在使用一种 Web 框架，要考虑 SqlSession 放在一个和 HTTP 请求对象相似的作用域中。 换句话说，每次收到的 HTTP 请求，就可以打开一个 SqlSession，返回一个响应，就关闭它。 这个关闭操作是很重要的，你应该把这个关闭操作放到 finally 块中以确保每次都能执行关闭。 下面的示例就是一个确保 SqlSession 关闭的标准模式：
```
try (SqlSession session = sqlSessionFactory.openSession()) {
  // 你的应用逻辑代码
}
```

## 映射器实例
* 映射器是一些由你创建的、绑定你映射的语句的接口。映射器接口的实例是从 SqlSession 中获得的。因此从技术层面讲，任何映射器实例的最大作用域是和请求它们的 SqlSession 相同的。
* 尽管如此，映射器实例的最佳作用域是方法作用域。 也就是说，映射器实例应该在调用它们的方法中被请求，用过之后即可丢弃。 
* 并不需要显式地关闭映射器实例，尽管在整个请求作用域保持映射器实例也不会有什么问题，但是你很快会发现，像 SqlSession 一样，在这个作用域上管理太多的资源的话会难于控制。 
* 为了避免这种复杂性，最好把映射器放在方法作用域内。下面的示例就展示了这个实践：
```
try (SqlSession session = sqlSessionFactory.openSession()) {
  BlogMapper mapper = session.getMapper(BlogMapper.class);
  // 你的应用逻辑代码
}
```

# 配置
## 配置优先级
如果属性在不只一个地方进行了配置，那么 MyBatis 将按照下面的顺序来加载：

* 在 properties 元素体内指定的属性首先被读取。
* 然后根据 properties 元素中的 resource 属性读取类路径下属性文件或根据 url 
* 属性指定的路径读取属性文件，并覆盖已读取的同名属

## 占位符特性
* username在不存在时会被字符串root替代
* 特性默认关闭，需要设置enable-default-value为true
```
<properties>
        <property name="org.apache.ibatis.parsing.PropertyParser.enable-default-value" value="true"/> <!-- 启用默认值特性 -->
        <property name="password" value="xxxxx"/>
</properties>

<dataSource type="POOLED">
                <property name="driver" value="com.mysql.cj.jdbc.Driver"/>
                <property name="url" value="jdbc:mysql://localhost:3306/test4work?useUnicode=true&amp;characterEncoding=UTF-8&amp;allowMultiQueries=true&amp;serverTimezone=Asia/Shanghai"/>
                <property name="username" value="${username:root}"/>
                <property name="password" value="${password}"/>
 </dataSource>
```

* 如果你已经使用 ":" 作为属性的键（如：db:username） ，或者你已经在 SQL 定义中使用 OGNL 表达式的三元运算符（如： ${tableName!=null?tableName:'global_constants'}），你应该通过设置特定的属性来修改分隔键名和默认值的字符。例如：
```
<properties resource="org/mybatis/example/config.properties">
  <!-- ... -->
  <property name="org.apache.ibatis.parsing.PropertyParser.default-value-separator" value="?:"/> <!-- 修改默认值的分隔符 -->
</properties>
<dataSource type="POOLED">
  <!-- ... -->
  <property name="username" value="${db:username?:ut_user}"/>
</dataSource>
```

## 类型别名（typeAliases）
* 类型别名是为 Java 类型设置一个短的名字。 它只和 XML 配置有关，存在的意义仅在于用来减少类完全限定名的冗余。例如：
```
<typeAliases>
  <typeAlias alias="Author" type="domain.blog.Author"/>
  <typeAlias alias="Blog" type="domain.blog.Blog"/>
  <typeAlias alias="Comment" type="domain.blog.Comment"/>
  <typeAlias alias="Post" type="domain.blog.Post"/>
  <typeAlias alias="Section" type="domain.blog.Section"/>
  <typeAlias alias="Tag" type="domain.blog.Tag"/>
</typeAliases>
```
* 也可以指定一个包名，MyBatis 会在包名下面搜索需要的 Java Bean，每一个在包 domain.blog 中的 Java Bean，在没有注解的情况下，会使用 Bean 的首字母小写的非限定类名来作为它的别名。 比如 domain.blog.Author 的别名为 author
```
<typeAliases>
  <package name="domain.blog"/>
</typeAliases>
```
* 若有注解，则别名为其注解值。见下面的例子：
```
@Alias("author")
public class Author {
    ...
}
```

## 类型处理器（typeHandlers）（枚举类型还没看）(源码看不是很懂)
* 无论是 MyBatis 在预处理语句（PreparedStatement）中设置一个参数时，还是从结果集中取出一个值时， 都会用类型处理器将获取的值以合适的方式转换成 Java 类型
* 可以重写类型处理器或创建你自己的类型处理器来处理不支持的或非标准的类型。 具体做法为：实现 org.apache.ibatis.type.TypeHandler 接口， 或继承一个很便利的类 org.apache.ibatis.type.BaseTypeHandler

### Mapper
```
@Insert("insert into user (id,username,password,type,idAndPassWord)
values(#{id},'test','test','testType',#{idAndPassWord})")
    void insertByMyUser(MyUser myUser);
```

### MyUser
```
public class MyUser {

    private String id;
    private IdAndPassWord idAndPassWord;//复杂对象属性
    private String username;
    private String type;
    private String createDate;
```

### IdAndPassWord
```
public class IdAndPassWord {
    private String id;
    private String password;
```

### IdAndPassWordTypeHandler 
* 自定义类型处理器，可以把IdAndPassWord对象通过逻辑映射成VARCHAR
```
@MappedJdbcTypes(JdbcType.VARCHAR)
public class IdAndPassWordTypeHandler extends BaseTypeHandler<IdAndPassWord> {


    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, IdAndPassWord parameter, JdbcType jdbcType) throws SQLException {
        System.out.println("ps.setString");
        ps.setString(i, JSON.toJSONString(parameter));
    }

    @Override
    public IdAndPassWord getNullableResult(ResultSet rs, String columnName) throws SQLException {
        System.out.println("String:"+rs.getString(columnName)+"/"+columnName);
        return IdAndPassWord.parseFromJson(rs.getString(columnName));
    }

    @Override
    public IdAndPassWord getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        System.out.println("int:"+rs.getString(columnIndex));
        return null;
    }

    @Override
    public IdAndPassWord getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        System.out.println(cs.getString(columnIndex));
        return null;
    }
}
```


* 配置方式一：文件注册
```
<!-- mybatis-config.xml -->
<typeHandlers>
  <typeHandler handler="test4v.IdAndPassWordTypeHandler"/>
</typeHandlers>
```

* 配置方式二：java注册
```
configuration.getTypeHandlerRegistry().register(IdAndPassWordTypeHandler.class);
```

* 注册类型处理器要在Mapper添加前，不然会找不到类型处理器报错
```
        Configuration configuration = sqlSessionFactory.getConfiguration();
        configuration.getTypeHandlerRegistry().register(IdAndPassWordTypeHandler.class);//早于Mapper添加
        configuration.addMapper(UserMapper2.class);
```



## 对象工厂（objectFactory）
* MyBatis 每次创建结果对象的新实例时，它都会使用一个对象工厂（ObjectFactory）实例来完成

## 插件（plugins）（这个不是很懂怎么用）
MyBatis 允许你在已映射语句执行过程中的某一点进行拦截调用。默认情况下，MyBatis 允许使用插件来拦截的方法调用包括：

* Executor (update, query, flushStatements, commit, rollback, getTransaction, close, isClosed)
* ParameterHandler (getParameterObject, setParameters)
* ResultSetHandler (handleResultSets, handleOutputParameters)
* StatementHandler (prepare, parameterize, batch, update, query)

```
package test4v;


import org.apache.ibatis.executor.statement.StatementHandler;
import org.apache.ibatis.mapping.BoundSql;
import org.apache.ibatis.plugin.*;
import org.apache.ibatis.session.ResultHandler;
import java.sql.Statement;
import java.util.Properties;

@Intercepts({@Signature(type = StatementHandler.class, method = "query", args = {Statement.class, ResultHandler.class})})
public class MyInterceptor implements Interceptor {
    @Override
    public Object intercept(Invocation invocation) throws Throwable {
        StatementHandler statementHandler = (StatementHandler) invocation.getTarget();
        BoundSql boundSql = statementHandler.getBoundSql();
        String sql = boundSql.getSql();
        System.out.println("sql:" + sql);
        return invocation.proceed();
    }

    @Override
    public Object plugin(Object target) {
        return Plugin.wrap(target, this);//使用JDK的动态代理，给target对象创建一个delegate代理对象，以此来实现方法拦截和增强功能，它会回调intercept()方法,方法
    }

    @Override
    public void setProperties(Properties properties) {
        String dialect = properties.getProperty("dialect");
        System.out.println(dialect);
    }
}

```
* @Intercepts注解：装载一个@Signature列表，一个@Signature其实就是一个需要拦截的方法封装。那么，一个拦截器要拦截多个方法，自然就是一个@Signature列表
* intercept()方法：执行拦截内容的地方，比如想收点保护费。由plugin()方法触发，interceptor.plugin(target)足以证明。

* plugin()方法：决定是否触发intercept()方法。

* setProperties()方法：给自定义的拦截器传递xml配置的属性参数。

### Plugin
* Map<Class<?>, Set<Method>>signatureMap：缓存需拦截对象的反射结果，避免多次反射，即target的反射结果
```
public static Object wrap(Object target, Interceptor interceptor) {
    Map<Class<?>, Set<Method>> signatureMap = getSignatureMap(interceptor);
    Class<?> type = target.getClass();
    Class<?>[] interfaces = getAllInterfaces(type, signatureMap);
    if (interfaces.length > 0) {
      return Proxy.newProxyInstance(
          type.getClassLoader(),
          interfaces,
          new Plugin(target, interceptor, signatureMap));
    }
    return target;
  }

  @Override
  public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
    try {
      Set<Method> methods = signatureMap.get(method.getDeclaringClass());
      if (methods != null && methods.contains(method)) {
        return interceptor.intercept(new Invocation(target, method, args));
      }
      return method.invoke(target, args);
    } catch (Exception e) {
      throw ExceptionUtil.unwrapThrowable(e);
    }
  }
```


### Signature签名
```
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({})
public @interface Signature {
  Class<?> type();//类

  String method();//方法

  Class<?>[] args();//参数类型
}
```

## 环境配置（environments）
* 尽管可以配置多个环境，但每个 SqlSessionFactory 实例只能选择一种环境。
* 如果你想连接两个数据库，就需要创建两个 SqlSessionFactory 实例

## 事务管理器（transactionManager）
* 如果你正在使用 Spring + MyBatis，则没有必要配置事务管理器， 因为 Spring 模块会使用自带的管理器来覆盖前面的配置
* JDBC – 这个配置就是直接使用了 JDBC 的提交和回滚设置，它依赖于从数据源得到的连接来管理事务作用域。
* MANAGED – 这个配置几乎没做什么。它从来不提交或回滚一个连接，而是让容器来管理事务的整个生命周期（比如 JEE 应用服务器的上下文）。 默认情况下它会关闭连接，然而一些容器并不希望这样，因此需要将 closeConnection 属性设置为 false 来阻止它默认的关闭行为

## 数据源（dataSource）



# 操作流程对应类

## select

```
 mapper.insertByMyUser(myUser
 sqlSession.commit();
```

### MapperProxy
* mapper通过代理工厂创建的
```
@Override
  public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
    try {
      if (Object.class.equals(method.getDeclaringClass())) {
        return method.invoke(this, args);
      } else if (isDefaultMethod(method)) {
        return invokeDefaultMethod(proxy, method, args);
      }
    } catch (Throwable t) {
      throw ExceptionUtil.unwrapThrowable(t);
    }
    final MapperMethod mapperMethod = cachedMapperMethod(method);//没有就执行插入
    return mapperMethod.execute(sqlSession, args);
  }
  
 private MapperMethod cachedMapperMethod(Method method) {
    return methodCache.computeIfAbsent(method, k -> new MapperMethod(mapperInterface, method, sqlSession.getConfiguration()));
  }  
  
```

### MapperMethod
```

//在cachedMapperMethod方法中调用了构造方法构造了MapperMethod对象
public MapperMethod(Class<?> mapperInterface, Method method, Configuration config) {
    this.command = new SqlCommand(config, mapperInterface, method);
    this.method = new MethodSignature(config, mapperInterface, method);
  }


public Object execute(SqlSession sqlSession, Object[] args) {
    Object result;
    switch (command.getType()) {//判断操作类型
      case INSERT: {//插入
        Object param = method.convertArgsToSqlCommandParam(args);
        result = rowCountResult(sqlSession.insert(command.getName(), param));
        break;
      }
      case UPDATE: {//更新
        Object param = method.convertArgsToSqlCommandParam(args);
        result = rowCountResult(sqlSession.update(command.getName(), param));
        break;
      }
      case DELETE: {//删除
        Object param = method.convertArgsToSqlCommandParam(args);
        result = rowCountResult(sqlSession.delete(command.getName(), param));
        break;
      }
      case SELECT://查询
        if (method.returnsVoid() && method.hasResultHandler()) {
          executeWithResultHandler(sqlSession, args);
          result = null;
        } else if (method.returnsMany()) {
          result = executeForMany(sqlSession, args);
        } else if (method.returnsMap()) {
          result = executeForMap(sqlSession, args);
        } else if (method.returnsCursor()) {
          result = executeForCursor(sqlSession, args);
        } else {
          Object param = method.convertArgsToSqlCommandParam(args);
          result = sqlSession.selectOne(command.getName(), param);
          if (method.returnsOptional()
                  && (result == null || !method.getReturnType().equals(result.getClass()))) {
            result = Optional.ofNullable(result);
          }
        }
        break;
      case FLUSH://刷新
        result = sqlSession.flushStatements();
        break;
      default:
        throw new BindingException("Unknown execution method for: " + command.getName());
    }
    if (result == null && method.getReturnType().isPrimitive() && !method.returnsVoid()) {
      throw new BindingException("Mapper method '" + command.getName()
              + " attempted to return null from a method with a primitive return type (" + method.getReturnType() + ").");
    }
    return result;
  }
```

### MethodSignature（MapperMethod的静态内部类） 
```
public Object convertArgsToSqlCommandParam(Object[] args) {
      return paramNameResolver.getNamedParams(args);
    }
    
  
```

### ParamNameResolver
* 返回一个没有名称的非特殊参数。
* 使用命名规则命名多个参数
```
public Object getNamedParams(Object[] args) {
    final int paramCount = names.size();
    if (args == null || paramCount == 0) {//没有参数
      return null;
    } else if (!hasParamAnnotation && paramCount == 1) {//没有注解且只有一个参数
      return args[names.firstKey()];
    } else {
      final Map<String, Object> param = new ParamMap<>();//继承HashMap，get找不到会报异常
      int i = 0;
      for (Map.Entry<Integer, String> entry : names.entrySet()) {
      
        //names是个Map的数据结构类似0-->arg0   1-->arg1   2-->arg2
        //有注解的话结构类似0-->id   1-->name   2-->password
        //最终param以argx--->xxx值存储
        //有注解的话以id--->xxx值存储
        param.put(entry.getValue(), args[entry.getKey()]);
        // 设置通用参数名称，param1，param2，param3等（有没注解都会这么设置）
        final String genericParamName = GENERIC_NAME_PREFIX + String.valueOf(i + 1);
        // 确保不要覆盖用@Param命名的参数
        if (!names.containsValue(genericParamName)) {//如果不存在
          param.put(genericParamName, args[entry.getKey()]);//以通用名称插入值
        }
        i++;
      }
      return param;//返回
    }
  }  
```

### DefaultSqlSession
```
@Override
  public int insert(String statement, Object parameter) {
    return update(statement, parameter);
  }
  
@Override
  public int update(String statement, Object parameter) {
    try {
      dirty = true;
      MappedStatement ms = configuration.getMappedStatement(statement);//获取MappedStatement
      return executor.update(ms, wrapCollection(parameter));
    } catch (Exception e) {
      throw ExceptionFactory.wrapException("Error updating database.  Cause: " + e, e);
    } finally {
      ErrorContext.instance().reset();
    }
  }  
  
  
private Object wrapCollection(final Object object) {//包装集合
    if (object instanceof Collection) {
      StrictMap<Object> map = new StrictMap<>();
      map.put("collection", object);
      if (object instanceof List) {
        map.put("list", object);
      }
      return map;
    } else if (object != null && object.getClass().isArray()) {
      StrictMap<Object> map = new StrictMap<>();
      map.put("array", object);
      return map;
    }
    return object;
  }  
 
 @Override
 public void commit() {
    commit(false);
  }  
  
@Override
  public void commit(boolean force) {
    try {
      executor.commit(isCommitOrRollbackRequired(force));//CachingExecutor实例的commit()方法
      dirty = false;
    } catch (Exception e) {
      throw ExceptionFactory.wrapException("Error committing transaction.  Cause: " + e, e);
    } finally {
      ErrorContext.instance().reset();
    }
  }  
```

### CachingExecutor
* 缓存执行器
```
 @Override
  public int update(MappedStatement ms, Object parameterObject) throws SQLException {
    flushCacheIfRequired(ms);//清除缓存如果需要
    return delegate.update(ms, parameterObject);
  }
  
 private void flushCacheIfRequired(MappedStatement ms) {
    Cache cache = ms.getCache();
    if (cache != null && ms.isFlushCacheRequired()) {
      tcm.clear(cache);
    }
  }  
  
@Override
  public void commit(boolean required) throws SQLException {
    delegate.commit(required);//BaseExecutor
    tcm.commit();//暂时不知道干嘛用的,调用的是TransactionalCacheManager实例里的commit()
  }  
```

### TransactionalCacheManager
```
public void commit() {
    for (TransactionalCache txCache : transactionalCaches.values()) {
      txCache.commit();
    }
  }
```

### BaseExecutor
* 这是一个抽象类
```
@Override
  public int update(MappedStatement ms, Object parameter) throws SQLException {
    ErrorContext.instance().resource(ms.getResource()).activity("executing an update").object(ms.getId());
    if (closed) {
      throw new ExecutorException("Executor was closed.");
    }
    clearLocalCache();
    return doUpdate(ms, parameter);
  }

@Override
  public void clearLocalCache() {
    if (!closed) {
      localCache.clear();
      localOutputParameterCache.clear();
    }
  }  
  
@Override
  public void commit(boolean required) throws SQLException {
    if (closed) {
      throw new ExecutorException("Cannot commit, transaction is already closed");
    }
    clearLocalCache();
    flushStatements();
    if (required) {
      transaction.commit();//JdbcTransaction
    }
  }  
```

### JdbcTransaction
```
@Override
  public void commit() throws SQLException {
    if (connection != null && !connection.getAutoCommit()) {
      if (log.isDebugEnabled()) {
        log.debug("Committing JDBC Connection [" + connection + "]");
      }
      connection.commit();//PooledConnection代理类，最终调用的是ConnectionImpl的commit()
    }
  }
```

### SimpleExecutor
* 简单执行器
```
@Override
  public int doUpdate(MappedStatement ms, Object parameter) throws SQLException {
    Statement stmt = null;
    try {
      Configuration configuration = ms.getConfiguration();
      StatementHandler handler = configuration.newStatementHandler(this, ms, parameter, RowBounds.DEFAULT, null, null);
      stmt = prepareStatement(handler, ms.getStatementLog());//这里取参数值
       //Plugin对象实例，代理着RoutingStatementHandler，里面包含着PreparedStatementHandler
      //最终执行的是PreparedStatementHandler的update()方法
      return handler.update(stmt);
    } finally {
      closeStatement(stmt);
    }
  }
  
private Statement prepareStatement(StatementHandler handler, Log statementLog) throws SQLException {
    Statement stmt;
    Connection connection = getConnection(statementLog);
    stmt = handler.prepare(connection, transaction.getTimeout());//这里会执行插件
    handler.parameterize(stmt);//这里取参数值，代理对象代理的是PreparedStatementHandler的parameterize()方法
    return stmt;
  }
  
protected void closeStatement(Statement statement) {
    if (statement != null) {
      try {
        statement.close();
      } catch (SQLException e) {
        // ignore
      }
    }
  }  
  
```

### PreparedStatementHandler
* 预编译处理器
```
@Override
  public void parameterize(Statement statement) throws SQLException {
    parameterHandler.setParameters((PreparedStatement) statement);//此处是使用DefaultParameterHandler实现
  }
  
 @Override
  public int update(Statement statement) throws SQLException {
    PreparedStatement ps = (PreparedStatement) statement;
    ps.execute();//执行操作
    int rows = ps.getUpdateCount();
    Object parameterObject = boundSql.getParameterObject();
    KeyGenerator keyGenerator = mappedStatement.getKeyGenerator();
    keyGenerator.processAfter(executor, mappedStatement, ps, parameterObject);
    return rows;
  }  
```

### DefaultParameterHandler(实现了ParameterHandler接口)
```
@Override
  public void setParameters(PreparedStatement ps) {
    ErrorContext.instance().activity("setting parameters").object(mappedStatement.getParameterMap().getId());
    List<ParameterMapping> parameterMappings = boundSql.getParameterMappings();
    if (parameterMappings != null) {
      for (int i = 0; i < parameterMappings.size(); i++) {
        ParameterMapping parameterMapping = parameterMappings.get(i);
        if (parameterMapping.getMode() != ParameterMode.OUT) {
          Object value;
          String propertyName = parameterMapping.getProperty();
          if (boundSql.hasAdditionalParameter(propertyName)) { // issue #448 ask first for additional params
            value = boundSql.getAdditionalParameter(propertyName);
          } else if (parameterObject == null) {
            value = null;
          } else if (typeHandlerRegistry.hasTypeHandler(parameterObject.getClass())) {
            value = parameterObject;
          } else {
            MetaObject metaObject = configuration.newMetaObject(parameterObject);
            value = metaObject.getValue(propertyName);//这个位子获取参数值
          }
          TypeHandler typeHandler = parameterMapping.getTypeHandler();
          JdbcType jdbcType = parameterMapping.getJdbcType();
          if (value == null && jdbcType == null) {
            jdbcType = configuration.getJdbcTypeForNull();
          }
          try {
            typeHandler.setParameter(ps, i + 1, value, jdbcType);
          } catch (TypeException | SQLException e) {
            throw new TypeException("Could not set parameters for mapping: " + parameterMapping + ". Cause: " + e, e);
          }
        }
      }
    }
  }
```

### MetaObject
```
 public Object getValue(String name) {
    PropertyTokenizer prop = new PropertyTokenizer(name);//分析复杂参数名
    if (prop.hasNext()) {//属于复杂参数名
      MetaObject metaValue = metaObjectForProperty(prop.getIndexedName());
      if (metaValue == SystemMetaObject.NULL_META_OBJECT) {
        return null;
      } else {
        return metaValue.getValue(prop.getChildren());
      }
    } else {//普通参数名
      return objectWrapper.get(prop);//使用MapWrapper的实现
    }
  }
```

### MapWrapper
```
private final Map<String, Object> map;//这个map就是上面存入的参数map
 
@Override
  public Object get(PropertyTokenizer prop) {
    if (prop.getIndex() != null) {
      Object collection = resolveCollection(prop, map);
      return getCollectionValue(prop, collection);
    } else {
      return map.get(prop.getName());
    }
  }
```

### Configuration
```
 public StatementHandler newStatementHandler(Executor executor, MappedStatement mappedStatement, Object parameterObject, RowBounds rowBounds, ResultHandler resultHandler, BoundSql boundSql) {
    StatementHandler statementHandler = new RoutingStatementHandler(executor, mappedStatement, parameterObject, rowBounds, resultHandler, boundSql);
    statementHandler = (StatementHandler) interceptorChain.pluginAll(statementHandler);
    return statementHandler;
  }
```

### RoutingStatementHandler
* Configuration对象会采用newRoutingStatementHandler()来生成StatementHandler对象
* 换句话说我们真正使用的是RoutingStatementHandler对象，然后它会根据Executor的类型去创建对应具体的statementHandler对象（SimpleStatementHandler，PreparedStatementHandler和CallableStatementHandler）
* 然后利用具体statementHandler的方法完成所需要的功能。那么这个具体的statementHandler是保存在RoutingStatementHandler对象的delegate属性的
* 在MyBatis实现了statementHandler的有四个类：

1. RoutingStatementHandler，这是一个封装类，它不提供具体的实现，只是根据Executor的类型，创建不同的类型StatementHandler。

2. SimpleStatementHandler，这个类对应于JDBC的Statement对象，用于没有预编译参数的SQL的运行。

3. PreparedStatementHandler 这个用于预编译参数SQL的运行。

4. CallableStatementHandler 它将实存储过程的调度。


### RoutingStatementHandler
```
public RoutingStatementHandler(Executor executor, MappedStatement ms, Object parameter, RowBounds rowBounds, ResultHandler resultHandler, BoundSql boundSql) {

    switch (ms.getStatementType()) {
      case STATEMENT:
        delegate = new SimpleStatementHandler(executor, ms, parameter, rowBounds, resultHandler, boundSql);
        break;
      case PREPARED:
        delegate = new PreparedStatementHandler(executor, ms, parameter, rowBounds, resultHandler, boundSql);
        break;
      case CALLABLE:
        delegate = new CallableStatementHandler(executor, ms, parameter, rowBounds, resultHandler, boundSql);
        break;
      default:
        throw new ExecutorException("Unknown statement type: " + ms.getStatementType());
    }

  }
```

### InterceptorChain
* pluginAll方法在创建上述4个接口对象时调用，其含义为给这些接口对象注册拦截器功能，注意是注册，而不是执行拦截
```
public Object pluginAll(Object target) {//逐一注册插件，传入的是一个StatementHandler
    for (Interceptor interceptor : interceptors) {
      target = interceptor.plugin(target);
    }
    return target;
  }
```



## update

```
mapper.updateUserById("e33a8e64-75c1-4929-908c-0af8ef4ac46b", "早11上好");
sqlSession.commit();
```
* MapperMethod类execute()走UPDATE
* DefaultSqlSession走update()
* 流程一样

## delete

```
mapper.deleteUserById("e33a8e64-75c1-4929-908c-0af8ef4ac46b");
sqlSession.commit();
```

* MapperMethod类execute()走DELETE
* DefaultSqlSession走delete()
```
 @Override
  public int delete(String statement, Object parameter) {
    return update(statement, parameter);
  }
  
@Override
  public int update(String statement, Object parameter) {
    try {
      dirty = true;
      MappedStatement ms = configuration.getMappedStatement(statement);
      return executor.update(ms, wrapCollection(parameter));
    } catch (Exception e) {
      throw ExceptionFactory.wrapException("Error updating database.  Cause: " + e, e);
    } finally {
      ErrorContext.instance().reset();
    }
  }  
```
* CachingExecutor类走update()
```
 @Override
  public int update(MappedStatement ms, Object parameterObject) throws SQLException {
    flushCacheIfRequired(ms);
    return delegate.update(ms, parameterObject);
  }
```
* SimpleExecutor走update(),update调的是抽象类BaseExecutor的方法，然后再走doUpdate()
```
 @Override
  public int update(MappedStatement ms, Object parameter) throws SQLException {
    ErrorContext.instance().resource(ms.getResource()).activity("executing an update").object(ms.getId());
    if (closed) {
      throw new ExecutorException("Executor was closed.");
    }
    clearLocalCache();
    return doUpdate(ms, parameter);
  }
  
@Override
  public int doUpdate(MappedStatement ms, Object parameter) throws SQLException {
    Statement stmt = null;
    try {
      Configuration configuration = ms.getConfiguration();
      StatementHandler handler = configuration.newStatementHandler(this, ms, parameter, RowBounds.DEFAULT, null, null);
      stmt = prepareStatement(handler, ms.getStatementLog());//获取预编译对象,插件在这里会执行
      //Plugin对象实例，代理着RoutingStatementHandler，里面包含着PreparedStatementHandler
      //最终执行的是PreparedStatementHandler的update()方法
      return handler.update(stmt);
    } finally {
      closeStatement(stmt);
    }
  }  
  
private Statement prepareStatement(StatementHandler handler, Log statementLog) throws SQLException {
    Statement stmt;
    Connection connection = getConnection(statementLog);
    stmt = handler.prepare(connection, transaction.getTimeout());//Plugin对象实例，插件在这里会执行
    handler.parameterize(stmt);
    return stmt;
  }
```


## select
```
 List<MyUser> myUsers = mapper.selectUserByPassWord("123");
```

### MapperProxy代理类运行MapperMethod的execute(),走SELECT
```
public Object execute(SqlSession sqlSession, Object[] args) {
    Object result;
    switch (command.getType()) {
      case INSERT: {
        Object param = method.convertArgsToSqlCommandParam(args);
        result = rowCountResult(sqlSession.insert(command.getName(), param));
        break;
      }
      case UPDATE: {
        Object param = method.convertArgsToSqlCommandParam(args);
        result = rowCountResult(sqlSession.update(command.getName(), param));
        break;
      }
      case DELETE: {
        Object param = method.convertArgsToSqlCommandParam(args);
        result = rowCountResult(sqlSession.delete(command.getName(), param));
        break;
      }
      case SELECT://做查询
        if (method.returnsVoid() && method.hasResultHandler()) {
          executeWithResultHandler(sqlSession, args);
          result = null;
        } else if (method.returnsMany()) {//返回集合
          result = executeForMany(sqlSession, args);
        } else if (method.returnsMap()) {//返回map
          result = executeForMap(sqlSession, args);
        } else if (method.returnsCursor()) {//返回cursor
          result = executeForCursor(sqlSession, args);
        } else {//返回只有一个,调用的是sqlSession.selectOne，实质也是sqlSession.selectList，这是多一步判断结果集如果不止一个，那么抛出异常
          Object param = method.convertArgsToSqlCommandParam(args);
          result = sqlSession.selectOne(command.getName(), param);
          if (method.returnsOptional()
                  && (result == null || !method.getReturnType().equals(result.getClass()))) {
            result = Optional.ofNullable(result);
          }
        }
        break;
      case FLUSH:
        result = sqlSession.flushStatements();
        break;
      default:
        throw new BindingException("Unknown execution method for: " + command.getName());
    }
    if (result == null && method.getReturnType().isPrimitive() && !method.returnsVoid()) {
      throw new BindingException("Mapper method '" + command.getName()
              + " attempted to return null from a method with a primitive return type (" + method.getReturnType() + ").");
    }
    return result;
  }
  
  
private <E> Object executeForMany(SqlSession sqlSession, Object[] args) {//返回集合
    List<E> result;
    Object param = method.convertArgsToSqlCommandParam(args);
    if (method.hasRowBounds()) {
      RowBounds rowBounds = method.extractRowBounds(args);
      result = sqlSession.selectList(command.getName(), param, rowBounds);
    } else {
      result = sqlSession.selectList(command.getName(), param);
    }
    // issue #510 Collections & arrays support
    if (!method.getReturnType().isAssignableFrom(result.getClass())) {
      if (method.getReturnType().isArray()) {
        return convertToArray(result);
      } else {
        return convertToDeclaredCollection(sqlSession.getConfiguration(), result);
      }
    }
    return result;
  }  
```

### DefaultSqlSession运行selectList()
```
 @Override
  public <E> List<E> selectList(String statement, Object parameter) {
    return this.selectList(statement, parameter, RowBounds.DEFAULT);
  }
  
@Override
  public <E> List<E> selectList(String statement, Object parameter, RowBounds rowBounds) {
    try {
      MappedStatement ms = configuration.getMappedStatement(statement);//获取MappedStatement
      return executor.query(ms, wrapCollection(parameter), rowBounds, Executor.NO_RESULT_HANDLER);
    } catch (Exception e) {
      throw ExceptionFactory.wrapException("Error querying database.  Cause: " + e, e);
    } finally {
      ErrorContext.instance().reset();
    }
  }
```

### 调用CachingExecutor的query()，
```
@Override
  public <E> List<E> query(MappedStatement ms, Object parameterObject, RowBounds rowBounds, ResultHandler resultHandler) throws SQLException {
    BoundSql boundSql = ms.getBoundSql(parameterObject);
    CacheKey key = createCacheKey(ms, parameterObject, rowBounds, boundSql);
    return query(ms, parameterObject, rowBounds, resultHandler, key, boundSql);
  }
  
@Override
  public CacheKey createCacheKey(MappedStatement ms, Object parameterObject, RowBounds rowBounds, BoundSql boundSql) {
    return delegate.createCacheKey(ms, parameterObject, rowBounds, boundSql);//BaseExecutor的createCacheKey()
  }  
  
 @Override
  public <E> List<E> query(MappedStatement ms, Object parameterObject, RowBounds rowBounds, ResultHandler resultHandler, CacheKey key, BoundSql boundSql)
      throws SQLException {
    Cache cache = ms.getCache();
    if (cache != null) {
      flushCacheIfRequired(ms);
      if (ms.isUseCache() && resultHandler == null) {
        ensureNoOutParams(ms, boundSql);
        @SuppressWarnings("unchecked")
        List<E> list = (List<E>) tcm.getObject(cache, key);
        if (list == null) {
          list = delegate.query(ms, parameterObject, rowBounds, resultHandler, key, boundSql);
          tcm.putObject(cache, key, list); // issue #578 and #116
        }
        return list;
      }
    }
    return delegate.query(ms, parameterObject, rowBounds, resultHandler, key, boundSql);//SimpleExecutor的query()，调用的是抽象类BaseExecutor的方法
  }  
```

### MappedStatement的getBoundSql()
```
public BoundSql getBoundSql(Object parameterObject) {
    BoundSql boundSql = sqlSource.getBoundSql(parameterObject);
    List<ParameterMapping> parameterMappings = boundSql.getParameterMappings();
    if (parameterMappings == null || parameterMappings.isEmpty()) {
      boundSql = new BoundSql(configuration, boundSql.getSql(), parameterMap.getParameterMappings(), parameterObject);
    }

    // 检查参数映射中的嵌套结果映射（issue ＃30）
    for (ParameterMapping pm : boundSql.getParameterMappings()) {
      String rmId = pm.getResultMapId();
      if (rmId != null) {
        ResultMap rm = configuration.getResultMap(rmId);
        if (rm != null) {
          hasNestedResultMaps |= rm.hasNestedResultMaps();
        }
      }
    }

    return boundSql;
  }
```

### RawSqlSource的getBoundSql()
```
 @Override
  public BoundSql getBoundSql(Object parameterObject) {
    return sqlSource.getBoundSql(parameterObject);
  }
```

### StaticSqlSource的getBoundSql()
```
 @Override
  public BoundSql getBoundSql(Object parameterObject) {
    return new BoundSql(configuration, sql, parameterMappings, parameterObject);
  }
```

### BoundSql类
```
public class BoundSql {

  private final String sql;
  private final List<ParameterMapping> parameterMappings;
  private final Object parameterObject;
  private final Map<String, Object> additionalParameters;
  private final MetaObject metaParameters;

  public BoundSql(Configuration configuration, String sql, List<ParameterMapping> parameterMappings, Object parameterObject) {
    this.sql = sql;
    this.parameterMappings = parameterMappings;
    this.parameterObject = parameterObject;
    this.additionalParameters = new HashMap<>();
    this.metaParameters = configuration.newMetaObject(additionalParameters);
  }
```


### BaseExecutor的createCacheKey()（这个不是很理解写法）
```
@Override
  public CacheKey createCacheKey(MappedStatement ms, Object parameterObject, RowBounds rowBounds, BoundSql boundSql) {
    if (closed) {
      throw new ExecutorException("Executor was closed.");
    }
    CacheKey cacheKey = new CacheKey();
    cacheKey.update(ms.getId());
    cacheKey.update(rowBounds.getOffset());
    cacheKey.update(rowBounds.getLimit());
    cacheKey.update(boundSql.getSql());
    List<ParameterMapping> parameterMappings = boundSql.getParameterMappings();
    TypeHandlerRegistry typeHandlerRegistry = ms.getConfiguration().getTypeHandlerRegistry();
    // mimic DefaultParameterHandler logic
    for (ParameterMapping parameterMapping : parameterMappings) {
      if (parameterMapping.getMode() != ParameterMode.OUT) {
        Object value;
        String propertyName = parameterMapping.getProperty();
        if (boundSql.hasAdditionalParameter(propertyName)) {
          value = boundSql.getAdditionalParameter(propertyName);
        } else if (parameterObject == null) {
          value = null;
        } else if (typeHandlerRegistry.hasTypeHandler(parameterObject.getClass())) {
          value = parameterObject;
        } else {
          MetaObject metaObject = configuration.newMetaObject(parameterObject);
          value = metaObject.getValue(propertyName);
        }
        cacheKey.update(value);
      }
    }
    if (configuration.getEnvironment() != null) {
      // issue #176
      cacheKey.update(configuration.getEnvironment().getId());
    }
    return cacheKey;
  }
  
@SuppressWarnings("unchecked")
  @Override
  public <E> List<E> query(MappedStatement ms, Object parameter, RowBounds rowBounds, ResultHandler resultHandler, CacheKey key, BoundSql boundSql) throws SQLException {
    ErrorContext.instance().resource(ms.getResource()).activity("executing a query").object(ms.getId());
    if (closed) {
      throw new ExecutorException("Executor was closed.");
    }
    if (queryStack == 0 && ms.isFlushCacheRequired()) {
      clearLocalCache();
    }
    List<E> list;
    try {
      queryStack++;
      list = resultHandler == null ? (List<E>) localCache.getObject(key) : null;
      if (list != null) {
        handleLocallyCachedOutputParameters(ms, key, parameter, boundSql);
      } else {
        list = queryFromDatabase(ms, parameter, rowBounds, resultHandler, key, boundSql);
      }
    } finally {
      queryStack--;
    }
    if (queryStack == 0) {
      for (DeferredLoad deferredLoad : deferredLoads) {
        deferredLoad.load();
      }
      // issue #601
      deferredLoads.clear();
      if (configuration.getLocalCacheScope() == LocalCacheScope.STATEMENT) {
        // issue #482
        clearLocalCache();
      }
    }
    return list;
  }
  
  
private <E> List<E> queryFromDatabase(MappedStatement ms, Object parameter, RowBounds rowBounds, ResultHandler resultHandler, CacheKey key, BoundSql boundSql) throws SQLException {
    List<E> list;
    localCache.putObject(key, EXECUTION_PLACEHOLDER);
    try {
      list = doQuery(ms, parameter, rowBounds, resultHandler, boundSql);
    } finally {
      localCache.removeObject(key);
    }
    localCache.putObject(key, list);//添加缓存
    if (ms.getStatementType() == StatementType.CALLABLE) {
      localOutputParameterCache.putObject(key, parameter);
    }
    return list;
  }
```

### SimpleExecutor
```
@Override
  public <E> List<E> doQuery(MappedStatement ms, Object parameter, RowBounds rowBounds, ResultHandler resultHandler, BoundSql boundSql) throws SQLException {
    Statement stmt = null;
    try {
      Configuration configuration = ms.getConfiguration();
      StatementHandler handler = configuration.newStatementHandler(wrapper, ms, parameter, rowBounds, resultHandler, boundSql);//创建处理器
      stmt = prepareStatement(handler, ms.getStatementLog());//获取预编译对象
      return handler.query(stmt, resultHandler);//PreparedStatementHandler的query()
    } finally {
      closeStatement(stmt);
    }
  }
  
  
  private Statement prepareStatement(StatementHandler handler, Log statementLog) throws SQLException {
    Statement stmt;
    Connection connection = getConnection(statementLog);//获取链接
    stmt = handler.prepare(connection, transaction.getTimeout());//执行插件
    handler.parameterize(stmt);//设置参数值
    return stmt;
  }
```

### PreparedStatementHandler的query()
```
@Override
  public <E> List<E> query(Statement statement, ResultHandler resultHandler) throws SQLException {
    PreparedStatement ps = (PreparedStatement) statement;
    ps.execute();
    return resultSetHandler.handleResultSets(ps);//DefaultResultSetHandler
  }
```

### DefaultResultSetHandler的handleResultSets()
```
 @Override
  public List<Object> handleResultSets(Statement stmt) throws SQLException {
    ErrorContext.instance().activity("handling results").object(mappedStatement.getId());

    final List<Object> multipleResults = new ArrayList<>();

    int resultSetCount = 0;
    ResultSetWrapper rsw = getFirstResultSet(stmt);//包装器

    List<ResultMap> resultMaps = mappedStatement.getResultMaps();
    int resultMapCount = resultMaps.size();
    validateResultMapsCount(rsw, resultMapCount);//验证返回数量
    while (rsw != null && resultMapCount > resultSetCount) {
      ResultMap resultMap = resultMaps.get(resultSetCount);
      handleResultSet(rsw, resultMap, multipleResults, null);//处理结果集
      rsw = getNextResultSet(stmt);
      cleanUpAfterHandlingResultSet();
      resultSetCount++;
    }

    String[] resultSets = mappedStatement.getResultSets();
    if (resultSets != null) {
      while (rsw != null && resultSetCount < resultSets.length) {
        ResultMapping parentMapping = nextResultMaps.get(resultSets[resultSetCount]);
        if (parentMapping != null) {
          String nestedResultMapId = parentMapping.getNestedResultMapId();
          ResultMap resultMap = configuration.getResultMap(nestedResultMapId);
          handleResultSet(rsw, resultMap, null, parentMapping);
        }
        rsw = getNextResultSet(stmt);
        cleanUpAfterHandlingResultSet();
        resultSetCount++;
      }
    }

    return collapseSingleResultList(multipleResults);//返回结果集
  }
  
  
private void handleResultSet(ResultSetWrapper rsw, ResultMap resultMap, List<Object> multipleResults, ResultMapping parentMapping) throws SQLException {//处理结果集
    try {
      if (parentMapping != null) {
        handleRowValues(rsw, resultMap, null, RowBounds.DEFAULT, parentMapping);
      } else {
        if (resultHandler == null) {
          DefaultResultHandler defaultResultHandler = new DefaultResultHandler(objectFactory);
          handleRowValues(rsw, resultMap, defaultResultHandler, rowBounds, null);//处理行值
          multipleResults.add(defaultResultHandler.getResultList());
        } else {
          handleRowValues(rsw, resultMap, resultHandler, rowBounds, null);
        }
      }
    } finally {
      // issue #228 (close resultsets)
      closeResultSet(rsw.getResultSet());
    }
  }
  
  
 public void handleRowValues(ResultSetWrapper rsw, ResultMap resultMap, ResultHandler<?> resultHandler, RowBounds rowBounds, ResultMapping parentMapping) throws SQLException {//处理行值
    if (resultMap.hasNestedResultMaps()) {//判断有嵌套结果映射
      ensureNoRowBounds();
      checkResultHandler();
      handleRowValuesForNestedResultMap(rsw, resultMap, resultHandler, rowBounds, parentMapping);
    } else {
    //处理简单结果映射的行值
      handleRowValuesForSimpleResultMap(rsw, resultMap, resultHandler, rowBounds, parentMapping);
    }
  }
  
  
private void handleRowValuesForSimpleResultMap(ResultSetWrapper rsw, ResultMap resultMap, ResultHandler<?> resultHandler, RowBounds rowBounds, ResultMapping parentMapping)
      throws SQLException {//处理简单结果映射的行值
    DefaultResultContext<Object> resultContext = new DefaultResultContext<>();
    ResultSet resultSet = rsw.getResultSet();
    skipRows(resultSet, rowBounds);
    while (shouldProcessMoreRows(resultContext, rowBounds) && !resultSet.isClosed() && resultSet.next()) {//循环装载集合数据
      ResultMap discriminatedResultMap = resolveDiscriminatedResultMap(resultSet, resultMap, null);
      Object rowValue = getRowValue(rsw, discriminatedResultMap, null);//获取行值
      storeObject(resultHandler, resultContext, rowValue, parentMapping, resultSet);
    }
  }
  
  
private Object getRowValue(ResultSetWrapper rsw, ResultMap resultMap, String columnPrefix) throws SQLException {//获取行值
    final ResultLoaderMap lazyLoader = new ResultLoaderMap();
    Object rowValue = createResultObject(rsw, resultMap, lazyLoader, columnPrefix);//创建空对象
    if (rowValue != null && !hasTypeHandlerForResultObject(rsw, resultMap.getType())) {
      final MetaObject metaObject = configuration.newMetaObject(rowValue);
      boolean foundValues = this.useConstructorMappings;
      if (shouldApplyAutomaticMappings(resultMap, false)) {
        foundValues = applyAutomaticMappings(rsw, resultMap, metaObject, columnPrefix) || foundValues;//装载属性,应用自动映射
      }
      foundValues = applyPropertyMappings(rsw, resultMap, metaObject, lazyLoader, columnPrefix) || foundValues;
      foundValues = lazyLoader.size() > 0 || foundValues;
      rowValue = foundValues || configuration.isReturnInstanceForEmptyRow() ? rowValue : null;
    }
    return rowValue;
  }  

private boolean applyAutomaticMappings(ResultSetWrapper rsw, ResultMap resultMap, MetaObject metaObject, String columnPrefix) throws SQLException {//应用自动映射
    List<UnMappedColumnAutoMapping> autoMapping = createAutomaticMappings(rsw, resultMap, metaObject, columnPrefix);
    boolean foundValues = false;
    if (!autoMapping.isEmpty()) {
      for (UnMappedColumnAutoMapping mapping : autoMapping) {
        final Object value = mapping.typeHandler.getResult(rsw.getResultSet(), mapping.column);
        if (value != null) {
          foundValues = true;
        }
        if (value != null || (configuration.isCallSettersOnNulls() && !mapping.primitive)) {
          // gcode issue #377, call setter on nulls (value is not 'found')
          metaObject.setValue(mapping.property, value);
        }
      }
    }
    return foundValues;
  }
```



