# TreeMap



## 内部数据结构基类

### Entry实现Map.Entry接口（红黑树）
```
static final class Entry<K,V> implements Map.Entry<K,V> {
        K key;
        V value;
        Entry<K,V> left;//左孩子
        Entry<K,V> right;//右孩子
        Entry<K,V> parent;//父节点
        boolean color = BLACK;

        /**
         * Make a new cell with given key, value, and parent, and with
         * {@code null} child links, and BLACK color.
         */
        Entry(K key, V value, Entry<K,V> parent) {
            this.key = key;
            this.value = value;
            this.parent = parent;
        }

        /**
         * Returns the key.
         *
         * @return the key
         */
        public K getKey() {
            return key;
        }

        /**
         * Returns the value associated with the key.
         *
         * @return the value associated with the key
         */
        public V getValue() {
            return value;
        }

        /**
         * Replaces the value currently associated with the key with the given
         * value.
         *
         * @return the value associated with the key before this method was
         *         called
         */
        public V setValue(V value) {
            V oldValue = this.value;
            this.value = value;
            return oldValue;
        }

        public boolean equals(Object o) {
            if (!(o instanceof Map.Entry))
                return false;
            Map.Entry<?,?> e = (Map.Entry<?,?>)o;

            return valEquals(key,e.getKey()) && valEquals(value,e.getValue());
        }

        public int hashCode() {
            int keyHash = (key==null ? 0 : key.hashCode());
            int valueHash = (value==null ? 0 : value.hashCode());
            return keyHash ^ valueHash;
        }

        public String toString() {
            return key + "=" + value;
        }
    }
```

## 属性
```
   
    private final Comparator<? super K> comparator;
    //比较器用于维护此树映射中的顺序，如果它使用其键的自然顺序，则为null

    private transient Entry<K,V> root;

    
    private transient int size = 0;//树中的条目数

   
    private transient int modCount = 0;//树的结构修改数
    
    
    //初始化的字段在第一次请求此视图时包含条目集视图的实例
    private transient EntrySet entrySet;
    private transient KeySet<K> navigableKeySet;
    private transient NavigableMap<K,V> descendingMap;

```

## 构造方法

### TreeMap()使用其键的自然顺序构造一个新的空树图
```
public TreeMap() {
        comparator = null;
    }
```

### TreeMap(Comparator<? super K> comparator)构造一个新的空树图，根据给定的顺序排序
```
  public TreeMap(Comparator<? super K> comparator) {
        this.comparator = comparator;
    }
```

### TreeMap(Map<? extends K, ? extends V> m)
* 构造一个包含与给定映射相同映射的新树映射,使用其键的自然顺序
```
 public TreeMap(Map<? extends K, ? extends V> m) {
        comparator = null;
        putAll(m);
    }
```

### TreeMap(SortedMap<K, ? extends V> m)
* 构造一个包含相同映射的新树映射，并使用与指定有序映射相同的顺序
* 此方法以线性时间运行
```
 public TreeMap(SortedMap<K, ? extends V> m) {
        comparator = m.comparator();
        try {
            buildFromSorted(m.size(), m.entrySet().iterator(), null, null);
        } catch (java.io.IOException | ClassNotFoundException cannotHappen) {
        }
    }
```


## 方法

### size()返回树中的条目数
```
 public int size() {
        return size;
    }
```

### containsKey(Object key)如果此映射包含指定键的映射返回true
```
public boolean containsKey(Object key) {
        return getEntry(key) != null;
    }
```

### getEntry(Object key)
```
final Entry<K,V> getEntry(Object key) {
        // Offload comparator-based version for sake of performance
        if (comparator != null)//如果存在比较器
            return getEntryUsingComparator(key);//获取key对应的对象
        if (key == null)
            throw new NullPointerException();
        @SuppressWarnings("unchecked")
            Comparable<? super K> k = (Comparable<? super K>) key;
        Entry<K,V> p = root;
        while (p != null) {
            int cmp = k.compareTo(p.key);//调用key的compareTo
            if (cmp < 0)
                p = p.left;//左节点
            else if (cmp > 0)
                p = p.right;//右节点
            else
                return p;//相等
        }
        return null;
    }
```

### getEntryUsingComparator(Object key)使用比较器的getEntry版本。 从getEntry分离以获得性能
```
final Entry<K,V> getEntryUsingComparator(Object key) {
        @SuppressWarnings("unchecked")
            K k = (K) key;
        Comparator<? super K> cpr = comparator;
        if (cpr != null) {
            Entry<K,V> p = root;
            while (p != null) {//迭代
                int cmp = cpr.compare(k, p.key);
                if (cmp < 0)
                    p = p.left;//左节点
                else if (cmp > 0)
                    p = p.right;//右节点
                else
                    return p;//等于，返回
            }
        }
        return null;
    }
```

