# 动态加载java代码


## 依赖
```
<!-- https://mvnrepository.com/artifact/org.codehaus.groovy/groovy-all -->
<dependency>
    <groupId>org.codehaus.groovy</groupId>
    <artifactId>groovy-all</artifactId>
    <version>3.0.0-beta-3</version>
    <type>pom</type>
</dependency>

```

## 代码
```
package maven_app.xxl;

import groovy.lang.GroovyClassLoader;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

public class CodeUtils {
    private ConcurrentMap<String, Class<?>> CLASS_CACHE = new ConcurrentHashMap();
    private GroovyClassLoader groovyClassLoader = new GroovyClassLoader();


    private Class<?> getCodeSourceClass(String codeSource) {
        try {
            byte[] md5 = MessageDigest.getInstance("MD5").digest(codeSource.getBytes());
            String md5Str = (new BigInteger(1, md5)).toString(16);
            Class<?> clazz = this.CLASS_CACHE.get(md5Str);
            if (clazz == null) {
                clazz = this.groovyClassLoader.parseClass(codeSource);
                this.CLASS_CACHE.putIfAbsent(md5Str, clazz);
            }

            return clazz;
        } catch (Exception var5) {
            return this.groovyClassLoader.parseClass(codeSource);
        }
    }
}

```
