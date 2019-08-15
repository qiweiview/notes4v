# ThreadLocal

* 实现依托于ThreadLocal对象中有一个private final int threadLocalHashCode = nextHashCode();属性，
* 每个线程中都包含一个ThreadLocal的内部类ThreadLocalMap，通过getMap()方法获取当前线程中的ThreadLocalMap
* ThreadLocalMap中有个内部类Entry，Entry内有个Entry数组的table，类似哈希桶，下标通过ThreadLocal中的threadLocalHashCode & (table.length - 1)计算
* 因此获取值实质就是通过threadLocalHashCode获取桶下标获取对应Entry数组中的Entry,Entry中的value存的就是我们存放的对象
* 隔离是通过每个线程对象隔离的，即一个ThreadLocal的threadLocalHashCode被放到了好几个线程对象中

## 属性
```
    private final int threadLocalHashCode = nextHashCode();//哈希码

    
    private static AtomicInteger nextHashCode =new AtomicInteger();//下一个要发出的哈希码。 AtomicInteger申明。 从零开始

  
    private static final int HASH_INCREMENT = 0x61c88647;//固定hash增量

   
```

## 方法

### 返回下一个哈希值
```
    private static int nextHashCode() {
        return nextHashCode.getAndAdd(HASH_INCREMENT);//CAS方式
    }
```

### withInitial(Supplier<? extends S> supplier)
* 使用函数作为初始化方法
* 返回的是SuppliedThreadLocal
* SuppliedThreadLocal会在setInitialValue()中被调用

```
  public static <S> ThreadLocal<S> withInitial(Supplier<? extends S> supplier) {
        return new SuppliedThreadLocal<>(supplier);
    }
```

### get()
```
public T get() {
        Thread t = Thread.currentThread();//获取当前线程
        ThreadLocalMap map = getMap(t);
        if (map != null) {
            ThreadLocalMap.Entry e = map.getEntry(this);
            if (e != null) {
                @SuppressWarnings("unchecked")
                T result = (T)e.value;
                return result;
            }
        }
        return setInitialValue();
    }
```

### isPresent() 不为空返回true
```
boolean isPresent() {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        return map != null && map.getEntry(this) != null;
    }

```

### setInitialValue()
* set（）的变体用于建立initialValue。
* 如果用户已重写set（）方法，则使用而不是set（）。
```
 private T setInitialValue() {
        T value = initialValue();
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null) {
            map.set(this, value);
        } else {
            createMap(t, value);
        }
        if (this instanceof TerminatingThreadLocal) {
            TerminatingThreadLocal.register((TerminatingThreadLocal<?>) this);
        }
        return value;
    }
```


### set(T value)
```
 public void set(T value) {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null) {
            map.set(this, value);
        } else {
            createMap(t, value);
        }
    }
```

### getMap(Thread t)
```
ThreadLocalMap getMap(Thread t) {
        return t.threadLocals;
    }
```

### createMap(Thread t, T firstValue) 
```
void createMap(Thread t, T firstValue) {
        t.threadLocals = new ThreadLocalMap(this, firstValue);
    }
```

### remove()
```
 public void remove() {
         ThreadLocalMap m = getMap(Thread.currentThread());
         if (m != null) {
             m.remove(this);
         }
     }
```

### createInheritedMap(ThreadLocalMap parentMap)
```
static ThreadLocalMap createInheritedMap(ThreadLocalMap parentMap) {
        return new ThreadLocalMap(parentMap);
    }
```




### SuppliedThreadLocal类
* ThreadLocal的扩展，从中获取其初始值
```
static final class SuppliedThreadLocal<T> extends ThreadLocal<T> {

        private final Supplier<? extends T> supplier;

        SuppliedThreadLocal(Supplier<? extends T> supplier) {
            this.supplier = Objects.requireNonNull(supplier);
        }

        @Override
        protected T initialValue() {//重写了initialValue方法
            return supplier.get();
        }
    }
```





# ThreadLocalMap类（ThreadLocal的内部类）



## 属性
```

        private static final int INITIAL_CAPACITY = 16;//初始容量 - 必须是2的幂

       
        private Entry[] table;//该表根据需要调整大小。 table.length必须始终是2的幂。

       
        private int size = 0;//表中的条目数

       
        private int threshold; // 要调整大小的下一个大小值,默认0
```

## 构造方法