### containsValue(Object value)当且仅当此映射包含至少一个映射到值v的映射时返回true
```
public boolean containsValue(Object value) {
        for (Entry<K,V> e = getFirstEntry(); e != null; e = successor(e))//从第一个元素开始往上迭代
            if (valEquals(value, e.value))//比对
                return true;
        return false;
    }
```

### get(Object key)获取节点
```
 public V get(Object key) {
        Entry<K,V> p = getEntry(key);
        return (p==null ? null : p.value);
    }
```


### getFirstEntry() 返回TreeMap中的第一个Entry
```
final Entry<K,V> getFirstEntry() {
        Entry<K,V> p = root;
        if (p != null)//TreeMap不为空
            while (p.left != null)
                p = p.left;//遍历到最左边
        return p;
    }
```

###  getLastEntry()获取最后一个值
```
 final Entry<K,V> getLastEntry() {
        Entry<K,V> p = root;
        if (p != null)
            while (p.right != null)
                p = p.right;//遍历到最右
        return p;
    }
```

### successor(Entry<K,V> t)返回指定Entry的后继者
```
static <K,V> TreeMap.Entry<K,V> successor(Entry<K,V> t) {
        if (t == null)              //传入的节点为空
            return null;
            
        else if (t.right != null) { //传入的节点不为空，且右节点不为空
            Entry<K,V> p = t.right;
            while (p.left != null)
                p = p.left;//遍历到最左边
            return p;
            
        } else {                    //传入的节点不为空，且右节点为空
            Entry<K,V> p = t.parent;//取他的父节点
            Entry<K,V> ch = t;
            while (p != null && ch == p.right) {（不理解）
                ch = p;
                p = p.parent;
            }
            return p;
        }
    }
```

### get(Object key)根据key获取节点的值
```
 public V get(Object key) {
        Entry<K,V> p = getEntry(key);
        return (p==null ? null : p.value);
    }
```

### comparator()返回比较器
```
  public Comparator<? super K> comparator() {
        return comparator;
    }
```



### firstKey()获取第一个Entry的key
```
public K firstKey() {
        return key(getFirstEntry());
    }
```

### key(Entry<K,?> e)
```
static <K> K key(Entry<K,?> e) {
        if (e==null)
            throw new NoSuchElementException();
        return e.key;
    }
```

### 获取最后一个Entry的key
```
  public K lastKey() {
        return key(getLastEntry());
    }
```







### putAll(Map<? extends K, ? extends V> map)将指定映射中的所有映射复制到此映射
```
public void putAll(Map<? extends K, ? extends V> map) {
        int mapSize = map.size();
        if (size==0 && mapSize!=0 && map instanceof SortedMap) {
            Comparator<?> c = ((SortedMap<?,?>)map).comparator();//获取map的比较器
            if (c == comparator || (c != null && c.equals(comparator))) {
                ++modCount;
                try {
                    buildFromSorted(mapSize, map.entrySet().iterator(),
                                    null, null);
                } catch (java.io.IOException | ClassNotFoundException cannotHappen) {
                }
                return;
            }
        }
        
        super.putAll(map);//AbstractMap的方法
    }
```

### getCeilingEntry(K key)获取与指定键对应的条目(暂不知道用处)
```
final Entry<K,V> getCeilingEntry(K key) {
        Entry<K,V> p = root;
        while (p != null) {//根节点不为空
            int cmp = compare(key, p.key);
            if (cmp < 0) {
                if (p.left != null)
                    p = p.left;
                else
                    return p;
            } else if (cmp > 0) {
                if (p.right != null) {
                    p = p.right;
                } else {
                    Entry<K,V> parent = p.parent;
                    Entry<K,V> ch = p;
                    while (parent != null && ch == parent.right) {
                        ch = parent;
                        parent = parent.parent;
                    }
                    return parent;
                }
            } else
                return p;
        }
        return null;
    }
```

### getFloorEntry(K key)（暂不知道用处）
```
final Entry<K,V> getFloorEntry(K key) {
        Entry<K,V> p = root;
        while (p != null) {
            int cmp = compare(key, p.key);
            if (cmp > 0) {
                if (p.right != null)
                    p = p.right;
                else
                    return p;
            } else if (cmp < 0) {
                if (p.left != null) {
                    p = p.left;
                } else {
                    Entry<K,V> parent = p.parent;
                    Entry<K,V> ch = p;
                    while (parent != null && ch == parent.left) {
                        ch = parent;
                        parent = parent.parent;
                    }
                    return parent;
                }
            } else
                return p;

        }
        return null;
    }
```

