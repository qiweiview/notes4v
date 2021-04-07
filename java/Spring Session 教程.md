# Spring Session 教程
## 原理

* 通过过滤器实现
```
public class SessionRepositoryFilter<S extends Session> extends OncePerRequestFilter {

  @Override
  protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) {
    /** 替换 request */
    SessionRepositoryRequestWrapper wrappedRequest = new SessionRepositoryRequestWrapper(request, response, this.servletContext);
    /** 替换 response */
    SessionRepositoryResponseWrapper wrappedResponse = new SessionRepositoryResponseWrapper(wrappedRequest, response);
    /** try-finally，finally 必定执行 */
    try {
      /** 执行后续过滤器链 */
      filterChain.doFilter(wrappedRequest, wrappedResponse);
    } finally {
      /** 后续过滤器链执行完毕，提交 session，用于存储 session 信息并返回 set-cookie 信息 */
      wrappedRequest.commitSession();
    }
  }
}
```

* response封装
```
private final class SessionRepositoryResponseWrapper extends OnCommittedResponseWrapper {

  SessionRepositoryResponseWrapper(SessionRepositoryRequestWrapper request, HttpServletResponse response) {
    super(response);
    this.request = request;
  }

  @Override
  protected void onResponseCommitted() {
    /** response 提交后提交 session */
    this.request.commitSession();
  }
}
```

* request封装
```
private final class SessionRepositoryRequestWrapper extends HttpServletRequestWrapper {

  private SessionRepositoryRequestWrapper(HttpServletRequest request, HttpServletResponse response, ServletContext servletContext) {
    super(request);
    this.response = response;
    this.servletContext = servletContext;
  }

  /**
   * 将 sessionId 写入 reponse，并持久化 session
   */
  private void commitSession() {
    /** 获取当前 session 信息 */
    S session = getCurrentSession().getSession();
    /** 持久化 session */
    SessionRepositoryFilter.this.sessionRepository.save(session);
    /** reponse 写入 sessionId */
    SessionRepositoryFilter.this.httpSessionIdResolver.setSessionId(this, this.response, session.getId());
  }

  /**
   * 重写 HttpServletRequest 的 getSession 方法
   */
  @Override
  public HttpSessionWrapper getSession(boolean create) {
    /** 从持久化中查询 session */
    S requestedSession = getRequestedSession();
    /** session 存在，直接返回 */
    if (requestedSession != null) {
      currentSession = new HttpSessionWrapper(requestedSession, getServletContext());
      currentSession.setNew(false);
      return currentSession;
    }
    /** 设置不创建，返回空 */
    if (!create) {
      return null;
    }
    /** 创建 session 并返回 */
    S session = SessionRepositoryFilter.this.sessionRepository.createSession();
    currentSession = new HttpSessionWrapper(session, getServletContext());
    return currentSession;
  }

  /**
   * 从 repository 查询 session
   */
  private S getRequestedSession() {
    /** 查询 sessionId 信息 */
    List<String> sessionIds = SessionRepositoryFilter.this.httpSessionIdResolver.resolveSessionIds(this);
    /** 遍历查询 */
    for (String sessionId : sessionIds) {
      S session = SessionRepositoryFilter.this.sessionRepository.findById(sessionId);
      if (session != null) {
        this.requestedSession = session;
        break;
      }
    }
    /** 返回持久化 session */
    return this.requestedSession;
  }

  /**
   * http session 包装器
   */
  private final class HttpSessionWrapper extends HttpSessionAdapter<S> {

    HttpSessionWrapper(S session, ServletContext servletContext) {
      super(session, servletContext);
    }

    @Override
    public void invalidate() {
      super.invalidate();
      /** session 不合法，从存储中删除信息 */
      SessionRepositoryFilter.this.sessionRepository.deleteById(getId());
    }
  }
}
```
## 依赖
```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>org.spring</groupId>
    <artifactId>learn-spring-session</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>
    <name>First Learn Spring Session</name>

    <properties>
        <jdk.version>1.7</jdk.version>
        <spring.version>4.3.4.RELEASE</spring.version>
        <spring-session.version>1.3.1.RELEASE</spring-session.version>
    </properties>

    <dependencies>
        <!-- https://mvnrepository.com/artifact/javax.servlet/servlet-api  -->
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>javax.servlet-api</artifactId>
            <version>3.0.1</version>
            <scope>provided</scope>
        </dependency>

        <dependency>
            <groupId>org.springframework.session</groupId>
            <artifactId>spring-session-data-redis</artifactId>
            <version>${spring-session.version}</version>
            <type>pom</type>
        </dependency>

        <dependency>
            <groupId>biz.paluch.redis</groupId>
            <artifactId>lettuce</artifactId>
            <version>3.5.0.Final</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-web</artifactId>
            <version>${spring.version}</version>
        </dependency>


    </dependencies>



</project>
```

