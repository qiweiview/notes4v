# Guice教程

## 依赖
```
       <dependency>
            <groupId>com.google.inject</groupId>
            <artifactId>guice</artifactId>
            <version>4.1.0</version>
        </dependency>
```

## 理解Guice
* 思路：类申明自己需要什么数据,Guice提供对应的数据,即受管理的类是一种申明模型而非命令模型
* ***You don't pull things out of a map, you declare that you need them***
```
# This is the essence of dependency injection.
# If you need something, you don't go out and get it from somewhere, or even ask a class to return you something. 
# Instead, you simply declare that you can't do your work without it, and rely on someone else to give you what you need.
```
* 把Guice看作一个map，通过Key来判断一个依赖是否能够提供
* 大多数应用程序不直接创建Key，而是使用Modules配置从Key到Provider的映射
```
Map<Key<?>, Provider<?>>
```

## 对象需求申明
* @Inject注解,申明的域在method,constructor,和field
```
@Target({METHOD, CONSTRUCTOR, FIELD})
@Retention(RUNTIME)
@Documented
public @interface Inject {

```

## 对象注册提供
* @Provides注释方法
* 实现Provider接口
* createInjector方法内初始化

## 对象绑定
### 链接绑定
```
bind(DatabaseTransactionLog.class).to(MySqlDatabaseTransactionLog.class);
```
### 注解绑定（适合同一类型多绑定）

* 没有显示编码的类不会被扫注解，例如A中inject了B，B有注解，但是不会被扫描

```
@Qualifier
@Retention(RUNTIME)
public @interface ValueProviders {

}
```

```
  @Inject
  public RealBillingService(@ValueProviders BaseAction name) {
    //todo action 2
  }
```

```
  @Inject
  public RealBillingService(BaseAction name) {
    //todo action 1
  }
```


```
bind(BaseAction.class).to(Action1.class);
bind(BaseAction.class).annotatedWith(ValueProviders.class).to(Action2.class);
```

### 常量绑定
* @Named注解绑定值
```
bind(Integer.class).annotatedWith(Names.named("time_out")).toInstance(333);
bind(String.class).annotatedWith(Names.named("secret")).toInstance("aavvcc_112");
```
* 常量绑定，避免使用bindConstant创建复杂对象，会使启动变慢
```
bindConstant().annotatedWith(ValueProviders.class).to(777d);
```

### @Provides 注解方法 绑定
* 方法需要申明在一个module里
* 和注释一起使用则会使用：注释+类型作为key
```
//------ 提供
public class BillingModule extends AbstractModule {

       @Provides
        @Named("two")
        public FunctionI getFunctionTwo(){
            return new FunctionTwo();
        }


//------- 使用        
    @Inject
    @Named("two")
    private FunctionI functionI;
```

### Provider 接口绑定
* 接口
```
public interface Provider<T> {
  T get();
}
```

* 使用一
```
bind(TransactionLog.class).toProvider(DatabaseTransactionLogProvider.class);
```


### 构造函数绑定
* 不同的构造函数
* 有局限，不能使用AOP
* 构造函数不需要@Inject批注
* 每个toConstructor（）绑定的作用域都是独立的。如果创建针对同一构造函数的多个单例绑定，则每个绑定都会产生自己的实例
```
public class Bean2 {
    private String value1;
    private Integer value2;
    
    public Bean2(String value1) {
        System.out.println("init value1");
        this.value1 = value1;
    }

    public Bean2(Integer value2) {
        System.out.println("init value2");
        this.value2 = value2;
    }
}
```
* 构造函数绑定
```
bind(Integer.class).toInstance(555);
bind(Bean2.class).toConstructor(Bean2.class.getConstructor(Integer.class));
```

### 内置对象
```
Logger 
```

### 接口中使用注解指定实现类

```
@ImplementedBy(value =Action1.class )
public interface BaseAction {
    public void sayHi();
}

//上面的申明等效于，bind()优先级更高
bind(BaseAction.class).to(Action1.class);
```


