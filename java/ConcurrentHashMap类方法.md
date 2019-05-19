## ConcurrentHashMap类方法

### 三个重要的关键字
* compute :计算
* Absent：不存在
* Present：存在
* merge 合并


### computeIfAbsent() 如果不存在就执行lamda，lamda里的return为插入的值，方法返回值为插入的值，如果传入函数的返回值为空，则会删除对应key.
```
 concurrentHashMap.computeIfAbsent("keyWord", (x) -> {
                    System.out.println("computeIfAbsent：" + x );
                    return "Absent_Value";
                });
```

### computeIfPresent() 如果存在则执行，lamda里的return为插入的值，方法返回值为插入的值，如果传入函数的返回值为空，则会删除对应key.
```
concurrentHashMap.computeIfPresent("keyWord", (x, y) -> {
                    System.out.println("computeIfPresent：" + x + "/" + y);
                    return "Present_Value";
                });
```

### compute() 不管怎么样都会执行lamda，lamda里的return为插入的值，方法返回值为插入的值，如果传入函数的返回值为空，则会删除对应key.

```
 String keyWord = concurrentHashMap.compute("keyWord", (k, y) -> {
                    System.out.println("compute:" + k + "/" + y);
                    return Thread.currentThread().getName();
                });
```


### merge()key对应的值为空的话，把值设置为传入的value（valu不能为空，为空的话会报空指针），否则把值设置成传入函数的返回值，如果传入函数的返回值为空，则会删除对应key.

**原理代码（非真实源码）**
```
default V merge(K key, V value, BiFunction<V, V, V> remappingFunction) {
    V oldValue = get(key);
    V newValue = (oldValue == null) ? value ://为空则把值设置为传入的值，否知把值设置成函数的返回值
               remappingFunction.apply(oldValue, value);
    if (newValue == null) {
        remove(key);//这一步不理解
    } else {
        put(key, newValue);//放入新的值
    }
    return newValue;//返回新生成的值
}
```
