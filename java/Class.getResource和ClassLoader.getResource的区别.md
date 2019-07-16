# Class.getResource和ClassLoader.getResource的区别

## Class.getResource(String path)
* path不以'/'开头时，默认是从此类所在的包下取资源
* path以'/'开头时，则是从项目的ClassPath根下获取资源。在这里'/'表示ClassPath

```
public static void main(String[] args) throws IOException {

        System.out.println(Test4View.class.getResource(""));
        System.out.println(Test4View.class.getResource("/"));

    }
    
// file:/D:/DocProject/mybatis-3-mybatis-3.5.1/target/test-classes/test4v/
// file:/D:/DocProject/mybatis-3-mybatis-3.5.1/target/test-classes/

```


### Class类的getResource(String name)
```
public URL getResource(String name) {
        name = resolveName(name);//处理地址

        Module thisModule = getModule();
        if (thisModule.isNamed()) {
            // 检查调用者是否可以找到资源,找不到直接返回空
            if (Resources.canEncapsulate(name)&& !isOpenToCaller(name, Reflection.getCallerClass())) {
                return null;
            }

            // 资源未封装或打包给打电话的包
            String mn = thisModule.getName();
            ClassLoader cl = getClassLoader0();
            try {
                if (cl == null) {
                    return BootLoader.findResource(mn, name);
                } else {
                    return cl.findResource(mn, name);
                }
            } catch (IOException ioe) {
                return null;
            }
        }

        // 未命名的模块
        ClassLoader cl = getClassLoader0();
        if (cl == null) {
            return ClassLoader.getSystemResource(name);
        } else {
            return cl.getResource(name);
        }
    }
```

## Class.getClassLoader().getResource(String path)
* path不能以'/'开头时，path是指类加载器的加载范围，在资源加载的过程中，使用的逐级向上委托的形式加载的
* '/'表示Boot ClassLoader中的加载范围，因为这个类加载器是C++实现的，所以加载范围为null

```
public class Test
{
    public static void main(String[] args)
    {
        System.out.println(Test.class.getClassLoader().getResource(""));
        System.out.println(Test.class.getClassLoader().getResource("/"));
    }
}

// file:/D:/work_space/java/bin/
// null
```

### ClassLoader的getResource(String name)
```
public URL getResource(String name) {
        Objects.requireNonNull(name);
        URL url;
        if (parent != null) {//类加载器不为空
            url = parent.getResource(name);//类加载器里获取资源
        } else {
            url = BootLoader.findResource(name);//BootLoader里获取资源
        }
        if (url == null) {//都找不到
            url = findResource(name);//这个方法返回空
        }
        return url;
    }
```

## resolveName(String name)这个是两个getResource主要区别
```
private String resolveName(String name) {
        if (!name.startsWith("/")) {// 如果不以/开头
            Class<?> c = this;
            while (c.isArray()) {
                c = c.getComponentType();
            }
            String baseName = c.getPackageName();
            if (baseName != null && !baseName.isEmpty()) {
                name = baseName.replace('.', '/') + "/" + name;
            }
        } else {// 如果是以"/"开头，则去掉
            name = name.substring(1);
        }
        return name;
    }
```