### 接口中使用注解指定Providers
* 使用@ProvidedBy注解
```
@ProvidedBy(value =ActionProvider.class )
public interface BaseAction {
    public void sayHi();
}
```
* ActionProvider类
```
public class ActionProvider implements Provider<BaseAction> {
    @Override
    public BaseAction get() {
        return new Action1();
    }
}

//等价于 ，bind()优先级更高
bind(BaseAction.class).toProvider(ActionProvider.class);
```

### 禁用隐式绑定绑定
```
 binder().requireExplicitBindings();
```

###  多重绑定
* Multibinder
* 不会影响原有的绑定
* 多个集合会被合并


```
 public class ModuleSupport2 extends AbstractModule{
            @Override
        protected void configure() {

 Multibinder<BaseAction> baseActionMultibinder = Multibinder.newSetBinder(binder(), BaseAction.class);
 
//不受影响 
bind(BaseAction.class).to(Action3.class);

baseActionMultibinder .addBinding().to(Action1.class);
baseActionMultibinder .addBinding().to(Action2.class);
}
```
* 使用```Set<T>```获取
```
 @Inject
 public BaseAction baseAction;//不受影响
 
 @Inject
 public Set<BaseAction> baseActionSet;

```

* MapBinder
```
        MapBinder<String, BaseAction> stringBaseActionMapBinder = MapBinder.newMapBinder(binder(), String.class, BaseAction.class);

        stringBaseActionMapBinder.addBinding("action2").to(Action2.class);
        stringBaseActionMapBinder.addBinding("action3").to(Action3.class);
```
* 使用```Map<K,V>```获取
```
 @Inject
 public BaseAction baseAction;//不受影响
 
 @Inject
 public Map<String,BaseAction> baseActionMap;

```
* @ProvidesIntoSet
```
    @ProvidesIntoSet
    public BaseAction getAction2(){
        return new Action2();
    }
    @ProvidesIntoSet
    public BaseAction getAction3(){
        return new Action3();
    }

```
* @ProvidesIntoMap
```
    @ProvidesIntoMap
    @StringMapKey("Action2")
    public BaseAction getAction2(){
        return new Action2();
    }
    @ProvidesIntoMap
    @StringMapKey("Action3")
    public BaseAction getAction3(){
        return new Action3();
    }

```

### 限制绑定
* 则modules必须由@PermitAno注解注释
```
@RestrictedBindingSource(explanation = "need be ano", permits = {PermitAno.class})
@Qualifier
@Retention(RUNTIME)
public @interface ValueProviders {

}
```
```
    @Inject
    @ValueProviders
    public int num;

    @Provides
    @ValueProviders
    public int getIntValue(){
        return 777;
    }
```

## AOP
* 通过字节码生成支持的
```
AppMain$$EnhancerByGuice$$16159
```
* 注解
```
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface DbManage {
}
```
* 拦截器
```
public class DataSourceChange implements MethodInterceptor {
    @Override
    public Object invoke(MethodInvocation methodInvocation) throws Throwable {
        System.out.println(methodInvocation.getMethod().getName()+" invoke");
        return methodInvocation.proceed();
    }
}
```
* 配置
```
bindInterceptor(Matchers.any(), Matchers.annotatedWith(DbManage.class), new DataSourceChange());
```
* 使用
```
    @DbManage
    public void sayHi2(){

    }
```



## 对象的生命周期
* @Singleton
```
@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RUNTIME)
@ScopeAnnotation
public @interface Singleton {}
```

* 标注后对象将会是单例
```
       @Singleton
       public class FunctionOne implements FunctionI{



       //始终获取到的是同一对象
       while (true){
           FunctionI instance = injector.getInstance(FunctionI.class);
           instance.sayHi();
       }
```


* 等同于
```
binder.bind(FunctionI.class).to(FunctionOne.class).in(Singleton.class);
binder.bind(FunctionI.class).to(FunctionOne.class).in(Scopes.SINGLETON);
```
