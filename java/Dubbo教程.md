# Dubbo教程

## 关键
* 关注对象的值，不关注对象的方法
* 消费端类加载器加载不到类接口的类，会使用map去装结果集

## Dubbo范例

## 依赖
```
 <dependency>
            <groupId>org.apache.dubbo</groupId>
            <artifactId>dubbo</artifactId>
            <version>2.7.3</version>
        </dependency>

        <dependency>
            <groupId>org.apache.curator</groupId>
            <artifactId>curator-framework</artifactId>
            <version>4.2.0</version>
        </dependency>

        <!-- https://mvnrepository.com/artifact/org.apache.curator/curator-recipes -->
        <dependency>
            <groupId>org.apache.curator</groupId>
            <artifactId>curator-recipes</artifactId>
            <version>4.2.0</version>
        </dependency>
```



## 配置
* 接口
```
public interface JobInterface {
    public String  doJob();
}
```
* 实现
```
public class JobImpl implements JobInterface {
    @Override
    public String doJob() {
        System.out.println("do job");
        return UUID.randomUUID().toString();
    }
}
```

* 生产者
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:dubbo="http://dubbo.apache.org/schema/dubbo"
       xsi:schemaLocation="http://www.springframework.org/schema/beans        http://www.springframework.org/schema/beans/spring-beans-4.3.xsd        http://dubbo.apache.org/schema/dubbo        http://dubbo.apache.org/schema/dubbo/dubbo.xsd">

    <!-- 提供方应用信息，用于计算依赖关系 -->
    <dubbo:application name="hello-world-app"  />

    <!-- 使用multicast广播注册中心暴露服务地址 -->
<!--    <dubbo:registry address="multicast://224.2.2.2:1234?unicast=false" />-->

    <dubbo:registry address="zookeeper://127.0.0.1:2181"/>

    <!-- 用dubbo协议在20880端口暴露服务 -->
    <dubbo:protocol name="dubbo" port="20880" />

    <!-- 声明需要暴露的服务接口 -->
    <dubbo:service interface="dubbo.JobInterface"  ref="demoService" version="1.0"/>

    <!-- 和本地bean一样实现服务 -->
    <bean id="demoService" class="dubbo.JobImpl" />
</beans>
```

* 消费者
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:dubbo="http://dubbo.apache.org/schema/dubbo"
       xsi:schemaLocation="http://www.springframework.org/schema/beans        http://www.springframework.org/schema/beans/spring-beans-4.3.xsd        http://dubbo.apache.org/schema/dubbo        http://dubbo.apache.org/schema/dubbo/dubbo.xsd">

    <!-- 消费方应用名，用于计算依赖关系，不是匹配条件，不要与提供方一样 -->
    <dubbo:application name="consumer-of-helloworld-app"  />

    <!-- 使用multicast广播注册中心暴露发现服务地址 -->
<!--    <dubbo:registry address="multicast://224.2.2.2:1234?unicast=false" />-->

    <dubbo:registry address="zookeeper://127.0.0.1:2181"/>

    <!-- 生成远程服务代理，可以和本地bean一样使用demoService -->
    <dubbo:reference id="demoService" interface="dubbo.JobInterface" version="1.0" check="false"/>
</beans>
```


## 泛化
* provider
```
 @Bean
    public ServiceConfig getServiceConfig(){
        GenericService xxxService  = new GenericServiceImpl();

        ServiceConfig<GenericService> service = new ServiceConfig<>();
        service.setApplication(getApplicationConfig());
        service.setRegistry(getRegistryConfig()); // 多个注册中心可以用setRegistries()
        service.setProtocol(getProtocolConfig()); // 多个协议可以用setProtocols()
        service.setInterface("com.xxx.XxxService");//泛化的话调用类全部指向这个，是个虚类
        service.setRef(xxxService );//实际指向类引用
        service.setVersion("1");//版本
        service.export();

        return service;

    }
```

```
public class GenericServiceImpl implements GenericService {
    @Override
    public Object $invoke(String s, String[] strings, Object[] objects) throws GenericException {
        System.out.println("method"+s);
        System.out.println(Arrays.toString(strings));
        System.out.println(Arrays.toString(objects));
        return "welcome";

    }
}
```

