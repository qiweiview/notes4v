# spring cloud alibaba使用（配合nacos）

## 依赖
```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.3.2.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    <groupId>com</groupId>
    <artifactId>cloud_alibaba</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>cloud_alibaba</name>
    <description>cloud_alibaba</description>

    <packaging>jar</packaging>

    <properties>
        <java.version>1.8</java.version>
        <!-- Environment Settings -->

        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>

        <!-- Spring Settings -->

        <spring-cloud.version>Hoxton.SR8</spring-cloud.version>
        <spring-cloud-alibaba.version>2.2.5.RELEASE</spring-cloud-alibaba.version>
    </properties>



    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
            <dependency>
                <groupId>com.alibaba.cloud</groupId>
                <artifactId>spring-cloud-alibaba-dependencies</artifactId>
                <version>${spring-cloud-alibaba.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>


    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
        </dependency>

        <!-- https://mvnrepository.com/artifact/org.springframework.boot/spring-boot-starter-web -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
            <version>${spring-cloud-alibaba.version}</version>
        </dependency>

        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
            <version>${spring-cloud-alibaba.version}</version>
        </dependency>

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
            <version>${spring-cloud-alibaba.version}</version>
        </dependency>

        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-sentinel</artifactId>
            <version>${spring-cloud-alibaba.version}</version>
        </dependency>
    </dependencies>



    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>

</project>
```

## 注解
```
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
public class CloudAlibabaApplication {

    public static void main(String[] args) {
        SpringApplication.run(CloudAlibabaApplication.class, args);
    }

}
```

## 配置
```
spring:
  application:
    name: nacos-provider
  cloud:
    nacos:
      discovery:
        server-addr: 127.0.0.1:8848

server:
  port: 8081
#  port: ${random.int(2000,8000)}


feign:
  sentinel:
    enabled: true

```

## 暴露
```
@RestController
@RequestMapping( "/config")
@RequiredArgsConstructor
public class ConfigController {

    private final ConfigurableApplicationContext applicationContext;

    @RequestMapping("/sayHi")
    public String sayHi(){
        if (System.currentTimeMillis()%2==1){
            throw new RuntimeException("biz exception");
        }
        return "hi";
```
## 调用
* loadBalancerClient方式
```
    private final RestTemplate restTemplate;

    private final LoadBalancerClient loadBalancerClient;

    private final IConsumer iConsumer;

    
    @RequestMapping("/getData")
    public String getData(){
        ServiceInstance serviceInstance = loadBalancerClient.choose("nacos-provider");
        String url = String.format("http://%s:%s/config/sayHi", serviceInstance.getHost(), serviceInstance.getPort());
        log.info(url);
        return restTemplate.getForObject(url, String.class);
    }
```

* Feign方式
```
@FeignClient(value = "nacos-provider", fallback = ConsumerBackImpl.class)
public interface IConsumer {

    @GetMapping(value = "/config/sayHi")
    String getDataByFeign();
```

```
   @RequestMapping("/getDataByFeign")
    public String getDataByFeign(){
        log.info("getDataByFeign");
        return iConsumer.getDataByFeign();
    }
```

## 熔断
```
@Component
public class ConsumerBackImpl  implements IConsumer {
    @Override
    public String getDataByFeign() {
        return "熔断降级响应";
    }
```

## 服务配置
* bootstrap.properties
```
# 这里的应用名对应 Nacos Config 中的 Data ID，实际应用名称以配置中心的配置为准
spring.application.name=nacos-provider-config
# 指定查找名为 nacos-provider-config.yaml 的配置文件
spring.cloud.nacos.config.file-extension=yaml
# Nacos Server 的地址
spring.cloud.nacos.config.server-addr=127.0.0.1:8848
```

* 调用
```
   private final ConfigurableApplicationContext applicationContext;
 
   @RequestMapping("/getConfig")
    public String getConfig(){
        Boolean property = applicationContext.getEnvironment().getProperty("mock.enabled", Boolean.class);
        return "mock.enabled:"+property;
    }
```