```
ThreadLocalMap(ThreadLocal<?> firstKey, Object firstValue) {
            table = new Entry[INITIAL_CAPACITY];
            int i = firstKey.threadLocalHashCode & (INITIAL_CAPACITY - 1);
            table[i] = new Entry(firstKey, firstValue);
            size = 1;
            setThreshold(INITIAL_CAPACITY);
        }
        
        
        
 private ThreadLocalMap(ThreadLocalMap parentMap) {
            Entry[] parentTable = parentMap.table;
            int len = parentTable.length;
            setThreshold(len);
            table = new Entry[len];

            for (Entry e : parentTable) {
                if (e != null) {
                    @SuppressWarnings("unchecked")
                    ThreadLocal<Object> key = (ThreadLocal<Object>) e.get();
                    if (key != null) {
                        Object value = key.childValue(e.value);
                        Entry c = new Entry(key, value);
                        int h = key.threadLocalHashCode & (len - 1);
                        while (table[h] != null)
                            h = nextIndex(h, len);
                        table[h] = c;
                        size++;
                    }
                }
            }
        }        
```

## 方法

### Entry内部类
```
static class Entry extends WeakReference<ThreadLocal<?>> {
            /** The value associated with this ThreadLocal. */
            Object value;

            Entry(ThreadLocal<?> k, Object v) {
                super(k);
                value = v;
            }
        }
```


### setThreshold(int len)设置扩容阈值为2/3
```
private void setThreshold(int len) {
            threshold = len * 2 / 3;
        }
```


### nextIndex(int i, int len)
```
 private static int nextIndex(int i, int len) {
            return ((i + 1 < len) ? i + 1 : 0);
        }
```


### prevIndex(int i, int len)
```
 private static int prevIndex(int i, int len) {
            return ((i - 1 >= 0) ? i - 1 : len - 1);
        }
```


### getEntry(ThreadLocal<?> key)根据键值获取值
```
   private Entry getEntry(ThreadLocal<?> key) {
            int i = key.threadLocalHashCode & (table.length - 1);
            Entry e = table[i];
            if (e != null && e.get() == key)
                return e;
            else
                return getEntryAfterMiss(key, i, e);
        }
```


### getEntryAfterMiss(ThreadLocal<?> key, int i, Entry e)
* 在直接散列槽中找不到密钥时使用的getEntry方法的版本
```
private Entry getEntryAfterMiss(ThreadLocal<?> key, int i, Entry e) {
            Entry[] tab = table;
            int len = tab.length;

            while (e != null) {
                ThreadLocal<?> k = e.get();
                if (k == key)//键相同
                    return e;
                if (k == null)//键时空的
                    expungeStaleEntry(i);//通过重新处理staleSlot和下一个空槽之间的任何可能碰撞的条目来清除过时的条目。
                    
                else
                    i = nextIndex(i, len);//下标后移
                e = tab[i];
            }
            return null;
        }
```

### set(ThreadLocal<?> key, Object value)
```
 private void set(ThreadLocal<?> key, Object value) {

           //我们不像get（）那样使用快速路径，因为使用set（）创建新条目至少与替换现有条目一样常见，在这种情况下，快速路径会更频繁地失败。

            Entry[] tab = table;
            int len = tab.length;
            int i = key.threadLocalHashCode & (len-1);//计算桶位

            for (Entry e = tab[i];
                 e != null;
                 e = tab[i = nextIndex(i, len)]) {
                ThreadLocal<?> k = e.get();

                if (k == key) {//桶位相等就设置值然后返回
                    e.value = value;
                    return;
                }

                if (k == null) {//获取出的是空
                    replaceStaleEntry(key, value, i);//将set操作期间遇到的陈旧条目替换为指定键的条目
                    return;
                }
            }

            tab[i] = new Entry(key, value);
            int sz = ++size;
            if (!cleanSomeSlots(i, sz) && sz >= threshold)//尝试扫描一些寻找陈旧条目的单元格，并且超过扩容阈值
                rehash();
        }
```


### remove(ThreadLocal<?> key)
```
private void remove(ThreadLocal<?> key) {
            Entry[] tab = table;
            int len = tab.length;
            int i = key.threadLocalHashCode & (len-1);
            for (Entry e = tab[i];
                 e != null;
                 e = tab[i = nextIndex(i, len)]) {
                if (e.get() == key) {//相等
                    e.clear();//清空
                    expungeStaleEntry(i);//通过重新处理staleSlot和下一个空槽之间的任何可能碰撞的条目来清除过时的条目。
                    return;
                }
            }
        }
```

