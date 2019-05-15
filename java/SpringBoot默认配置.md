# SpringBoot默认配置

* 默认页面映射路径为classpath:/templates/*.html
* 静态文件路径为classpath:/static/
* SpringBoot把static的映射配置到了基础地址上，例如：
static里有jquery.js那么访问路径就是localhost:8080/jquery.js
* 修改静态资源映射：
```
extends WebMvcConfigurationSupport

@Override
    protected void addResourceHandlers(ResourceHandlerRegistry registry) {
        /*静态资源地址映射为resource*/
        registry.addResourceHandler("/resource/**").addResourceLocations("classpath:/static/");
        super.addResourceHandlers(registry);
    }
```