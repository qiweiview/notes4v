# Guice教程

## 依赖
```
       <dependency>
            <groupId>com.google.inject</groupId>
            <artifactId>guice</artifactId>
            <version>4.1.0</version>
        </dependency>
```


## 实例注入
* [通过@Provides注解注册类](#通过@Provides注解注册类)
* [通过静态方法注册类](#通过静态方法注册类)
* [通过@Singleton注册类](#通过@Singleton注册类)


### 范例涉及类
* 接口
```
public interface BaseWorker {
}
```
* 实现类1
```
public class WorkerImpl  extends AbstractModule implements BaseWorker {

    @Override
    protected void configure() {
        bind(BaseWorker.class).to(WorkerImpl.class);
    }

    @Override
    public String toString() {
        return "WorkerImpl";
    }

}
```
* 实现类2
```
public class WorkerImpl2  implements BaseWorker {


    @Override
    public String toString() {
        return "WorkerImpl2";
    }

}
```
### 通过@Provides注解注册类
* 类提供，并打上标识
```
public class BeanConfiguration extends AbstractModule {

    @Provides
    @BeanFilter(name = "worker")
    static BaseWorker getBaseWorker() {
        return new WorkerImpl();
    }

    @Provides
    @BeanFilter(name = "worker2")
    static BaseWorker getBaseWorker2() {
        return new WorkerImpl2();
    }
    
    @Provides
    @BeanFilter(name = "name")
    static String getName() {
        return "kaka";
    }
}
```
* 构造方法标识
```
public class DemoModuleSon extends AbstractModule {

    @Inject
    @BeanFilter(name = "name")
    private   String name ;

    private BaseWorker baseWorker;

    @Inject
    public DemoModuleSon(@BeanFilter(name = "worker2") BaseWorker baseWorker) {
        this.baseWorker = baseWorker;
    }
}
```
* 调用
```
public static void main(String[] args) {
        Injector injector = Guice.createInjector(new BeanConfiguration());
        DemoModuleSon instance = injector.getInstance(DemoModuleSon.class);
        System.out.println(instance);
    }
```

### 通过静态方法注册类
* 注入接口时候要继承AbstractModule类重写configure()方法,执行绑定
* 注意使用@Singleton注解注释类，不会触发configure()
```
 @Override
    protected void configure() {
        bind(BaseWorker.class).to(WorkerImpl.class);
    }
```
* 调用
```
public class GuiceTest {



    public static void main(String[] args) {
    //注册类
        Injector injector = Guice.createInjector(new BeanConfiguration(),new WorkerImpl());
        BaseWorker instance = injector.getInstance(BaseWorker.class);
        System.out.println(instance);


    }
}
```


### 通过@Singleton注册类
* 注册
```
@Singleton
public class AgeValue {
    private int value=3;

    @Override
    public String toString() {
        return value+"";
    }
}
```
* 注入
```
    @Inject
    private AgeValue ageValue;
```

