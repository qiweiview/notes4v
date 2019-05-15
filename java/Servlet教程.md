# Servlet教程

引入Tomcat下的serlvlet.jar的包



## 异步请求(需要servlet-api.jar)
servlet3.0后使用注解配置
```
import javax.servlet.AsyncContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.PushBuilder;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.util.concurrent.TimeUnit;

@WebServlet(name = "MyHttpServlet",urlPatterns = "/servlet", asyncSupported = true)  // url路径
public class MyHttpServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {


        PushBuilder pushBuilder = request.newPushBuilder();

        AsyncContext asyncContext = request.startAsync();
        asyncContext.addListener(new MyAsyncListener());

        asyncContext.start(() -> {
            try {
                TimeUnit.SECONDS.sleep(1);
                asyncContext.getResponse().getWriter().write("Hello View!"+ LocalDateTime.now());
                asyncContext.complete();
            } catch (IOException e) {
                e.printStackTrace();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });

        System.out.println("run here");
        response.getWriter().print("run here\n\r");

    }


    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        try {
            TimeUnit.SECONDS.sleep(3);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        PrintWriter pw = resp.getWriter();
        pw.print("hello post request!");
        pw.flush();
        pw.close();
    }
}

```


## 异步监听
```
import javax.servlet.AsyncEvent;
import javax.servlet.AsyncListener;
import java.io.IOException;

public class MyAsyncListener implements AsyncListener {
    @Override
    public void onComplete(AsyncEvent asyncEvent) throws IOException {
        System.out.println("MyAsyncListener onComplete");
    }

    @Override
    public void onTimeout(AsyncEvent asyncEvent) throws IOException {
        System.out.println("MyAsyncListener onTimeout");
    }

    @Override
    public void onError(AsyncEvent asyncEvent) throws IOException {
        System.out.println("MyAsyncListener onError");
    }

    @Override
    public void onStartAsync(AsyncEvent asyncEvent) throws IOException {
        System.out.println("onStartAsync");
    }
}

```

## 容器监听
```
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener("This is only a demo listener")
public class MyServletContextListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent servletContextEvent) {
        System.out.println("contextInitialized");
    }

    @Override
    public void contextDestroyed(ServletContextEvent servletContextEvent) {
        System.out.println("contextDestroyed");
    }
}
```

## 过滤器

#### HttpFilter（继承GenericFilter）
```
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebFilter(servletNames = {"MyHttpServlet"},filterName="MyHttpFilter",asyncSupported = true)
public class MyHttpFilter extends HttpFilter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        System.out.println("MyHttpFilter doFilter");
        chain.doFilter(request, response);
    }

    /**
     * 上面一个方法优先级比较高
     * @param request
     * @param response
     * @param chain
     * @throws IOException
     * @throws ServletException
     */
    @Override
    protected void doFilter(HttpServletRequest request, HttpServletResponse response, FilterChain chain) throws IOException, ServletException {
        System.out.println("MyHttpFilter doFilter 4 HTTP");
        chain.doFilter(request, response);
    }


}

```

#### GenericFilter(实现Filter接口)
```
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import java.io.IOException;

@WebFilter(servletNames = {"MyHttpServlet"},filterName="MyGenericFilter",asyncSupported = true)
public class MyGenericFilter extends GenericFilter {

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        System.out.println("MyGenericFilter doFilter");
        filterChain.doFilter(servletRequest,servletResponse);
    }

    @Override
    public void destroy() {

    }
}

```


#### Filter
```
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebFilter(servletNames = {"MyHttpServlet"},filterName="MyFilter",asyncSupported = true)
public class MyFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        Logger.getGlobal().info("init");
    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        System.out.println("MyFilter doFilter");
        filterChain.doFilter(servletRequest,servletResponse);
    }

    @Override
    public void destroy() {
        System.out.println("destroy");
    }
}

```


## Websocket(需要websocket-api.jar)
```
import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@ServerEndpoint("/webSocketServlet")
public class WebSocketServlet {
    private static final Map<String, Session> sessionMap = new HashMap<>();

    @OnOpen
    public void onOpen(Session session) throws IOException {
        String id = session.getId();
        if (!sessionMap.containsKey(id)) {
            sessionMap.put(id, session);
        }
        StringBuilder stringBuilder=new StringBuilder("在线用户有：\n\r");
        sessionMap.forEach((k,v)->stringBuilder.append(k+"\n\r"));
        session.getBasicRemote().sendText("登录成功，您的帐号为：" + id+"\n\r"+stringBuilder);
    }
    @OnClose
    public void onClose(Session session) {
        sessionMap.remove(session.getId());
    }

    @OnMessage
    public void onMessage(String s, Session session) throws IOException {


        if (s.indexOf(":") == -1) {
            session.getBasicRemote().sendText("目标参数缺失");
        }
        String[] split = s.split(":");
        String target = split[0];
        String message = split[1];
        Session targetSession = sessionMap.get(target);
        if (targetSession == null) {
            session.getBasicRemote().sendText("目标" + target + "不在线");
        } else {
            targetSession.getBasicRemote().sendText("收到来自" + session.getId() + "消息：" + message);
        }
    }

    @OnError
    public void onError(Throwable t) {
        t.printStackTrace();
        System.out.println("onError::" + t.getMessage());
    }
}

```
### websocket jsp页面
```
<%--
  Created by IntelliJ IDEA.
  User: liuqiwei
  Date: 2019/4/17
  Time: 16:39
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
<div>
    目标<input type="text" id="target">
    消息<input type="text" id="message">
    <button onclick="sendMessage()">发送</button>
</div>
<div style="margin-top: 20px;">
    <textarea  style="resize:none;width: 400px;height: 200px" id="result"></textarea>
</div>

<script>
    function sendMessage() {
        ws.send(document.getElementById("target").value+":"+document.getElementById("message").value);
    }

    // 初始化一个 WebSocket 对象
    let ws = new WebSocket("ws://172.16.28.120:8080/webSocketServlet");

    // 建立 web socket 连接成功触发事件
    ws.onopen = function () {
        // 使用 send() 方法发送数据
    };

    // 接收服务端数据时触发事件
    ws.onmessage = function (evt) {
        let received_msg = evt.data;
        document.getElementById("result").innerHTML += "\n\r"+evt.data;
        console.log("数据已接收0--->"+evt.data);
    };

    // 断开 web socket 连接成功触发事件
    ws.onclose = function () {
        console.log("连接已关闭...");
    };
</script>
</body>
</html>

```


### 找不到jsp文件需要配置
![image.png](https://i.loli.net/2019/04/18/5cb8266293507.png)



