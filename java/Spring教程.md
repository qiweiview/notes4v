# Spring教程

## 事务配置
```
xmlns:tx="http://www.springframework.org/schema/tx"

http://www.springframework.org/schema/tx
http://www.springframework.org/schema/tx/spring-tx.xsd

 <!-- 开启事务注解@Transactional支持 -->
 <tx:annotation-driven transaction-manager="transactionManager" />

```

### 传播机制
* PROPAGATION_REQUIRED(默认): 支持当前事务，如果当前没有事务，则新建事务,如果当前存在事务，则加入当前事务，合并成一个事务
* REQUIRES_NEW：新建事务，如果当前存在事务，则把当前事务挂起，这个方法会独立提交事务，不受调用者的事务影响，父级异常，它也是正常提交
* NESTED: 如果当前存在事务，它将会成为父级事务的一个子事务，方法结束后并没有提交，只有等父事务结束才提交,如果当前没有事务，则新建事务,如果它异常，父级可以捕获它的异常而不进行回滚，正常提交,但如果父级异常，它必然回滚，这就是和 REQUIRES_NEW 的区别
* SUPPORTS: 如果当前存在事务，则加入事务,如果当前不存在事务，则以非事务方式运行，这个和不写没区别
* NOT_SUPPORTED: 以非事务方式运行,如果当前存在事务，则把当前事务挂起
* MANDATORY: 如果当前存在事务，则运行在当前事务中,如果当前无事务，则抛出异常，也即父级方法必须有事务
* NEVER:以非事务方式运行，如果当前存在事务，则抛出异常，即父级方法必须无事务

## 最小单位的项目
* 依赖
```
         <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
            <version>5.2.6.RELEASE</version>
        </dependency>
```

* 配置
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd
       http://www.springframework.org/schema/context
       http://www.springframework.org/schema/context/spring-context.xsd
       ">



    <!--启动注解扫描-->
    <context:component-scan base-package="com">
        <context:exclude-filter type="annotation" expression="org.springframework.stereotype.Controller"/><!--排除Controller-->
    </context:component-scan>

</beans>
```

* 启动
```
  ClassPathXmlApplicationContext context =new ClassPathXmlApplicationContext("HelloWeb-servlet.xml");
```

## 范例
* 从类路径下加载spring配置文件
```
String s = Test4v.class.getResource("Beans.xml").toString();
ApplicationContext context = new ClassPathXmlApplicationContext(s);
```
* beans.xml配置文件
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:tx="http://www.springframework.org/schema/tx"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:aop="http://www.springframework.org/schema/aop"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd
       http://www.springframework.org/schema/context
       http://www.springframework.org/schema/context/spring-context.xsd
       http://www.springframework.org/schema/tx
       http://www.springframework.org/schema/tx/spring-tx-3.0.xsd
       http://www.springframework.org/schema/aop
       http://www.springframework.org/schema/aop/spring-aop.xsd">


  <!--事物注解驱动：Spring会对unchecked异常进行事务回滚；如果是checked异常则不回滚 -->
  <tx:annotation-driven transaction-manager="transactionManager" proxy-target-class="true"/>

  <!--启动注解扫描-->
  <context:component-scan base-package="test4v">
    <context:exclude-filter type="annotation" expression="org.springframework.stereotype.Controller"/><!--排除Controller-->
  </context:component-scan>

</beans>

```

##  @Transactional事务失效解决
1. 检查你方法是不是public的

2. 你的异常类型是不是unchecked异常 
如果我想check异常也想回滚怎么办，注解上面写明异常类型即可
```
@Transactional(rollbackFor=Exception.class) 
```
类似的还有norollbackFor，自定义不回滚的异常

3. 数据库引擎要支持事务，如果是MySQL，注意表要使用支持事务的引擎，比如innodb，如果是myisam，事务是不起作用的

4. 是否开启了对注解的解析
```
<tx:annotation-driven transaction-manager="transactionManager" proxy-target-class="true"/>
```
5. spring是否扫描到你这个包，如下是扫描到org.test下面的包
```
<context:component-scan base-package="org.test" ></context:component-scan>
```
6. 检查是不是同一个类中的方法调用（如a方法调用同一个类中的b方法） 

7. 异常是不是被你catch住了



