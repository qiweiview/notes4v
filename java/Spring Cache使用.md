# Spring Cache使用

## 引入cache命名空间，通过<cache:annotation-driven />启用Spring对基于注解的Cache的支持

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:cache="http://www.springframework.org/schema/cache"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
						http://www.springframework.org/schema/beans/spring-beans.xsd
						http://www.springframework.org/schema/context
						http://www.springframework.org/schema/context/spring-context.xsd
						http://www.springframework.org/schema/cache
                        http://www.springframework.org/schema/cache/spring-cache.xsd


	">

    <!-- 启用注解 -->
    <context:annotation-config/>
    <!-- 启动组件扫描，排除@Controller组件，该组件由SpringMVC配置文件扫描 -->
    <context:component-scan base-package="maven_app">
        <context:exclude-filter type="annotation"
                                expression="org.springframework.stereotype.Controller"/>
    </context:component-scan>

    <cache:annotation-driven  cache-manager="defaultCacheManager"/>
</beans>
```
## 配置需要注册一个CacheManager的实现类
```
public interface CacheManager {
    @Nullable
    Cache getCache(String var1);

    Collection<String> getCacheNames();
}

```

## 缓存管理通过Cache接口的实现类管理多个缓存（rdis里的，mongo里的）
```
public interface Cache {
    String getName();

    Object getNativeCache();

    @Nullable
    Cache.ValueWrapper get(Object var1);

    @Nullable
    <T> T get(Object var1, @Nullable Class<T> var2);

    @Nullable
    <T> T get(Object var1, Callable<T> var2);

    void put(Object var1, @Nullable Object var2);

    @Nullable
    Cache.ValueWrapper putIfAbsent(Object var1, @Nullable Object var2);

    void evict(Object var1);

    void clear();

    public static class ValueRetrievalException extends RuntimeException {
        @Nullable
        private final Object key;

        public ValueRetrievalException(@Nullable Object key, Callable<?> loader, Throwable ex) {
            super(String.format("Value for key '%s' could not be loaded using '%s'", key, loader), ex);
            this.key = key;
        }

        @Nullable
        public Object getKey() {
            return this.key;
        }
    }

    @FunctionalInterface
    public interface ValueWrapper {
        @Nullable
        Object get();
    }
}
```

## ValueWrapper是个数值传递的包装类
```
 @FunctionalInterface
    public interface ValueWrapper {
        @Nullable
        Object get();
    }
```

## 通过使用@Cacheable注解进行缓存
```
@Service
public class CacheService {

    public static final String CACHE_NAME="CACHE_NAME";

    @Cacheable(key = "#id",value = CACHE_NAME)
    public String getData(String id){
        String viewData = "dat:" + id;
        System.out.println(viewData);
        return viewData;
    }
}
```

* key作为是否使用缓存的凭证，
* value可以指定多个缓存库，manger通过value查询对应缓存库
* condition作为缓存执行的条件，其值是通过SpringEL表达式来指定的，当为true时表示进行缓存处理；当为false时表示不进行缓存处理，即每次调用该方法时该方法都会执行一次

## 使用@CachePut
* 与@Cacheable不同的是使用@CachePut标注的方法在执行前不会去检查缓存中是否存在之前执行过的结果，而是每次都会执行该方法，并将执行结果以键值对的形式存入指定的缓存中

## 使用@CacheEvict
* 当标记在一个类上时表示其中所有的方法的执行都会触发缓存的清除操作
