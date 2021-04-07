# Spring Session 教程
## 相关原理

### tomcat session存储位置
* Request里找不到就会到对应的ManagerBase实现类中的map里找
```
public abstract class ManagerBase extends LifecycleMBeanBase implements Manager {
  /**
     * The set of currently active Sessions for this Manager, keyed by
     * session identifier.
     */
    protected Map<String, Session> sessions = new ConcurrentHashMap<>();
    
    @Override
    public Session findSession(String id) throws IOException {
        if (id == null) {
            return null;
        }
        return sessions.get(id);
    }
```

### tomcat 默认的HttpServletRequest实现是Request类
* 调用getSession()方法

```
/**
 * Wrapper object for the Coyote request.
 *
 * @author Remy Maucherat
 * @author Craig R. McClanahan
 */
public class Request implements HttpServletRequest {

    @Override
    public HttpSession getSession(boolean create) {
        Session session = doGetSession(create);//关键方法
        if (session == null) {
            return null;
        }

        return session.getSession();
    }
```
* doGetSession方法(核心)
```
 protected Session doGetSession(boolean create) {

        // There cannot be a session if no context has been assigned yet
        Context context = getContext();
        if (context == null) {
            return null;
        }

        // Return the current session if it exists and is valid
        if ((session != null) && !session.isValid()) {
            session = null;
        }
        if (session != null) {//对象中缓存属性有则直接返回
            return session;
        }

        // Return the requested session if it exists and is valid
        Manager manager = context.getManager();
        if (manager == null) {
            return null;      // Sessions are not supported
        }
        if (requestedSessionId != null) {
            try {
                session = manager.findSession(requestedSessionId);//id 不为空则在ManagerBase实现类中调用方法找
            } catch (IOException e) {
                if (log.isDebugEnabled()) {
                    log.debug(sm.getString("request.session.failed", requestedSessionId, e.getMessage()), e);
                } else {
                    log.info(sm.getString("request.session.failed", requestedSessionId, e.getMessage()));
                }
                session = null;
            }
            if ((session != null) && !session.isValid()) {
                session = null;
            }
            if (session != null) {
                session.access();
                return session;
            }
        }

        // Create a new session if requested and the response is not committed
        if (!create) {
            return null;
        }
        boolean trackModesIncludesCookie =
                context.getServletContext().getEffectiveSessionTrackingModes().contains(SessionTrackingMode.COOKIE);
        if (trackModesIncludesCookie && response.getResponse().isCommitted()) {
            throw new IllegalStateException(sm.getString("coyoteRequest.sessionCreateCommitted"));
        }

        // Re-use session IDs provided by the client in very limited
        // circumstances.
        String sessionId = getRequestedSessionId();
        if (requestedSessionSSL) {
            // If the session ID has been obtained from the SSL handshake then
            // use it.
        } else if (("/".equals(context.getSessionCookiePath())
                && isRequestedSessionIdFromCookie())) {
            /* This is the common(ish) use case: using the same session ID with
             * multiple web applications on the same host. Typically this is
             * used by Portlet implementations. It only works if sessions are
             * tracked via cookies. The cookie must have a path of "/" else it
             * won't be provided for requests to all web applications.
             *
             * Any session ID provided by the client should be for a session
             * that already exists somewhere on the host. Check if the context
             * is configured for this to be confirmed.
             */
            if (context.getValidateClientProvidedNewSessionId()) {
                boolean found = false;
                for (Container container : getHost().findChildren()) {
                    Manager m = ((Context) container).getManager();
                    if (m != null) {
                        try {
                            if (m.findSession(sessionId) != null) {
                                found = true;
                                break;
                            }
                        } catch (IOException e) {
                            // Ignore. Problems with this manager will be
                            // handled elsewhere.
                        }
                    }
                }
                if (!found) {
                    sessionId = null;
                }
            }
        } else {
            sessionId = null;
        }
        session = manager.createSession(sessionId);

        // Creating a new session cookie based on that session
        if (session != null && trackModesIncludesCookie) {
            Cookie cookie = ApplicationSessionCookieConfig.createSessionCookie(
                    context, session.getIdInternal(), isSecure());

            response.addSessionCookieInternal(cookie);
        }

        if (session == null) {
            return null;
        }

        session.access();
        return session;
    }
```
### tomcat session id 生成算法
```

public class StandardSessionIdGenerator extends SessionIdGeneratorBase {

    @Override
    public String generateSessionId(String route) {

        byte random[] = new byte[16];
        int sessionIdLength = getSessionIdLength();

        // Render the result as a String of hexadecimal digits
        // Start with enough space for sessionIdLength and medium route size
        StringBuilder buffer = new StringBuilder(2 * sessionIdLength + 20);

        int resultLenBytes = 0;

        while (resultLenBytes < sessionIdLength) {
            getRandomBytes(random);
            for (int j = 0;
            j < random.length && resultLenBytes < sessionIdLength;
            j++) {
                byte b1 = (byte) ((random[j] & 0xf0) >> 4);
                byte b2 = (byte) (random[j] & 0x0f);
                if (b1 < 10)
                    buffer.append((char) ('0' + b1));
                else
                    buffer.append((char) ('A' + (b1 - 10)));
                if (b2 < 10)
                    buffer.append((char) ('0' + b2));
                else
                    buffer.append((char) ('A' + (b2 - 10)));
                resultLenBytes++;
            }
        }

        if (route != null && route.length() > 0) {
            buffer.append('.').append(route);
        } else {
            String jvmRoute = getJvmRoute();
            if (jvmRoute != null && jvmRoute.length() > 0) {
                buffer.append('.').append(jvmRoute);
            }
        }

        return buffer.toString();
    }
}
```

### spring session 实现

* session id 生成方式，redis的实现是直接UUID,并未使用特殊算法
```
  final class RedisSession implements ExpiringSession {
        private final MapSession cached;//内嵌了一个类
        private Long originalLastAccessTime;
        private Map<String, Object> delta;
        private boolean isNew;
        private String originalPrincipalName;
        
        
    RedisSession() {
            this(new MapSession());
            this.delta.put("creationTime", this.getCreationTime());
            this.delta.put("maxInactiveInterval", this.getMaxInactiveIntervalInSeconds());
            this.delta.put("lastAccessedTime", this.getLastAccessedTime());
            this.isNew = true;
            this.flushImmediateIfNecessary();
        }      
```

```

public final class MapSession implements ExpiringSession, Serializable {
    public static final int DEFAULT_MAX_INACTIVE_INTERVAL_SECONDS = 1800;
    private String id;
    private Map<String, Object> sessionAttrs;
    private long creationTime;
    private long lastAccessedTime;
    private int maxInactiveInterval;
    private static final long serialVersionUID = 7160779239673823561L;

    public MapSession() {
        this(UUID.randomUUID().toString());
    }
    
    public MapSession(String id) {
        this.sessionAttrs = new HashMap();
        this.creationTime = System.currentTimeMillis();
        this.lastAccessedTime = this.creationTime;
        this.maxInactiveInterval = 1800;
        this.id = id;
    }
```

* 通过过滤器实现,包装HttpServletRequest，重写getSession方法，改成从外部存储里拿
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
