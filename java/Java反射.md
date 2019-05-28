## Java反射

### 设置属性可获取
```
 Field last = LinkedList.class.getDeclaredField("last");
 first.setAccessible(true);//否则IllegalAccessException
 Object o = first.get(linkedList);
```