* consumer
```
  // 普通编码配置方式
        ApplicationConfig application = new ApplicationConfig();
        application.setName("generic-consumer");

        // 连接注册中心配置
        RegistryConfig registry = new RegistryConfig();
        registry.setAddress("zookeeper://127.0.0.1:2181");

        ReferenceConfig<GenericService> reference = new ReferenceConfig<GenericService>();
        reference.setApplication(application);
        reference.setRegistry(registry);
        reference.setVersion("1");//版本也要一样
        reference.setInterface("com.xxx.XxxService");//要与提供者名字一样
        reference.setGeneric(true); // 声明为泛化接口

        ReferenceConfigCache cache = ReferenceConfigCache.getCache();
        GenericService genericService = cache.get(reference);

        // 基本类型以及Date,List,Map等不需要转换，直接调用
        Object resultObj = genericService.$invoke("getUserInfo", new String[] {"java.lang.Integer", "java.lang.String"},
                new Object[] {1, "guoxi.li"});
        removeClassFeild(resultObj);
        System.out.println(resultObj);
```

## 踩坑
* 使用apache的包，不然会有奇奇怪怪的问题
* 暴露的接口和实现中如果申明为public 的方法，那么就不能是void，否则会报compile error: getPropertyValue (Ljava/lang/Object;Ljava/lang/String;)

## 依赖
* 不要引成alibaba的，可能造成异步返回失败
```
<dependencies>

        <!-- https://mvnrepository.com/artifact/org.springframework/spring-context -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
            <version>5.1.8.RELEASE</version>
        </dependency>
        <!-- https://mvnrepository.com/artifact/com.alibaba/dubbo -->
        <dependency>
            <groupId>org.apache.dubbo</groupId>
            <artifactId>dubbo</artifactId>
            <version>2.7.3</version>
        </dependency>
        <!-- https://mvnrepository.com/artifact/io.netty/netty-all -->
        <dependency>
            <groupId>io.netty</groupId>
            <artifactId>netty-all</artifactId>
            <version>4.1.37.Final</version>
        </dependency>
        <!-- https://mvnrepository.com/artifact/org.apache.curator/curator-framework -->
        <dependency>
            <groupId>org.apache.curator</groupId>
            <artifactId>curator-framework</artifactId>
            <version>4.2.0</version>
        </dependency>

        <!-- https://mvnrepository.com/artifact/org.apache.curator/curator-recipes -->
        <dependency>
            <groupId>org.apache.curator</groupId>
            <artifactId>curator-recipes</artifactId>
            <version>4.2.0</version>
        </dependency>
    </dependencies>
```

## Xml配置

