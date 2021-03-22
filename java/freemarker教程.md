# freemarker教程

## 依赖

```
  <dependency>
            <groupId>org.freemarker</groupId>
            <artifactId>freemarker</artifactId>
            <version>2.3.31</version>
        </dependency>
```

## 模板
* FTL  freemarker template language
* 区分大小写

## 范例

### 文本
* 模板

```html
  <html>
  <head>
      <title>Welcome!</title>
  </head>
  <body>
  <#if user == 'view'>
      我是view
  <#else >
      我不是view
  </#if>
  </body>
  </html>
```

* 渲染
```java

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import freemarker.template.TemplateExceptionHandler;

import java.io.File;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.HashMap;
import java.util.Map;

public class FreemarkerTest {
    public static void main(String[] args) throws IOException, TemplateException {
        // Create your Configuration instance, and specify if up to what FreeMarker
        // version (here 2.3.29) do you want to apply the fixes that are not 100%
        // backward-compatible. See the Configuration JavaDoc for details.
        Configuration cfg = new Configuration(Configuration.VERSION_2_3_29);

        // Specify the source where the template files come from. Here I set a
        // plain directory for it, but non-file-system sources are possible too:
        cfg.setDirectoryForTemplateLoading(new File("D:\\JAVA_WORK_SPACE\\java_focus\\src\\main\\resources\\template"));

        // From here we will set the settings recommended for new projects. These
        // aren't the defaults for backward compatibilty.

        // Set the preferred charset template files are stored in. UTF-8 is
        // a good choice in most applications:
        cfg.setDefaultEncoding("UTF-8");

        // Sets how errors will appear.
        // During web page *development* TemplateExceptionHandler.HTML_DEBUG_HANDLER is better.
        cfg.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);

        // Don't log exceptions inside FreeMarker that it will thrown at you anyway:
        cfg.setLogTemplateExceptions(false);

        // Wrap unchecked exceptions thrown during template processing into TemplateException-s:
        cfg.setWrapUncheckedExceptions(true);

        // Do not fall back to higher scopes when reading a null loop variable:
        cfg.setFallbackOnNullLoopVariable(false);

        // Create the root hash. We use a Map here, but it could be a JavaBean too.
        Map<String, Object> root = new HashMap<>();

        // Put string "user" into the root
        root.put("user", "Big Joe");
        
        Template temp = cfg.getTemplate("test.ftlh");

        Writer out = new OutputStreamWriter(System.out);
        temp.process(root, out);
    }
}

```

### 判断
```
<#if name=='a'>
    a
<#elseif name=='lily' >
    lily
<#else >
    c
</#if>
```



### 集合
```html
<#list  sims as sim>
    ${sim.fieldName}
</#list>
```

```java
  List<Simple>  list=new ArrayList<>();

        list.add(new Simple("name"));

        list.add(new Simple("age"));

       
        Template temp = cfg.getTemplate("test.ftlh");

        root.put("sims",list);
        Writer out = new OutputStreamWriter(System.out);
        temp.process(root, out);
```
