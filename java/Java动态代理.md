## Java动态代理

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


### 源码解析

* 设置debug模式输出代理类
```
System.getProperties().put("jdk.proxy.ProxyGenerator.saveGeneratedFiles", "true");
```

* newProxyInstance
```
public static Object newProxyInstance(ClassLoader loader,
                                          Class<?>[] interfaces,
                                          InvocationHandler h) {
        Objects.requireNonNull(h);

        final Class<?> caller = System.getSecurityManager() == null
                                    ? null
                                    : Reflection.getCallerClass();

        /*
         * Look up or generate the designated proxy class and its constructor.
         */
        Constructor<?> cons = getProxyConstructor(caller, loader, interfaces);

        return newProxyInstance(caller, cons, h);
    }
```
* getProxyConstructor
```
private static Constructor<?> getProxyConstructor(Class<?> caller,
                                                      ClassLoader loader,
                                                      Class<?>... interfaces)
    {
        // optimization for single interface
        if (interfaces.length == 1) {
            Class<?> intf = interfaces[0];
            if (caller != null) {
                checkProxyAccess(caller, loader, intf);
            }
            return proxyCache.sub(intf).computeIfAbsent(
                loader,
                (ld, clv) -> new ProxyBuilder(ld, clv.key()).build()
            );
        } else {
            // interfaces cloned
            final Class<?>[] intfsArray = interfaces.clone();
            if (caller != null) {
                checkProxyAccess(caller, loader, intfsArray);
            }
            final List<Class<?>> intfs = Arrays.asList(intfsArray);
            return proxyCache.sub(intfs).computeIfAbsent(
                loader,
                (ld, clv) -> new ProxyBuilder(ld, clv.key()).build()
            );
        }
    }
```
* build
```
 Constructor<?> build() {
            Class<?> proxyClass = defineProxyClass(module, interfaces);
            final Constructor<?> cons;
            try {
                cons = proxyClass.getConstructor(constructorParams);
            } catch (NoSuchMethodException e) {
                throw new InternalError(e.toString(), e);
            }
            AccessController.doPrivileged(new PrivilegedAction<Void>() {
                public Void run() {
                    cons.setAccessible(true);
                    return null;
                }
            });
            return cons;
        }
```
* defineProxyClass
```
private static Class<?> defineProxyClass(Module m, List<Class<?>> interfaces) {
            String proxyPkg = null;     // package to define proxy class in
            int accessFlags = Modifier.PUBLIC | Modifier.FINAL;

            /*
             * Record the package of a non-public proxy interface so that the
             * proxy class will be defined in the same package.  Verify that
             * all non-public proxy interfaces are in the same package.
             */
            for (Class<?> intf : interfaces) {
                int flags = intf.getModifiers();
                if (!Modifier.isPublic(flags)) {
                    accessFlags = Modifier.FINAL;  // non-public, final
                    String pkg = intf.getPackageName();
                    if (proxyPkg == null) {
                        proxyPkg = pkg;
                    } else if (!pkg.equals(proxyPkg)) {
                        throw new IllegalArgumentException(
                                "non-public interfaces from different packages");
                    }
                }
            }

            if (proxyPkg == null) {
                // all proxy interfaces are public
                proxyPkg = m.isNamed() ? PROXY_PACKAGE_PREFIX + "." + m.getName()
                                       : PROXY_PACKAGE_PREFIX;
            } else if (proxyPkg.isEmpty() && m.isNamed()) {
                throw new IllegalArgumentException(
                        "Unnamed package cannot be added to " + m);
            }

            if (m.isNamed()) {
                if (!m.getDescriptor().packages().contains(proxyPkg)) {
                    throw new InternalError(proxyPkg + " not exist in " + m.getName());
                }
            }

            /*
             * Choose a name for the proxy class to generate.
             */
            long num = nextUniqueNumber.getAndIncrement();
            String proxyName = proxyPkg.isEmpty()
                                    ? proxyClassNamePrefix + num
                                    : proxyPkg + "." + proxyClassNamePrefix + num;

            ClassLoader loader = getLoader(m);
            trace(proxyName, m, loader, interfaces);

            /*
             * Generate the specified proxy class.
             */
            byte[] proxyClassFile = ProxyGenerator.generateProxyClass(
                    proxyName, interfaces.toArray(EMPTY_CLASS_ARRAY), accessFlags);
            try {
                Class<?> pc = JLA.defineClass(loader, proxyName, proxyClassFile,
                                              null, "__dynamic_proxy__");
                reverseProxyCache.sub(pc).putIfAbsent(loader, Boolean.TRUE);
                return pc;
            } catch (ClassFormatError e) {
                /*
                 * A ClassFormatError here means that (barring bugs in the
                 * proxy class generation code) there was some other
                 * invalid aspect of the arguments supplied to the proxy
                 * class creation (such as virtual machine limitations
                 * exceeded).
                 */
                throw new IllegalArgumentException(e.toString());
            }
        }
```
* generateProxyClass
```
static byte[] generateProxyClass(final String name,
                                     Class<?>[] interfaces,
                                     int accessFlags)
    {
        ProxyGenerator gen = new ProxyGenerator(name, interfaces, accessFlags);
        final byte[] classFile = gen.generateClassFile();

        if (saveGeneratedFiles) {
            java.security.AccessController.doPrivileged(
            new java.security.PrivilegedAction<Void>() {
                public Void run() {
                    try {
                        int i = name.lastIndexOf('.');
                        Path path;
                        if (i > 0) {
                            Path dir = Path.of(name.substring(0, i).replace('.', File.separatorChar));
                            Files.createDirectories(dir);
                            path = dir.resolve(name.substring(i+1, name.length()) + ".class");
                        } else {
                            path = Path.of(name + ".class");
                        }
                        Files.write(path, classFile);
                        return null;
                    } catch (IOException e) {
                        throw new InternalError(
                            "I/O exception saving generated file: " + e);
                    }
                }
            });
        }

        return classFile;
    }
```



