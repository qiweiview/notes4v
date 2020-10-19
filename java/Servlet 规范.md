# Servlet 规范

***Servlet规范描述了HTTP请求及响应处理过程相关的对象及其作用***

## 生命周期
* Servlet的生命周期主要包括加载实例化、初始化、处理客户端请求、销毁。
* 加载实例化主要由Web容器完成，而其他三个阶段则对应Servlet的init、service和destroy方法

## 会话
* Servlet没有提出协议无关的会话规定，而是每个通信协议自己规定，HTTP对应的会话接口是HttpSession
* Cookie是常用的会话跟踪机制，其中Cookie的标准名字必须为JSESSIONID
* 另外一种会话跟踪机制则是URL重写，即在URL后面添加一个jsessionid参数，***当支持Cookie和SSL会话的情况下，不应该使用URL重写作为会话跟踪机制***
* 会话ID通过调用HttpSession.getId()获取，且能在创建后通过调用HttpServletRequest. changeSessionId()改变。***HttpSession对象必须限定在ServletContext级别，会话里面的属性不能在不同ServletContext之间共享***
* 如果某些对象想要在保存到会话或从会话中移除时得到通知，可以让某个对象实现HttpSessionBindingListener接口，里面的valueBound和valueUnbound分别会在对应时刻触发


## 涉及主要接口

* Servle：Servlet 的核心，具体 Servlet 中方法的处理规范，Servlet 的生命周期等。
```
public interface Servlet {
    void init(ServletConfig var1) throws ServletException;

    ServletConfig getServletConfig();

    void service(ServletRequest var1, ServletResponse var2) throws ServletException, IOException;

    String getServletInfo();

    void destroy();
}
```

* ServletConfig:  封装了对应的 Servlet 的相关配置信息，如 Servlet 的初始参数以及 Servlet 所在的上下文对象，即ServletContext。ServletConfig 中的属性通常在 Servlet 初始化时进行初始化。
```
public interface ServletConfig {
    String getServletName();

    ServletContext getServletContext();

    String getInitParameter(String var1);

    Enumeration getInitParameterNames();
}
```

* ***ServletRequest***:  
 1. 封装了所有来自 client 端的请求信息，如请求参数、cookie、attribute、请求类型、请求方式（安全还是非安全等）等，同时 ServletRequest 中的还需要明确指定部分属性，如 请求内容的编码（可以自己设定）等。
 2. ServletRequest接口的对象只在Servlet的service方法或过滤器的doFilter方法作用域内有效，除非启用了异步处理以调用ServletRequest接口对象的startAsync方法，此时request对象会一直有效，直到调用AsyncContext的complete方法。
 3. 另外，Web容器通常会出于性能原因而不销毁ServletRequest接口的对象，而是重复利用ServletRequest接口对象

* ***ServletContext***: 
ServletContext接口定义了运行所有Servlet的Web应用的视图。其提供的内容包括以下几个部分:
 1. 某个Web应用的Servlet全局存储空间，某Web应用对应的所有Servlet共有的各种资源和功能的访问。

 2. 获取Web应用的部署描述配置文件的方法，例如getInitParameter和getInitParameterNames。

 3. 添加Servlet到ServletContext里面的方法，例如addServlet。

 4. 添加Filter（过滤器）到ServletContext里面的方法，例如addFilter。

 5. 添加Listener（监听器）到ServletContext里面的方法，例如addListener。

 6. 全局的属性保存和获取功能，例如setAttribute、getAttribute、getAttributeNames和removeAttribute等

 7. 访问Web应用静态内容的方法，例如getResource和getResourceAsStream，以路径作为参数进行查询，此参数要以“/”开头，相对于Web应用上下文的根或相对于Web应用WEB-INF/lib目录下jar包的META-INF/resources。

所有Servlet及它们使用的类需要由一个单独的类加载器加载。每个实现ServletContext接口的对象都需要一个临时存储目录，Servlet容器必须为每个ServletContext分配一个临时目录，并可在ServletContext接口中通过javax.servlet.context.tempdir属性获取该目录