[xml参考手册](http://dubbo.apache.org/zh-cn/docs/user/references/xml/introduction.html)

### produce范例
```
<beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:dubbo="http://dubbo.apache.org/schema/dubbo"
       xmlns="http://www.springframework.org/schema/beans"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
       http://dubbo.apache.org/schema/dubbo http://dubbo.apache.org/schema/dubbo/dubbo.xsd">
    <dubbo:application name="demo-provider"/>
    <dubbo:registry address="zookeeper://127.0.0.1:2181"/>
    <dubbo:protocol name="dubbo" port="20890"/>
    <bean id="demoService" class="org.apache.dubbo.samples.basic.impl.DemoServiceImpl"/>
    <dubbo:service interface="org.apache.dubbo.samples.basic.api.DemoService" ref="demoService"/>
</beans>
```

### consumer范例
```
<beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:dubbo="http://dubbo.apache.org/schema/dubbo"
       xmlns="http://www.springframework.org/schema/beans"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
       http://dubbo.apache.org/schema/dubbo http://dubbo.apache.org/schema/dubbo/dubbo.xsd">
    <dubbo:application name="demo-consumer"/>
    <dubbo:registry group="aaa" address="zookeeper://127.0.0.1:2181"/>
    <dubbo:reference id="demoService" check="false" interface="org.apache.dubbo.samples.basic.api.DemoService"/>
</beans>
```



### dubbo:service（生产端）
* 服务提供者暴露服务配置,对应的配置类：org.apache.dubbo.config.ServiceConfig

### dubbo:reference(消费端)
* 服务消费者引用服务配置。对应的配置类： org.apache.dubbo.config.ReferenceConfig

### dubbo:protocol
* 服务提供者协议配置。对应的配置类：org.apache.dubbo.config.ProtocolConfig。
* 同时，如果需要支持多协议，可以声明多个 <dubbo:protocol> 标签，并在 <dubbo:service> 中通过 protocol 属性指定使用的协议。

### dubbo:registry
* 注册中心配置。对应的配置类：org.apache.dubbo.config.RegistryConfig。
* 同时如果有多个不同的注册中心，可以声明多个 <dubbo:registry> 标签，并在 <dubbo:service> 或 <dubbo:reference> 的 registry 属性指定使用的注册中心。

### dubbo:monitor
* 监控中心配置。对应的配置类： org.apache.dubbo.config.MonitorConfig

### dubbo:application
* 应用信息配置。对应的配置类：org.apache.dubbo.config.ApplicationConfig

### dubbo:module
* 模块信息配置。对应的配置类 org.apache.dubbo.config.ModuleConfig

### dubbo:provider
* 服务提供者缺省值配置。对应的配置类： org.apache.dubbo.config.ProviderConfig。
* 同时该标签为 <dubbo:service> 和 <dubbo:protocol> 标签的缺省值设置。

### dubbo:consumer
* 服务消费者缺省值配置。配置类： org.apache.dubbo.config.ConsumerConfig 。
* 同时该标签为 <dubbo:reference> 标签的缺省值设置。

### dubbo:method
* 方法级配置。对应的配置类： org.apache.dubbo.config.MethodConfig。
* 同时该标签为 <dubbo:service> 或 <dubbo:reference> 的子标签，用于控制到方法级。

### dubbo:argument
* 方法参数配置。对应的配置类： org.apache.dubbo.config.ArgumentConfig。
* 该标签为 <dubbo:method> 的子标签，用于方法参数的特征描述，比如：
```xml
<dubbo:method name="findXxx" timeout="3000" retries="2">
    <dubbo:argument index="0" callback="true" />
</dubbo:method>
```

### dubbo:parameter
* 选项参数配置。对应的配置类：java.util.Map。
* 同时该标签为```<dubbo:protocol>```或```<dubbo:service>```或```<dubbo:provider>```或```<dubbo:reference>```或```<dubbo:consumer>```的子标签，用于配置自定义参数，该配置项将作为扩展点设置自定义参数使用

### dubbo:config-center
* 配置中心。对应的配置类：org.apache.dubbo.config.ConfigCenterConfig



## Api配置

* 配置类
```
org.apache.dubbo.config.ServiceConfig
org.apache.dubbo.config.ReferenceConfig
org.apache.dubbo.config.ProtocolConfig
org.apache.dubbo.config.RegistryConfig
org.apache.dubbo.config.MonitorConfig
org.apache.dubbo.config.ApplicationConfig
org.apache.dubbo.config.ModuleConfig
org.apache.dubbo.config.ProviderConfig
org.apache.dubbo.config.ConsumerConfig
org.apache.dubbo.config.MethodConfig
org.apache.dubbo.config.ArgumentConfig
```


### producer配置
```
package config;


import org.apache.dubbo.config.*;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import service.AppService;
import service.AppServiceImpl;

import java.util.Arrays;


@Configuration
public class DubboConfig {

    @Bean
    public ApplicationConfig getApplicationConfig(){
        ApplicationConfig applicationConfig=new ApplicationConfig();
        applicationConfig.setName("dubboProducer");
        return applicationConfig;
    }

    @Bean
    public RegistryConfig getRegistryConfig(){
        RegistryConfig registryConfig=new RegistryConfig();
        registryConfig.setAddress("zookeeper://127.0.0.1:2181");
        return registryConfig;
    }


    @Bean
    public ProtocolConfig getProtocolConfig(){
        ProtocolConfig protocolConfig=new ProtocolConfig();
        protocolConfig.setName("dubbo");
        protocolConfig.setPort(-1);
        return protocolConfig;
    }

    @Bean
    public ServiceConfig getServiceConfig(){
        ServiceConfig serviceConfig=new ServiceConfig();
        serviceConfig.setApplication(getApplicationConfig());
        serviceConfig.setRegistry(getRegistryConfig()); // 多个注册中心可以用setRegistries()
        serviceConfig.setProtocol(getProtocolConfig()); // 多个协议可以用setProtocols()
        serviceConfig.setInterface(AppService.class);//接口
        serviceConfig.setRef(getAppServiceImpl());//实现
        serviceConfig.export();//暴露接口
       /* serviceConfig.setAsync(true);*/ //这个不知道怎么影响异步
        return serviceConfig;
    }


    @Bean
    AppServiceImpl getAppServiceImpl(){
        return new AppServiceImpl();
    }


}

```

### consumer配置
```
package config;

import org.apache.dubbo.config.ApplicationConfig;
import org.apache.dubbo.config.MethodConfig;
import org.apache.dubbo.config.ReferenceConfig;
import org.apache.dubbo.config.RegistryConfig;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import service.AppService;

import java.util.Arrays;

@Configuration
public class DubboConfig {

    @Bean
    public ApplicationConfig getApplicationConfig() {
        ApplicationConfig applicationConfig = new ApplicationConfig();
        applicationConfig.setName("dubboConsumer");
        return applicationConfig;
    }

    @Bean
    public RegistryConfig getRegistryConfig() {
        RegistryConfig registryConfig = new RegistryConfig();
        registryConfig.setAddress("zookeeper://127.0.0.1:2181");
        return registryConfig;
    }

    @Bean
    public ReferenceConfig getReferenceConfig() {
        ReferenceConfig referenceConfig = new ReferenceConfig();
        referenceConfig.setInterface(AppService.class);//设置接口
        referenceConfig.setApplication(getApplicationConfig());//设置应用
        referenceConfig.setRegistry(getRegistryConfig());//设置注册中心
       /* referenceConfig.setAsync(true);*/ //这个也不知道怎么影响到异步的
        referenceConfig.setTimeout(10000);
        /* MethodConfig methodConfig=new MethodConfig();
        methodConfig.setAsync(true);
        methodConfig.setName("sayHello");
        referenceConfig.setTimeout(10000);
        referenceConfig.setMethods(Arrays.asList(methodConfig));*/
        return referenceConfig;
    }

    @Bean
    public AppService getAppService(){
        return (AppService) getReferenceConfig().get();
    }



}

```

## 集群容错

### Failover Cluster
* 没有验证成功
* 失败自动切换，当出现失败，重试其它服务器 [1]。通常用于读操作，但重试会带来更长延迟。可通过 retries="2" 来设置重试次数(不含第一次)。

### Failfast Cluster
* 没有验证
* 快速失败，只发起一次调用，失败立即报错。通常用于非幂等性的写操作，比如新增记录。

### Failsafe Cluster
* 失败安全，出现异常时，直接忽略。通常用于写入审计日志等操作。

### Failback Cluster
* 失败自动恢复，后台记录失败请求，定时重发。通常用于消息通知操作。

### Forking Cluster
* 并行调用多个服务器，只要一个成功即返回。通常用于实时性要求较高的读操作，但需要浪费更多服务资源。可通过 forks="2" 来设置最大并行数。

### Broadcast Cluster
* 广播调用所有提供者，逐个调用，任意一台报错则报错。通常用于通知所有提供者更新缓存或日志等本地资源信息。

## 负载均衡策略
### Random LoadBalance
* 随机，按权重设置随机概率。
在一个截面上碰撞的概率高，但调用量越大分布越均匀，而且按概率使用权重后也比较均匀，有利于动态调整提供者权重。

### RoundRobin LoadBalance
* 轮询，按公约后的权重设置轮询比率。
存在慢的提供者累积请求的问题，比如：第二台机器很慢，但没挂，当请求调到第二台时就卡在那，久而久之，所有请求都卡在调到第二台上。

### LeastActive LoadBalance
* 最少活跃调用数，相同活跃数的随机，活跃数指调用前后计数差。
使慢的提供者收到更少请求，因为越慢的提供者的调用前后计数差会越大。

### ConsistentHash LoadBalance
* 一致性 Hash，相同参数的请求总是发到同一提供者。
当某一台提供者挂时，原本发往该提供者的请求，基于虚拟节点，平摊到其它提供者，不会引起剧烈变动。
算法参见：http://en.wikipedia.org/wiki/Consistent_hashing
缺省只对第一个参数 Hash，如果要修改，请配置 <dubbo:parameter key="hash.arguments" value="0,1" />
缺省用 160 份虚拟节点，如果要修改，请配置 <dubbo:parameter key="hash.nodes" value="320" />


## 服务分组

* 两组服务互不干扰，独自调用

服务，api配置直接申明两个service
```
<dubbo:service group="feedback" interface="com.xxx.IndexService" />
<dubbo:service group="member" interface="com.xxx.IndexService" />
```
消费，api配置直接申明两个reference
```
<dubbo:reference id="feedbackIndexService" group="feedback" interface="com.xxx.IndexService" />
<dubbo:reference id="memberIndexService" group="member" interface="com.xxx.IndexService" />
```
任意组 [1]：
```
<dubbo:reference id="barService" interface="com.foo.BarService" group="*" />
```


## 多版本
* 当一个接口实现，出现不兼容升级时，可以用版本号过渡，版本号不同的服务相互间不引用。

* 可以按照以下的步骤进行版本迁移：
1. 在低压力时间段，先升级一半提供者为新版本
2. 再将所有消费者升级为新版本
3. 然后将剩下的一半提供者升级为新版本

老版本服务提供者配置：
```
<dubbo:service interface="com.foo.BarService" version="1.0.0" />
```

新版本服务提供者配置：
```
<dubbo:service interface="com.foo.BarService" version="2.0.0" />
```

老版本服务消费者配置：
```
<dubbo:reference id="barService" interface="com.foo.BarService" version="1.0.0" />
```

新版本服务消费者配置：
```
<dubbo:reference id="barService" interface="com.foo.BarService" version="2.0.0" />
```

如果不需要区分版本，可以按照以下的方式配置 [1]：
```
<dubbo:reference id="barService" interface="com.foo.BarService" version="*" />
```



## 异步调用

* 接口申明，CompletableFuture返回值
```
package service;
import java.util.concurrent.CompletableFuture;
public interface AppService {
    CompletableFuture<String> sayHello(String name);
}
```

### 生产者实现
* Provider端异步执行，将阻塞的业务从Dubbo内部线程池切换到业务自定义线程，避免Dubbo线程池的过度占用，有助于避免不同服务间的互相影响。
* 异步执行无益于节省资源或提升RPC响应性能，因为如果业务执行需要阻塞，则始终还是要有线程来负责执行
* 注意：Provider端异步执行和Consumer端异步调用是相互独立的，你可以任意正交组合两端配置
```
Consumer同步 - Provider同步
Consumer异步 - Provider同步
Consumer同步 - Provider异步
Consumer异步 - Provider异步
```

* 类实现代码，通过return CompletableFuture.supplyAsync()，业务执行已从Dubbo线程切换到业务线程，避免了对Dubbo线程池的阻塞。
```
  @Override
    public CompletableFuture<String> sayHello(String name) {

        // 建议为supplyAsync提供自定义线程池，避免使用JDK公用线程池
       
        CompletableFuture<String> stringCompletableFuture = CompletableFuture.supplyAsync(() -> {

            try {
                Thread.sleep(5 * 1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println("发送响应");
            return "你好啊，" + name + "等了很久吧";
        });
        
        RpcContext savedContext = RpcContext.getContext();
        return stringCompletableFuture;
    }
```


### 消费者调用
* 从v2.7.0开始，Dubbo的所有异步编程接口开始以CompletableFuture为基础
* 基于 NIO 的非阻塞实现并行调用，客户端不需要启动多线程即可完成并行调用多个远程服务，相对多线程开销较小

* 设置允许超时等待
```
 referenceConfig.setTimeout(10000);
```
* 调用
```
CompletableFuture<String> stringCompletableFuture = bean.sayHello("大头");
        CountDownLatch latch = new CountDownLatch(1);
        stringCompletableFuture.whenComplete((x, y) -> {
            String x1 = x;
            Throwable y1 = y;
            if (y1 == null) {
                System.out.println("获取响应:" + x1);
                latch.countDown();
                DebugUtils.stopTheTimer(1);
            } else {
                System.out.println("程序出错:" + y1);
            }
        });

        DebugUtils.startTheTimer(1);
        latch.await();
```

## 本地调用
* 本地调用使用了 injvm 协议，是一个伪协议，它不开启端口，不发起远程调用，只在 JVM 内直接关联，但执行 Dubbo 的 Filter 链。


## 参数回调
* Dubbo 将基于长连接生成反向代理，这样就可以从服务器端调用客户端逻辑 
* 即服务器去调用客户端

### 服务端暴露接口
```
void addListener(String key, CallbackListener listener);
```

```
package service;
public interface CallbackListener {
    void changed(String msg);
}
```

### 服务端接口实现
```
  @Override
    public void addListener(String key, CallbackListener listener) {
        getAddress();
        listeners.put(key, listener);
        CompletableFuture.runAsync(()->{
            while (true){
                DebugUtils.sleep(1);
                listener.changed(getChanged(key));//服务器去主动调用消费者
            }
        });// 发送变更通知
    }
```

### 消费端调用
* 接口也是要相同的定义
```
AppService bean = classPathXmlApplicationContext.getBean(AppService.class);

bean.addListener("view",(x)->{
    System.out.println("run back:"+x);
});

DebugUtils.bock();
```

## 事件通知(未尝试)
* 在调用之前、调用之后、出现异常时，会触发 oninvoke、onreturn、onthrow 三个事件，可以配置当事件发生时，通知哪个类的哪个方法


* 服务消费者 Callback 接口
```
interface Notify {
    public void onreturn(Person msg, Integer id);
    public void onthrow(Throwable ex, Integer id);
}
```

* 服务消费者 Callback 实现
```
class NotifyImpl implements Notify {
    public Map<Integer, Person>    ret    = new HashMap<Integer, Person>();
    public Map<Integer, Throwable> errors = new HashMap<Integer, Throwable>();
    
    public void onreturn(Person msg, Integer id) {
        System.out.println("onreturn:" + msg);
        ret.put(id, msg);
    }
    
    public void onthrow(Throwable ex, Integer id) {
        errors.put(id, ex);
    }
}
```

* 服务消费者 Callback 配置
```xml
<bean id ="demoCallback" class = "org.apache.dubbo.callback.implicit.NofifyImpl" />

<dubbo:reference id="demoService"interface="org.apache.dubbo.callback.implicit.IDemoService"version="1.0.0" group="cn" >

<dubbo:method name="get" async="true" onreturn = "demoCallback.onreturn"onthrow="demoCallback.onthrow" />

</dubbo:reference>
callback 与 async 功能正交分解，async=true 表示结果是否马上返回，onreturn 表示是否需要回调。
```

* 两者叠加存在以下几种组合情况：
```
异步回调模式：async=true onreturn="xxx"
同步回调模式：async=false onreturn="xxx"
异步无回调 ：async=true
同步无回调 ：async=false
```

## 本地伪装
* 本地伪装通常用于服务降级，比如某验权服务，当服务提供方全部挂掉后，客户端不抛出异常，而是通过 Mock 数据返回授权失败
* 仅force通过了
```
<dubbo:reference id="demoService" check="false" interface="com.foo.BarService">
    <dubbo:parameter key="sayHello.mock" value="force:return fake"/>
</dubbo:reference>
```

## 并发控制
* 限制 com.foo.BarService 的每个方法，服务器端并发执行（或占用线程池线程数）不能超过 10 个：
```
<dubbo:service interface="com.foo.BarService" executes="10" />
```


## 连接控制
### 服务端连接控制
* 限制服务器端接受的连接不能超过 10 个 [1]：
```
<dubbo:provider protocol="dubbo" accepts="10" />
```
或
```
<dubbo:protocol name="dubbo" accepts="10" />
```
### 客户端连接控制
* 限制客户端服务使用连接不能超过 10 个 [2]：
```
<dubbo:reference interface="com.foo.BarService" connections="10" />
```

## 延迟连接
延迟连接用于减少长连接数。当有调用发起时，再创建长连接。[1]
```
<dubbo:protocol name="dubbo" lazy="true" />
```

## 令牌验证
* 通过令牌验证在注册中心控制权限，以决定要不要下发令牌给消费者，可以防止消费者绕过注册中心访问提供者，另外通过注册中心可灵活改变授权方式，而不需修改或升级提供者


### 可以全局设置开启令牌验证：
```
<!--随机token令牌，使用UUID生成-->
<dubbo:provider interface="com.foo.BarService" token="true" />
```
或
```
<!--固定token令牌，相当于密码-->
<dubbo:provider interface="com.foo.BarService" token="123456" />
```
### 也可在服务级别设置：
```
<!--随机token令牌，使用UUID生成-->
<dubbo:service interface="com.foo.BarService" token="true" />
```
或
```
<!--固定token令牌，相当于密码-->
<dubbo:service interface="com.foo.BarService" token="123456" />
```


## 在 Provider 端尽量多配置 Consumer 端属性
原因如下：

* 作服务的提供方，比服务消费方更清楚服务的性能参数，如调用的超时时间、合理的重试次数等
* 在 Provider 端配置后，Consumer 端不配置则会使用 Provider 端的配置，即 Provider 端的配置可以作为 Consumer 的缺省值 [1]。否则，Consumer 会使用 Consumer 端的全局设置，这对于 Provider 是不可控的，并且往往是不合理的
* Provider 端尽量多配置 Consumer 端的属性，让 Provider 的实现者一开始就思考 Provider 端的服务特点和服务质量等问题。

示例：
```
<dubbo:service interface="com.alibaba.hello.api.HelloService" version="1.0.0" ref="helloService"
    timeout="300" retry="2" loadbalance="random" actives="0" />
 
<dubbo:service interface="com.alibaba.hello.api.WorldService" version="1.0.0" ref="helloService"
    timeout="300" retry="2" loadbalance="random" actives="0" >
    <dubbo:method name="findAllPerson" timeout="10000" retries="9" loadbalance="leastactive" actives="5" />
<dubbo:service/>
```
* 建议在 Provider 端配置的 Consumer 端属性有：

1. timeout：方法调用的超时时间
2. retries：失败重试次数，缺省是 2 [2]
3. loadbalance：负载均衡算法 [3]，缺省是随机 random。还可以配置轮询 roundrobin、最不活跃优先 [4] leastactive 和一致性哈希 consistenthash 等
4. actives：消费者端的最大并发调用限制，即当 Consumer 对一个服务的并发调用到上限后，新调用会阻塞直到超时，在方法上配置 dubbo:method 则针对该方法进行并发限制，在接口上配置 dubbo:service，则针对该服务进行并发限制


## 在 Provider 端配置合理的 Provider 端属性
```
<dubbo:protocol threads="200" /> 
<dubbo:service interface="com.alibaba.hello.api.HelloService" version="1.0.0" ref="helloService"
    executes="200" >
    <dubbo:method name="findAllPerson" executes="50" />
</dubbo:service>
```
* 建议在 Provider 端配置的 Provider 端属性有：

1. threads：服务线程池大小
2. executes：一个服务提供者并行执行请求上限，即当 Provider 对一个服务的并发调用达到上限后，新调用会阻塞，此时 Consumer 可能会超时。在方法上配置 dubbo:method 则针对该方法进行并发限制，在接口上配置 dubbo:service，则针对该服务进行并发限制

## 配置 Dubbo 缓存文件
提供者列表缓存文件：
```
<dubbo:registry file=”${user.home}/output/dubbo.cache” />
```
注意：

可以根据需要调整缓存文件的路径，保证这个文件不会在发布过程中被清除；
如果有多个应用进程，请注意不要使用同一个文件，避免内容被覆盖；
该文件会缓存注册中心列表和服务提供者列表。配置缓存文件后，应用重启过程中，若注册中心不可用，应用会从该缓存文件读取服务提供者列表，进一步保证应用可靠性。


## 新版本 telnet 命令使用说明
* dubbo 2.5.8 新版本增加了 QOS 模块，提供了新的 telnet 命令支持。

### 端口
* 新版本的 telnet 端口 与 dubbo 协议的端口是不同的端口，默认为 22222，可通过配置文件dubbo.properties 修改:
```
dubbo.application.qos.port=33333
```

* 默认情况下，dubbo 接收任何主机发起的命令，可通过配置文件dubbo.properties 修改:
```
dubbo.application.qos.accept.foreign.ip=false
```

### 支持的命令
* ls 列出消费者和提供者
* Online 上线服务命令
* Offline 下线服务命令
* help 命令
