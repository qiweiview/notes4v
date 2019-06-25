# LinkedHashSet

## 构造方法

### LinkedHashSet(int initialCapacity, float loadFactor)初始化容量和负载系数
```
  public LinkedHashSet(int initialCapacity, float loadFactor) {
        super(initialCapacity, loadFactor, true);//父类是HashSet，三分参数构造方法使用的是LinkedHashMap
    }
```

### LinkedHashSet(int initialCapacity)初始化容量
```
public LinkedHashSet(int initialCapacity) {
        super(initialCapacity, .75f, true);
    }
```

### LinkedHashSet()
```
 public LinkedHashSet() {
        super(16, .75f, true);
    }
```

### LinkedHashSet(Collection<? extends E> c)
```
 public LinkedHashSet(Collection<? extends E> c) {
        super(Math.max(2*c.size(), 11), .75f, true);
        addAll(c);//AbstractCollection的方法
    }
```