## 体系结构
![image.png](https://i.loli.net/2019/04/17/5cb6d43d8b5dd.png)
### 核心容器
由**spring-core**，**spring-beans**，**spring-context**，**spring-context-support**和**spring-expression**（SpEL，Spring表达式语言，Spring Expression Language）等模块组成

由：spring-core， spring-beans，spring-context，spring-context-support，和spring-expression，组成

* spring-core和spring-beans模块提供了框架的基础功能，包括IOC和依赖注入功能。 BeanFactory是一个成熟的工厂模式的实现。你不再需要编程去实现单例模式，允许你把依赖关系的配置和描述从程序逻辑中解耦。
* spring-context模块建立在由Core和Beans模块提供的坚实的基础上：它提供一个框架式的对象访问方式，类似于一个JNDI注册表。上下文模块从Beans模块继承其功能，并添加支持国际化（使用，例如，资源集合），事件传播，资源负载，并且透明创建上下文。ApplicationContext接口是Context模块的焦点。 
* spring-context-support支持整合普通第三方库到Spring应用程序上下文，特别是用于高速缓存（ehcache，JCache）和调度（CommonJ，Quartz）的支持
* spring-expression模块提供了强大的表达式语言去支持查询和操作运行时对象图。这是对JSP 2.1规范中规定的统一表达式语言（unified EL）的扩展
* spring-aop模块提供了一个符合AOP联盟（要求）的面向方面的编程实现，例如，允许您定义方法拦截器和切入点（pointcuts），以便干净地解耦应该被分离的功能实现
* pring-instrument模块提供了类植入(instrumentation)支持和类加载器的实现,可以应用在特定的应用服务器中。该spring-instrument-tomcat 模块包含了支持Tomcat的植入代理
* spring-jdbc模块提供了一个JDBC –抽象层，消除了需要的繁琐的JDBC编码和数据库厂商特有的错误代码解析。
* spring-tx模块支持用于实现特殊接口和所有POJO（普通Java对象）的类的编程和声明式事务 管理。
* spring-orm模块为流行的对象关系映射(object-relational mapping )API提供集成层，包括JPA和Hibernate。
* spring-oxm模块提供了一个支持对象/ XML映射实现的抽象层，如JAXB，Castor，JiBX和XStream。
* spring-jms模块(Java Messaging Service) 包含用于生产和消费消息的功能。自Spring Framework 4.1以来，它提供了与 spring-messaging模块的集成。
* spring-web模块提供基本的面向Web的集成功能，例如多部分文件上传功能，以及初始化一个使用了Servlet侦听器和面向Web的应用程序上下文的IoC容器。它还包含一个HTTP客户端和Spring的远程支持的Web相关部分。
* spring-webmvc模块（也称为Web-Servlet模块）包含用于Web应用程序的Spring的模型-视图-控制器(MVC)和REST Web Services实现。 Spring的MVC框架提供了领域模型代码和Web表单之间的清晰分离，并与Spring Framework的所有其他功能集成。
* spring-websocket
* spring-test模块支持使用JUnit或TestNG对Spring组件进行单元测试和 集成测试。


### 数据访问/集成
数据访问/集成层包括 JDBC，ORM，OXM，JMS 和事务处理模块，它们的细节如下：

（注：JDBC=Java Data Base Connectivity，ORM=Object Relational Mapping，OXM=Object XML Mapping，JMS=Java Message Service）

* JDBC 模块提供了JDBC抽象层，它消除了冗长的JDBC编码和对数据库供应商特定错误代码的解析。

* ORM 模块提供了对流行的对象关系映射API的集成，包括JPA、JDO和Hibernate等。通过此模块可以让这些ORM框架和spring的其它功能整合，比如前面提及的事务管理。

* OXM 模块提供了对OXM实现的支持，比如JAXB、Castor、XML Beans、JiBX、XStream等。

* JMS 模块包含生产（produce）和消费（consume）消息的功能。从Spring 4.1开始，集成了spring-messaging模块。。

* 事务模块为实现特殊接口类及所有的 POJO 支持编程式和声明式事务管理。（注：编程式事务需要自己写beginTransaction()、commit()、rollback()等事务管理方法，声明式事务是通过注解或配置由spring自动处理，编程式事务粒度更细）


### Web
* Web 层由 Web，Web-MVC，Web-Socket 和 Web-Portlet 组成，它们的细节如下：

* Web 模块提供面向web的基本功能和面向web的应用上下文，比如多部分（multipart）文件上传功能、使用Servlet监听器初始化IoC容器等。它还包括HTTP客户端以及Spring远程调用中与web相关的部分。。

* Web-MVC 模块为web应用提供了模型视图控制（MVC）和REST Web服务的实现。Spring的MVC框架可以使领域模型代码和web表单完全地分离，且可以与Spring框架的其它所有功能进行集成。

* Web-Socket 模块为 WebSocket-based 提供了支持，而且在 web 应用程序中提供了客户端和服务器端之间通信的两种方式。

* Web-Portlet 模块提供了用于Portlet环境的MVC实现，并反映了spring-webmvc模块的功能。

### 其他
还有其他一些重要的模块，像 AOP，Aspects，Instrumentation，Web 和测试模块，它们的细节如下：

* AOP 模块提供了面向方面的编程实现，允许你定义方法拦截器和切入点对代码进行干净地解耦，从而使实现功能的代码彻底的解耦出来。使用源码级的元数据，可以用类似于.Net属性的方式合并行为信息到代码中。

* Aspects 模块提供了与 AspectJ 的集成，这是一个功能强大且成熟的面向切面编程（AOP）框架。

* Instrumentation 模块在一定的应用服务器中提供了类 instrumentation 的支持和类加载器的实现。

* Messaging 模块为 STOMP 提供了支持作为在应用程序中 WebSocket 子协议的使用。它也支持一个注解编程模型，它是为了选路和处理来自 WebSocket 客户端的 STOMP 信息。

* 测试模块支持对具有 JUnit 或 TestNG 框架的 Spring 组件的测试。


## 容器
### Spring BeanFactory 容器
这是一个最简单的容器，它主要的功能是为依赖注入 （DI） 提供支持，这个容器接口在 org.springframework.beans.factory.BeanFactor 中被定义。BeanFactory 和相关的接口，比如BeanFactoryAware、DisposableBean、InitializingBean，仍旧保留在 Spring 中，主要目的是向后兼容已经存在的和那些 Spring 整合在一起的第三方框架。
在 Spring 中，有大量对 BeanFactory 接口的实现。其中，最常被使用的是 XmlBeanFactory 类。这个容器从一个 XML 文件中读取配置元数据，由这些元数据来生成一个被配置化的系统或者应用。
```
package com.tutorialspoint;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.xml.XmlBeanFactory;
import org.springframework.core.io.ClassPathResource;
public class MainApp {
   public static void main(String[] args) {
      XmlBeanFactory factory = new XmlBeanFactory
                             (new ClassPathResource("Beans.xml"));
      HelloWorld obj = (HelloWorld) factory.getBean("helloWorld");
      obj.getMessage();
   }
}
```
在资源宝贵的移动设备或者基于 applet 的应用当中， BeanFactory 会被优先选择。否则，一般使用的是 ApplicationContext，除非你有更好的理由选择 BeanFactory。
### Spring ApplicationContext 容器
ApplicationContext 包含 BeanFactory 所有的功能，一般情况下，相对于 BeanFactory，ApplicationContext 会更加优秀。当然，BeanFactory 仍可以在轻量级应用中使用，比如移动设备或者基于 applet 的应用程序。
最常被使用的 ApplicationContext 接口实现：
* FileSystemXmlApplicationContext：该容器从 XML 文件中加载已被定义的 bean。在这里，你需要提供给构造器 XML 文件的完整路径。
* ClassPathXmlApplicationContext：该容器从 XML 文件中加载已被定义的 bean。在这里，你不需要提供 XML 文件的完整路径，只需正确配置 CLASSPATH 环境变量即可，因为，容器会从 CLASSPATH 中搜索 bean 配置文件。
* WebXmlApplicationContext：该容器会在一个 web 应用程序的范围内加载在 XML 文件中已被定义的 bean。


## Bean

### 结构
| 属性 | 描述 |
| ------ | ------ | 
| class | 这个属性是强制性的，并且指定用来创建 bean 的 bean 类。 |
| name | 这个属性指定唯一的 bean 标识符。在基于 XML 的配置元数据中，你可以使用 ID 和/或 name 属性来指定 bean 标识符。 |
| scope | 这个属性指定由特定的 bean 定义创建的对象的作用域 | 
```
<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">

   <!-- A simple bean definition -->
   <bean id="..." class="...">
       <!-- collaborators and configuration for this bean go here -->
   </bean>

   <!-- A bean definition with lazy init set on -->
   <bean id="..." class="..." lazy-init="true">
       <!-- collaborators and configuration for this bean go here -->
   </bean>

   <!-- A bean definition with initialization method -->
   <bean id="..." class="..." init-method="...">
       <!-- collaborators and configuration for this bean go here -->
   </bean>

   <!-- A bean definition with destruction method -->
   <bean id="..." class="..." destroy-method="...">
       <!-- collaborators and configuration for this bean go here -->
   </bean>

   <!-- more bean definitions go here -->

</beans>
```

### 作用域
| 作用域 | 描述 |
| ------ | ------ | 
| singleton | 在spring IoC容器仅存在一个Bean实例，Bean以单例方式存在，默认值 |
| prototype |	每次从容器中调用Bean时，都返回一个新的实例，即每次调用getBean()时，相当于执行newXxxBean() |
| request |	每次HTTP请求都会创建一个新的Bean，该作用域仅适用于WebApplicationContext环境 |
| session |	同一个HTTP Session共享一个Bean，不同Session使用不同的Bean，仅适用于WebApplicationContext环境 |
| global-session |	一般用于Portlet应用环境，该运用域仅适用于WebApplicationContext环境 |


* singleton 作用域：

singleton 是默认的作用域，也就是说，当定义 Bean 时，如果没有指定作用域配置项，则 Bean 的作用域被默认为 singleton。
当一个bean的作用域为Singleton，那么Spring IoC容器中只会存在一个共享的bean实例，并且所有对bean的请求，只要id与该bean定义相匹配，则只会返回bean的同一实例。
也就是说，当将一个bean定义设置为singleton作用域的时候，Spring IoC容器只会创建该bean定义的唯一实例。
Singleton是单例类型，就是在创建起容器时就同时自动创建了一个bean的对象，不管你是否使用，他都存在了，每次获取到的对象都是同一个对象。注意，Singleton作用域是Spring中的缺省作用域。你可以在 bean 的配置文件中设置作用域的属性为 singleton，如下所示：
```
<!-- A bean definition with singleton scope -->
<bean id="..." class="..." scope="singleton">
    <!-- collaborators and configuration for this bean go here -->
</bean>
```
* prototype 作用域

当一个bean的作用域为Prototype，表示一个bean定义对应多个对象实例。Prototype作用域的bean会导致在每次对该bean请求（将其注入到另一个bean中，或者以程序的方式调用容器的getBean()方法）时都会创建一个新的bean实例。**++Prototype是原型类型，它在我们创建容器的时候并没有实例化，而是当我们获取bean的时候才会去创建一个对象，而且我们每次获取到的对象都不是同一个对象。根据经验，对有状态的bean应该使用prototype作用域，而对无状态的bean则应该使用singleton作用域。++**
### 生命周期
Bean的生命周期可以表达为：Bean的定义——Bean的初始化——Bean的使用——Bean的销毁
#### 初始化回调
实现org.springframework.beans.factory.InitializingBean 接口，重写afterPropertiesSet()方法：
```
void afterPropertiesSet() throws Exception;
```
在基于 XML 的配置元数据的情况下，你可以使用 init-method 属性来指定带有 void 无参数方法的名称。例如：
```
<bean id="exampleBean" 
         class="examples.ExampleBean" init-method="init"/>
```
**afterPropertiesSet()会先于init-method指定的方法运行**
#### 销毁回调
实现org.springframework.beans.factory.DisposableBean 接口，destroy()方法：
```
void destroy() throws Exception;
```
在基于 XML 的配置元数据的情况下，你可以使用 init-method 属性来指定带有 void 无参数方法的名称。例如：
```
<bean id="exampleBean" 
         class="examples.ExampleBean" destroy-method="destroy"/>
```
**destroy()会先于destroy-method指定的方法运行**

**建议你不要使用 InitializingBean 或者 DisposableBean 的回调方法，因为 XML 配置在命名方法上提供了极大的灵活性。**

#### 默认的初始化和销毁方法
如果你有太多具有相同名称的初始化或者销毁方法的 Bean，那么你不需要在每一个 bean 上声明初始化方法和销毁方法。框架使用 元素中的 default-init-method 和 default-destroy-method 属性提供了灵活地配置这种情况，如下所示：
```
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-3.0.xsd"
    default-init-method="init" 
    default-destroy-method="destroy">

   <bean id="..." class="...">
       <!-- collaborators and configuration for this bean go here -->
   </bean>

</beans>
```
### Spring Bean 后置处理器
Bean 后置处理器允许在调用初始化方法前后对 Bean 进行额外的处理。
BeanPostProcessor 接口定义回调方法，你可以实现该方法来提供自己的实例化逻辑，依赖解析逻辑等。你也可以在 Spring 容器通过插入一个或多个 BeanPostProcessor 的实现来完成实例化，配置和初始化一个bean之后实现一些自定义逻辑回调方法。

你可以配置多个 BeanPostProcessor 接口，通过设置 BeanPostProcessor 实现的 Ordered 接口提供的 order 属性来控制这些 BeanPostProcessor 接口的执行顺序。
BeanPostProcessor 可以对 bean（或对象）实例进行操作，这意味着 Spring IoC 容器实例化一个 bean 实例，然后 BeanPostProcessor 接口进行它们的工作。

ApplicationContext 会自动检测由 BeanPostProcessor 接口的实现定义的 bean，注册这些 bean 为后置处理器，然后通过在容器中创建 bean，在适当的时候调用它。
```
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.core.Ordered;

/**
 * 可以定义多个后置处理器
 * 一个bean运行一次
 */
public class MyBeanPostProcessor2 implements BeanPostProcessor, Ordered {


    @Override
    public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
        System.out.println("后置处理器2开始");
        return bean;
    }

    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        System.out.println("后置处理器2结束");
        return bean;
    }

    @Override
    public int getOrder() {
        return 1;
    }
}
```

### Spring Bean 定义继承
Spring Bean 定义的继承与 Java 类的继承无关，但是继承的概念是一样的。你可以定义一个父 bean 的定义作为模板和其他子 bean 就可以从父 bean 中继承所需的配置。

#### Bean 定义模板
你可以创建一个 Bean 定义模板，不需要花太多功夫它就可以被其他子 bean 定义使用。在定义一个 Bean 定义模板时，你不应该指定类的属性，而应该指定带 true 值的抽象属性，如下所示：
```
<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">

   <bean id="beanTeamplate" abstract="true">
      <property name="message1" value="Hello World!"/>
      <property name="message2" value="Hello Second World!"/>
      <property name="message3" value="Namaste India!"/>
   </bean>

   <bean id="helloIndia" class="com.tutorialspoint.HelloIndia" parent="beanTeamplate">
      <property name="message1" value="Hello India!"/>
      <property name="message3" value="Namaste India!"/>
   </bean>

</beans>
```
**父 bean 自身不能被实例化，因为它是不完整的，而且它也被明确地标记为抽象的。**当一个定义是抽象的，它仅仅作为一个纯粹的模板 bean 定义来使用的，充当子定义的父定义使用。

## 依赖注入
当编写一个复杂的 Java 应用程序时，应用程序类应该尽可能独立于其他 Java 类来增加这些类重用的可能性，并且在做单元测试时，测试独立于其他类的独立性。

### Spring 基于构造函数的依赖注入
当容器调用带有一组参数的类构造函数时，基于构造函数的 DI 就完成了，其中每个参数代表一个对其他类的依赖。
```
package com.tutorialspoint;
public class TextEditor {
   private SpellChecker spellChecker;
   public TextEditor(SpellChecker spellChecker) {
      System.out.println("Inside TextEditor constructor." );
      this.spellChecker = spellChecker;
   }
   public void spellCheck() {
      spellChecker.checkSpelling();
   }
}
```

xml配置
```
<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">

   <!-- Definition for textEditor bean -->
   <bean id="textEditor" class="com.tutorialspoint.TextEditor">
      <constructor-arg ref="spellChecker"/>
   </bean>

   <!-- Definition for spellChecker bean -->
   <bean id="spellChecker" class="com.tutorialspoint.SpellChecker">
   </bean>

</beans>
```
#### 构造函数参数解析
如果存在不止一个参数时，当把参数传递给构造函数时，可能会存在歧义。要解决这个问题，那么构造函数的参数在 bean 定义中的顺序就是把这些参数提供给适当的构造函数的顺序就可以了
```
<beans>
   <bean id="exampleBean" class="examples.ExampleBean">
      <constructor-arg index="0" value="2001"/>
      <constructor-arg index="1" value="Zara"/>
   </bean>
</beans>
```
最后，如果你想要向一个对象传递一个引用，你需要使用 标签的 ref 属性，如果你想要直接传递值，那么你应该使用如上所示的 value 属性。
### Spring 基于设值函数的依赖注入
当容器调用一个无参的构造函数或一个无参的静态 factory 方法来初始化你的 bean 后，通过容器在你的 bean 上调用设值函数，基于设值函数的 DI 就完成了。
**前提是要有属性的getter和setter**
```
<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">

   <!-- Definition for textEditor bean -->
   <bean id="textEditor" class="com.tutorialspoint.TextEditor">
      <property name="spellChecker" ref="spellChecker"/>
   </bean>

   <!-- Definition for spellChecker bean -->
   <bean id="spellChecker" class="com.tutorialspoint.SpellChecker">
   </bean>

</beans>
```
### Spring 注入内部 Beans

下面是使用内部 bean 为基于 setter 注入进行配置的配置文件 Beans.xml 文件：
```
<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">

   <!-- Definition for textEditor bean using inner bean -->
   <bean id="textEditor" class="com.tutorialspoint.TextEditor">
      <property name="spellChecker">
         <bean id="spellChecker" class="com.tutorialspoint.SpellChecker"/>
       </property>
   </bean>

</beans>
```
### Spring 注入集合
现在如果你想传递多个值，如 Java Collection 类型 List、Set、Map 和 Properties，应该怎么做呢。为了处理这种情况，Spring 提供了四种类型的集合的配置元素，如下所示：

| 元素 |	描述 |
| - | - | 
| < list> |	它有助于连线，如注入一列值，允许重复。 |
| < set> |	它有助于连线一组值，但不能重复。 |
| < map> |	它可以用来注入名称-值对的集合，其中名称和值可以是任何类型。 |
| < props> |	它可以用来注入名称-值对的集合，其中名称和值都是字符串类型。 |

#### 数值类型
```
<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">

   <!-- Definition for javaCollection -->
   <bean id="javaCollection" class="com.tutorialspoint.JavaCollection">

      <!-- results in a setAddressList(java.util.List) call -->
      <property name="addressList">
         <list>
            <value>INDIA</value>
            <value>Pakistan</value>
            <value>USA</value>
            <value>USA</value>
         </list>
      </property>

      <!-- results in a setAddressSet(java.util.Set) call -->
      <property name="addressSet">
         <set>
            <value>INDIA</value>
            <value>Pakistan</value>
            <value>USA</value>
            <value>USA</value>
        </set>
      </property>

      <!-- results in a setAddressMap(java.util.Map) call -->
      <property name="addressMap">
         <map>
            <entry key="1" value="INDIA"/>
            <entry key="2" value="Pakistan"/>
            <entry key="3" value="USA"/>
            <entry key="4" value="USA"/>
         </map>
      </property>

      <!-- results in a setAddressProp(java.util.Properties) call -->
      <property name="addressProp">
         <props>
            <prop key="one">INDIA</prop>
            <prop key="two">Pakistan</prop>
            <prop key="three">USA</prop>
            <prop key="four">USA</prop>
         </props>
      </property>

   </bean>

</beans>
```

#### 引用类型
```
<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">

   <!-- Bean Definition to handle references and values -->
   <bean id="..." class="...">

      <!-- Passing bean reference  for java.util.List -->
      <property name="addressList">
         <list>
            <ref bean="address1"/>
            <ref bean="address2"/>
            <value>Pakistan</value>
         </list>
      </property>

      <!-- Passing bean reference  for java.util.Set -->
      <property name="addressSet">
         <set>
            <ref bean="address1"/>
            <ref bean="address2"/>
            <value>Pakistan</value>
         </set>
      </property>

      <!-- Passing bean reference  for java.util.Map -->
      <property name="addressMap">
         <map>
            <entry key="one" value="INDIA"/>
            <entry key ="two" value-ref="address1"/>
            <entry key ="three" value-ref="address2"/>
         </map>
      </property>

   </bean>

</beans>
```

#### 注入 null 和空字符串的值
如果你需要传递一个空字符串作为值，那么你可以传递它，如下所示：
```
<bean id="..." class="exampleBean">
   <property name="email" value=""/>
</bean>
```
前面的例子相当于 Java 代码：exampleBean.setEmail("")。
如果你需要传递一个 NULL 值，那么你可以传递它，如下所示：
```
<bean id="..." class="exampleBean">
   <property name="email"><null/></property>
</bean>
```
前面的例子相当于 Java 代码：exampleBean.setEmail(null)。

## Spring Beans 自动装配

#### byName
通过bean的名字自动装配bean
```
<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">

   <!-- Definition for textEditor bean -->
   <bean id="textEditor" class="com.tutorialspoint.TextEditor" 
      autowire="byName">
      <property name="name" value="Generic Text Editor" />
   </bean>

   <!-- Definition for spellChecker bean -->
   <bean id="spellChecker" class="com.tutorialspoint.SpellChecker">
   </bean>

</beans>
```
#### byType
**如果定义了两个同类型的bean那么会报错**
```
<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">

   <!-- Definition for textEditor bean -->
   <bean id="textEditor" class="com.tutorialspoint.TextEditor" 
      autowire="byType">
      <property name="name" value="Generic Text Editor" />
   </bean>

   <!-- Definition for spellChecker bean -->
   <bean id="SpellChecker" class="com.tutorialspoint.SpellChecker">
   </bean>
</beans>
```
#### Spring 由构造函数自动装配
将自动转配构造函数
```
<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans-3.0.xsd">

   <!-- Definition for textEditor bean -->
   <bean id="textEditor" class="com.tutorialspoint.TextEditor" 
      autowire="constructor">
      <constructor-arg value="Generic Text Editor"/>
   </bean>

   <!-- Definition for spellChecker bean -->
   <bean id="SpellChecker" class="com.tutorialspoint.SpellChecker">
   </bean>

</beans>
```
## Spring 基于注解的配置
注解连线在默认情况下在 Spring 容器中不打开。因此，在可以使用基于注解的连线之前，我们将需要在我们的 Spring 配置文件中启用它。
**开启注解扫描**
```
//方法一
<context:annotation-config/>
//方法二
<context:component-scan base-package="com"/>
```

```
<context:annotation-config/>

仅能够在已经在已经注册过的bean上面起作用。对于没有在spring容器中注册的bean，它并不能执行任何操作。 
<context:component-scan>除了具有<context:annotation-config/>的功能之外，还具有自动将带有@component,@service,@Repository等注解的对象注册到spring容器中的功能。所以我们一般用context:component-scan，当使用 <context:component-scan/> 后，就可以将 <context:annotation-config/> 移除了
```

#### @Autowired 注释
当 Spring遇到一个在 setter 方法中使用的 @Autowired 注释，它会在方法中视图执行 byType 自动连接。

默认情况下，@Autowired 注释意味着依赖是必须的，它类似于 @Required 注释，然而，你可以使用 @Autowired 的 （required=false） 选项关闭默认行为
```
@Autowired(required = false)
```
#### @Qualifier 注释
可能会有这样一种情况，当你创建多个具有相同类型的 bean 时，并且想要用一个属性只为它们其中的一个进行装配，在这种情况下，你可以使用 @Qualifier 注释和 @Autowired 注释通过指定哪一个真正的 bean 将会被装配来消除混乱。下面显示的是使用 @Qualifier 注释的一个示例。

#### @PostConstruct 和 @PreDestroy 注释：

为了定义一个 bean 的安装和卸载，我们使用 init-method 和/或 destroy-method 参数简单的声明一下 。init-method 属性指定了一个方法，该方法在 bean 的实例化阶段会立即被调用。同样地，destroy-method 指定了一个方法，该方法只在一个 bean 从容器中删除之前被调用。

你可以使用 @PostConstruct 注释作为初始化回调函数的一个替代，@PreDestroy 注释作为销毁回调函数的一个替代，其解释如下示例所示。

#### @Resource 注释：
你可以在字段中或者 setter 方法中使用 @Resource 注释，它和在 Java EE 5 中的运作是一样的。@Resource 注释使用一个 ‘name’ 属性，该属性以一个 bean 名称的形式被注入。**它遵循 by-name 自动连接语义**

## Spring 基于 Java 的配置
#### @Configuration 和 @Bean 注解
带有 @Configuration 的注解类表示这个类可以使用 Spring IoC 容器作为 bean 定义的来源。@Bean 注解告诉 Spring，一个带有 @Bean 的注解方法将返回一个对象，该对象应该被注册为在 Spring 应用程序上下文中的 bean
#### @Bean 注解支持指定任意的初始化和销毁的回调方法
就像在 bean 元素中 Spring 的 XML 的初始化方法和销毁方法的属性：
```
@Configuration
public class AppConfig {
   @Bean(initMethod = "init", destroyMethod = "cleanup" )
   public Foo foo() {
      return new Foo();
   }
}
```
#### 指定 Bean 的范围：
默认范围是单实例，但是你可以重写带有 @Scope 注解的该方法

```
@Configuration
public class AppConfig {
   @Bean
   @Scope("prototype")
   public Foo foo() {
      return new Foo();
   }
}
```
## Spring 框架的 AOP

com包下所有类的所有方法
```
@Pointcut("execution(* com.bean.*.*(..))") // expression
```

### 基于xml配置
**需要包aspectjweaver.jar**
```
 <bean class="com.bean.Logging" name="logging"></bean>
    <aop:config>
        <aop:aspect id="myAspect" ref="logging">
            <aop:pointcut id="businessService"
                          expression="execution(* com.bean.Bag.intro(..))"/>

            <aop:before pointcut-ref="businessService"
                        method="beforeAdvice"/>
            <!-- an after advice definition -->
            <aop:after pointcut-ref="businessService"
                       method="afterAdvice"/>
            <!-- an after-returning advice definition -->
            <!--The doRequiredTask method must have parameter named retVal -->
            <aop:after-returning pointcut-ref="businessService"
                                 returning="retVal"
                                 method="afterReturningAdvice"/>
            <!-- an after-throwing advice definition -->
            <!--The doRequiredTask method must have parameter named ex -->
            <aop:after-throwing pointcut-ref="businessService"
                                throwing="ex"
                                method="AfterThrowingAdvice"/>
        </aop:aspect>
    </aop:config>
```

```
package com.bean;

public class Logging {
    /**
     * This is the method which I would like to execute
     * before a selected method execution.
     */
    public void beforeAdvice(){
        System.out.println("beforeAdvice 运行");
    }
    /**
     * This is the method which I would like to execute
     * after a selected method execution.
     */
    public void afterAdvice(){
        System.out.println("afterAdvice 运行");
    }
    /**
     * This is the method which I would like to execute
     * when any method returns.
     */
    public void afterReturningAdvice(Object retVal){
        System.out.println("返回:" + retVal.toString() );
    }
    /**
     * This is the method which I would like to execute
     * if there is an exception raised.
     */
    public void AfterThrowingAdvice(IllegalArgumentException ex){
        System.out.println("异常: " + ex.toString());
    }
}

```

### 基于注解
**需要包aspectjrt-1.9.2.jar**
```
package com.tutorialspoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.After;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.Around;
@Aspect
public class Logging {
   /** Following is the definition for a pointcut to select
    *  all the methods available. So advice will be called
    *  for all the methods.
    */
   @Pointcut("execution(* com.tutorialspoint.*.*(..))")
   private void selectAll(){}
   /** 
    * This is the method which I would like to execute
    * before a selected method execution.
    */
   @Before("selectAll()")
   public void beforeAdvice(){
      System.out.println("Going to setup student profile.");
   }
   /** 
    * This is the method which I would like to execute
    * after a selected method execution.
    */
   @After("selectAll()")
   public void afterAdvice(){
      System.out.println("Student profile has been setup.");
   }
   /** 
    * This is the method which I would like to execute
    * when any method returns.
    */
   @AfterReturning(pointcut = "selectAll()", returning="retVal")
   public void afterReturningAdvice(Object retVal){
      System.out.println("Returning:" + retVal.toString() );
   }
   /**
    * This is the method which I would like to execute
    * if there is an exception raised by any method.
    */
   @AfterThrowing(pointcut = "selectAll()", throwing = "ex")
   public void AfterThrowingAdvice(IllegalArgumentException ex){
      System.out.println("There has been an exception: " + ex.toString());   
   }  
    @Around("selectAll()")
    public Object  doAroundTask(ProceedingJoinPoint proceedingJoinPoint) throws Throwable {
        Object ret = proceedingJoinPoint.proceed();
        return ret;

    }
}
```
#### @Aroud 注意要写返回值，不写不会运行before,并且return会为null
```
 @Around("log2PointCunt()")
    public Object  doAroundTask(ProceedingJoinPoint proceedingJoinPoint) throws Throwable {
        Object ret = proceedingJoinPoint.proceed();
        return ret;

    }
```
![此处输入图片的描述][1]
  [1]: https://i.loli.net/2019/03/14/5c89cd751c8d6.png

  
