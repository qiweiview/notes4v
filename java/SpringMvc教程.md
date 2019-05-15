# Springmvc教程
**Spring的模型-视图-控制器（MVC）框架是围绕一个DispatcherServlet来设计的**

**如果你确实不想使用Spring的Web MVC，但又希望能从Spring提供的一些解决方案中受益，那么将你所使用的框架和Spring进行集成也很容易。只需要在ContextLoaderListener中启动一个Spring的根应用上下文（root application context），然后你就可以在任何action对象中通过其ServletContext属性（或通过Spring对应的helper方法）取得。不需要**

```
<!--上下文监听，用来启动Spring-->
    <listener>
        <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
    </listener>


    <!--没写默认会去找/WEB-INF/applicationContext.xml-->
    <context-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>classpath:Beans.xml</param-value>
    </context-param>
```

## DispatcherServlet
* Spring MVC框架，与其他很多web的MVC框架一样：请求驱动
* DispatcherServlet其实就是个Servlet（它继承自HttpServlet基类），同样也需要在你web应用的web.xml配置文件下声明
* Spring Web MVC的DispatcherServlet处理请求的工作流:
![image.png](https://i.loli.net/2019/03/20/5c91ab305a828.png)

* 你需要在web.xml文件中把你希望DispatcherServlet处理的请求映射到对应的URL上去。这就是标准的Java EE Servlet配置；下面的代码就展示了对DispatcherServlet和路径映射的声明：


```xml
// 例子中，所有路径以/example开头的请求都会被名字为example的DispatcherServlet处理
<web-app>
   <servlet>
        <servlet-name>HelloWeb</servlet-name>
        <servlet-class>
            org.springframework.web.servlet.DispatcherServlet
        </servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>classpath:HelloWeb-servlet.xml</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>

    <servlet-mapping>
        <servlet-name>HelloWeb</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>
</web-app>
```

* Servlet 3.0+的环境下，你还可以用编程的方式配置Servlet容器。
```java
//与上面定义的web.xml配置文件是等效的。
import org.springframework.web.WebApplicationInitializer;
import org.springframework.web.servlet.DispatcherServlet;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRegistration;

public class MyWebApplicationInitializer implements WebApplicationInitializer {
    @Override
    public void onStartup(ServletContext servletContext) throws ServletException {
        System.out.println("servlet配置");
        ServletRegistration.Dynamic registration = servletContext.addServlet("dispatcher", new DispatcherServlet());
        registration.setLoadOnStartup(1);
        registration.addMapping("/");
        registration.setInitParameter("contextConfigLocation","classpath:HelloWeb-servlet.xml");
    }
}
```
WebApplicationInitializer是Spring MVC提供的一个接口，它会查找你所有基于代码的配置，并应用它们来初始化Servlet 3版本以上的web容器。它有一个抽象的实现AbstractDispatcherServletInitializer，用以简化DispatcherServlet的注册工作

* 在Spring MVC中，每个DispatcherServlet都持有一个自己的上下文对象WebApplicationContext,它又继承了根（root）WebApplicationContext对象中已经定义的所有bean,这些继承的bean可以在具体的Servlet实例中被重载，在每个Servlet实例中你也可以定义其scope下的新bean

![image.png](https://i.loli.net/2019/03/20/5c91b1c2b04eb.png)

**DispatcherServlet的初始化过程中，Spring MVC会在你web应用的WEB-INF目录下查找一个名为[servlet-name]-servlet.xml的配置文件，并创建其中所定义的bean。如果在全局上下文中存在相同名字的bean，则它们将被新定义的同名bean覆盖**

WebApplicationContext继承自ApplicationContext，它提供了一些web应用经常需要用到的特性。它与普通的ApplicationContext不同的地方在于，它支持主题的解析（详见21.9 主题Themes一小节），并且知道它关联到的是哪个servlet（它持有一个该ServletContext的引用）。WebApplicationContext被绑定在ServletContext中。如果需要获取它，你可以通过RequestContextUtils工具类中的静态方法来拿到这个web应用的上下文WebApplicationContext

## WebApplicationContext中特殊的bean类型
pring的DispatcherServlet使用了特殊的bean来处理请求、渲染视图等，这些特定的bean是Spring MVC框架的一部分。如果你想指定使用哪个特定的bean，你可以在web应用上下文WebApplicationContext中简单地配置它们。当然这只是可选的，Spring MVC维护了一个默认的bean列表，如果你没有进行特别的配置，框架将会使用默认的bean


| bean的类型 |	作用 |
| -- | -- |
| HandlerMapping |	处理器映射。它会根据某些规则将进入容器的请求映射到具体的处理器以及一系列前处理器和后处理器（即处理器拦截器）上。具体的规则视HandlerMapping类的实现不同而有所不同。其最常用的一个实现支持你在控制器上添加注解，配置请求路径。当然，也存在其他的实现。 |
| HandlerAdapter |	处理器适配器。拿到请求所对应的处理器后，适配器将负责去调用该处理器，这使得DispatcherServlet无需关心具体的调用细节。比方说，要调用的是一个基于注解配置的控制器，那么调用前还需要从许多注解中解析出一些相应的信息。因此，HandlerAdapter的主要任务就是对DispatcherServlet屏蔽这些具体的细节。
| HandlerExceptionResolver |	处理器异常解析器。它负责将捕获的异常映射到不同的视图上去，此外还支持更复杂的异常处理代码。
| ViewResolver |	视图解析器。它负责将一个代表逻辑视图名的字符串（String）映射到实际的视图类型View上。
| LocaleResolver & LocaleContextResolver |	地区解析器 和 地区上下文解析器。它们负责解析客户端所在的地区信息甚至时区信息，为国际化的视图定制提供了支持。
| ThemeResolver |	主题解析器。它负责解析你web应用中可用的主题，比如，提供一些个性化定制的布局等。
| MultipartResolver |	解析multi-part的传输请求，比如支持通过HTML表单进行的文件上传等。
| FlashMapManager |	FlashMap管理器。它能够存储并取回两次请求之间的FlashMap对象。后者可用于在请求之间传递数据，通常是在请求重定向的情境下使用。

## 默认的DispatcherServlet配置
DispatcherServlet维护了一个列表，其中保存了其所依赖的所有bean的默认实现。这个列表保存在包org.springframework.web.servlet下的DispatcherServlet.properties文件中
```properties
# Default implementation classes for DispatcherServlet's strategy interfaces.
# Used as fallback when no matching beans are found in the DispatcherServlet context.
# Not meant to be customized by application developers.

org.springframework.web.servlet.LocaleResolver=org.springframework.web.servlet.i18n.AcceptHeaderLocaleResolver

org.springframework.web.servlet.ThemeResolver=org.springframework.web.servlet.theme.FixedThemeResolver

org.springframework.web.servlet.HandlerMapping=org.springframework.web.servlet.handler.BeanNameUrlHandlerMapping,\
	org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping

org.springframework.web.servlet.HandlerAdapter=org.springframework.web.servlet.mvc.HttpRequestHandlerAdapter,\
	org.springframework.web.servlet.mvc.SimpleControllerHandlerAdapter,\
	org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter

org.springframework.web.servlet.HandlerExceptionResolver=org.springframework.web.servlet.mvc.method.annotation.ExceptionHandlerExceptionResolver,\
	org.springframework.web.servlet.mvc.annotation.ResponseStatusExceptionResolver,\
	org.springframework.web.servlet.mvc.support.DefaultHandlerExceptionResolver

org.springframework.web.servlet.RequestToViewNameTranslator=org.springframework.web.servlet.view.DefaultRequestToViewNameTranslator

org.springframework.web.servlet.ViewResolver=org.springframework.web.servlet.view.InternalResourceViewResolver

org.springframework.web.servlet.FlashMapManager=org.springframework.web.servlet.support.SessionFlashMapManager
```

这些特殊的bean都有一些基本的默认行为。或早或晚，你可能需要对它们提供的一些默认配置进行定制。比如说，通常你需要配置InternalResourceViewResolver类提供的prefix属性，使其指向视图文件所在的目录。  这里需要理解的一个事情是，一旦你在web应用上下文WebApplicationContext中配置了某个特殊bean以后（比如InternalResourceViewResolver），实际上你也覆写了该bean的默认实现。比方说，如果你配置了InternalResourceViewResolver，那么框架就不会再使用beanViewResolver的默认实现

## DispatcherServlet的处理流程
DispatcherServlet会依照以下的次序对请求进行处理：

* 首先，搜索应用的上下文对象WebApplicationContext并把它作为一个属性（attribute）绑定到该请求上，以便控制器和其他组件能够使用它。属性的键名默认为DispatcherServlet.WEB_APPLICATION_CONTEXT_ATTRIBUTE
* 将地区（locale）解析器绑定到请求上，以便其他组件在处理请求（渲染视图、准备数据等）时可以获取区域相关的信息。如果你的应用不需要解析区域相关的信息，忽略它即可
* 将主题（theme）解析器绑定到请求上，以便其他组件（比如视图等）能够了解要渲染哪个主题文件。同样，如果你不需要使用主题相关的特性，忽略它即可
* 如果你配置了multipart文件处理器，那么框架将查找该文件是不是multipart（分为多个部分连续上传）的。若是，则将该请求包装成一个MultipartHttpServletRequest对象，以便处理链中的其他组件对它做进一步的处理。关于Spring对multipart文件传输处理的支持，读者可以参考21.10 Spring的multipart（文件上传）支持一小节
* 为该请求查找一个合适的处理器。如果可以找到对应的处理器，则与该处理器关联的整条执行链（前处理器、后处理器、控制器等）都会被执行，以完成相应模型的准备或视图的渲染
* 如果处理器返回的是一个模型（model），那么框架将渲染相应的视图。若没有返回任何模型（可能是因为前后的处理器出于某些原因拦截了请求等，比如，安全问题），则框架不会渲染任何视图，此时认为对请求的处理可能已经由处理链完成了

### 定制DispatcherServlet的配置
在web.xml文件中，Servlet的声明元素上添加一些Servlet的初始化参数（通过init-param元素）。该元素可选的参数列表如下：
| 可选参数 | 	解释 | 
| -- | -- |
| contextClass |	任意实现了WebApplicationContext接口的类。这个类会初始化该servlet所需要用到的上下文对象。默认情况下，框架会使用一个XmlWebApplicationContext对象。 |
| contextConfigLocation |	一个指定了上下文配置文件路径的字符串，该值会被传入给contextClass所指定的上下文实例对象。该字符串内可以包含多个字符串，字符串之间以逗号分隔，以此支持你进行多个上下文的配置。在多个上下文中重复定义的bean，以最后加载的bean定义为准 |
| namespace |	WebApplicationContext的命名空间。默认是[servlet-name]-servlet |

## 控制器(Controller)的实现
Spring支持classpath路径下组件类的自动检测，以及对已定义bean的自动注册
你需要在配置中加入组件扫描的配置代码来开启框架对注解控制器的自动检测。请使用下面XML代码所示的spring-context schema：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:p="http://www.springframework.org/schema/p"
    xmlns:context="http://www.springframework.org/schema/context"
    xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context.xsd">

    <context:component-scan base-package="org.springframework.samples.petclinic.web"/>

    <!-- ... -->

</beans>
```

## 使用@RequestMapping注解映射请求路径
类级别的@RequestMapping注解并不是必须的。不配置的话则所有的路径都是绝对路径，而非相对路径。以下的代码示例来自PetClinic，它展示了一个具有多个处理器方法的控制器：
```
@Controller
public class ClinicController {

    private final Clinic clinic;

    @Autowired
    public ClinicController(Clinic clinic) {
        this.clinic = clinic;
    }

    @RequestMapping("/")
    public void welcomeHandler() {
    }

    @RequestMapping("/vets")
    public ModelMap vetsHandler() {
        return new ModelMap(this.clinic.getVets());
    }
}
```
以上代码没有指定请求必须是GET方法还是PUT/POST或其他方法，@RequestMapping注解默认会映射所有的HTTP请求方法。如果仅想接收某种请求方法，请在注解中指定之@RequestMapping(method=GET)以缩小范围。

## @Controller和面向切面（AOP）代理
* 当你直接在控制器上使用@Transactional注解时
* 我们推荐使用类级别（在控制器上使用）的代理方式。这一般是代理控制器的默认做法。

## Spring MVC 3.1中新增支持@RequestMapping的一些类
* 在Spring 3.1之前，框架会在两个不同的阶段分别检查类级别和方法级别的请求映射——首先，```DefaultAnnotationHanlderMapping```会先在类级别上选中一个控制器，然后再通过```AnnotationMethodHandlerAdapter```定位到具体要调用的方法。

* 使用Spring 3.1中的新支持类，```RequestMappingHandlerMapping```是唯一决定应该处理请求的方法的地方。
将控制器方法视为唯一端点的集合，其中每个方法的映射都是从类型和方法级别的@RequestMapping信息派生的。

## URI模板

* 当@PathVariable注解被应用于Map<String,String>类型的参数上时，框架会使用所有URI模板变量来填充这个map。
* URI模板可以从类级别和方法级别的 @RequestMapping 注解获取数据。因此，像这样的findPet()方法可以被类似于**/owners/42/pets/21**这样的URL路由并调用到：
* 当访问地址为/owners/42/pets/123时，findPet2有优先级
* @PathVariable可以被应用于所有 简单类型 的参数上，比如int、long、Date等类型。Spring会自动地帮你把参数转化成合适的类型，如果转换失败，就抛出一个TypeMismatchException
```java
@Controller
@RequestMapping("/owners/{ownerId}")
public class RelativePathUriTemplateController {

    @RequestMapping("/pets/{petId}")
    public void findPet(@PathVariable String ownerId, @PathVariable String petId, Model model) {
        // 方法实现体这里忽略
    }
      @RequestMapping("/pets/123")
    public void findPet2(@PathVariable String ownerId, Model model) {
        // 方法实现体这里忽略
    }
    }
```

## 带正则表达式的URI模板
@RequestMapping注解支持你在URI模板变量中使用正则表达式。语法是{varName:regex}，其中第一部分定义了变量名，第二部分就是你所要应用的正则表达式。比如下面的代码样例：
```
@RequestMapping("/spring-web/{symbolicName:[a-z-]+}-{version:\\d\\.\\d\\.\\d}{extension:\\.[a-z]+}")
    public void handle(@PathVariable String version, @PathVariable String extension) {
        // 代码部分省略...
    }
}
```
## 路径样式的匹配(Path Pattern Comparison)
当一个URL同时匹配多个模板（pattern）时，我们将需要一个算法来决定其中最匹配的一个。

* URI模板变量的数目和通配符数量的总和最少的那个路径模板更准确：
举个例子，/hotels/{hotel}/*这个路径拥有一个URI变量和一个通配符，而/hotels/{hotel}/**这个路径则拥有一个URI变量和两个通配符，因此，我们认为前者是更准确的路径模板。

* 如果两个模板的URI模板数量和通配符数量总和一致，则路径更长的那个模板更准确：
举个例子，/foo/bar*就被认为比/foo/*更准确，因为前者的路径更长。

* 如果两个模板的数量和长度均一致，则那个具有更少通配符的模板是更加准确的：
比如/hotels/{hotel}就比/hotels/*更精确。

* 默认的通配模式 /** 比其他所有的模式都更“不准确”。比方说，/api/{a}/{b}/{c}就比默认的通配模式/ ** 要更准确
* 前缀通配（比如/public/星星)被认为比其他任何不包括双通配符的模式更不准确。比如说，/public/path3/{a}/{b}/{c}就比/public/**更准确

## Suffix Pattern Matching 后缀模式匹配
Spring MVC默认采用".*"的后缀模式匹配来进行路径匹配，因此，一个映射到/person路径的控制器也会隐式地被映射到/person.**
**/person.pdf，/person.xml匹配的都是/person**
## 矩阵变量
1. **如果要允许矩阵变量的使用，你必须把RequestMappingHandlerMapping类的removeSemicolonContent属性设置为false。该值默认是true的。**

2. **使用MVC的命名空间配置时，你可以把<mvc:annotation-driven>元素下的enable-matrix-variables属性设置为true。该值默认情况下是配置为false的。**
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:mvc="http://www.springframework.org/schema/mvc"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/mvc
        http://www.springframework.org/schema/mvc/spring-mvc.xsd">

    <mvc:annotation-driven enable-matrix-variables="true"/>

</beans>
```


* 矩阵变量可以在任何路径段落中出现，每对矩阵变量之间使用一个分号“;”隔开。比如这样的URI："/cars;color=red;year=2012"。多个值可以用逗号隔开"color=red,green,blue"，或者重复变量名多次"color=red;color=green;color=blue"。
* 如果一个URL有可能需要包含矩阵变量，那么在请求路径的映射配置上就需要使用URI模板来体现这一点。这样才能确保请求可以被正确地映射，而不管矩阵变量在URI中是否出现、出现的次序是怎样等。

* 下面是一个例子，展示了我们如何从矩阵变量中获取到变量“q”的值：
```
// GET /pets/42;q=11;r=22

@RequestMapping(path = "/pets/{petId}", method = RequestMethod.GET)
public void findPet(@PathVariable String petId, @MatrixVariable int q) {

    // petId == 42
    // q == 11

}
```
* 由于任意路径段落中都可以含有矩阵变量，在某些场景下，你需要用更精确的信息来指定一个矩阵变量的位置：
```
// GET /owners/42;q=11/pets/21;q=22

@RequestMapping(path = "/owners/{ownerId}/pets/{petId}", method = RequestMethod.GET)
public void findPet(
    @MatrixVariable(name="q", pathVar="ownerId") int q1,
    @MatrixVariable(name="q", pathVar="petId") int q2) {

    // q1 == 11
    // q2 == 22

}
```

* 也可以通过一个Map来存储所有的矩阵变量：
```
// GET /owners/42;q=11;r=12/pets/21;q=22;s=23

@RequestMapping(path = "/owners/{ownerId}/pets/{petId}", method = RequestMethod.GET)
public void findPet(
    @MatrixVariable Map<String, String> matrixVars,
    @MatrixVariable(pathVar="petId") Map<String, String> petMatrixVars) {

    // matrixVars: ["q" : [11,22], "r" : 12, "s" : 23]
    // petMatrixVars: ["q" : 11, "s" : 23]

}
```

## 可消费的媒体类型
你可以指定一组可消费的媒体类型，缩小映射的范围。这样只有当请求头中 Content-Type 的值与指定可消费的媒体类型中有相同的时候，请求才会被匹配。比如下面这个例子：
```
@Controller
@RequestMapping(path = "/pets", method = RequestMethod.POST, consumes="application/json")
public void addPet(@RequestBody Pet pet, Model model) {
    // 方法实现省略
}
```

## 可生产的媒体类型
你可以指定一组可生产的媒体类型，缩小映射的范围。这样只有当请求头中 Accept 的值与指定可生产的媒体类型中有相同的时候，请求才会被匹配。而且，使用 produces 条件可以确保用于生成响应（response）的内容与指定的可生产的媒体类型是相同的。举个例子：
```
@Controller
@RequestMapping(path = "/pets/{petId}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
@ResponseBody
public Pet getPet(@PathVariable String petId, Model model) {
    // 方法实现省略
}
```

## 请求参数与请求头的值
只映射头包含myHeader且zhimyValue
```
@ResponseBody
    @RequestMapping(path = "/pets", method = RequestMethod.GET, headers="myHeader=myValue")
    public String findPet() {
        // 方法体实现省略


        return "findPet run";
    }
```

**注意：**尽管，你可以使用媒体类型的通配符（比如 "content-type=text/*"）来匹配请求头 Content-Type和 Accept的值，但我们更推荐独立使用 consumes和 produces条件来筛选各自的请求。因为它们就是专门为区分这两种不同的场景而生的。


## 使用@RequestParam将请求参数绑定至方法参数
若参数使用了该注解，则该参数默认是必须提供的，但你也可以把该参数标注为非必须的：只需要将@RequestParam注解的required属性设置为false即可（比如，@RequestParam(path="id", required=false)）。

## 使用@RequestBody注解映射请求体
方法参数中的@RequestBody注解暗示了方法参数应该被绑定了HTTP请求体的值。举个例子：
```
@RequestMapping(path = "/something", method = RequestMethod.PUT)
public void handle(@RequestBody String body, Writer writer) throws IOException {
    writer.write(body);
}
```

请求体到方法参数的转换是由```HttpMessageConverter```完成的。```HttpMessageConverter```负责将HTTP请求信息转换成对象，以及将对象转换回一个HTTP响应体。对于@RequestBody注解，RequestMappingHandlerAdapter提供了以下几种默认的```HttpMessageConverter```支持

```
class org.springframework.http.converter.ByteArrayHttpMessageConverter
class org.springframework.http.converter.StringHttpMessageConverter
class org.springframework.http.converter.ResourceHttpMessageConverter
class org.springframework.http.converter.ResourceRegionHttpMessageConverter
class org.springframework.http.converter.xml.SourceHttpMessageConverter
class org.springframework.http.converter.support.AllEncompassingFormHttpMessageConverter

```

* ByteArrayHttpMessageConverter用以转换字节数组
* StringHttpMessageConverter用以转换字符串
* FormHttpMessageConverter用以将表格数据转换成MultiValueMap<String, String>或从MultiValueMap<String, String>中转换出表格数据
* SourceHttpMessageConverter用于javax.xml.transform.Source类的互相转换

## 使用@ResponseBody注解映射响应体
* @ResponseBody注解可被应用于方法上，标志该方法的返回值，应该被直接写回到HTTP响应体中去（而不会被被放置到Model中或被解释为一个视图名）

## 使用HTTP实体HttpEntity
```
 @RequestMapping("/showResponseEntity")
    public ResponseEntity<String> showResponseEntity(HttpEntity<byte[]> requestEntity) throws UnsupportedEncodingException {
        String requestHeader = requestEntity.getHeaders().getFirst("MyRequestHeader");
        System.out.println(requestHeader);

        byte[] requestBody = requestEntity.getBody();
        System.out.println(new String(requestBody));
        // do something with request header and body

        HttpHeaders responseHeaders = new HttpHeaders();
        responseHeaders.set("MyResponseHeader", "MyValue");
        return new ResponseEntity<String>("Hello World", responseHeaders, HttpStatus.CREATED);
    }
```
* 上面这段示例代码先是获取了MyRequestHeader请求头的值，然后读取请求体的主体内容。读完以后往影响头中添加了一个自己的响应头MyResponseHeader，然后向响应流中写了字符串Hello World，最后把响应状态码设置为201（创建成功）。

## 对方法使用@ModelAttribute注解
* @ModelAttribute注解可被应用在方法或方法参数上
* 注解在方法上的@ModelAttribute说明了方法的作用是用于添加一个或多个属性**到Model上**。这样的方法能接受与@RequestMapping注解相同的参数类型，只不过不能直接被映射到具体的请求上。**在同一个控制器中，注解了@ModelAttribute的方法实际上会在@RequestMapping方法之前被调用。**
```
  @ModelAttribute
    public void populateModel(@RequestParam String name,Model model) {
        System.out.println("name:"+name);
        model.addAttribute("model","model Value");//控制器中所有请求都会先过 @ModelAttribute注解的方法
    }
```
* @ModelAttribute方法通常被用来填充一些公共需要的属性或数据：比如一个下拉列表所预设的几种状态
* 一个控制器可以拥有数量不限的@ModelAttribute方法。同个控制器内的所有这些方法，都会在@RequestMapping方法之前被调用。
* @ModelAttribute方法也可以定义在@ControllerAdvice注解的类中，并且这些@ModelAttribute可以同时对许多控制器生效。
* @ModelAttribute注解也可以被用在@RequestMapping方法上。这种情况下，@RequestMapping方法的返回值将会被解释为model的一个属性，而非一个视图名

## 在方法参数上使用@ModelAttribute注解
* 注解在方法参数上的@ModelAttribute说明了该方法参数的值将由model中取得。
1. **如果model中找不到，那么该参数会先被实例化，然后被添加到model中。**(如果model中没有所修饰的对象，就new一个放进去)
2. 在model中存在以后，请求中所有名称匹配的参数都会填充到该参数中。（往对象里塞属性）
3. 这在Spring MVC中被称为数据绑定，一个非常有用的特性，节约了你每次都需要手动从表格数据中转换这些字段数据的时间。

Model的值可能来自于:
1. 它可能因为@SessionAttributes注解的使用已经存在于model中
2. 它可能因为在同个控制器中使用了@ModelAttribute方法已经存在于model中——正如上一小节所叙述的
3. 它可能是由URI模板变量和类型转换中取得的（下面会详细讲解）
4. 它可能是调用了自身的默认构造器被实例化出来的
 
## 在请求之间使用@SessionAttributes注解，使用HTTP会话保存模型数据
* @SessionAttribute不能和@ResponseBody共用，会引起```Cannot create a session after the response has been committed```
* @SessionAttributes的value代表我们需要把什么样的对象放入session。当我们把对象放入ModelMap或Model时，符合value的对象也会自动放入session域中
```
 @ModelAttribute
    public void populateModel(@RequestParam String name, Model model) {
        model.addAttribute("model", "model Value");
        Bag bag=new Bag();
        bag.setPrice(666);
        model.addAttribute("bag", bag);
        model.addAttribute("sessionParam","view");
    }


    @RequestMapping(path = "/processSubmit")
    public String processSubmit(@ModelAttribute Bag bag, HttpServletRequest request, Model model) {
        System.out.println(bag);
        Enumeration<String> attributeNames = request.getSession().getAttributeNames();
        Iterator<String> stringIterator = attributeNames.asIterator();
        stringIterator.forEachRemaining(x-> System.out.println("session param"+x));
        return "myIndex";
    }
    
    //控制台输出
    //Bag{price=666, list=null, set=null, map=null, properties=null}
    //session parambag
    //session paramsessionParam
```

## 使用@CookieValue注解映射cookie值
```
//不能用Map,一一对应
  @RequestMapping("/getCookie")
    public void getCookie(@CookieValue("JSESSIONID") String cookie) {
        System.out.println("cookie:"+cookie);
    }
```

## 使用@RequestHeader注解映射请求头属性
* @RequestHeader注解能将一个方法参数与一个请求头属性进行绑定。
```
  @RequestMapping("/getHeader")
    public void getHeader(@RequestHeader("Accept-Encoding") String encoding, @RequestHeader(name = "Keep-Alive",required = false) Long keepAlive) {
        System.out.println(encoding);//gzip, deflate, br
        System.out.println(keepAlive);//null

    }
    //注意keepAlive如果申明成long会报错IllegalStateException，因为基类无法被转换成null
```
* 如果@RequestHeader注解应用在Map<String, String>、MultiValueMap<String, String>或HttpHeaders类型的参数上，那么所有的请求头属性值都会被填充到map中。
```
 @RequestMapping("/getHeader")
    public void getHeader(@RequestHeader Map<String, String> headerMap) {
        System.out.println(headerMap);

    }
```

## 方法参数与类型转换
* 从请求参数、路径变量、请求头属性或者cookie中抽取出来的String类型的值,如果目标类型不是String，Spring会自动进行类型转换.
* 如果想进一步定制这个转换过程，你可以通过WebDataBinder(不懂)

## 使用@ControllerAdvice辅助控制器


### ControllerAdvice定义的Class是有作用范围的
* 注解@ControllerAdvice的类可以拥有@ExceptionHandler、@InitBinder（不会用）或@ModelAttribute注解的方法，并且这些方法会被应用至控制器类层次??的所有@RequestMapping方法上。

* 默认情况下，什么参数都不指定时它的作用范围是所有的范围。ControllerAdvice提供了一些可以缩小它的处理范围的参数。

1.  value：数组类型，用来指定可以作用的基包，即将对指定的包下面的Controller及其子包下面的Controller起作用。
2. basePackages：数组类型，等价于value。
3. basePackageClasses：数组类型，此时的基包将以指定的Class所在的包为准。
4. assignableTypes：数组类型，用来指定具体的Controller类型，它可以是一个共同的接口或父类等。
5. annotations：数组类型，用来指定Class上拥有指定的注解的Controller。


```
@ControllerAdvice
public class AnnotationAdvice {

    /**
     * 该方法将处理SpringMVC处理过程中抛出的所有的异常，
     * 将使用该方法的返回值来替换正常的Controller方法的返回值
     * @param e
     * @return
     */
    @ExceptionHandler(Exception.class)
    @ResponseBody
    public Object handleException(Exception e) {
        System.out.println("统一处理器："+e.getMessage());
        Map<String, Object> jsonObj = new HashMap<>();
        jsonObj.put("errorMessage", e.getMessage());
        return jsonObj;
    }



    /**
     * 该方法将处理SpringMVC过程中抛出的所有的java.lang.IllegalStateException，
     * 而其它异常的处理还由上面定义的handleException()处理。当抛出了一个异常可以同时被
     * 多个@ExceptionHandler标注的方法处理时，对应的异常将交由更精确的异常处理方法处理。
     *
     * 且抛出该异常时将把处理结果以@ResponseBody的形式返回，此时将被当作JSON返回。
     * @param e
     * @return
     */
    @ExceptionHandler(NullPointerException.class)
    @ResponseBody
    public Object handleIllegalStateException(NullPointerException e) {
        System.out.println("空指针处理器："+e.getMessage());
        Map<String, Object> jsonObj = new HashMap<>();
        jsonObj.put("errorMessage", e.getMessage());
        return jsonObj;
    }
    //序列化对象需要三个包
    //jackson-annotations.jar
    //jackson-core.jar
    //jacksono-databind,jar
}
```
* 在@ExceptionHandler标注的处理方法中如果希望获取到当前抛出的异常，则可以在方法参数中声明一个需要处理的异常类型的参数，SpringMVC在调用对应的处理方法处理异常时将传递当前的异常对象。
* @ExceptionHandler标注的参数可以和Controller一样，比如HttpServletRequest、HttpServletResponse、java.util.Map、Model等。 
* @ExceptionHandler标注的返回值可以和Controller一样，比如String、Model、ModelAndView、void、Object

## 异步请求的处理
* 控制器方法可以返回一个java.util.concurrent.Callable的对象，并通过Spring MVC所管理的线程来产生返回值
* 与此同时，Servlet容器的主线程则可以退出并释放其资源了，同时也允许容器去处理其他的请求。
* 通过一个TaskExecutor，Spring MVC可以在另外的线程中调用Callable。
* **当Callable返回时，请求再携带Callable返回的值，再次被分配到Servlet容器中恢复处理流程**。
* 需要在配置中开启异步支持
```
//web.xml
<servlet>
<async-supported>true</async-supported>
</servlet>


//或配置类
 @Override
    public void onStartup(ServletContext servletContext) throws ServletException {
        ServletRegistration.Dynamic registration = servletContext.addServlet("ViewDispatcher", new DispatcherServlet());
        registration.setAsyncSupported(true);//开启异步请求
        registration.setLoadOnStartup(1);
        registration.addMapping("/");
        registration.setInitParameter("contextConfigLocation","classpath:HelloWeb-servlet.xml");//设置了这个就不扫描WEB-INFO下的[servlet-name]-servlet.xml的配置文件

    }
```
* 控制器范例
```
@RequestMapping(method=RequestMethod.POST)
public Callable<String> processUpload(final MultipartFile file) {

    return new Callable<String>() {
        public String call() throws Exception {
            // ...
            return "someView";
        }
    };

}
```

## 异步请求的异常处理
当Callable抛出异常时，Spring MVC会把一个Exception对象分派给Servlet容器进行处理，而不是正常返回方法的返回值，然后容器恢复对此异步请求异常的处理。若方法返回的是一个DeferredResult对象，你可以选择调Exception实例的setResult方法还是setErrorResult方法。

## 处理器映射（Handler Mappings）

需要注意的是，HandlerInterceptor的后拦截postHandle方法不一定总是适用于注解了@ResponseBody或ResponseEntity的方法。这些场景中，HttpMessageConverter会在拦截器的postHandle方法被调之前就把信息写回响应中。这样拦截器就无法再改变响应了，比如要增加一个响应头之类的。如果有这种需求，请让你的应用实现ResponseBodyAdvice接口，并将其定义为一个@ControllerAdvicebean或直接在RequestMappingHandlerMapping中配置


处理器映射处理过程配置的拦截器，必须实现org.springframework.web.servlet包下的HandlerInterceptor接口
接口定义了三个方法：

* preHandle(..)，它在处理器实际执行 之前 会被执行；
方法返回一个boolean值。你可以通过这个方法来决定是否继续执行处理链中的部件。当方法返回 true时，处理器链会继续执行；若方法返回 false， DispatcherServlet即认为拦截器自身已经完成了对请求的处理（比如说，已经渲染了一个合适的视图），那么其余的拦截器以及执行链中的其他处理器就不会再被执行了
* postHandle(..)，它在处理器执行 完毕 以后被执行； 
* afterCompletion(..)，它在 整个请求处理完成 之后被执行



* 编写拦截器
```
public class MyHandlerInterceptor  extends HandlerInterceptorAdapter {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        System.out.println("preHandle");
        return true;
    }
}
```
* 添加拦截器
```
public class WebConfig implements WebMvcConfigurer {
@Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new MyHandlerInterceptor());
    }
    }
```

## 视图解析
有两个接口在Spring处理视图相关事宜时至关重要，分别是视图解析器接口ViewResolver和视图接口本身View

* Spring有非常多内置的视图解析器

| 视图解析器  | 	描述 |
| --  | --  |  
| AbstractCachingViewResolver | 	一个抽象的视图解析器类，提供了缓存视图的功能。通常视图在能够被使用之前需要经过准备。继承这个基类的视图解析器即可以获得缓存视图的能力。 |
| XmlViewResolver | 	视图解析器接口ViewResolver的一个实现，该类接受一个XML格式的配置文件。该XML文件必须与Spring XML的bean工厂有相同的DTD。默认的配置文件名是/WEB-INF/views.xml。 |
| ResourceBundleViewResolver | 	视图解析器接口ViewResolver的一个实现，采用bundle根路径所指定的ResourceBundle中的bean定义作为配置。一般bundle都定义在classpath路径下的一个配置文件中。默认的配置文件名为views.properties。 |
| UrlBasedViewResolver | 	ViewResolver接口的一个简单实现。它直接使用URL来解析到逻辑视图名，除此之外不需要其他任何显式的映射声明。如果你的逻辑视图名与你真正的视图资源名是直接对应的，那么这种直接解析的方式就很方便，不需要你再指定额外的映射。 |
| InternalResourceViewResolver | 	UrlBasedViewResolver的一个好用的子类。它支持内部资源视图（具体来说，Servlet和JSP）、以及诸如JstlView和TilesView等类的子类|
| VelocityViewResolver |  / FreeMarkerViewResolver	UrlBasedViewResolver下的实用子类，支持Velocity视图VelocityView（Velocity模板）和FreeMarker视图FreeMarkerView以及它们对应子类。 |
| ContentNegotiatingViewResolver | 	视图解析器接口ViewResolver的一个实现，它会根据所请求的文件名或请求的Accept头来解析一个视图 |



假设这里使用的是JSP视图技术，那么我们可以使用一个基于URL的视图解析器UrlBasedViewResolver。这个视图解析器会将URL解析成一个视图名，并将请求转交给请求分发器来进行视图渲染。
```
<bean id="viewResolver" class="org.springframework.web.servlet.view.UrlBasedViewResolver">
    <property name="viewClass" value="org.springframework.web.servlet.view.JstlView"/>
    <property name="prefix" value="/WEB-INF/jsp/"/>
    <property name="suffix" value=".jsp"/>
</bean>
```
若返回一个test逻辑视图名，那么该视图解析器会将请求转发到RequestDispatcher，后者会将请求交给/WEB-INF/jsp/test.jsp视图去渲染。


如果需要在应用中使用多种不同的视图技术，你可以使用ResourceBundleViewResolver：
```
<bean id="viewResolver"
        class="org.springframework.web.servlet.view.ResourceBundleViewResolver">
    <property name="basename" value="views"/>
    <property name="defaultParentView" value="parentView"/>
</bean>
```

## 视图链
* Spring支持同时使用多个视图解析器。你可以通过把多个视图解析器设置到应用上下文(application context)中的方式来串联它们。
* 设置order属性指定次序。请记住，order属性的值越大，该视图解析器在链中的位置就越靠后

视图解析器链中包含了两个解析器：一个是InternalResourceViewResolver，它总是自动被放置在解析器链的最后；另一个是XmlViewResolver，它用来指定Excel视图。InternalResourceViewResolver不支持Excel视图。
```
<bean id="jspViewResolver" class="org.springframework.web.servlet.view.InternalResourceViewResolver">
    <property name="viewClass" value="org.springframework.web.servlet.view.JstlView"/>
    <property name="prefix" value="/WEB-INF/jsp/"/>
    <property name="suffix" value=".jsp"/>
</bean>

<bean id="excelViewResolver" class="org.springframework.web.servlet.view.XmlViewResolver">
    <property name="order" value="1"/>
    <property name="location" value="/WEB-INF/views.xml"/>
</bean>

<!-- in views.xml -->

<beans>
    <bean name="report" class="org.springframework.example.ReportExcelView"/>
</beans>
```

* 如果一个视图解析器不能返回一个视图，那么Spring会继续检查上下文中其他的视图解析器直到产生一个视图返回为止。如果最后所有视图解析器都不能返回一个视图，Spring就抛出一个ServletException
* 一个视图解析器是可以返回null值的，这表示不能找到任何合适的视图

## 重定向视图 RedirectView
* 强制重定向的一种方法是，在控制器中创建并返回一个Spring重定向视图RedirectView的实例
* 它会使得DispatcherServlet放弃使用一般的视图解析机制，因为你已经返回一个（重定向）视图给DispatcherServlet了，所以它会构造一个视图来满足渲染的需求。
* 紧接着RedirectView会调用HttpServletResponse.sendRedirect()方法，发送一个HTTP重定向响应给客户端浏览器
* 如果你决定返回RedirectView，并且这个视图实例是由控制器内部创建出来的，那我们更推荐在外部配置重定向URL然后注入到控制器中来，而不是写在控制器里面。这样它就可以与视图名一起在配置文件中配置。

## 重定向前缀——redirect:
* 如果返回的视图名中含有redirect:前缀，那么UrlBasedViewResolver（及它的所有子类）就会接受到这个信号，意识到这里需要发生重定向。然后视图名剩下的部分会被解析成重定向URL。
* 这种方式与通过控制器返回一个重定向视图RedirectView所达到的效果是一样的，不过这样一来控制器就可以只专注于处理并返回逻辑视图名了。
* 如果逻辑视图名是这样的形式：redirect:/myapp/some/resource，他们重定向路径将以Servlet上下文作为相对路径进行查找
* 而逻辑视图名如果是这样的形式：redirect:http://myhost.com/some/arbitrary/path，那么重定向URL使用的就是绝对路径。
* 控制器方法注解了@ResponseStatus，那么注解设置的状态码值会覆盖RedirectView设置的响应状态码值。
* 速度较慢，涉及客户端浏览器，浏览器显示重定向的URL，它会向重定向的URL创建新请求

## 转发前缀——forward:
* 速度更快，客户端浏览器不参与，浏览器显示原始URL，转发请求转发URL

##  URI构造
* 在Spring MVC中，使用了UriComponentsBuilder和UriComponents两个类来提供一种构造和加密URI的机制。

在Spring MVC中，使用了UriComponentsBuilder和UriComponents两个类来提供一种构造和编码(加密？)URI的机制。
比如，你可以通过一个URI模板字符串来填充并加密一个URI：
```
UriComponents uriComponents = UriComponentsBuilder.fromUriString(
        "http://example.com/hotels/{hotel}/bookings/{booking}").build();

URI uri = uriComponents.expand("42", "21").encode().toUri();
```
请注意UriComponents是不可变对象。因此expand()与encode()操作在必要的时候会返回一个新的实例。

你也可以使用一个URI组件实例对象来实现URI的填充与编码(加密？)：
```
UriComponents uriComponents = UriComponentsBuilder.newInstance()
        .scheme("http").host("example.com").path("/hotels/{hotel}/bookings/{booking}").build()
        .expand("42", "21")
        .encode();
```

在Servlet环境下，ServletUriComponentsBuilder类提供了一个静态的工厂方法，可以用于从Servlet请求中获取URL信息：
```java

   //主机名、schema, 端口号、请求路径和查询字符串都重用请求里已有的值
   //替换了其中的"accountId"查询参数,有则更改，没有则添加
   //地址http://localhost:8080/route4/testUrl
   //输出http://localhost:8080/route4/testUrl?accountId=123

    @ResponseBody
    @RequestMapping("/testUrl")
    public String testUrl(HttpServletRequest request){
        UriComponents accountId = ServletUriComponentsBuilder.fromRequest(request)
                .replaceQueryParam("accountId", "{id}").build()
                .expand("123")
                .encode();
        System.out.println(accountId);
        return "suc";

    }
   
```

或者，你也可以选择只复用请求中一部分的信息：
```java

// 重用主机名、端口号和context path
// 在路径后添加"/newView"
//地址http://localhost:8080/route4/testUrl
//输出http://localhost:8080/newView
 @ResponseBody
    @RequestMapping("/testUrl")
    public String testUrl(HttpServletRequest request) {
        UriComponents build = ServletUriComponentsBuilder.fromContextPath(request)
                .path("/newView").build();
        System.out.println(build);
        return "suc";

    }
```

## 为控制器和方法指定URI
pring MVC也提供了构造指定控制器方法链接的机制。以下面代码为例子，假设我们有这样一个控制器：
```
@Controller
@RequestMapping("/hotels/{hotel}")
public class BookingController {

    @RequestMapping("/bookings/{booking}")
    public String getBooking(@PathVariable Long booking) {

    // ...

    }
}
```
你可以通过引用方法名字的办法来准备一个链接：
```
UriComponents uriComponents = MvcUriComponentsBuilder
    .fromMethodName(BookingController.class, "getBooking", 21).buildAndExpand(42);
URI uri = uriComponents.encode().toUri();

//输入http://localhost:8080/hotels/111/bookings/222
//转换后为http://localhost:8080/hotels/42/bookings/21
```



* 在上面的例子中，我们为方法参数准备了填充值：一个long型的变量值21，以用于填充路径变量并插入到URL中
* 另外，我们还提供了一个值42，以用于填充其他剩余的URI变量，比如从类层级的请求映射中继承来的hotel变量

## Spring的multipart（文件上传）支持
* 默认情况下，Spring的多路上传支持是不开启的，因为有些开发者希望由自己来处理多路请求。
* 如果想启用Spring的多路上传支持，你需要在web应用的上下文中添加一个多路传输解析器。每个进来的请求，解析器都会检查是不是一个多部分请求。若发现请求是完整的，则请求按正常流程被处理；如果发现请求是一个多路请求，则你在上下文中注册的MultipartResolver解析器会被用来处理该请求。
* 之后，请求中的多路上传属性就与其他属性一样被正常对待了

### 使用MultipartResolver与Commons FileUpload传输文件

当Spring的DispatcherServlet检测到一个多部分请求时，它会激活你在上下文中声明的多路解析器并把请求交给它。解析器会把当前的```HttpServletRequest```请求对象包装成一个支持多路文件上传的请求对象```MultipartHttpServletRequest```。有了```MultipartHttpServletRequest```对象，你不仅可以获取该多路请求中的信息，还可以在你的控制器中获得该多路请求的内容本身

使用CommonsMultipartResolver，***需要的jar包commons-fileupload.jar***

```java
/**
     *
     * 配置multipart解析器
     * 具体参数的配置在AbstractAnnotationConfigDispatcherServletInitializer的customizeRegistration方法
     * @return
     */
    @Bean
    public MultipartResolver multipartResolver(){
        return new CommonsMultipartResolver();//需要commons-io-2.6.jar
        /*return new StandardServletMultipartResolver();*/
    }
```

```
/**
     * 配置multipart上传的详细参数（临时存放文件夹，单个文件最大大小，整个请求最大大小）
     *不配置会报Unable to process parts as no multi-part configuration has been provided
     * （由于未提供多部件配置，因此无法处理部件）
     * @param registration
     */
    @Override
    protected void customizeRegistration(ServletRegistration.Dynamic registration) {
        registration.setMultipartConfig(
                new MultipartConfigElement("", 10*1024 * 1024, 10 *1024* 1024, 0));
    }
```

### @RequestParam和@RequestPart区别
* 都支持multipart/form-data请求
* 他们最大的不同是@RequestParam适用String类型的请求域，@RequestPart适用于复杂的请求域（像JSON，XML）

前台表单
```javascript
let form = new FormData();

        for (k in $('#uploadForm')[0].files) {
            if (k != "length" && k != "item") {
                form.append("file", $('#uploadForm')[0].files[k]);
            }
        }

        form.append("userSimple", "{\"name\":\"view\"}");
        
        //表单包含文件file和字段userSimple，其中userSimple是json字符串
```
后台
```
 @RequestMapping(path = "/doUpload", method = RequestMethod.POST)
    @ResponseBody
    public MyResponse doUpload(@RequestPart(name = "userSimple") UserSimple userSimple, @RequestParam("file") MultipartFile[] file)  {

        System.out.println("name;"+userSimple);
        System.out.println("文件个数"+file.length);

        return new MyResponse(0,"suc","123");
    }
    
//输出：name;UserSimple{name='view'} 文件个数2
```

需要的配置
```
@Bean
    public ObjectMapper getObjectMapper() {
        ObjectMapper responseMapper = new ObjectMapper();
        return responseMapper;
    }

    /**
     * 支持application/octet-stream的转换器
     * @return
     */
    @Bean
    MultipartJackson2HttpMessageConverter getMultipartJackson2HttpMessageConverter(){
        MultipartJackson2HttpMessageConverter multipartJackson2HttpMessageConverter=new MultipartJackson2HttpMessageConverter(getObjectMapper());
        return multipartJackson2HttpMessageConverter;
    }

    /**
     *扩展消息转换器
     * @param converters
     */
    @Override
    public void extendMessageConverters(List<HttpMessageConverter<?>> converters) {
        converters.add(getMultipartJackson2HttpMessageConverter());//相同MediaType框架读取第一个,可指定放置位置
    }
```

支持application/octet-stream的转换器
```
public class MultipartJackson2HttpMessageConverter extends AbstractJackson2HttpMessageConverter {



    /**
     * Converter for support http request with header Content-Type: multipart/form-data
     */
    public MultipartJackson2HttpMessageConverter(ObjectMapper objectMapper) {
        super(objectMapper, MediaType.APPLICATION_OCTET_STREAM);//这个要自己注
    }



    @Override
    public boolean canWrite(Class<?> clazz, MediaType mediaType) {
        return false;
    }

    @Override
    public boolean canWrite(Type type, Class<?> clazz, MediaType mediaType) {
        return false;
    }

    @Override
    protected boolean canWrite(MediaType mediaType) {
        return false;
    }
}
```

### 自定义httpMessageConvert

* 请求中，spring会根据Request对象header部分的content-Type类型，逐一匹配合适的HttpMessageConverter来读取数据
* 在响应时,spring会根据Request对象header部分的Accept属性（逗号分隔），逐一按accept中的类型，去遍历找到能处理的HttpMessageConverter


#### 依赖于Content-Type逐一匹配合适的HttpMessageConverter
```
@Controller
@RequestMapping("/testConvertController")
public class TestConvertController {

    @ResponseBody
    @RequestMapping(value = "/firstTest", produces = {"application/x-view"})
    public MyConvertPojo firstTest(@RequestBody MyConvertPojo myConvertPojo) {
        System.out.println(myConvertPojo);
        return myConvertPojo;
    }


}
```

#### 自定义转换器（需要在配置里add进去，可指定放置顺序，同content-type的转换器只使用第一个）
```
public class MyMessageConverter extends AbstractHttpMessageConverter<MyConvertPojo> {


    public MyMessageConverter() {
        super(new MediaType("application", "x-view", Charset.forName("UTF-8")));
        System.out.println("convert1 构造");
    }

    /**
     * 是否支持
     *
     * @param aClass
     * @return
     */
    @Override
    protected boolean supports(Class<?> aClass) {
        return MyConvertPojo.class.isAssignableFrom(aClass);
    }

    /**
     * 处理请求的数据
     *
     * @param aClass
     * @param httpInputMessage
     * @return
     * @throws IOException
     * @throws HttpMessageNotReadableException
     */
    @Override
    protected MyConvertPojo readInternal(Class<? extends MyConvertPojo> aClass, HttpInputMessage httpInputMessage) throws IOException, HttpMessageNotReadableException {
        InputStream body = httpInputMessage.getBody();//获取到请求数据流
        String s = StreamUtils.copyToString(body, Charset.forName("UTF-8"));//转字符串
        String[] split = s.split("~");
        MyConvertPojo myConvertPojo = new MyConvertPojo();
        System.out.println(Arrays.toString(split));
        if (split.length > 1) {
            myConvertPojo.setAge(split[0]);
            myConvertPojo.setName(split[1]);
        }
        System.out.println("convert1 请求");
        return myConvertPojo;
    }

    /**
     * 处理如何输出数据到response
     *
     * @param myConvertPojo
     * @param httpOutputMessage
     * @throws IOException
     * @throws HttpMessageNotWritableException
     */
    @Override
    protected void writeInternal(MyConvertPojo myConvertPojo, HttpOutputMessage httpOutputMessage) throws IOException, HttpMessageNotWritableException {
        System.out.println("convert1 响应");
        OutputStream body = httpOutputMessage.getBody();
        body.write(myConvertPojo.toString().getBytes());

    }
}
```

### 配置fastjson转换器（拓展）
```
 @Bean
    FastJsonHttpMessageConverter getFastJsonHttpMessageConverter() {
        FastJsonHttpMessageConverter fastJsonHttpMessageConverter = new FastJsonHttpMessageConverter();
        return fastJsonHttpMessageConverter;

    }

    /**
     * 扩展消息转换器
     *
     * @param converters
     */
    @Override
    public void extendMessageConverters(List<HttpMessageConverter<?>> converters) {
        converters.add(getMultipartJackson2HttpMessageConverter());
        converters.add(getMyMessageConverter());//已有的类型只取第一个,可指定放置顺序
        converters.add(0,getFastJsonHttpMessageConverter());


    }
```

## 异常处理

### @ExceptionHandler注解
* Spring的处理器异常解析器HandlerExceptionResolver接口的实现负责处理各类控制器执行过程中出现的异常
* HandlerExceptionResolver接口以及SimpleMappingExceptionResolver解析器类的实现使得你能声明式地将异常映射到特定的视图上，还可以在异常被转发（forward）到对应的视图前使用Java代码做些判断和逻辑。
* 如果@ExceptionHandler方法是在控制器内部定义的，那么它会接收并处理由控制器（当前类或其任何子类）中的@RequestMapping方法抛出的异常。
* 如果你将@ExceptionHandler方法定义在@ControllerAdvice类中，那么它会处理相关控制器中抛出的异常。
* @ExceptionHandler注解还可以接受一个异常类型的数组作为参数值。若抛出了已在列表中声明的异常，那么相应的@ExceptionHandler方法将会被调用
* 与标准的控制器@RequestMapping注解处理方法一样，@ExceptionHandler方法的方法参数和返回值也可以很灵活

## 对静态资源的HTTP缓存支持
你可以设置ResourceHttpRequestHandler上的cachePeriod属性值，或使用一个CacheControl实例来支持更细致的指令：
```
@Configuration
@EnableWebMvc
public class WebConfig extends WebMvcConfigurerAdapter {

  @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/static/**")//映射的地址
                .addResourceLocations("/resources/")//项目里真实的地址
                .setCacheControl(CacheControl.maxAge(1, TimeUnit.HOURS).cachePublic());//设置缓存时间
    }

}
```

请求的响应
```http
Accept-Ranges: bytes
Cache-Control: max-age=3600, public
Content-Length: 5
Content-Type: text/plain;charset=UTF-8
Date: Fri, 12 Apr 2019 01:31:42 GMT
Last-Modified: Thu, 11 Apr 2019 13:00:52 GMT
```

## 基于代码的Servlet容器初始化
* 在Servlet 3.0以上的环境下，你可以通过编程的方式来配置Servlet容器了
* Spring MVC提供了一个WebApplicationInitializer接口，实现这个接口能保证你的配置能自动被检测到并应用于Servlet 3容器的初始化中。
* WebApplicationInitializer有一个实现，是一个抽象的基类，名字叫AbstractDispatcherServletInitializer。有了它，要配置DispatcherServlet将变得更简单，你只需要覆写相应的方法，在其中提供servlet映射、DispatcherServlet所需配置的位置即可：
```
public class MyWebAppInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {

    @Override
    protected Class<?>[] getRootConfigClasses() {
        return null;
    }

    @Override
    protected Class<?>[] getServletConfigClasses() {
        return new Class[] { MyWebConfig.class };
    }

    @Override
    protected String[] getServletMappings() {
        return new String[] { "/" };
    }

}
```

以上的例子适用于使用基于Java配置的Spring应用。如果你使用的是基于XML的Spring配置方式，那么请直接继承AbstractDispatcherServletInitializer这个类：
```
public class MyWebAppInitializer extends AbstractDispatcherServletInitializer {

    @Override
    protected WebApplicationContext createRootApplicationContext() {
        return null;
    }

    @Override
    protected WebApplicationContext createServletApplicationContext() {
        XmlWebApplicationContext cxt = new XmlWebApplicationContext();
        cxt.setConfigLocation("/WEB-INF/spring/dispatcher-config.xml");
        return cxt;
    }

    @Override
    protected String[] getServletMappings() {
        return new String[] { "/" };
    }
    
     /**
     * 配置过滤器
     * @return
     */
    @Override
    protected Filter[] getServletFilters() {
        return new Filter[]{new MyFilter()};
    }

}
```

AbstractDispatcherServletInitializer同样也提供了便捷的方式来添加过滤器Filter实例并使他们自动被映射到DispatcherServlet下：
```
public class MyWebAppInitializer extends AbstractDispatcherServletInitializer {

    // ...

    /**
     * 配置过滤器
     * @return
     */
    @Override
    protected Filter[] getServletFilters() {
        return new Filter[]{new MyFilter()};
    }
    

}
```