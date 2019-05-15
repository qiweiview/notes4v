# Springboot配置外部静态文件映射

1. 配置yml:
```
server:
  port: 80
  tomcat:
    basedir: tomcat_static
#项目创建会在同级创建tomcat_static文件夹
```
2. 配置映射：
```
@Configuration
public class WebConfig extends WebMvcConfigurationSupport {
    @Override
    protected void addResourceHandlers(ResourceHandlerRegistry registry) {

        File path = null;
        try {
            path = new File(ResourceUtils.getURL("classpath:").getPath());
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        String gitPath=path.getParentFile().getParentFile().getParent()+File.separator+"tomcat_static"+File.separator;
        System.out.println("path"+gitPath);
        registry.addResourceHandler("/server_static/**").addResourceLocations(gitPath);//外部映射
        registry.addResourceHandler("/**").addResourceLocations(ResourceUtils.CLASSPATH_URL_PREFIX+"/static/");//系统映射
        super.addResourceHandlers(registry);
    }
}

```
3. 访问地址为
```
http://localhost/server_static/123.txt
```

4. idea运行需要将gitPath变量写死成测试目录（路径为file:\\\\开头）：
```
 registry.addResourceHandler("/server_static/**").addResourceLocations("file:\\E:\\IdeaWorkSpace\\tomcat_static\\");
 
 
 
```