### replaceStaleEntry(ThreadLocal<?> key, Object value,int staleSlot)(看不懂)
* 将set操作期间遇到的陈旧条目替换为指定键的条目
```
 private void replaceStaleEntry(ThreadLocal<?> key, Object value,int staleSlot) {
            Entry[] tab = table;
            int len = tab.length;
            Entry e;

           //备份以检查当前运行中的先前失效条目。 我们一次清理整个运行以避免由于垃圾收集器释放串中的refs（即，每当收集器运行时）不断的增量重复
           
            int slotToExpunge = staleSlot;//旧的桶位
            
            for (int i = prevIndex(staleSlot, len);(e = tab[i]) != null;i = prevIndex(i, len))
                if (e.get() == null)
                    slotToExpunge = i;

           
            for (int i = nextIndex(staleSlot, len);
                 (e = tab[i]) != null;
                 i = nextIndex(i, len)) {
                ThreadLocal<?> k = e.get();

                // If we find key, then we need to swap it
                // with the stale entry to maintain hash table order.
                // The newly stale slot, or any other stale slot
                // encountered above it, can then be sent to expungeStaleEntry
                // to remove or rehash all of the other entries in run.
                if (k == key) {
                    e.value = value;

                    tab[i] = tab[staleSlot];
                    tab[staleSlot] = e;

                    // Start expunge at preceding stale entry if it exists
                    if (slotToExpunge == staleSlot)
                        slotToExpunge = i;
                    cleanSomeSlots(expungeStaleEntry(slotToExpunge), len);
                    return;
                }

                // If we didn't find stale entry on backward scan, the
                // first stale entry seen while scanning for key is the
                // first still present in the run.
                if (k == null && slotToExpunge == staleSlot)
                    slotToExpunge = i;
            }

            // If key not found, put new entry in stale slot
            tab[staleSlot].value = null;
            tab[staleSlot] = new Entry(key, value);

            // If there are any other stale entries in run, expunge them
            if (slotToExpunge != staleSlot)
                cleanSomeSlots(expungeStaleEntry(slotToExpunge), len);
        }
```


### expungeStaleEntry(int staleSlot)（看不懂）
* 通过重新处理staleSlot和下一个空槽之间的任何可能碰撞的条目来清除过时的条目
```
private int expungeStaleEntry(int staleSlot) {
            Entry[] tab = table;
            int len = tab.length;

            // expunge entry at staleSlot
            tab[staleSlot].value = null;
            tab[staleSlot] = null;
            size--;

            // Rehash until we encounter null
            Entry e;
            int i;
            for (i = nextIndex(staleSlot, len);
                 (e = tab[i]) != null;
                 i = nextIndex(i, len)) {
                ThreadLocal<?> k = e.get();
                if (k == null) {
                    e.value = null;
                    tab[i] = null;
                    size--;
                } else {
                    int h = k.threadLocalHashCode & (len - 1);
                    if (h != i) {
                        tab[i] = null;

                        // Unlike Knuth 6.4 Algorithm R, we must scan until
                        // null because multiple entries could have been stale.
                        while (tab[h] != null)
                            h = nextIndex(h, len);
                        tab[h] = e;
                    }
                }
            }
            return i;
        }
```


### cleanSomeSlots(int i, int n)
* 尝试扫描一些寻找陈旧条目的单元格
```
private boolean cleanSomeSlots(int i, int n) {
            boolean removed = false;
            Entry[] tab = table;
            int len = tab.length;
            do {
                i = nextIndex(i, len);
                Entry e = tab[i];
                if (e != null && e.get() == null) {
                    n = len;
                    removed = true;
                    i = expungeStaleEntry(i);//通过重新处理staleSlot和下一个空槽之间的任何可能碰撞的条目来清除过时的条目
                }
            } while ( (n >>>= 1) != 0);
            return removed;
        }
```


### rehash()
```
private void rehash() {
            expungeStaleEntries();//通过重新处理staleSlot和下一个空槽之间的任何可能碰撞的条目来清除过时的条目

            // Use lower threshold for doubling to avoid hysteresis
            if (size >= threshold - threshold / 4)//大于3/4就扩容
                resize();
        }
```


### resize() 
```
private void resize() {
            Entry[] oldTab = table;
            int oldLen = oldTab.length;
            int newLen = oldLen * 2;//两倍
            Entry[] newTab = new Entry[newLen];
            int count = 0;

            for (Entry e : oldTab) {
                if (e != null) {//不为空
                
                    ThreadLocal<?> k = e.get();
                    if (k == null) {//线程是空的，就将值置为空
                        e.value = null; // Help the GC
                    } else {
                        int h = k.threadLocalHashCode & (newLen - 1);//重新计算桶下标
                        while (newTab[h] != null)
                            h = nextIndex(h, newLen);
                        newTab[h] = e;//设置值
                        count++;
                    }
                    
                    
                }
            }

            setThreshold(newLen);//设置阈值
            size = count;
            table = newTab;
        }
```

### expungeStaleEntries()清除表中的所有陈旧条目
```
private void expungeStaleEntries() {
            Entry[] tab = table;
            int len = tab.length;
            for (int j = 0; j < len; j++) {
                Entry e = tab[j];
                if (e != null && e.get() == null)
                    expungeStaleEntry(j);
            }
        }
```



