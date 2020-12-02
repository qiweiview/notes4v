# Jetty教程

## 应用内嵌入

* 依赖
```
<!-- https://mvnrepository.com/artifact/org.eclipse.jetty/jetty-server -->
<dependency>
    <groupId>org.eclipse.jetty</groupId>
    <artifactId>jetty-server</artifactId>
    <version>9.4.35.v20201120</version>
</dependency>

```

### Servlet应用
* 启动
```
        Server server = new Server(7070);
        ServletContextHandler handler = new ServletContextHandler(server, "/example");
        handler.addServlet(ExampleServlet.class, "/");
        server.start();
```

* servlet
```

import org.eclipse.jetty.http.HttpStatus;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class ExampleServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws  IOException {
        resp.setStatus(HttpStatus.OK_200);
        resp.getWriter().println("EmbeddedJetty");
    }
}
```

### SpringMvc整合
* 依赖
```

    <dependencies>

        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-webmvc</artifactId>
            <version>5.2.9.RELEASE</version>
        </dependency>

        <!-- https://mvnrepository.com/artifact/org.eclipse.jetty/jetty-server -->
        <dependency>
            <groupId>org.eclipse.jetty</groupId>
            <artifactId>jetty-server</artifactId>
            <version>9.4.32.v20200930</version>
        </dependency>

        <!-- https://mvnrepository.com/artifact/org.eclipse.jetty/jetty-servlet -->
        <dependency>
            <groupId>org.eclipse.jetty</groupId>
            <artifactId>jetty-servlet</artifactId>
            <version>9.4.32.v20200930</version>
        </dependency>

        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
            <version>2.9.4</version>
        </dependency>

    </dependencies>

```

* 启动
```
 public void run() throws Exception {
        Server server = new Server(DEFAULT_PORT);
        AnnotationConfigWebApplicationContext applicationContext = new AnnotationConfigWebApplicationContext();
        applicationContext.register(AppConfiguration.class);
        ServletContextHandler servletContextHandler = servletContextHandler(applicationContext);
        server.setHandler(servletContextHandler);
        server.start();
        server.join();
    }

    private ServletContextHandler servletContextHandler(WebApplicationContext context) {
        ServletContextHandler handler = new ServletContextHandler();
        handler.setContextPath("/");
        handler.addServlet(new ServletHolder(new DispatcherServlet(context)), "/*");
        handler.addEventListener(new ContextLoaderListener(context));
        return handler;
    }
```

* 处理器
```

import org.springframework.context.annotation.ComponentScan;


@ComponentScan(basePackages = { "com" })
public class AppConfiguration {
}
```
