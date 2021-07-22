## Java反射

## 静态方法调用
```
        Class<?> aClass = jarClassLoader.loadClass("app.AppStart");
        Method main = aClass.getDeclaredMethod("main", String[].class);
        Object invoke = main.invoke(null, new Object[]{new String[]{"1"}});
```

## 设置属性可获取
```
 Field last = LinkedList.class.getDeclaredField("last");
 first.setAccessible(true);//否则IllegalAccessException
 Object o = first.get(linkedList);
```
