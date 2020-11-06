# Tomcat及Servlet规范

* [![BR2OxS.png](https://s1.ax1x.com/2020/11/05/BR2OxS.png)](https://imgchr.com/i/BR2OxS)

## 容器组件
### 顶级组件
* ***Server***：表示一个Tomcat实例 (单例的)；Server代表整个catalina servlet容器；包含一个或多个service子容器。主要是用来管理容器下各个Serivce组件的生命周期。

* ***Service***：代表Tomcat中一组提供服务、处理请求的组件。是一个分组结构，包括多个Connector和一个Container

### 连接器
* ***Connector***是客户端连接到Tomcat容器的服务点，它为引擎提供协议服务来将引擎与客户端各种协议隔离开来，如HTTP、HTTPS、AJP协议。Connector的基本属性都是它所需要监听的IP地址及端口号，以及所支持的协议。还有一个关键属性就是并发处理传入请求的最大线程数。注意，Connector关键的有 连接器（HTTP   HTTPS   HTTP1.1   AJP    SSL  proxy） 运行模式（BIO  NIO  NIO2/AIO  APR）多线程/线程池


### 容器组件

* ***Container***：是容器的父接口，用于封装和管理Servlet，以及具体处理Request请求，该容器的设计用的是典型的责任链的设计模式，它由四个自容器组件构成，分别是***Engine***、***Host***、***Context***、***Wrapper***。这四个组件是负责关系，存在包含关系。只包含一个引擎。

* ***Engine 引擎***：表示可运行的Catalina的servlet引擎实例，并且包含了servlet容器的核心功能。在一个服务中只能有一个引擎。同时，作为一个真正的容器，Engine元素之下可以包含一个或多个虚拟主机。它主要功能是将传入请求委托给适当的虚拟主机处理。如果根据名称没有找到可处理的虚拟主机，那么将根据默认的Host来判断该由哪个虚拟主机处理。

* ***Host 虚拟主机***：作用就是运行多个应用，它负责安装和展开这些应用，并且标识这个应用以便能够区分它们。它的子容器通常是 Context。一个虚拟主机下都可以部署一个或者多个Web App，每个Web App对应于一个Context，当Host获得一个请求时，将把该请求匹配到某个Context上，然后把该请求交给该Context来处理。主机组件类似于Apache中的虚拟主机，但在Tomcat中只支持基于FQDN(完全合格的主机名)的“虚拟主机”。Host主要用来解析web.xml。

* ***Context上下文***：代表 Servlet 的 Context，它具备了 Servlet 运行的基本环境，它表示Web应用程序本身。Context 最重要的功能就是管理它里面的 Servlet 实例，***一个Context对应于一个Web Application，一个Web Application由一个或者多个Servlet实例组成。***

* ***Wrapper包装器***: 代表一个 Servlet，它负责管理一个 Servlet，包括的 Servlet 的装载、初始化、执行以及资源回收。***Wrapper 是最底层的容器，它没有子容器了，所以调用它的 addChild 将会报错***


### 嵌套组件
* ***Valve阀门***：类似于Servlet规范中定义的过滤器，用来拦截请求并在将其转至目标之前进行某种处理操作。Valve可以定义在任何容器类的组件中。Valve常被用来记录客户端请求、客户端IP地址和服务器等信息，这种处理技术通常被称作请求转储(request dumping)。请求转储valve记录请求客户端请求数据包中的HTTP首部信息和cookie信息文件中，响应转储valve则记录响应数据包首部信息和cookie信息至文件中。

* ***Logger日志记录器***：用于记录组件内部的状态信息，可被用于除Context之外的任何容器中。日志记录的功能可被继承，因此，一个引擎级别的Logger将会记录引擎内部所有组件相关的信息，除非某内部组件定义了自己的Logger组件。

* ***Loader类加载器***：负责加载、解释Java类编译后的字节码。

* ***Realm领域***：用于用户的认证和授权；在配置一个应用程序时，管理员可以为每个资源或资源组定义角色及权限，而这些访问控制功能的生效需要通过Realm来实现。Realm的认证可以基于文本文件、数据库表、LDAP服务等来实现。Realm的效用会遍及整个引擎或顶级容器，因此，一个容器内的所有应用程序将共享用户资源。同时，Realm可以被其所在组件的子组件继承，也可以被子组件中定义的Realm所覆盖。

* ***Excutor执行器***：执行器组件允许您配置一个共享的线程池，以供您的连接器使用。从tomcat 6.0.11版本开始。

* ***Listener监听器***：监听已注册组件的生命周期。

* ***Manager会话管理器***：用于实现http会话管理的功能，tomcat6种有5种会话管理的manager的实现（standardManager、persisentManager、DeltaManager、BackupManager、SimpleTcpReplicationManager）。会话让使用无状态HTTP协议的应用程序完成通信。会话表示客户端和服务器之间的通信，会话功能是由javax.servlet.http.HttpSession 的实例实现的，该实例存储在服务器上而且与一个唯一的标识符相关联，客户端在与服务器的每次交互中根据请求中的标识符找到它的会话。一个新的会话在客户端请求后被创建，会话一直有效直到一段时间后客户端连接超时，或者会话直接失效例如客户退出访问服务器。

* ***Cluster集群***：专用于配置Tomcat集群的元素，可用于Engine和Host容器中。


## tomcat容器启动销毁的钩子ServletContextListener
* 例如spring容器监听类ContextLoaderListener就实现了这个接口
```
public class ContextLoaderListener extends ContextLoader implements ServletContextListener {
```

## 部署项目HostConfig类
```
protected void deployApps() {

        File appBase = host.getAppBaseFile();
        File configBase = host.getConfigBaseFile();
        String[] filteredAppPaths = filterAppPaths(appBase.list());
        // Deploy XML descriptors from configBase
        deployDescriptors(configBase, configBase.list());
        // Deploy WARs
        deployWARs(appBase, filteredAppPaths);
        // Deploy expanded folders
        deployDirectories(appBase, filteredAppPaths);

    }
```
### 执行部署任务DeployDirectory类实现了Runnable，交由ExecutorService线程池处理
```
protected void deployDirectories(File appBase, String[] files) {

  results.add(es.submit(new DeployDirectory(this, cn, dir)));
```


```
 private static class DeployDirectory implements Runnable {

        @Override
        public void run() {
            config.deployDirectory(cn, dir);
        }
    }
```

```
 protected void deployDirectory(ContextName cn, File dir) {
  host.addChild(context);
```
### 并且默认10s会执行一次 check()目录检查，已经部署的文件就跳过
```
 if (isServiced(cn.getName()) || deploymentExists(cn.getName()))
                    continue;
```


## web.xml和注解
### xml
```
<web-app xmlns="http://java.sun.com/xml/ns/javaee"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://java.sun.com/xml/ns/javaee 
  http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd"
  version="2.5">
    <listener>
        <listener-class>com.baeldung.servlets3.web.listeners.RequestListener</listener-class>
    </listener>
    <servlet>
        <servlet-name>uppercaseServlet</servlet-name>
        <servlet-class>com.baeldung.servlets3.web.servlets.UppercaseServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>uppercaseServlet</servlet-name>
        <url-pattern>/uppercase</url-pattern>
    </servlet-mapping>
    <filter>
        <filter-name>emptyParamFilter</filter-name>
        <filter-class>com.baeldung.servlets3.web.filters.EmptyParamFilter</filter-class>
    </filter>
    <filter-mapping>
        <filter-name>emptyParamFilter</filter-name>
        <url-pattern>/uppercase</url-pattern>
    </filter-mapping>
</web-app>
```

### 注解
* 不带xml打war包要配置
```
 <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <configuration>
                    <failOnMissingWebXml>false</failOnMissingWebXml>
                </configuration>
            </plugin>
        </plugins>
    </build>
```


* WebServlet
```
@WebServlet(urlPatterns = "/uppercase", name = "uppercaseServlet")
public class UppercaseServlet extends HttpServlet {
    public void doGet(HttpServletRequest request, HttpServletResponse response) 
      throws IOException {
        String inputString = request.getParameter("input").toUpperCase();
 
        PrintWriter out = response.getWriter();
        out.println(inputString);
    }
}
```
* WebFilter
```
@WebFilter(urlPatterns = "/uppercase")
public class EmptyParamFilter implements Filter {
    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse,
      FilterChain filterChain) throws IOException, ServletException {
        String inputString = servletRequest.getParameter("input");
 
        if (inputString != null && inputString.matches("[A-Za-z0-9]+")) {
            filterChain.doFilter(servletRequest, servletResponse);
        } else {
            servletResponse.getWriter().println("Missing input parameter");
        }
    }
 
    // implementations for other methods
}
```

* WebListener
```
@WebListener
public class RequestListener implements ServletRequestListener {
    @Override
    public void requestDestroyed(ServletRequestEvent event) {
        HttpServletRequest request = (HttpServletRequest)event.getServletRequest();
        if (!request.getServletPath().equals("/counter")) {
            ServletContext context = event.getServletContext();
            context.setAttribute("counter", (int) context.getAttribute("counter") + 1);
        }
    }
 
    // implementations for other methods
}
```


## ServletContainerInitializer机制(在web容器启动时为提供给第三方组件机会做一些初始化的工)
* Servlet容器启动会扫描，当前应用里面每一个jar包的ServletContainerInitializer的实现并运行
* 只扫jar包，不扫项目目录
* 会把@HandlesTypes注释里的类的实现类，作为第一个参数传进来
```
import javax.servlet.ServletContainerInitializer;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRegistration;
import javax.servlet.annotation.HandlesTypes;
import java.util.Set;

@HandlesTypes({ServiceI.class})
public class MyServletContainerInitializer implements ServletContainerInitializer {

    public void onStartup(Set<Class<?>> set, ServletContext servletContext) throws ServletException {
       
       //打印关注的类的实现类
        for(Class<?> clazz: set){
            System.out.println("-------------》"+clazz.getName());
        }


       //注册组件  ServletRegistration  
        ServletRegistration.Dynamic servlet = sc.addServlet("userServlet", new UserServlet());
        //配置servlet的映射信息
        servlet.addMapping("/user");
        
        
        //注册Listener
        sc.addListener(UserListener.class);
        
        //注册Filter  FilterRegistration
        FilterRegistration.Dynamic filter = sc.addFilter("userFilter", UserFilter.class);
        //配置Filter的映射信息
        filter.addMappingForUrlPatterns(EnumSet.of(DispatcherType.REQUEST), true, "/*");

    }
}
```
