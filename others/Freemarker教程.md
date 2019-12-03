# Freemarker教程

## 依赖
```
        <dependency>
            <groupId>org.freemarker</groupId>
            <artifactId>freemarker</artifactId>
            <version>2.3.29</version>
        </dependency>
```

## 范例
* 模板
```
user: ${user}
friends:
  <#list friends as f>
    - name: ${f.name}
      age: ${f.age}
      <#if f.name == "lily">
      like: monika
      </#if>
  </#list>
```
* 代码
```
/*不需要重复创建 Configuration 实例； 它的代价很高，尤其是会丢失缓存。Configuration 实例就是应用级别的单例。*/
        Configuration cfg = new Configuration(Configuration.VERSION_2_3_22);
        try {
            cfg.setDirectoryForTemplateLoading(new File("D:\\"));
        } catch (IOException e) {
            e.printStackTrace();
        }
        cfg.setDefaultEncoding("UTF-8");
        cfg.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);

        // Create the root hash
        Map<String, Object> root = new HashMap<>();
        root.put("user", "Big Joe");

        Map<String, Object> lily = new HashMap<>();
        lily.put("name", "lily");
        lily.put("age", 16);

        Map<String, Object> jack = new HashMap<>();
        jack.put("name", "jack");
        jack.put("age", 17);

        Map<String, Object> alice = new HashMap<>();
        alice.put("name", "alice");
        alice.put("age", 18);

        List<Map> collect = Stream.of(lily, jack, alice).collect(Collectors.toList());
        root.put("friends", collect);

        try {
            Template temp = cfg.getTemplate("text.yml");
            Writer out = new OutputStreamWriter(System.out);
            temp.process(root, out);
        } catch (IOException e) {
            e.printStackTrace();
        } catch (TemplateException e) {
            e.printStackTrace();
        }
```


* 输出
```
user: Big Joe
friends:
    - name: lily
      age: 16
      like: monika
    - name: jack
      age: 17
    - name: alice
      age: 18

```

### 字符串模板
```
 public String stringTemplate(String templateContent, String templateName, Object data) {
        stringTemplateLoader.putTemplate(templateName, templateContent);
        cfg.clearTemplateCache();
        try {
            Template template = cfg.getTemplate(templateName, "utf-8");
            Writer writer = new StringWriter();
            processTemplateWithData(template, data, writer);
            String s = writer.toString();
            return s;
        } catch (IOException e) {
            logger.error(e.getMessage());
            return null;
        }
    }
```