### getHigherEntry(K key)暂不知道用处
```
final Entry<K,V> getHigherEntry(K key) {
        Entry<K,V> p = root;
        while (p != null) {
            int cmp = compare(key, p.key);
            if (cmp < 0) {
                if (p.left != null)
                    p = p.left;
                else
                    return p;
            } else {
                if (p.right != null) {
                    p = p.right;
                } else {
                    Entry<K,V> parent = p.parent;
                    Entry<K,V> ch = p;
                    while (parent != null && ch == parent.right) {
                        ch = parent;
                        parent = parent.parent;
                    }
                    return parent;
                }
            }
        }
        return null;
    }
```

### getLowerEntry(K key)暂不知道用处
```
final Entry<K,V> getLowerEntry(K key) {
        Entry<K,V> p = root;
        while (p != null) {
            int cmp = compare(key, p.key);
            if (cmp > 0) {
                if (p.right != null)
                    p = p.right;
                else
                    return p;
            } else {
                if (p.left != null) {
                    p = p.left;
                } else {
                    Entry<K,V> parent = p.parent;
                    Entry<K,V> ch = p;
                    while (parent != null && ch == parent.left) {
                        ch = parent;
                        parent = parent.parent;
                    }
                    return parent;
                }
            }
        }
        return null;
    }
```

### put(K key, V value)将指定的值与此映射中的指定键相关联。如果映射先前包含键的映射，则替换旧值。
```
public V put(K key, V value) {
        Entry<K,V> t = root;
        if (t == null) {//根节点是空的
            compare(key, key); //key为空确认

            root = new Entry<>(key, value, null);//直接赋值根节点
            size = 1;
            modCount++;
            return null;
        }
        int cmp;
        Entry<K,V> parent;
        // split comparator and comparable paths
        Comparator<? super K> cpr = comparator;
        
        //迭代到叶子节点，然后插入
        if (cpr != null) {
            do {
                parent = t;
                cmp = cpr.compare(key, t.key);
                if (cmp < 0)
                    t = t.left;
                else if (cmp > 0)
                    t = t.right;
                else
                    return t.setValue(value);
            } while (t != null);
        }
        else {
            if (key == null)
                throw new NullPointerException();
            @SuppressWarnings("unchecked")
                Comparable<? super K> k = (Comparable<? super K>) key;
            do {
                parent = t;
                cmp = k.compareTo(t.key);
                if (cmp < 0)
                    t = t.left;
                else if (cmp > 0)
                    t = t.right;
                else
                    return t.setValue(value);
            } while (t != null);
        }
        
        //父节点设置子节点
        Entry<K,V> e = new Entry<>(key, value, parent);
        if (cmp < 0)
            parent.left = e;
        else
            parent.right = e;
            
        //修复红黑树    
        fixAfterInsertion(e);
        size++;
        modCount++;
        return null;
    }
```


### remove(Object key)删除元素
```
public V remove(Object key) {
        Entry<K,V> p = getEntry(key);//获取指定元素
        
        if (p == null)
            return null;

        V oldValue = p.value;
        deleteEntry(p);
        return oldValue;
    }
```

### deleteEntry(Entry<K,V> p)删除节点p，然后重新平衡树
```
private void deleteEntry(Entry<K,V> p) {
        modCount++;
        size--;

        // If strictly internal, copy successor's element to p and then make p
        // point to successor.
        
        
        //有两个子节点
        if (p.left != null && p.right != null) {
            Entry<K,V> s = successor(p);
            p.key = s.key;
            p.value = s.value;
            p = s;
        } 

        // 如果存在，在替换节点上启动修复
        Entry<K,V> replacement = (p.left != null ? p.left : p.right);

        if (replacement != null) {
        
            //链接替换为父级
            replacement.parent = p.parent;
            if (p.parent == null)
                root = replacement;
            else if (p == p.parent.left)
                p.parent.left  = replacement;
            else
                p.parent.right = replacement;

            // Null out links so they are OK to use by fixAfterDeletion.
            p.left = p.right = p.parent = null;

            // Fix replacement
            if (p.color == BLACK)
                fixAfterDeletion(replacement);//重新平衡
                
        } else if (p.parent == null) { //只存在根节点
            root = null;
        } else { //叶子节点
            if (p.color == BLACK)
                fixAfterDeletion(p);//重新平衡

            //把父节点的子节点置空
            if (p.parent != null) {
                if (p == p.parent.left)
                    p.parent.left = null;
                else if (p == p.parent.right)
                    p.parent.right = null;
                p.parent = null;
            }
        }
    }
```

### clear()直接清空根节点
```
 public void clear() {
        modCount++;
        size = 0;
        root = null;
    }
```

未完成...
