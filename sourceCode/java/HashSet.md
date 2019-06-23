# HashSet

## 属性
```
private transient HashMap<E,Object> map;

private static final Object PRESENT = new Object();//与支持Map中的Object关联的虚拟值
```

## 构造方法

###  HashSet()
```
public HashSet() {
        map = new HashMap<>();
    }

```

### HashSet(Collection<? extends E> c)传入集合
```
public HashSet(Collection<? extends E> c) {
        map = new HashMap<>(Math.max((int) (c.size()/.75f) + 1, 16));//16和集合计算出来的空间取大值
        addAll(c);
    }
```

### HashSet(int initialCapacity)设置初始容量
```
public HashSet(int initialCapacity) {
        map = new HashMap<>(initialCapacity);
    }
```

### HashSet(int initialCapacity, float loadFactor)设置初始容量和负载因子
```
public HashSet(int initialCapacity, float loadFactor) {
        map = new HashMap<>(initialCapacity, loadFactor);
    }
```

### HashSet(int initialCapacity, float loadFactor, boolean dummy)//使用LinkedHashMap构造
```
  HashSet(int initialCapacity, float loadFactor, boolean dummy) {
        map = new LinkedHashMap<>(initialCapacity, loadFactor);
    }
```

## 方法

### iterator()返回迭代器
```
public Iterator<E> iterator() {
        return map.keySet().iterator();
    }
```

###  size()哈希桶内键值对数量
```
 public int size() {
        return map.size();
    }
```

### isEmpty()哈系桶的键值对是否为空，调用map的isEmpty
```
public boolean isEmpty() {
        return map.isEmpty();
    }
```

### contains(Object o)查询哈系桶中是否存在o,调用hashMap的containsKey
```
public boolean contains(Object o) {
        return map.containsKey(o);
    }
```

### add(E e)添加元素
```
 public boolean add(E e) {
        return map.put(e, PRESENT)==null;//使用替值PRESENT
    }
```

### remove(Object o)删除哈系桶中以o作为key的元素
```
  public boolean remove(Object o) {
        return map.remove(o)==PRESENT;//o作为key调用hashMap的remove
    }
```

### clear()
```
 public void clear() {
        map.clear();//调用hashMap的clear()
    }
```



