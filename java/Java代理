## 动态代理

### 公共接口
```
public interface FlyInterface {
    void fly();

}
```

### 实现类
```
public class MyFly implements FlyInterface {
    @Override
    public void fly() {
        System.out.println("fly");
    }

}
```

### 委托代理类
```
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;

public class MyInvocationHandler implements InvocationHandler {

    //obj为委托类对象;
    private Object obj;

    public MyInvocationHandler(Object obj) {
        this.obj = obj;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        System.out.println("before");
        Object result = method.invoke(obj, args);
        System.out.println("after");
        return result;
    }
}
```

### 调用示例
```
        MyInvocationHandler inter = new MyInvocationHandler(new MyFly());//创建中介类实例
        Class[] classes = {FlyInterface.class, Comparable.class};//代理类实现的接口     
        FlyInterface sell = (FlyInterface) Proxy.newProxyInstance(FlyInterface.class.getClassLoader(), classes, inter);
        sell.fly();
 
```


## cglib库实现代理

### 依赖引入
```
 <!-- https://mvnrepository.com/artifact/cglib/cglib -->
        <dependency>
            <groupId>cglib</groupId>
            <artifactId>cglib</artifactId>
            <version>3.2.12</version>
        </dependency>
```

### 被代理类
```
public class MikTea {
    public void sell(){
        System.out.println("i sell a milkTea");
    }
}
```



### 回调处理器
```
import net.sf.cglib.proxy.MethodInterceptor;
import net.sf.cglib.proxy.MethodProxy;

import java.lang.reflect.Method;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Arrays;

public class CgMethodInterceptor implements MethodInterceptor {
    @Override
    public Object intercept(Object o, Method method, Object[] objects, MethodProxy methodProxy) throws Throwable {
        LocalDateTime now = LocalDateTime.now();
        System.out.println("before");
        Object o1 = methodProxy.invokeSuper(o, objects);
        System.out.println("end");
        LocalDateTime now2 = LocalDateTime.now();
        long l = Duration.between(now, now2).toMillis();
        System.out.println("耗时"+l+"毫秒");
        return o1;
    }
}
```



### 调用示例
```
  Enhancer enhancer = new Enhancer();
        enhancer.setSuperclass(MikTea.class);
        enhancer.setCallback(new CgMethodInterceptor());
        MikTea proxy = (MikTea) enhancer.create();
        proxy.sell();
```
