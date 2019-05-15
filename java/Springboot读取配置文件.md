## 一：读取propety
```
@Configuration
@EnableAspectJAutoProxy
@PropertySource(value = "classpath:init.properties")
public class BeanFactory {
	public PropertySourcesPlaceholderConfigurer propertySourcesPlaceholderConfigurer() {
		return new PropertySourcesPlaceholderConfigurer();

	}
	

}
```

## 在其他类中使用

```
 @Autowired
	private Environment env;

System.out.println(env.getProperty("mail.mailName"));
```

## 二：读取yml
application.yml
```
sina:
  appkey: 2479635394
  appsecrete: 319733199e44e8ad47b2c50af295cc5d
  clientid: 2479635394

```
加载自定义配置文件
```
@Configuration
public class BeanFactory {

    @Bean
    public static PropertySourcesPlaceholderConfigurer properties() {
        PropertySourcesPlaceholderConfigurer configurer = new PropertySourcesPlaceholderConfigurer();
        YamlPropertiesFactoryBean yaml = new YamlPropertiesFactoryBean();
        yaml.setResources(new ClassPathResource("pro.yml"));//File引入
        configurer.setProperties(yaml.getObject());
        return configurer;
    }
}
```

添加依赖
```
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-configuration-processor</artifactId>
	<optional>true</optional>
</dependency>
```


读取类

使用方法一
```
    @Value("${sina.appkey}")
    private String key;
```

使用方法二 
```





@Component
@ConfigurationProperties(prefix = "sina")


private String appkey;
private String appsecrete;
private String clientid;

getter...
setter...
```