## 配置
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
           http://www.springframework.org/schema/beans/spring-beans-4.3.xsd
           http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-4.3.xsd">

    <context:annotation-config/>


    <!--创建一个Spring Bean的名称springSessionRepositoryFilter实现过滤器。
    筛选器负责将HttpSession实现替换为Spring会话支持。在这个实例中，Spring会话得到了Redis的支持。-->
    <bean class="org.springframework.session.data.redis.config.annotation.web.http.RedisHttpSessionConfiguration"/>
    <!--创建了一个RedisConnectionFactory，它将Spring会话连接到Redis服务器。我们配置连接到默认端口(6379)上的本地主机！-->
    <bean class="org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory"/>

</beans>
```

## web.xml
```
<?xml version="1.0" encoding="UTF-8"?>
<web-app version="2.4"
         xmlns="http://java.sun.com/xml/ns/j2ee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd">

    <context-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>classpath*:*xml</param-value>
    </context-param>

    <listener>
        <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
    </listener>


    <!--DelegatingFilterProxy将查找一个Bean的名字springSessionRepositoryFilter丢给一个过滤器。为每个请求
    调用DelegatingFilterProxy, springSessionRepositoryFilter将被调用-->
    <filter>
        <filter-name>springSessionRepositoryFilter</filter-name>
        <filter-class>org.springframework.web.filter.DelegatingFilterProxy</filter-class>
    </filter>


    <filter-mapping>
        <filter-name>springSessionRepositoryFilter</filter-name>
        <url-pattern>/*</url-pattern>
        <dispatcher>REQUEST</dispatcher>
        <dispatcher>ERROR</dispatcher>
    </filter-mapping>


    <welcome-file-list>
        <welcome-file>index.jsp</welcome-file>
    </welcome-file-list>

</web-app>
```

## 测试
```
package com;

import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/session")
public class SessionServlet extends HttpServlet {

    @Override
    public void service(ServletRequest req, ServletResponse res) throws ServletException, IOException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        System.out.println(request.getRemoteAddr());
        System.out.print(request.getRemoteHost() + " : " + request.getRemotePort());

        String sesssionID = request.getSession().getId();
        System.out.println("-----------tomcat2---sesssionID-------" + sesssionID);

        String testKey = (String)request.getSession().getAttribute("testKey");
        System.out.println("-----------tomcat2-testKey-------" + testKey);

        PrintWriter out = null;
        try {
            out = response.getWriter();
            out.append("tomcat2 ---- sesssionID : " + sesssionID);
            out.append("{\"name\":\"dufy2\"}" + "\n");
            out.append("tomcat2 ----- testKey : " + testKey + "\n");
        }catch (Exception e){
            e.printStackTrace();
        }finally {
            if(out != null){
                out.close();
            }
        }

    }

}
```

```
package com;

import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    public void service(ServletRequest req, ServletResponse res) throws ServletException, IOException {


        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;


        request.getSession().setAttribute("testKey", "742981086@qq.com");

        request.getSession().setMaxInactiveInterval(10*1000);

        response.sendRedirect(request.getContextPath() + "/session");

    }

}
```
