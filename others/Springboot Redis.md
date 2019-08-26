# Springboot Redis


## 依赖
```
 <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
```


## 配置
```
@Configuration
public class RedisConfig {


    @Bean
    public LettuceConnectionFactory getLettuceConnectionFactory() {

        RedisStandaloneConfiguration redisStandaloneConfiguration = new RedisStandaloneConfiguration("127.0.0.1", 6379);
        redisStandaloneConfiguration.setPassword("wdwdwd");
        return new LettuceConnectionFactory(redisStandaloneConfiguration);
    }

    @Bean
    public StringRedisTemplate getStringRedisTemplate() {
        StringRedisTemplate stringRedisTemplate=new StringRedisTemplate();
        stringRedisTemplate.setConnectionFactory(getLettuceConnectionFactory());
        stringRedisTemplate.setKeySerializer(new StringRedisSerializer()); //设置序列化Key的实例化对象
        stringRedisTemplate.setValueSerializer(new GenericToStringSerializer<>(Object.class)); //设置序列化Value的实例化对象
        return stringRedisTemplate;
    }
}
```