### 代理类结构
```
package com.sun.proxy;

import core.proxy.FlyInterface;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.lang.reflect.UndeclaredThrowableException;

public final class $Proxy0 extends Proxy implements FlyInterface, Comparable {
  private static Method m1;
  
  private static Method m4;
  
  private static Method m3;
  
  private static Method m2;
  
  private static Method m0;
  
  public $Proxy0(InvocationHandler paramInvocationHandler) {
    super(paramInvocationHandler);
  }
  
  public final boolean equals(Object paramObject) {
    try {
      return ((Boolean)this.h.invoke(this, m1, new Object[] { paramObject })).booleanValue();
    } catch (Error|RuntimeException error) {
      throw null;
    } catch (Throwable throwable) {
      throw new UndeclaredThrowableException(throwable);
    } 
  }
  
  public final int compareTo(Object paramObject) {
    try {
      return ((Integer)this.h.invoke(this, m4, new Object[] { paramObject })).intValue();
    } catch (Error|RuntimeException error) {
      throw null;
    } catch (Throwable throwable) {
      throw new UndeclaredThrowableException(throwable);
    } 
  }
  
  public final void fly() {
    try {
      this.h.invoke(this, m3, null);
      return;
    } catch (Error|RuntimeException error) {
      throw null;
    } catch (Throwable throwable) {
      throw new UndeclaredThrowableException(throwable);
    } 
  }
  
  public final String toString() {
    try {
      return (String)this.h.invoke(this, m2, null);
    } catch (Error|RuntimeException error) {
      throw null;
    } catch (Throwable throwable) {
      throw new UndeclaredThrowableException(throwable);
    } 
  }
  
  public final int hashCode() {
    try {
      return ((Integer)this.h.invoke(this, m0, null)).intValue();
    } catch (Error|RuntimeException error) {
      throw null;
    } catch (Throwable throwable) {
      throw new UndeclaredThrowableException(throwable);
    } 
  }
  
  static {
    try {
      m1 = Class.forName("java.lang.Object").getMethod("equals", new Class[] { Class.forName("java.lang.Object") });
      m4 = Class.forName("java.lang.Comparable").getMethod("compareTo", new Class[] { Class.forName("java.lang.Object") });
      m3 = Class.forName("core.proxy.FlyInterface").getMethod("fly", new Class[0]);
      m2 = Class.forName("java.lang.Object").getMethod("toString", new Class[0]);
      m0 = Class.forName("java.lang.Object").getMethod("hashCode", new Class[0]);
      return;
    } catch (NoSuchMethodException noSuchMethodException) {
      throw new NoSuchMethodError(noSuchMethodException.getMessage());
    } catch (ClassNotFoundException classNotFoundException) {
      throw new NoClassDefFoundError(classNotFoundException.getMessage());
    } 
  }
}

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
