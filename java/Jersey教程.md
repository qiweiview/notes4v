# jersey教程

## 依赖
* 这个版本依赖是可以，再高没有测试通过
```
 <dependencies>
        <!-- https://mvnrepository.com/artifact/javax.ws.rs/javax.ws.rs-api -->
        <dependency>
            <groupId>javax.ws.rs</groupId>
            <artifactId>javax.ws.rs-api</artifactId>
            <version>2.1.1</version>
        </dependency>


        <!-- https://mvnrepository.com/artifact/org.glassfish.jersey.core/jersey-server -->
        <dependency>
            <groupId>org.glassfish.jersey.core</groupId>
            <artifactId>jersey-server</artifactId>
            <version>2.19</version>
        </dependency>

        <dependency>
            <groupId>org.glassfish.jersey.containers</groupId>
            <artifactId>jersey-container-servlet</artifactId>
            <version>2.19</version>
        </dependency>
    </dependencies>
```

## web.xml配置
* [参考](https://stackoverflow.com/questions/45625925/what-exactly-is-the-resourceconfig-class-in-jersey-2)
### 配置一
* 类
```
public class JerseyApplication  extends ResourceConfig {

    public JerseyApplication() {
        packages("com.web");
    }
}
```
* 配置
```
<servlet>
        <servlet-name>jersey-servlet</servlet-name>
        <servlet-class>org.glassfish.jersey.servlet.ServletContainer</servlet-class>
        <init-param>
            <param-name>javax.ws.rs.Application</param-name>
            <param-value>com.web.JerseyApplication</param-value>
        </init-param>

    </servlet>

    <!-- Url mapping, usage-http://domainname:port/appname/api/ -->
    <servlet-mapping>
        <servlet-name>jersey-servlet</servlet-name>
        <url-pattern>/*</url-pattern>
    </servlet-mapping>
```
### 配置二
```
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://java.sun.com/xml/ns/javaee"
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee
http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
         id="WebApp_ID" version="3.0">
    <servlet>
        <servlet-name>jersey-serlvet</servlet-name>
        <servlet-class>org.glassfish.jersey.servlet.ServletContainer</servlet-class>
        <init-param>
            <param-name>jersey.config.server.provider.packages</param-name>
            <!-- Service or resources to be placed in the following package -->
            <param-value>com.web</param-value>
        </init-param>
    </servlet>

    <!-- Url mapping, usage-http://domainname:port/appname/api/ -->
    <servlet-mapping>
        <servlet-name>jersey-serlvet</servlet-name>
        <url-pattern>/*</url-pattern>
    </servlet-mapping>
    <welcome-file-list>
        <welcome-file>index.jsp</welcome-file>
        <welcome-file>index.html</welcome-file>
        <welcome-file>index.htm</welcome-file>
    </welcome-file-list>
</web-app>
```
### 无web.xml配置
```
@ApplicationPath("/*")
public class JerseyApplication  extends ResourceConfig {

    public JerseyApplication() {
        packages("com.web");
    }
}
```

## 请求流程
* [![D7toZV.png](https://s3.ax1x.com/2020/12/03/D7toZV.png)](https://imgchr.com/i/D7toZV)

## 过滤器
* 请求
```

@Provider
public class RequestFilter implements ContainerRequestFilter {
    public RequestFilter() {
        System.out.println("init MyContainerResponseFilter");
    }



    @Override
    public void filter(ContainerRequestContext containerRequestContext) throws IOException {
        containerRequestContext.getHeaders().add("view","happy");
    }
}
```
* 响应
```
@Provider
public class ResponseFilter implements ContainerResponseFilter {
    public ResponseFilter() {
        System.out.println("init MyContainerResponseFilter");
    }

    @Override
    public void filter(ContainerRequestContext containerRequestContext, ContainerResponseContext containerResponseContext) throws IOException {
        containerResponseContext.getHeaders().add("X-Powered-By", "Jersey :-)");

    }
}
```

## 拦截器
* 读取
```
@Provider
public class MReaderInterceptor implements ReaderInterceptor {
    @Override
    public Object aroundReadFrom(ReaderInterceptorContext readerInterceptorContext) throws IOException, WebApplicationException {
        System.out.println("go to ReaderInterceptor");
        return readerInterceptorContext.proceed();
    }
}
```
* 写出
```
@Provider
public class WReaderInterceptor implements WriterInterceptor {
    @Override
    public void aroundWriteTo(WriterInterceptorContext writerInterceptorContext) throws IOException, WebApplicationException {
        System.out.println("go to WriterInterceptor");
        writerInterceptorContext.proceed();
    }
}

```

## 请求报文复合赋值
* 使用@BeanParam注解
* 支持多对象
```

    @POST
    @Path("/{name}")
    public String save(@BeanParam User user) {
       return "save with Integral "+user;
    }
```
* 对象
```
public class User {

    @PathParam(value = "name")
    private String name;

    @QueryParam("age")
    private int age;

    @HeaderParam("User-Agent")
    private String userAgent;

```

## 请求头获取
```
    @POST
    @Path("/{name}")
    public String save(@Context HttpHeaders hh) {
        MultivaluedMap<String, String> headerParams = hh.getRequestHeaders();
        Map<String, Cookie> pathParams = hh.getCookies();
       return "save with header "+headerParams+"and cookie "+pathParams;
    }
```

## 参数获取
### URL参数获取（地址参数和查询参数）
* 可以设置默认值
```
 @POST
    @Path("/{name}")
    public String save(@PathParam("name")String name,@DefaultValue("18")@QueryParam("age") int age) {
        return "save name "+name+" age "+age;
    }
```
* 使用@Context注解
```
    @POST
    @Path("/{name}")
    public String save(@Context UriInfo ui) {
        MultivaluedMap<String, String> queryParams = ui.getQueryParameters();
        MultivaluedMap<String, String> pathParams = ui.getPathParameters();
        return "save data with "+queryParams+" and "+pathParams;
    }
```

### 表单参数获取
* 使用@FormParam
```
 @POST
    @Consumes("application/x-www-form-urlencoded")
    public String save(@FormParam("name") String name) {
        return "save name "+name+" age ";
    }
```
* 使用MultivaluedMap
```
@POST
@Consumes("application/x-www-form-urlencoded")
public void post(MultivaluedMap<String, String> formParams) {
    // Store the message
}
```

## 映射

### 媒体类型映射
* 可用字符串，虽然不合规
* @Produces响应的媒体类型
* @Consumes请求的媒体类型
```
 @GET
    @Produces(MediaType.TEXT_PLAIN)
    @Consumes(MediaType.TEXT_PLAIN)
    public String sayPlainTextHello() {
        return "Hello Jersey";
    }
```

### 请求方法映射
```
  @DELETE
    @Path("/{name}")
    public String delete(@PathParam("name")String name) {
        return "delete name "+name;
    }
```


## 支持multipart/form-data
* 依赖
```
 <dependency>
            <groupId>org.glassfish.jersey.media</groupId>
            <artifactId>jersey-media-multipart</artifactId>
            <version>2.19</version>
        </dependency>
```

* 配置
```
 <init-param>
            <param-name>jersey.config.server.provider.classnames</param-name>
            <param-value>org.glassfish.jersey.media.multipart.MultiPartFeature</param-value>
        </init-param>
```

* 调用
```
 @POST
    @Path("/{name}")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    public String save(FormDataMultiPart formDataMultiPart) {
        Map<String, List<FormDataBodyPart>> fields = formDataMultiPart.getFields();
        fields.forEach((k,v)->{
            System.out.println(k);
        });

        return "save with Integral ";
    }
```