* ***ServletResponse***:  封装了 server 端资源到 client 端的所有相关信息，如 资源传输的 buffer 信息、响应的 url 地址信息、资源的编码信息等。
 1. 为了提高效率，一般ServletResponse接口对响应提供了输出缓冲
 2. ServletResponse接口对应HTTP的实现对象为HttpServletResponse，可以通过setHeader和addHeader方法向HttpServletResponse中添加头部；可以通过sendRedirect将客户端重定向到另外一个地址；可以通过sendError将错误信息输出到客户端
 3. 当ServletResponse接口关闭时，缓冲区中的内容必须立即刷新到客户端，ServletResponse接口只在Servlet的service方法或过滤器的doFilter方法的作用域内有效，除非它关联的ServletResponse接口调用了startAsync方法启用异步处理，此时ServletResponse接口会一直有效，直到调用AsyncContext的complete方法。
 4. 另外，Web容器通常会出于性能原因而不销毁ServletResponse接口对象，而是重复利用ServletResponse接口对象

* ***Filter***
Filter接口允许Web容器对请求和响应做统一处理。例如，统一改变HTTP请求内容和响应内容，它可以作用于某个Servlet或一组Servlet
 1. 当请求进来时，获取第一个过滤器并调用doFilter方法，接着传入ServletRequest对象、ServletResponse对象及过滤器链（FilterChain）, doFilter方法负责过滤器链中下一个实体的doFilter方法调用
 2. 当容器要移除某过滤器时必须先调用过滤器的destroy方法

* ***ServletInputStream/BufferedReader***:  读取 ServletRequest 所封装的信息的 I/O 接口，ServletInputStream，采用字节流的方式读取；BufferedReader，采用字符流的方式读取。

* ***ServletOutputSteam/PrintWriter***:  将资源写入到 client 的 I/O 接口。ServletOutputSteam 采用字节流的方式进行写入；PrintWriter 采用字符流的方式进行写入。

* ***GenericServlet***:  抽象类，它定义了一个 Servlet 的基本实现，虽然它是 Servlet 的基本实现，但是它是与协议无关的（即不依赖于 http 协议，也不依赖于其它应用层协议）。一般，基于协议的 Servlet，如 HttpServlet，通常会继承该类。

* ***RequestDispatcher***:  我们在搭建 web 应用的过程中，可能会有这样的需求： 在当前 Servlet中处理完成后，需要导向（forward）另外一个 Servlet 或静态资源（html或text等），或者 是在当前 Servlet 的处理过程中，需要将其它的资源包含（include）到当前的 Servlet 资源里来。而 RequestDisaptcher 接口中的 forward 和 inluce 方法就提供了实现以上两个需求的机制。

### GenericServlet
```
# 类
public abstract class GenericServlet implements Servlet, ServletConfig, Serializable

# 抽象方法
public abstract void service(ServletRequest var1, ServletResponse var2) throws ServletException, IOException;
```

### GenericServlet
```
# 类
public abstract class HttpServlet extends GenericServlet implements Serializable 
```
* 对抽象方法实现
```
protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String method = req.getMethod();
        long lastModified;
        if (method.equals("GET")) {
            lastModified = this.getLastModified(req);
            if (lastModified == -1L) {
                this.doGet(req, resp);
            } else {
                long ifModifiedSince = req.getDateHeader("If-Modified-Since");
                if (ifModifiedSince < lastModified / 1000L * 1000L) {
                    this.maybeSetLastModified(resp, lastModified);
                    this.doGet(req, resp);
                } else {
                    resp.setStatus(304);
                }
            }
        } else if (method.equals("HEAD")) {
            lastModified = this.getLastModified(req);
            this.maybeSetLastModified(resp, lastModified);
            this.doHead(req, resp);
        } else if (method.equals("POST")) {
            this.doPost(req, resp);
        } else if (method.equals("PUT")) {
            this.doPut(req, resp);
        } else if (method.equals("DELETE")) {
            this.doDelete(req, resp);
        } else if (method.equals("OPTIONS")) {
            this.doOptions(req, resp);
        } else if (method.equals("TRACE")) {
            this.doTrace(req, resp);
        } else {
            String errMsg = lStrings.getString("http.method_not_implemented");
            Object[] errArgs = new Object[]{method};
            errMsg = MessageFormat.format(errMsg, errArgs);
            resp.sendError(501, errMsg);
        }

    }
```





