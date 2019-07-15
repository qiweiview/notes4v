# ConcurrentHashMap

## 属性
```
    private static final int MAXIMUM_CAPACITY = 1 << 30;//最大可能的数据量

    private static final int DEFAULT_CAPACITY = 16;//默认初始表容量。 必须是2的幂
    
    static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;//最大可能（非幂2）哈希桶长度
   
    private static final int DEFAULT_CONCURRENCY_LEVEL = 16;//默认并发级别

    private static final float LOAD_FACTOR = 0.75f;//负载因子

    static final int TREEIFY_THRESHOLD = 8;//使用树的阈值
    
    static final int UNTREEIFY_THRESHOLD = 6;//要比TREEIFY_THRESHOLD小，拆分链表的阈值
    
    static final int MIN_TREEIFY_CAPACITY = 64;
    //容器可以树化的最小容量,该值应至少为4 * TREEIFY_THRESHOLD，以避免调整大小和树化阈值之间的冲突

    private static final int MIN_TRANSFER_STRIDE = 16;
    //每次转移步骤的最小重组次数。范围细分为允许多个缩放器线程。此值用作下限以避免resizer遇到过多的内存争用。 该值至少应为DEFAULT_CAPACITY

    private static final int RESIZE_STAMP_BITS = 16;//sizeCtl中用于生成戳记的位数。 32位阵列必须至少为6。

    private static final int MAX_RESIZERS = (1 << (32 - RESIZE_STAMP_BITS)) - 1;
    //可以帮助调整大小的最大线程数

    private static final int RESIZE_STAMP_SHIFT = 32 - RESIZE_STAMP_BITS;//sizeCtl中记录大小标记的位移

    /*
     * 节点哈希字段的编码
     */
    static final int MOVED     = -1; // 转发节点的哈希值
    static final int TREEBIN   = -2; // 树的根的哈希值
    static final int RESERVED  = -3; // 暂时保留的哈希值
    
    //0111_1111_1111_1111_1111_1111_1111_1111即Integer.MAX_VALUE
    static final int HASH_BITS = 0x7fffffff; // usable bits of normal node hash
    
    
    static final int NCPU =Runtime.getRuntime().availableProcessors();//CPUS的数量，在某些情况下设置边界
    
    /**
     序列化伪字段，仅为jdk7兼容性提供
     */
    private static final ObjectStreamField[] serialPersistentFields = {
        new ObjectStreamField("segments", Segment[].class),
        new ObjectStreamField("segmentMask", Integer.TYPE),
        new ObjectStreamField("segmentShift", Integer.TYPE),
    };
    
   
    transient volatile Node<K,V>[] table;//哈系桶
  
    private transient volatile Node<K,V>[] nextTable;//下一个使用的哈希桶
   
    private transient volatile long baseCount;//基本计数器值，主要在没有争用时使用
  
    private transient volatile int sizeCtl;
    //未初始化：
    //sizeCtl=0：表示没有指定初始容量。
    //sizeCtl>0：表示初始容量。
    
    
    //初始化中：
    //sizeCtl=-1,标记作用，告知其他线程，正在初始化
   
    //正常状态：
    //sizeCtl=0.75n ,扩容阈值
    
    //扩容中：
    //sizeCtl < 0 : 表示有其他线程正在执行扩容
    //sizeCtl = (resizeStamp(n) << RESIZE_STAMP_SHIFT) + 2 :表示此时只有一个线程在执行扩容

    
   
    private transient volatile int transferIndex;//调整大小时要分割的下一个表索引（扩容索引）

    private transient volatile int cellsBusy;//调整大小或创建CounterCell时使用的Spinlock
  
    private transient volatile CounterCell[] counterCells;//计数器桶，长度为2的幂

    // 三个视图
    private transient KeySetView<K,V> keySet;
    private transient ValuesView<K,V> values;
    private transient EntrySetView<K,V> entrySet;
    
```

### sizeCtl变更示例
![](https://i.loli.net/2019/07/02/5d1b12dd3738d52612.png)


### transferIndex变化

*  在扩容之前，transferIndex 在数组的最右边 。此时有一个线程发现已经到达扩容阈值，准备开始扩容

![](https://i.loli.net/2019/07/02/5d1b1399f26b492475.png)
* 扩容线程，在迁移数据之前，首先要将transferIndex左移（以cas的方式修改 transferIndex=transferIndex-stride(要迁移hash桶的个数)），获取迁移任务。每个扩容线程都会通过for循环+CAS的方式设置transferIndex，因此可以确保多线程扩容的并发安全

![](https://i.loli.net/2019/07/02/5d1b13bc5b2b945658.png)

## 通过Unsafe类获取属性偏移量
```
// Unsafe mechanics
    private static final Unsafe U = Unsafe.getUnsafe();
    private static final long SIZECTL;
    private static final long TRANSFERINDEX;
    private static final long BASECOUNT;
    private static final long CELLSBUSY;
    private static final long CELLVALUE;
    private static final int ABASE;
    private static final int ASHIFT;

    static {
        SIZECTL = U.objectFieldOffset
            (ConcurrentHashMap.class, "sizeCtl");//返回对象成员属性在内存地址相对于此对象的内存地址的偏移量
        TRANSFERINDEX = U.objectFieldOffset
            (ConcurrentHashMap.class, "transferIndex");
        BASECOUNT = U.objectFieldOffset
            (ConcurrentHashMap.class, "baseCount");
        CELLSBUSY = U.objectFieldOffset
            (ConcurrentHashMap.class, "cellsBusy");

        CELLVALUE = U.objectFieldOffset
            (CounterCell.class, "value");

        ABASE = U.arrayBaseOffset(Node[].class);//返回数组中第一个元素的偏移地址
        
        int scale = U.arrayIndexScale(Node[].class);//返回数组中一个元素占用的大小
        
        if ((scale & (scale - 1)) != 0)
            throw new ExceptionInInitializerError("array index scale not a power of two");
        ASHIFT = 31 - Integer.numberOfLeadingZeros(scale);

        // Reduce the risk of rare disastrous classloading in first call to
        // LockSupport.park: https://bugs.openjdk.java.net/browse/JDK-8074773
        Class<?> ensureLoaded = LockSupport.class;

        // Eager class load observed to help JIT during startup
        ensureLoaded = ReservationNode.class;
    }
```

## 静态工具
```

    //hash算法
    static final int spread(int h) {
        return (h ^ (h >>> 16)) & HASH_BITS;//高16位和低16位异或结果，再与上HASH_BITS
    }

   //返回给定所需容量的两个表大小的幂
    private static final int tableSizeFor(int c) {
        int n = -1 >>> Integer.numberOfLeadingZeros(c - 1);
        return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
    }

   //如果它是“C类实现”的形式，则返回x的类
    static Class<?> comparableClassFor(Object x) {
        if (x instanceof Comparable) {//实现了Comparable接口
            Class<?> c; Type[] ts, as; ParameterizedType p;
            if ((c = x.getClass()) == String.class) //String绕过检查
                return c;
            if ((ts = c.getGenericInterfaces()) != null) {//实现了接口
                for (Type t : ts) {
                    if ((t instanceof ParameterizedType) &&
                        ((p = (ParameterizedType)t).getRawType() ==
                         Comparable.class) &&
                        (as = p.getActualTypeArguments()) != null &&
                        as.length == 1 && as[0] == c) // type arg is c
                        return c;
                }
            }
        }
        return null;
    }

   //如果x与kc匹配，则返回k.compareTo（x）
    @SuppressWarnings({"rawtypes","unchecked"}) // for cast to Comparable
    static int compareComparables(Class<?> kc, Object k, Object x) {
        return (x == null || x.getClass() != kc ? 0 :
                ((Comparable)k).compareTo(x));
    }
```


## Cas原子操作
```
    //以volatile读的方式读取table数组中的元素
    @SuppressWarnings("unchecked")
    static final <K,V> Node<K,V> tabAt(Node<K,V>[] tab, int i) {
        return (Node<K,V>)U.getObjectAcquire(tab, ((long)i << ASHIFT) + ABASE);
    }


    //以CAS的方式，将元素插入table数组
    static final <K,V> boolean casTabAt(Node<K,V>[] tab, int i,Node<K,V> c, Node<K,V> v) {
       //原子的执行如下逻辑：如果tab[i]==c,则设置tab[i]=v，并返回ture.否则返回false
        return U.compareAndSetObject(tab, ((long)i << ASHIFT) + ABASE, c, v);
    }


    //以volatile写的方式，将元素插入table数组
    static final <K,V> void setTabAt(Node<K,V>[] tab, int i, Node<K,V> v) {
        U.putObjectRelease(tab, ((long)i << ASHIFT) + ABASE, v);
    }
```

## 节点类

### Node(key和val永远不会为空)
```
    static class Node<K,V> implements Map.Entry<K,V> {
        final int hash;
        final K key;
        volatile V val;
        volatile Node<K,V> next;

        Node(int hash, K key, V val) {
            this.hash = hash;
            this.key = key;
            this.val = val;
        }

        Node(int hash, K key, V val, Node<K,V> next) {
            this(hash, key, val);
            this.next = next;
        }

        public final K getKey()     { return key; }
        public final V getValue()   { return val; }
        public final int hashCode() { return key.hashCode() ^ val.hashCode(); }
        public final String toString() {
            return Helpers.mapEntryToString(key, val);
        }
        public final V setValue(V value) {
            throw new UnsupportedOperationException();
        }

        public final boolean equals(Object o) {
            Object k, v, u; Map.Entry<?,?> e;
            return ((o instanceof Map.Entry) &&//子类
                    (k = (e = (Map.Entry<?,?>)o).getKey()) != null &&//key不是空的
                    (v = e.getValue()) != null &&//value不是空的
                    (k == key || k.equals(key)) &&//key相等
                    (v == (u = val) || v.equals(u)));//value相等
        }

        /**
         * Virtualized support for map.get(); overridden in subclasses.
         */
        Node<K,V> find(int h, Object k) {
            Node<K,V> e = this;
            if (k != null) {
                do {
                    K ek;
                    if (e.hash == h &&
                        ((ek = e.key) == k || (ek != null && k.equals(ek))))
                        return e;
                } while ((e = e.next) != null);
            }
            return null;
        }
    }
```

### ForwardingNode 在传输操作期间插入哈希桶头部的节点(该类仅仅只存活在ConcurrentHashMap扩容操作时)
```
static final class ForwardingNode<K,V> extends Node<K,V> {
        final Node<K,V>[] nextTable;
        ForwardingNode(Node<K,V>[] tab) {
            super(MOVED, null, null);
            this.nextTable = tab;
        }

        Node<K,V> find(int h, Object k) {
            // 循环以避免转发节点上的任意深度递归
            outer: for (Node<K,V>[] tab = nextTable;;) {
                Node<K,V> e; int n;
                if (k == null || tab == null || (n = tab.length) == 0 ||
                    (e = tabAt(tab, (n - 1) & h)) == null)
                    return null;
                for (;;) {
                    int eh; K ek;
                    if ((eh = e.hash) == h &&
                        ((ek = e.key) == k || (ek != null && k.equals(ek))))
                        return e;
                    
                    if (eh < 0) {
                        if (e instanceof ForwardingNode) {
                            tab = ((ForwardingNode<K,V>)e).nextTable;
                            continue outer;
                        }
                        else
                            return e.find(h, k);
                    }
                    
                    if ((e = e.next) == null)
                        return null;
                }
            }
        }
    }
```

### ReservationNode(不理解作用)
```
 static final class ReservationNode<K,V> extends Node<K,V> {
        ReservationNode() {
            super(RESERVED, null, null);
        }

        Node<K,V> find(int h, Object k) {
            return null;
        }
    }
```


## 构造方法

### ConcurrentHashMap()创建一个映射，默认容量大小16
```
 public ConcurrentHashMap() {
    }
```

### ConcurrentHashMap(int initialCapacity)指定默认容量
```
 public ConcurrentHashMap(int initialCapacity) {
        this(initialCapacity, LOAD_FACTOR, 1);
    }
```

### ConcurrentHashMap(Map<? extends K, ? extends V> m)放入一个集合
```
 public ConcurrentHashMap(Map<? extends K, ? extends V> m) {
        this.sizeCtl = DEFAULT_CAPACITY;
        putAll(m);
    }
```


### ConcurrentHashMap(int initialCapacity, float loadFactor)设置初始容量和负载因子
```
public ConcurrentHashMap(int initialCapacity, float loadFactor) {
        this(initialCapacity, loadFactor, 1);
    }
```

#### ConcurrentHashMap(int initialCapacity,float loadFactor, int concurrencyLevel)设置初始容量，负载因子和和并发级别
```
 public ConcurrentHashMap(int initialCapacity,
                             float loadFactor, int concurrencyLevel) {
        if (!(loadFactor > 0.0f) || initialCapacity < 0 || concurrencyLevel <= 0)//错误的参数
            throw new IllegalArgumentException();
        if (initialCapacity < concurrencyLevel)   //使用尽可能多的哈系桶
            initialCapacity = concurrencyLevel;   //设置估计线程
        long size = (long)(1.0 + (long)initialCapacity / loadFactor);//计算哈希桶容量
        int cap = (size >= (long)MAXIMUM_CAPACITY) ?
            MAXIMUM_CAPACITY : tableSizeFor((int)size);
        this.sizeCtl = cap;
    }
```

//返回大于c的最小2次幂
```
private static final int tableSizeFor(int c) {
        int n = -1 >>> Integer.numberOfLeadingZeros(c - 1);
        return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
    }
```

## 方法

### size
```
public int size() {
        long n = sumCount();
        return ((n < 0L) ? 0 :
                (n > (long)Integer.MAX_VALUE) ? Integer.MAX_VALUE :
                (int)n);
    }
```

### mappingCount()Map 的长度是有可能超过 int 最大值，所以使用long
```
public long mappingCount() {
        long n = sumCount();
        return (n < 0L) ? 0L : n; // ignore transient negative values
    }
```

### sumCount
* 在没有并发的情况下，使用一个 baseCount volatile 变量就足够了
* 当并发的时候，CAS 修改 baseCount 失败后，就会使用 CounterCell 类了，会创建一个这个对象，通常对象的 volatile value 属性是 1。
* 在计算 size 的时候，会将 baseCount 和 CounterCell 数组中的元素的 value 累加，得到总的大小，但这个数字仍旧可能是不准确的
```
final long sumCount() {
        CounterCell[] cs = counterCells;
        long sum = baseCount;
        if (cs != null) {//当counterCells不是null
            for (CounterCell c : cs)
                if (c != null)
                    sum += c.value;//就遍历元素，并和baseCount累加
        }
        return sum;
    }
```


### 是否为空
```
 public boolean isEmpty() {
        return sumCount() <= 0L; // ignore transient negative values
    }
```




### 类CounterCell
```
//注解防止“伪共享”
    @jdk.internal.vm.annotation.Contended static final class CounterCell {
        volatile long value;
        CounterCell(long x) { value = x; }
    }
```


### get(Object key)返回指定键映射到的值
```
public V get(Object key) {
        Node<K,V>[] tab; Node<K,V> e, p; int n, eh; K ek;
        int h = spread(key.hashCode());//计算出hash
        if ((tab = table) != null && (n = tab.length) > 0 &&
            (e = tabAt(tab, (n - 1) & h)) != null) {//通过tabAt方法从tab中获取(n - 1) & h)索引节点
            if ((eh = e.hash) == h) {//判断节点的hash值和计算的哈希值
                if ((ek = e.key) == key || (ek != null && key.equals(ek)))//判断节点的key和传入的key
                    return e.val;//返回节点的值
            }
            else if (eh < 0)//如果eh<0 说明这个节点在树上 直接寻找（不理解）
                return (p = e.find(h, key)) != null ? p.val : null;
            while ((e = e.next) != null) {
                if (e.hash == h &&
                    ((ek = e.key) == key || (ek != null && key.equals(ek))))
                    return e.val;
            }
        }
        return null;
    }
```

### containsKey(Object key)是否存在key的映射
```
 public boolean containsKey(Object key) {
        return get(key) != null;//调用get
    }
```

### containsValue(Object value)是否存在value的映射
```
public boolean containsValue(Object value) {
        if (value == null)
            throw new NullPointerException();
        Node<K,V>[] t;
        if ((t = table) != null) {//桶不为空
            Traverser<K,V> it = new Traverser<K,V>(t, t.length, 0, t.length);
            for (Node<K,V> p; (p = it.advance()) != null; ) {//使用迭代器迭代
                V v;
                if ((v = p.val) == value || (v != null && value.equals(v)))
                    return true;
            }
        }
        return false;
    }
```

### Traverser 类
* 封装诸如containsValue之类的方法的遍历;
* 也可以作为其他迭代器和分裂器的基类
```
static class Traverser<K,V> {
        Node<K,V>[] tab;        // 当前桶，桶大小变化时候更新
        Node<K,V> next;         // 下一个指针
        TableStack<K,V> stack, spare; // 在ForwardingNodes上保存/恢复
        int index;              // 接下来要使用的bin索引
        int baseIndex;          // 初始桶的当前索引
        int baseLimit;          // 初始桶的索引绑定
        final int baseSize;     // 初始桶大小

        Traverser(Node<K,V>[] tab, int size, int index, int limit) {
            this.tab = tab;
            this.baseSize = size;
            this.baseIndex = this.index = index;
            this.baseLimit = limit;
            this.next = null;
        }

        /**
         * 如果可能，前进，返回下一个有效节点，否则返回null
         */
        final Node<K,V> advance() {
            Node<K,V> e;
            if ((e = next) != null)
                e = e.next;
            for (;;) {
                Node<K,V>[] t; int i, n;  // must use locals in checks
                if (e != null)
                    return next = e;
                if (baseIndex >= baseLimit || (t = tab) == null ||
                    (n = t.length) <= (i = index) || i < 0)
                    return next = null;
                if ((e = tabAt(t, i)) != null && e.hash < 0) {
                    if (e instanceof ForwardingNode) {
                        tab = ((ForwardingNode<K,V>)e).nextTable;
                        e = null;
                        pushState(t, i, n);
                        continue;
                    }
                    else if (e instanceof TreeBin)
                        e = ((TreeBin<K,V>)e).first;
                    else
                        e = null;
                }
                if (stack != null)
                    recoverState(n);
                else if ((index = i + baseSize) >= n)
                    index = ++baseIndex; // visit upper slots if present
            }
        }

        /**
         * 遇到转发节点时保存遍历状态
         */
        private void pushState(Node<K,V>[] t, int i, int n) {
            TableStack<K,V> s = spare;  // reuse if possible
            if (s != null)
                spare = s.next;
            else
                s = new TableStack<K,V>();
            s.tab = t;
            s.length = n;
            s.index = i;
            s.next = stack;
            stack = s;
        }

        /**
         * 可能会出现遍历状态
         *
         * @param n length of current table
         */
        private void recoverState(int n) {
            TableStack<K,V> s; int len;
            while ((s = stack) != null && (index += (len = s.length)) >= n) {
                n = len;
                index = s.index;
                tab = s.tab;
                s.tab = null;
                TableStack<K,V> next = s.next;
                s.next = spare; // save for reuse
                stack = next;
                spare = s;
            }
            if (s == null && (index += baseSize) >= n)
                index = ++baseIndex;
        }
    }
```

### put(K key, V value)将指定的键映射到此表中的指定值。 密钥和值都不能为空
```
 public V put(K key, V value) {
        return putVal(key, value, false);
    }
```

### putVal(K key, V value, boolean onlyIfAbsent)
```
final V putVal(K key, V value, boolean onlyIfAbsent) {
        if (key == null || value == null) throw new NullPointerException();//两个都不可以为空
        int hash = spread(key.hashCode());//获取hash
        int binCount = 0;
        
        for (Node<K,V>[] tab = table;;) {
            Node<K,V> f; int n, i, fh; K fk; V fv;
            if (tab == null || (n = tab.length) == 0)//空桶
                tab = initTable();//初始化哈希桶
            else if ((f = tabAt(tab, i = (n - 1) & hash)) == null) {//桶位处元素为空
                if (casTabAt(tab, i, null, new Node<K,V>(hash, key, value)))//以null为期望值进行CAS操作
                    break;                   //添加到空箱时没有锁定
            }
            else if ((fh = f.hash) == MOVED)//值为MOVED(-1),则有其他线程在执行扩容操作,帮助他们一起扩容,提高性能
                tab = helpTransfer(tab, f);
            else if (onlyIfAbsent // 检查第一个节点而不获取锁定（put方法onlyIfAbsent=false不会进去）
                     && fh == hash
                     && ((fk = f.key) == key || (fk != null && key.equals(fk)))
                     && (fv = f.val) != null)
                return fv;
            else {// 如果 hash 冲突了，且 hash 值不为 -1
                V oldVal = null;
                synchronized (f) {// 同步 f 节点，防止增加链表的时候导致链表成环
                
                    if (tabAt(tab, i) == f) {//原子获取值
                        
                        if (fh >= 0) {
                            binCount = 1;
                            for (Node<K,V> e = f;; ++binCount) {
                            
                                K ek;
                                
                                if (e.hash == hash&&
                                ((ek = e.key) == key||
                                (ek != null && key.equals(ek)))) {
                                     
                                    oldVal = e.val;
                                    if (!onlyIfAbsent)
                                        e.val = value;//覆盖旧值
                                    break;
                                    
                                }
                                
                                //一个相等都没有，会走到这步(不清楚为什么还会出现没有相等的情况)↓
                                
                                
                                Node<K,V> pred = e;
                                
                                if ((e = e.next) == null) {//迭代到结尾
                                    pred.next = new Node<K,V>(hash, key, value);//追加到尾部
                                    break;
                                }
                                
                                
                            }
                        }
                        else if (f instanceof TreeBin) {//如果 f 节点的 hash 小于0 并且f 是 树类型
                            
                            Node<K,V> p;
                            binCount = 2;
                            if ((p = ((TreeBin<K,V>)f).putTreeVal(hash, key,value)) != null) {
                                oldVal = p.val;
                                if (!onlyIfAbsent)
                                    p.val = value;
                            }
                            
                        }
                        else if (f instanceof ReservationNode)//如果是ReservationNode抛出异常
                            throw new IllegalStateException("Recursive update");
                            
                    }
                    
                    
                }//同步块结束
                
                if (binCount != 0) {
                    if (binCount >= TREEIFY_THRESHOLD) //链表长度大于等于8时，将该节点改成红黑树树
                        treeifyBin(tab, i);
                    if (oldVal != null)
                        return oldVal;
                    break;
                }
            }
        }
        addCount(1L, binCount);
        return null;
    }
```

### initTable()使用sizeCtl中记录的大小初始化表
```
 private final Node<K,V>[] initTable() {
        Node<K,V>[] tab; int sc;
        while ((tab = table) == null || tab.length == 0) {
        
        
    //当sizeCtl为负时，表正在初始化或调整大小：-1表示初始化，否则 - （1 +活动大小调整线程数）。
    //否则，当table为null时，保留要在创建时使用的初始表大小，或者默认为0。
    //初始化之后，保存下一个元素计数值，在该值上调整表的大小。
            if ((sc = sizeCtl) < 0)
                Thread.yield(); //代表table正在初始化,其他线程应该交出CPU时间片（会一直在这里循环）
            else if (U.compareAndSetInt(this, SIZECTL, sc, -1)) { //cas执行置-1操作，成功返回true
                
                try {
                    if ((tab = table) == null || tab.length == 0) {//空的哈希桶
                        int n = (sc > 0) ? sc : DEFAULT_CAPACITY;
                        @SuppressWarnings("unchecked")
                        Node<K,V>[] nt = (Node<K,V>[])new Node<?,?>[n];//构造一个长度为n的节点数组
                        table = tab = nt;
                        sc = n - (n >>> 2);//右移两位
                    }
                } finally {
                    sizeCtl = sc;
                }
                
                break;//跳出循环
            }
        }
        return tab;
    }
```


### helpTransfer(Node<K,V>[] tab, Node<K,V> f)如果正在扩容，帮助扩容
```
final Node<K,V>[] helpTransfer(Node<K,V>[] tab, Node<K,V> f) {
        Node<K,V>[] nextTab; int sc;
        
    // 如果 table 不是空 且 node 节点是转移类型，数据检验
    // 且 node 节点的 nextTable（新 table） 不是空，同样也是数据校验
    // 尝试帮助扩容
        if (tab != null && (f instanceof ForwardingNode) &&
            (nextTab = ((ForwardingNode<K,V>)f).nextTable) != null) {
            int rs = resizeStamp(tab.length) << RESIZE_STAMP_SHIFT;
            
        // 如果 nextTab 没有被并发修改 且 tab 也没有被并发修改
        // 且 sizeCtl  < 0 （说明还在扩容）
            while (nextTab == nextTable && table == tab &&(sc = sizeCtl) < 0) {
            
            // 如果 sizeCtl 无符号右移  16 不等于 rs （ sc前 16 位如果不等于标识符，则标识符变化了）
            // 或者 sizeCtl == rs + 1  （扩容结束了，不再有线程进行扩容）（默认第一个线程设置 sc ==rs 左移 16 位 + 2，当第一个线程结束扩容了，就会将 sc 减一。这个时候，sc 就等于 rs + 1）
            // 或者 sizeCtl == rs + 65535  （如果达到最大帮助线程的数量，即 65535）
            // 或者转移下标正在调整 （扩容结束）
            // 结束循环，返回 table
                if (sc == rs + MAX_RESIZERS || sc == rs + 1 ||transferIndex <= 0)
                    break;
                    
                 // 如果以上都不是, 将 sizeCtl + 1, （表示增加了一个线程帮助其扩容）    
                if (U.compareAndSetInt(this, SIZECTL, sc, sc + 1)) {
                
                    // 进行转移
                    transfer(tab, nextTab);
                    break;
                }
                
                
            }
            return nextTab;
        }
        return table;
    }
```

### resizeStamp(int n)返回用于调整大小为n的表的标记位。 当RESIZE_STAMP_SHIFT向左移动时必须为负数。
```
 static final int resizeStamp(int n) {
        return Integer.numberOfLeadingZeros(n) | (1 << (RESIZE_STAMP_BITS - 1));
    }
```

### addCount(long x, int check)
* 参数x要添加的计数
* 参数check如果<0，则不检查调整大小，如果<= 1则仅检查是否无竞争
* 添加计数，如果表太小而且尚未调整大小，则转移
* 如果已经调整大小，则在工作可用时帮助执行转移
* 在转移后重新检查占用情况，看是否已经需要另一个调整大小，因为限制是增加的
* 主要作用：
1. 对 table 的长度加一。无论是通过修改 baseCount，还是通过使用 CounterCell。当 CounterCell 被初始化了，就优先使用他，不再使用 baseCount。
2. 检查是否需要扩容，或者是否正在扩容。如果需要扩容，就调用扩容方法，如果正在扩容，就帮助其扩容。


```
private final void addCount(long x, int check) {
             //参数x表示的此次需要对表中元素的个数加几

        CounterCell[] cs; long b, s;
        
        // 如果计数盒子不是空 或者
        // 如果修改 baseCount(cas加法) 失败
        if ((cs = counterCells) != null ||!U.compareAndSetLong(this, BASECOUNT, b = baseCount, s = b + x)) {//设置了baseCount 
            
            CounterCell c; long v; int m;
            boolean uncontended = true;
            
        // 如果计数盒子是空（尚未出现并发）
        // 如果随机取余一个数组位置为空 或者
        // 修改这个槽位的变量失败（出现并发了）
        // 执行 fullAddCount 方法。并结束
            if (cs == null || (m = cs.length - 1) < 0 ||
                (c = cs[ThreadLocalRandom.getProbe() & m]) == null ||
                !(uncontended =U.compareAndSetLong(c, CELLVALUE, v = c.value, v + x))) {
                fullAddCount(x, uncontended);//重新死循环插入
                return;
            }
            if (check <= 1)//不需要检查扩容
                return;//直接返回
            s = sumCount();
        }
        
        
        //check 参数表示是否需要进行扩容检查，大于等于0 需要进行检查（在putVal 方法中的 binCount 参数最小也是 0 ，因此，每次添加元素都会进行检查）
        if (check >= 0) {
            Node<K,V>[] tab, nt; int n, sc;
            
        // 如果map.size() 大于 sizeCtl（达到扩容阈值需要扩容） 且table 不是空；且 table 的长度小于 1 << 30（可以扩容）,那么久扩容
            while (s >= (long)(sc = sizeCtl) && (tab = table) != null &&
                   (n = tab.length) < MAXIMUM_CAPACITY) {
                   
                int rs = resizeStamp(n) << RESIZE_STAMP_SHIFT;
                if (sc < 0) {
                
                // 如果 sc 的低 16 位不等于 标识符（校验异常 sizeCtl 变化了）
                // 如果 sc == 标识符 + 1 （扩容结束了，不再有线程进行扩容）（默认第一个线程设置 sc ==rs 左移 16 位 + 2，当第一个线程结束扩容了，就会将 sc 减一。这个时候，sc 就等于 rs + 1）
                // 如果 sc == 标识符 + 65535（帮助线程数已经达到最大）
                // 如果 nextTable == null（结束扩容了）
                // 如果 transferIndex <= 0 (转移状态变化了)
                // 结束循环
                    if (sc == rs + MAX_RESIZERS || sc == rs + 1 ||
                        (nt = nextTable) == null || transferIndex <= 0)
                        break;
                        
                // 如果可以帮助扩容，那么将 sc 加 1. 表示多了一个线程在帮助扩容        
                    if (U.compareAndSetInt(this, SIZECTL, sc, sc + 1))
                        transfer(tab, nt);
                }
            
                // 如果不在扩容，将 sc 更新：标识符左移 16 位 然后 + 2. 也就是变成一个负数。高 16 位是标识符，低 16 位初始是 2.
                else if (U.compareAndSetInt(this, SIZECTL, sc, rs + 2))
                    transfer(tab, null);
                s = sumCount();
                
                
            }
        }
    }
```

### fullAddCount(long x, boolean wasUncontended)
```
 private final void fullAddCount(long x, boolean wasUncontended) {
        int h;
        if ((h = ThreadLocalRandom.getProbe()) == 0) {
            ThreadLocalRandom.localInit();      // force initialization
            h = ThreadLocalRandom.getProbe();
            wasUncontended = true;
        }
        boolean collide = false;                // True if last slot nonempty
        for (;;) {
            CounterCell[] cs; CounterCell c; int n; long v;
            if ((cs = counterCells) != null && (n = cs.length) > 0) {
                if ((c = cs[(n - 1) & h]) == null) {
                    if (cellsBusy == 0) {            // Try to attach new Cell
                        CounterCell r = new CounterCell(x); // Optimistic create
                        if (cellsBusy == 0 &&
                            U.compareAndSetInt(this, CELLSBUSY, 0, 1)) {
                            boolean created = false;
                            try {               // Recheck under lock
                                CounterCell[] rs; int m, j;
                                if ((rs = counterCells) != null &&
                                    (m = rs.length) > 0 &&
                                    rs[j = (m - 1) & h] == null) {
                                    rs[j] = r;
                                    created = true;
                                }
                            } finally {
                                cellsBusy = 0;
                            }
                            if (created)
                                break;
                            continue;           // Slot is now non-empty
                        }
                    }
                    collide = false;
                }
                else if (!wasUncontended)       // CAS already known to fail
                    wasUncontended = true;      // Continue after rehash
                else if (U.compareAndSetLong(c, CELLVALUE, v = c.value, v + x))
                    break;
                else if (counterCells != cs || n >= NCPU)
                    collide = false;            // At max size or stale
                else if (!collide)
                    collide = true;
                else if (cellsBusy == 0 &&
                         U.compareAndSetInt(this, CELLSBUSY, 0, 1)) {
                    try {
                        if (counterCells == cs) // Expand table unless stale
                            counterCells = Arrays.copyOf(cs, n << 1);
                    } finally {
                        cellsBusy = 0;
                    }
                    collide = false;
                    continue;                   // Retry with expanded table
                }
                h = ThreadLocalRandom.advanceProbe(h);
            }
            else if (cellsBusy == 0 && counterCells == cs &&
                     U.compareAndSetInt(this, CELLSBUSY, 0, 1)) {
                boolean init = false;
                try {                           // Initialize table
                    if (counterCells == cs) {
                        CounterCell[] rs = new CounterCell[2];
                        rs[h & 1] = new CounterCell(x);
                        counterCells = rs;
                        init = true;
                    }
                } finally {
                    cellsBusy = 0;
                }
                if (init)
                    break;
            }
            else if (U.compareAndSetLong(this, BASECOUNT, v = baseCount, v + x))
                break;                          // Fall back on using base
        }
    }
```


### transfer(Node<K,V>[] tab, Node<K,V>[] nextTab) 
```
private final void transfer(Node<K,V>[] tab, Node<K,V>[] nextTab) {
        int n = tab.length, stride;
        // 将 length / 8 然后除以 CPU核心数。如果得到的结果小于 16，那么就使用 16。
        // 这里的目的是让每个 CPU 处理的桶一样多，避免出现转移任务不均匀的现象，如果桶较少的话，默认一个 CPU（一个线程）处理 16 个桶
        if ((stride = (NCPU > 1) ? (n >>> 3) / NCPU : n) < MIN_TRANSFER_STRIDE)
            stride = MIN_TRANSFER_STRIDE; // subdivide range
        if (nextTab == null) {   // 新的 table 尚未初始化
        
            try {
                @SuppressWarnings("unchecked")
                Node<K,V>[] nt = (Node<K,V>[])new Node<?,?>[n << 1];// 扩容  2 倍
                nextTab = nt;
            } catch (Throwable ex) {      // try to cope with OOME
                sizeCtl = Integer.MAX_VALUE; // 扩容失败， sizeCtl 使用 int 最大值。
                return;
            }
            nextTable = nextTab;// 更新成员变量
            transferIndex = n;// 更新转移下标（就是 老的 tab 的 length）
        }
        
        
        int nextn = nextTab.length;// 新 tab 的 length
        ForwardingNode<K,V> fwd = new ForwardingNode<K,V>(nextTab); // 创建一个 fwd 节点，用于占位。当别的线程发现这个槽位中是 fwd 类型的节点，则跳过这个节点。
        boolean advance = true;// 首次推进为 true，如果等于 true，说明需要再次推进一个下标（i--），反之，如果是 false，那么就不能推进下标，需要将当前的下标处理完毕才能继续推进
        boolean finishing = false; // 完成状态，如果是 true，就结束此方法
        
        for (int i = 0, bound = 0;;) { // 循环,i 表示下标，bound 表示当前线程可以处理的当前桶区间最小下标
            Node<K,V> f; int fh;
            
            // 如果当前线程可以向后推进；这个循环就是控制 i 递减。同时，每个线程都会进入这里取得自己需要转移的桶的区间
            while (advance) {
               int nextIndex, nextBound;
               
            // 对 i 减一，判断是否大于等于 bound （正常情况下，如果大于 bound 不成立，说明该线程上次领取的任务已经完成了。那么，需要在下面继续领取任务）
            // 如果对 i 减一大于等于 bound（还需要继续做任务），或者完成了，修改推进状态为 false，不能推进了。任务成功后修改推进状态为 true。
            // 通常，第一次进入循环，i-- 这个判断会无法通过，从而走下面的 nextIndex 赋值操作（获取最新的转移下标）。其余情况都是：如果可以推进，将 i 减一，然后修改成不可推进。如果 i 对应的桶处理成功了，改成可以推进。
            if (--i >= bound || finishing)
            
                advance = false;// 这里设置false，是为了防止在没有成功处理一个桶的情况下却进行了推进
            // 这里的目的是：1. 当一个线程进入时，会选取最新的转移下标。2. 当一个线程处理完自己的区间时，如果还有剩余区间的没有别的线程处理。再次获取区间。
            
                else if ((nextIndex = transferIndex) <= 0) {
                
                 // 如果小于等于0，说明没有区间了，i改成-1，推进状态变成false，不再推进，表示，扩容结束了，当前线程可以退出了
                i = -1;// 这个 -1 会在下面的 if 块里判断，从而进入完成状态判断
                advance = false;// 这里设置false，是为了防止在没有成功处理一个桶的情况下却进行了推进
                
            }// CAS 修改 transferIndex，即 length - 区间值，留下剩余的区间值供后面的线程使用
                else if (U.compareAndSetInt
                         (this, TRANSFERINDEX, nextIndex,
                          nextBound = (nextIndex > stride ?
                                       nextIndex - stride : 0))) {
                                       
                bound = nextBound;// 这个值就是当前线程可以处理的最小当前区间最小下标
                i = nextIndex - 1; // 初次对i 赋值，这个就是当前线程可以处理的当前区间的最大下标
                advance = false; // 这里设置 false，是为了防止在没有成功处理一个桶的情况下却进行了推进，这样对导致漏掉某个桶。下面的 if (tabAt(tab, i) == f) 判断会出现这样的情况。
                
                }
            }
            
        //  如果 i 小于0 （不在 tab 下标内，按照上面的判断，领取最后一段区间的线程扩容结束）
        //  如果 i >= tab.length(不知道为什么这么判断)
        //  如果 i + tab.length >= nextTable.length  （不知道为什么这么判断）
            if (i < 0 || i >= n || i + n >= nextn) {
                int sc;
                if (finishing) {// 如果完成了扩容
                
                nextTable = null;// 删除成员变量
                table = nextTab;// 更新 table
                sizeCtl = (n << 1) - (n >>> 1); // 更新阈值
                return;// 结束方法
                
                }
                if (U.compareAndSetInt(this, SIZECTL, sc = sizeCtl, sc - 1)) {//没有完成
                   if ((sc - 2) != resizeStamp(n) << RESIZE_STAMP_SHIFT)// 如果 sc-2不等于标识符左移 16 位。如果他们相等了，说明没有线程在帮助他们扩容了。也就是说，扩容结束了。
                return;// 不相等，说明没结束，当前线程结束方法。
                finishing = advance = true;// 如果相等，扩容结束了，更新 finising 变量
                i = n; // 再次循环检查一下整张表
                }
            }
            else if ((f = tabAt(tab, i)) == null)// 获取老 tab i 下标位置的变量，如果是 null，就使用 fwd 占位
                advance = casTabAt(tab, i, null, fwd);// 如果成功写入 fwd 占位，再次推进一个下标
            else if ((fh = f.hash) == MOVED)// 如果不是 null 且 hash 值是 MOVED
                advance = true; // 说明别的线程已经处理过了，再次推进一个下标
            else {// 到这里，说明这个位置有实际值了，且不是占位符。对这个节点上锁。为什么上锁，防止 putVal 的时候向链表插入数据
                synchronized (f) {
                    if (tabAt(tab, i) == f) {  // 判断 i 下标处的桶节点是否和 f 相同
                        Node<K,V> ln, hn;
                        if (fh >= 0) {
                        //对旧的长度进行与运算（第一个操作数的的第n位于第二个操作数的第n位如果都是1，那么结果的第n为也为1，否则为0）
                        //由于 Map 的长度都是 2 的次方（000001000 这类的数字），那么取于 length 只有 2 种结果，一种是 0，一种是1
                        //如果是结果是0 ，Doug Lea 将其放在低位，反之放在高位，目的是将链表重新 hash，放到对应的位置上，让新的取于算法能够击中他。
                            int runBit = fh & n;
                            Node<K,V> lastRun = f;
                            for (Node<K,V> p = f.next; p != null; p = p.next) {// 遍历这个桶
                                int b = p.hash & n;
                                if (b != runBit) {
                                runBit = b; // 更新runBit，用于下面判断lastRun该赋值给ln还是hn

                            lastRun=p;
                            //这个lastRun保证后面的节点与自己的取于值相同，避免后面没有必要的循环
                                }
                            }
                            if (runBit == 0) {// 如果最后更新的 runBit 是 0 ，设置低位节点
                                ln = lastRun;
                                hn = null;
                            }
                            else {
                                hn = lastRun;// 如果最后更新的 runBit 是 1， 设置高位节点
                                ln = null;
                            }
                            
                        //再次循环，生成两个链表，lastRun作为停止条件，这样就是避免无谓的循环（lastRun 后面都是相同的取于结果）
                            for (Node<K,V> p = f; p != lastRun; p = p.next) {
                                int ph = p.hash; K pk = p.key; V pv = p.val;
                                if ((ph & n) == 0)
                                    ln = new Node<K,V>(ph, pk, pv, ln);
                                else
                                    hn = new Node<K,V>(ph, pk, pv, hn);
                            }
                        // 其实这里类似 hashMap 
                        // 设置低位链表放在新链表的 i
                        setTabAt(nextTab, i, ln);
                        // 设置高位链表，在原有长度上加 n
                        setTabAt(nextTab, i + n, hn);
                        // 将旧的链表设置成占位符
                        setTabAt(tab, i, fwd);
                        // 继续向后推进
                        advance = true;
                        }
                        else if (f instanceof TreeBin) {// 如果是红黑树
                            TreeBin<K,V> t = (TreeBin<K,V>)f;
                            TreeNode<K,V> lo = null, loTail = null;
                            TreeNode<K,V> hi = null, hiTail = null;
                            int lc = 0, hc = 0;
                            for (Node<K,V> e = t.first; e != null; e = e.next) {
                                int h = e.hash;
                                TreeNode<K,V> p = new TreeNode<K,V>
                                    (h, e.key, e.val, null, null);
                                if ((h & n) == 0) {
                                    if ((p.prev = loTail) == null)
                                        lo = p;
                                    else
                                        loTail.next = p;
                                    loTail = p;
                                    ++lc;
                                }
                                else {
                                    if ((p.prev = hiTail) == null)
                                        hi = p;
                                    else
                                        hiTail.next = p;
                                    hiTail = p;
                                    ++hc;
                                }
                            }
                            ln = (lc <= UNTREEIFY_THRESHOLD) ? untreeify(lo) :
                                (hc != 0) ? new TreeBin<K,V>(lo) : t;
                            hn = (hc <= UNTREEIFY_THRESHOLD) ? untreeify(hi) :
                                (lc != 0) ? new TreeBin<K,V>(hi) : t;
                            setTabAt(nextTab, i, ln);
                            setTabAt(nextTab, i + n, hn);
                            setTabAt(tab, i, fwd);
                            advance = true;
                        }
                        else if (f instanceof ReservationNode)
                            throw new IllegalStateException("Recursive update");
                    }
                }
            }
        }
    }
```

### putAll(Map<? extends K, ? extends V> m)
```
 public void putAll(Map<? extends K, ? extends V> m) {
        tryPresize(m.size());
        for (Map.Entry<? extends K, ? extends V> e : m.entrySet())
            putVal(e.getKey(), e.getValue(), false);//循环调用putVal
    }
```

### tryPresize(int size)试图预先确定表以容纳给定数量的元
```
private final void tryPresize(int size) {
        int c = (size >= (MAXIMUM_CAPACITY >>> 1)) ? MAXIMUM_CAPACITY :
            tableSizeFor(size + (size >>> 1) + 1);
        int sc;
        while ((sc = sizeCtl) >= 0) {
            Node<K,V>[] tab = table; int n;
            if (tab == null || (n = tab.length) == 0) {
                n = (sc > c) ? sc : c;
                if (U.compareAndSetInt(this, SIZECTL, sc, -1)) {
                    try {
                        if (table == tab) {
                            @SuppressWarnings("unchecked")
                            Node<K,V>[] nt = (Node<K,V>[])new Node<?,?>[n];
                            table = nt;
                            sc = n - (n >>> 2);
                        }
                    } finally {
                        sizeCtl = sc;
                    }
                }
            }
            else if (c <= sc || n >= MAXIMUM_CAPACITY)
                break;
            else if (tab == table) {
                int rs = resizeStamp(n);
                if (U.compareAndSetInt(this, SIZECTL, sc,
                                        (rs << RESIZE_STAMP_SHIFT) + 2))
                    transfer(tab, null);
            }
        }
    }
```

### remove(Object key)从此映射中删除键（及其对应的值）
```
public V remove(Object key) {
        return replaceNode(key, null, null);
    }
```

### replaceNode(Object key, V value, Object cv)用v替换节点值，如果非空，则以cv匹配为条件。 如果结果值为null，则删除
```
final V replaceNode(Object key, V value, Object cv) {
        int hash = spread(key.hashCode());
        for (Node<K,V>[] tab = table;;) {
            Node<K,V> f; int n, i, fh;
            if (tab == null || (n = tab.length) == 0 ||(f = tabAt(tab, i = (n - 1) & hash)) == null)
                break;//volatile查，空的就直接跳出
            else if ((fh = f.hash) == MOVED)//如果在扩容
                tab = helpTransfer(tab, f);//帮助扩容
            else {//不为空，没在扩容
                V oldVal = null;
                boolean validated = false;
                synchronized (f) {//加锁
                    if (tabAt(tab, i) == f) {//volatile再次验证
                        if (fh >= 0) {//再次验证不在扩容
                            validated = true;
                            for (Node<K,V> e = f, pred = null;;) {//循环
                                K ek;
                                if (e.hash == hash &&
                                    ((ek = e.key) == key ||
                                     (ek != null && key.equals(ek)))) {//如果相等
                                    V ev = e.val;//获取值
                                    if (cv == null || cv == ev ||
                                        (ev != null && cv.equals(ev))) {//调用cv的equals
                                        oldVal = ev;//设置旧值
                                        if (value != null)//传入的value不为空
                                            e.val = value;//设置新值
                                        else if (pred != null)//不是头节点
                                            pred.next = e.next;//前一个节点的next设置成当前节点的next（也就是删除了当前节点）
                                        else
                                            setTabAt(tab, i, e.next);//头节点，直接volatile设置值
                                    }
                                    break;
                                }
                                pred = e;//将这个节点设置成pred供下一次循环使用
                                if ((e = e.next) == null)//链表尾
                                    break;//跳出
                            }
                        }
                        else if (f instanceof TreeBin) {//红黑树
                            validated = true;
                            TreeBin<K,V> t = (TreeBin<K,V>)f;
                            TreeNode<K,V> r, p;
                            if ((r = t.root) != null &&
                                (p = r.findTreeNode(hash, key, null)) != null) {//有根节点，找到了对应节点
                                V pv = p.val;
                                if (cv == null || cv == pv ||
                                    (pv != null && cv.equals(pv))) {
                                    oldVal = pv;
                                    if (value != null)//设置值
                                        p.val = value;
                                    else if (t.removeTreeNode(p))//移除节点
                                        setTabAt(tab, i, untreeify(t.first));
                                }
                            }
                        }
                        else if (f instanceof ReservationNode)
                            throw new IllegalStateException("Recursive update");
                    }
                }
                if (validated) {
                    if (oldVal != null) {//旧值不为空
                        if (value == null)//传入的value不为空
                            addCount(-1L, -1);//数据量-1，不进行扩容检查
                        return oldVal;
                    }
                    break;
                }
            }
        }
        return null;
    }
```

### clear()清空
```
public void clear() {
        long delta = 0L; // negative number of deletions
        int i = 0;
        Node<K,V>[] tab = table;
        while (tab != null && i < tab.length) {//非空
            int fh;
            Node<K,V> f = tabAt(tab, i);
            if (f == null)//已经空了就下一个
                ++i;
            else if ((fh = f.hash) == MOVED) {//扩容中
                tab = helpTransfer(tab, f);//帮助扩容
                i = 0; //重头开始
            }
            else {
                synchronized (f) {//加锁
                    if (tabAt(tab, i) == f) {//volatile查
                        Node<K,V> p = (fh >= 0 ? f :
                                       (f instanceof TreeBin) ?
                                       ((TreeBin<K,V>)f).first : null);
                        while (p != null) {
                            --delta;
                            p = p.next;
                        }
                        setTabAt(tab, i++, null);//volatile设置值置空
                    }
                }
            }
        }
        if (delta != 0L)
            addCount(delta, -1);//修改baseCount，不做扩容检查
    }
```

### keySet 所有键的集合
```
public KeySetView<K,V> keySet() {
        KeySetView<K,V> ks;
        if ((ks = keySet) != null) return ks;
        return keySet = new KeySetView<K,V>(this, null);//构造并赋值
    }
```

### CollectionView抽象类
```
 abstract static class CollectionView<K,V,E>
        implements Collection<E>, java.io.Serializable {
        private static final long serialVersionUID = 7249069246763182397L;
        final ConcurrentHashMap<K,V> map;
        CollectionView(ConcurrentHashMap<K,V> map)  { this.map = map; }

        /**
         * Returns the map backing this view.
         *
         * @return the map backing this view
         */
        public ConcurrentHashMap<K,V> getMap() { return map; }

        /**
         * Removes all of the elements from this view, by removing all
         * the mappings from the map backing this view.
         */
        public final void clear()      { map.clear(); }
        public final int size()        { return map.size(); }
        public final boolean isEmpty() { return map.isEmpty(); }

        // implementations below rely on concrete classes supplying these
        // abstract methods
        /**
         * Returns an iterator over the elements in this collection.
         *
         * <p>The returned iterator is
         * <a href="package-summary.html#Weakly"><i>weakly consistent</i></a>.
         *
         * @return an iterator over the elements in this collection
         */
        public abstract Iterator<E> iterator();
        public abstract boolean contains(Object o);
        public abstract boolean remove(Object o);

        private static final String OOME_MSG = "Required array size too large";

        public final Object[] toArray() {
            long sz = map.mappingCount();
            if (sz > MAX_ARRAY_SIZE)
                throw new OutOfMemoryError(OOME_MSG);
            int n = (int)sz;
            Object[] r = new Object[n];
            int i = 0;
            for (E e : this) {
                if (i == n) {
                    if (n >= MAX_ARRAY_SIZE)
                        throw new OutOfMemoryError(OOME_MSG);
                    if (n >= MAX_ARRAY_SIZE - (MAX_ARRAY_SIZE >>> 1) - 1)
                        n = MAX_ARRAY_SIZE;
                    else
                        n += (n >>> 1) + 1;
                    r = Arrays.copyOf(r, n);
                }
                r[i++] = e;
            }
            return (i == n) ? r : Arrays.copyOf(r, i);
        }

        @SuppressWarnings("unchecked")
        public final <T> T[] toArray(T[] a) {
            long sz = map.mappingCount();
            if (sz > MAX_ARRAY_SIZE)
                throw new OutOfMemoryError(OOME_MSG);
            int m = (int)sz;
            T[] r = (a.length >= m) ? a :
                (T[])java.lang.reflect.Array
                .newInstance(a.getClass().getComponentType(), m);
            int n = r.length;
            int i = 0;
            for (E e : this) {
                if (i == n) {
                    if (n >= MAX_ARRAY_SIZE)
                        throw new OutOfMemoryError(OOME_MSG);
                    if (n >= MAX_ARRAY_SIZE - (MAX_ARRAY_SIZE >>> 1) - 1)
                        n = MAX_ARRAY_SIZE;
                    else
                        n += (n >>> 1) + 1;
                    r = Arrays.copyOf(r, n);
                }
                r[i++] = (T)e;
            }
            if (a == r && i < n) {
                r[i] = null; // null-terminate
                return r;
            }
            return (i == n) ? r : Arrays.copyOf(r, i);
        }

        /**
         * Returns a string representation of this collection.
         * The string representation consists of the string representations
         * of the collection's elements in the order they are returned by
         * its iterator, enclosed in square brackets ({@code "[]"}).
         * Adjacent elements are separated by the characters {@code ", "}
         * (comma and space).  Elements are converted to strings as by
         * {@link String#valueOf(Object)}.
         *
         * @return a string representation of this collection
         */
        public final String toString() {
            StringBuilder sb = new StringBuilder();
            sb.append('[');
            Iterator<E> it = iterator();
            if (it.hasNext()) {
                for (;;) {
                    Object e = it.next();
                    sb.append(e == this ? "(this Collection)" : e);
                    if (!it.hasNext())
                        break;
                    sb.append(',').append(' ');
                }
            }
            return sb.append(']').toString();
        }

        public final boolean containsAll(Collection<?> c) {
            if (c != this) {
                for (Object e : c) {
                    if (e == null || !contains(e))
                        return false;
                }
            }
            return true;
        }

        public boolean removeAll(Collection<?> c) {
            if (c == null) throw new NullPointerException();
            boolean modified = false;
            // Use (c instanceof Set) as a hint that lookup in c is as
            // efficient as this view
            Node<K,V>[] t;
            if ((t = map.table) == null) {
                return false;
            } else if (c instanceof Set<?> && c.size() > t.length) {
                for (Iterator<?> it = iterator(); it.hasNext(); ) {
                    if (c.contains(it.next())) {
                        it.remove();
                        modified = true;
                    }
                }
            } else {
                for (Object e : c)
                    modified |= remove(e);
            }
            return modified;
        }

        public final boolean retainAll(Collection<?> c) {
            if (c == null) throw new NullPointerException();
            boolean modified = false;
            for (Iterator<E> it = iterator(); it.hasNext();) {
                if (!c.contains(it.next())) {
                    it.remove();
                    modified = true;
                }
            }
            return modified;
        }

    }
```

### 类KeySetView
* 将ConcurrentHashMap视图作为一组键，其中可以通过映射到公共值来可选地启用添加。 
* 此类无法直接实例化。
```
public static class KeySetView<K,V> extends CollectionView<K,V,K>
        implements Set<K>, java.io.Serializable {
        private static final long serialVersionUID = 7249069246763182397L;
        private final V value;
        KeySetView(ConcurrentHashMap<K,V> map, V value) {  // non-public
            super(map);
            this.value = value;
        }

        /**
         * Returns the default mapped value for additions,
         * or {@code null} if additions are not supported.
         *
         * @return the default mapped value for additions, or {@code null}
         * if not supported
         */
        public V getMappedValue() { return value; }

        /**
         * {@inheritDoc}
         * @throws NullPointerException if the specified key is null
         */
        public boolean contains(Object o) { return map.containsKey(o); }

        /**
         * Removes the key from this map view, by removing the key (and its
         * corresponding value) from the backing map.  This method does
         * nothing if the key is not in the map.
         *
         * @param  o the key to be removed from the backing map
         * @return {@code true} if the backing map contained the specified key
         * @throws NullPointerException if the specified key is null
         */
        public boolean remove(Object o) { return map.remove(o) != null; }

        /**
         * @return an iterator over the keys of the backing map
         */
        public Iterator<K> iterator() {
            Node<K,V>[] t;
            ConcurrentHashMap<K,V> m = map;
            int f = (t = m.table) == null ? 0 : t.length;
            return new KeyIterator<K,V>(t, f, 0, f, m);
        }

        /**
         * Adds the specified key to this set view by mapping the key to
         * the default mapped value in the backing map, if defined.
         *
         * @param e key to be added
         * @return {@code true} if this set changed as a result of the call
         * @throws NullPointerException if the specified key is null
         * @throws UnsupportedOperationException if no default mapped value
         * for additions was provided
         */
        public boolean add(K e) {
            V v;
            if ((v = value) == null)
                throw new UnsupportedOperationException();
            return map.putVal(e, v, true) == null;
        }

        /**
         * Adds all of the elements in the specified collection to this set,
         * as if by calling {@link #add} on each one.
         *
         * @param c the elements to be inserted into this set
         * @return {@code true} if this set changed as a result of the call
         * @throws NullPointerException if the collection or any of its
         * elements are {@code null}
         * @throws UnsupportedOperationException if no default mapped value
         * for additions was provided
         */
        public boolean addAll(Collection<? extends K> c) {
            boolean added = false;
            V v;
            if ((v = value) == null)
                throw new UnsupportedOperationException();
            for (K e : c) {
                if (map.putVal(e, v, true) == null)
                    added = true;
            }
            return added;
        }

        public int hashCode() {
            int h = 0;
            for (K e : this)
                h += e.hashCode();
            return h;
        }

        public boolean equals(Object o) {
            Set<?> c;
            return ((o instanceof Set) &&
                    ((c = (Set<?>)o) == this ||
                     (containsAll(c) && c.containsAll(this))));
        }

        public Spliterator<K> spliterator() {
            Node<K,V>[] t;
            ConcurrentHashMap<K,V> m = map;
            long n = m.sumCount();
            int f = (t = m.table) == null ? 0 : t.length;
            return new KeySpliterator<K,V>(t, f, 0, f, n < 0L ? 0L : n);
        }

        public void forEach(Consumer<? super K> action) {
            if (action == null) throw new NullPointerException();
            Node<K,V>[] t;
            if ((t = map.table) != null) {
                Traverser<K,V> it = new Traverser<K,V>(t, t.length, 0, t.length);
                for (Node<K,V> p; (p = it.advance()) != null; )
                    action.accept(p.key);
            }
        }
    }
```

### values()返回此映射中包含的值的Collection视图
```
public Collection<V> values() {
        ValuesView<K,V> vs;
        if ((vs = values) != null) return vs;
        return values = new ValuesView<K,V>(this);//构造并赋值
    }
```

### ValuesView类
```
static final class ValuesView<K,V> extends CollectionView<K,V,V>
        implements Collection<V>, java.io.Serializable {
        private static final long serialVersionUID = 2249069246763182397L;
        ValuesView(ConcurrentHashMap<K,V> map) { super(map); }
        public final boolean contains(Object o) {
            return map.containsValue(o);
        }

        public final boolean remove(Object o) {
            if (o != null) {
                for (Iterator<V> it = iterator(); it.hasNext();) {
                    if (o.equals(it.next())) {
                        it.remove();
                        return true;
                    }
                }
            }
            return false;
        }

        public final Iterator<V> iterator() {
            ConcurrentHashMap<K,V> m = map;
            Node<K,V>[] t;
            int f = (t = m.table) == null ? 0 : t.length;
            return new ValueIterator<K,V>(t, f, 0, f, m);
        }

        public final boolean add(V e) {
            throw new UnsupportedOperationException();
        }
        public final boolean addAll(Collection<? extends V> c) {
            throw new UnsupportedOperationException();
        }

        @Override public boolean removeAll(Collection<?> c) {
            if (c == null) throw new NullPointerException();
            boolean modified = false;
            for (Iterator<V> it = iterator(); it.hasNext();) {
                if (c.contains(it.next())) {
                    it.remove();
                    modified = true;
                }
            }
            return modified;
        }

        public boolean removeIf(Predicate<? super V> filter) {
            return map.removeValueIf(filter);
        }

        public Spliterator<V> spliterator() {
            Node<K,V>[] t;
            ConcurrentHashMap<K,V> m = map;
            long n = m.sumCount();
            int f = (t = m.table) == null ? 0 : t.length;
            return new ValueSpliterator<K,V>(t, f, 0, f, n < 0L ? 0L : n);
        }

        public void forEach(Consumer<? super V> action) {
            if (action == null) throw new NullPointerException();
            Node<K,V>[] t;
            if ((t = map.table) != null) {
                Traverser<K,V> it = new Traverser<K,V>(t, t.length, 0, t.length);
                for (Node<K,V> p; (p = it.advance()) != null; )
                    action.accept(p.val);
            }
        }
    }
```

### entrySet()返回此映射中包含的映射的Set视图
```
 public Set<Map.Entry<K,V>> entrySet() {
        EntrySetView<K,V> es;
        if ((es = entrySet) != null) return es;
        return entrySet = new EntrySetView<K,V>(this);
    }
```


### EntrySetView类
```
static final class EntrySetView<K,V> extends CollectionView<K,V,Map.Entry<K,V>>
        implements Set<Map.Entry<K,V>>, java.io.Serializable {
        private static final long serialVersionUID = 2249069246763182397L;
        EntrySetView(ConcurrentHashMap<K,V> map) { super(map); }

        public boolean contains(Object o) {
            Object k, v, r; Map.Entry<?,?> e;
            return ((o instanceof Map.Entry) &&
                    (k = (e = (Map.Entry<?,?>)o).getKey()) != null &&
                    (r = map.get(k)) != null &&
                    (v = e.getValue()) != null &&
                    (v == r || v.equals(r)));
        }

        public boolean remove(Object o) {
            Object k, v; Map.Entry<?,?> e;
            return ((o instanceof Map.Entry) &&
                    (k = (e = (Map.Entry<?,?>)o).getKey()) != null &&
                    (v = e.getValue()) != null &&
                    map.remove(k, v));
        }

        /**
         * @return an iterator over the entries of the backing map
         */
        public Iterator<Map.Entry<K,V>> iterator() {
            ConcurrentHashMap<K,V> m = map;
            Node<K,V>[] t;
            int f = (t = m.table) == null ? 0 : t.length;
            return new EntryIterator<K,V>(t, f, 0, f, m);
        }

        public boolean add(Entry<K,V> e) {
            return map.putVal(e.getKey(), e.getValue(), false) == null;
        }

        public boolean addAll(Collection<? extends Entry<K,V>> c) {
            boolean added = false;
            for (Entry<K,V> e : c) {
                if (add(e))
                    added = true;
            }
            return added;
        }

        public boolean removeIf(Predicate<? super Entry<K,V>> filter) {
            return map.removeEntryIf(filter);
        }

        public final int hashCode() {
            int h = 0;
            Node<K,V>[] t;
            if ((t = map.table) != null) {
                Traverser<K,V> it = new Traverser<K,V>(t, t.length, 0, t.length);
                for (Node<K,V> p; (p = it.advance()) != null; ) {
                    h += p.hashCode();
                }
            }
            return h;
        }

        public final boolean equals(Object o) {
            Set<?> c;
            return ((o instanceof Set) &&
                    ((c = (Set<?>)o) == this ||
                     (containsAll(c) && c.containsAll(this))));
        }

        public Spliterator<Map.Entry<K,V>> spliterator() {
            Node<K,V>[] t;
            ConcurrentHashMap<K,V> m = map;
            long n = m.sumCount();
            int f = (t = m.table) == null ? 0 : t.length;
            return new EntrySpliterator<K,V>(t, f, 0, f, n < 0L ? 0L : n, m);
        }

        public void forEach(Consumer<? super Map.Entry<K,V>> action) {
            if (action == null) throw new NullPointerException();
            Node<K,V>[] t;
            if ((t = map.table) != null) {
                Traverser<K,V> it = new Traverser<K,V>(t, t.length, 0, t.length);
                for (Node<K,V> p; (p = it.advance()) != null; )
                    action.accept(new MapEntry<K,V>(p.key, p.val, map));
            }
        }

    }
```


### hashCode()哈希值
```
public int hashCode() {
        int h = 0;
        Node<K,V>[] t;
        if ((t = table) != null) {
            Traverser<K,V> it = new Traverser<K,V>(t, t.length, 0, t.length);//迭代器
            for (Node<K,V> p; (p = it.advance()) != null; )
                h += p.key.hashCode() ^ p.val.hashCode();
        }
        return h;
    }
```

### toString()输出
```
public String toString() {
        Node<K,V>[] t;
        int f = (t = table) == null ? 0 : t.length;
        Traverser<K,V> it = new Traverser<K,V>(t, f, 0, f);//迭代器
        StringBuilder sb = new StringBuilder();
        sb.append('{');
        Node<K,V> p;
        if ((p = it.advance()) != null) {
            for (;;) {
                K k = p.key;
                V v = p.val;
                sb.append(k == this ? "(this Map)" : k);
                sb.append('=');
                sb.append(v == this ? "(this Map)" : v);
                if ((p = it.advance()) == null)
                    break;
                sb.append(',').append(' ');
            }
        }
        return sb.append('}').toString();
    }
```

### equals(Object o)对比
```
public boolean equals(Object o) {
        if (o != this) {
            if (!(o instanceof Map))//类型不对直接false
                return false;
            Map<?,?> m = (Map<?,?>) o;
            Node<K,V>[] t;
            int f = (t = table) == null ? 0 : t.length;
            Traverser<K,V> it = new Traverser<K,V>(t, f, 0, f);//迭代器
            for (Node<K,V> p; (p = it.advance()) != null; ) {
                V val = p.val;
                Object v = m.get(p.key);//调用的是o的get方法
                if (v == null || (v != val && !v.equals(val)))//只要有一个是空的或对不上，就false
                    return false;
            }
            
            for (Map.Entry<?,?> e : m.entrySet()) {//本集合是空的情况，上面循环不执行
                Object mk, mv, v;
                if ((mk = e.getKey()) == null ||
                    (mv = e.getValue()) == null ||
                    (v = get(mk)) == null ||
                    (mv != v && !mv.equals(v)))
                    return false;
            }
        }
        return true;
    }
```

### Segment
* 在先前版本中使用的精简版辅助类，为了序列化兼容性而声明
```
static class Segment<K,V> extends ReentrantLock implements Serializable {
        private static final long serialVersionUID = 2249069246763182397L;
        final float loadFactor;
        Segment(float lf) { this.loadFactor = lf; }
    }
```


### putIfAbsent(K key, V value)存在就不插入
```
 public V putIfAbsent(K key, V value) {
        return putVal(key, value, true);
    }
```

### remove(Object key, Object value)删除
```
 public boolean remove(Object key, Object value) {
        if (key == null)
            throw new NullPointerException();
        return value != null && replaceNode(key, null, value) != null;
    }
```

### replace(K key, V oldValue, V newValue)替换
```
 public boolean replace(K key, V oldValue, V newValue) {
        if (key == null || oldValue == null || newValue == null)//全非空
            throw new NullPointerException();
        return replaceNode(key, newValue, oldValue) != null;
    }
```

### replace(K key, V value)替换
```
 public V replace(K key, V value) {
        if (key == null || value == null)
            throw new NullPointerException();
        return replaceNode(key, value, null);
    }
```

### getOrDefault(Object key, V defaultValue)为空就返回defaultValue
```
 public V getOrDefault(Object key, V defaultValue) {
        V v;
        return (v = get(key)) == null ? defaultValue : v;
    }
```

### forEach(BiConsumer<? super K, ? super V> action)循环
```
public void forEach(BiConsumer<? super K, ? super V> action) {
        if (action == null) throw new NullPointerException();
        Node<K,V>[] t;
        if ((t = table) != null) {
            Traverser<K,V> it = new Traverser<K,V>(t, t.length, 0, t.length);
            for (Node<K,V> p; (p = it.advance()) != null; ) {
                action.accept(p.key, p.val);//循环执行action.accept
            }
        }
    }
```

### replaceAll(BiFunction<? super K, ? super V, ? extends V> function)所有结果都替换成函数返回
```
 public void replaceAll(BiFunction<? super K, ? super V, ? extends V> function) {
        if (function == null) throw new NullPointerException();
        Node<K,V>[] t;
        if ((t = table) != null) {
            Traverser<K,V> it = new Traverser<K,V>(t, t.length, 0, t.length);
            for (Node<K,V> p; (p = it.advance()) != null; ) {
                V oldValue = p.val;
                for (K key = p.key;;) {
                    V newValue = function.apply(key, oldValue);
                    if (newValue == null)//函数结果不为空
                        throw new NullPointerException();
                    if (replaceNode(key, newValue, oldValue) != null ||
                        (oldValue = get(key)) == null)
                        break;
                }
            }
        }
    }
```

### computeIfAbsent(K key, Function<? super K, ? extends V> mappingFunction)
* 存在就不会执行
* 不存在会执行，不为空就插入计算后的值，为空就不插入
```
public V computeIfAbsent(K key, Function<? super K, ? extends V> mappingFunction) {
        if (key == null || mappingFunction == null)//键和函数不为空
            throw new NullPointerException();
        int h = spread(key.hashCode());
        V val = null;
        int binCount = 0;
        for (Node<K,V>[] tab = table;;) {
            Node<K,V> f; int n, i, fh; K fk; V fv;
            if (tab == null || (n = tab.length) == 0)//如果是空的哈希桶
                tab = initTable();
            else if ((f = tabAt(tab, i = (n - 1) & h)) == null) {//如果桶位是空的
                Node<K,V> r = new ReservationNode<K,V>();
                synchronized (r) {//加锁
                    if (casTabAt(tab, i, null, r)) {//CAS将值先设置成ReservationNode
                        binCount = 1;
                        Node<K,V> node = null;
                        try {
                            if ((val = mappingFunction.apply(key)) != null)//计算出函数运行值
                                node = new Node<K,V>(h, key, val);//构造点
                        } finally {
                            setTabAt(tab, i, node);//volatile设置值
                        }
                    }
                }
                if (binCount != 0)
                    break;
            }
            else if ((fh = f.hash) == MOVED)//桶位不为空，但在扩容
                tab = helpTransfer(tab, f);
            else if (fh == h    // check first node without acquiring lock
                     && ((fk = f.key) == key || (fk != null && key.equals(fk)))
                     && (fv = f.val) != null)//如果桶位第一个就是对应key
                return fv;
            else {
                boolean added = false;
                synchronized (f) {//加锁
                    if (tabAt(tab, i) == f) {//volatile读
                        if (fh >= 0) {
                            binCount = 1;
                            for (Node<K,V> e = f;; ++binCount) {
                                K ek;
                                if (e.hash == h &&
                                    ((ek = e.key) == key ||
                                     (ek != null && key.equals(ek)))) {
                                    val = e.val;
                                    break;
                                }
                                Node<K,V> pred = e;
                                if ((e = e.next) == null) {
                                    if ((val = mappingFunction.apply(key)) != null) {
                                        if (pred.next != null)
                                            throw new IllegalStateException("Recursive update");
                                        added = true;
                                        pred.next = new Node<K,V>(h, key, val);
                                    }
                                    break;
                                }
                            }
                        }
                        else if (f instanceof TreeBin) {//红黑树
                            binCount = 2;
                            TreeBin<K,V> t = (TreeBin<K,V>)f;
                            TreeNode<K,V> r, p;
                            if ((r = t.root) != null &&
                                (p = r.findTreeNode(h, key, null)) != null)
                                val = p.val;
                            else if ((val = mappingFunction.apply(key)) != null) {
                                added = true;
                                t.putTreeVal(h, key, val);
                            }
                        }
                        else if (f instanceof ReservationNode)
                            throw new IllegalStateException("Recursive update");
                    }
                }
                if (binCount != 0) {
                    if (binCount >= TREEIFY_THRESHOLD)
                        treeifyBin(tab, i);
                    if (!added)
                        return val;
                    break;
                }
            }
        }
        if (val != null)
            addCount(1L, binCount);
        return val;
    }
```

### computeIfPresent(K key, BiFunction<? super K, ? super V, ? extends V> remappingFunction)
* 存在则执行函数存进去，返回不为空就设置
* 存在则执行函数存进去，返回为空就删除
```
public V computeIfPresent(K key, BiFunction<? super K, ? super V, ? extends V> remappingFunction) {
        if (key == null || remappingFunction == null)
            throw new NullPointerException();
        int h = spread(key.hashCode());
        V val = null;
        int delta = 0;
        int binCount = 0;
        for (Node<K,V>[] tab = table;;) {
            Node<K,V> f; int n, i, fh;
            if (tab == null || (n = tab.length) == 0)
                tab = initTable();
            else if ((f = tabAt(tab, i = (n - 1) & h)) == null)//对应桶位为空，直接返回
                break;
            else if ((fh = f.hash) == MOVED)//扩容中
                tab = helpTransfer(tab, f);
            else {//存在key值对应
                synchronized (f) {
                    if (tabAt(tab, i) == f) {//再次确认桶位不为空
                        if (fh >= 0) {
                            binCount = 1;
                            for (Node<K,V> e = f, pred = null;; ++binCount) {
                                K ek;
                                if (e.hash == h &&
                                    ((ek = e.key) == key ||
                                     (ek != null && key.equals(ek)))) {//查找到对应的值
                                    val = remappingFunction.apply(key, e.val);//计算
                                    if (val != null)
                                        e.val = val;//赋值
                                    else {
                                        delta = -1;
                                        Node<K,V> en = e.next;
                                        if (pred != null)
                                            pred.next = en;
                                        else
                                            setTabAt(tab, i, en);
                                    }
                                    break;
                                }
                                pred = e;
                                if ((e = e.next) == null)//如果是尾节点，直接跳出循环
                                    break;
                            }
                        }
                        else if (f instanceof TreeBin) {//红黑树
                            binCount = 2;
                            TreeBin<K,V> t = (TreeBin<K,V>)f;
                            TreeNode<K,V> r, p;
                            if ((r = t.root) != null &&
                                (p = r.findTreeNode(h, key, null)) != null) {
                                val = remappingFunction.apply(key, p.val);
                                if (val != null)
                                    p.val = val;
                                else {
                                    delta = -1;
                                    if (t.removeTreeNode(p))
                                        setTabAt(tab, i, untreeify(t.first));
                                }
                            }
                        }
                        else if (f instanceof ReservationNode)
                            throw new IllegalStateException("Recursive update");
                    }
                }
                if (binCount != 0)
                    break;
            }
        }
        if (delta != 0)
            addCount((long)delta, binCount);
        return val;
    }
```

### compute(K key,BiFunction<? super K, ? super V, ? extends V> remappingFunction)
* 桶位为空设置值
* 存在函数返回不为就设置值
* 存在函数返回为null就删除
```
 public V compute(K key,BiFunction<? super K, ? super V, ? extends V> remappingFunction) {
        if (key == null || remappingFunction == null)//不允许空键和空函数
            throw new NullPointerException();
        int h = spread(key.hashCode());
        V val = null;
        int delta = 0;
        int binCount = 0;
        for (Node<K,V>[] tab = table;;) {
            Node<K,V> f; int n, i, fh;
            if (tab == null || (n = tab.length) == 0)
                tab = initTable();
            else if ((f = tabAt(tab, i = (n - 1) & h)) == null) {//桶位为空的
                Node<K,V> r = new ReservationNode<K,V>();
                synchronized (r) {
                    if (casTabAt(tab, i, null, r)) {
                        binCount = 1;
                        Node<K,V> node = null;
                        try {
                            if ((val = remappingFunction.apply(key, null)) != null) {
                                delta = 1;
                                node = new Node<K,V>(h, key, val);
                            }
                        } finally {
                            setTabAt(tab, i, node);
                        }
                    }
                }
                if (binCount != 0)
                    break;
            }
            else if ((fh = f.hash) == MOVED)//扩容中
                tab = helpTransfer(tab, f);
            else {//桶位存在值
                synchronized (f) {
                    if (tabAt(tab, i) == f) {
                        if (fh >= 0) {
                            binCount = 1;
                            for (Node<K,V> e = f, pred = null;; ++binCount) {
                                K ek;
                                if (e.hash == h &&
                                    ((ek = e.key) == key ||
                                     (ek != null && key.equals(ek)))) {
                                    val = remappingFunction.apply(key, e.val);
                                    if (val != null)
                                        e.val = val;
                                    else {
                                        delta = -1;
                                        Node<K,V> en = e.next;
                                        if (pred != null)
                                            pred.next = en;
                                        else
                                            setTabAt(tab, i, en);
                                    }
                                    break;
                                }
                                pred = e;
                                if ((e = e.next) == null) {
                                    val = remappingFunction.apply(key, null);
                                    if (val != null) {
                                        if (pred.next != null)
                                            throw new IllegalStateException("Recursive update");
                                        delta = 1;
                                        pred.next = new Node<K,V>(h, key, val);
                                    }
                                    break;
                                }
                            }
                        }
                        else if (f instanceof TreeBin) {
                            binCount = 1;
                            TreeBin<K,V> t = (TreeBin<K,V>)f;
                            TreeNode<K,V> r, p;
                            if ((r = t.root) != null)
                                p = r.findTreeNode(h, key, null);
                            else
                                p = null;
                            V pv = (p == null) ? null : p.val;
                            val = remappingFunction.apply(key, pv);
                            if (val != null) {
                                if (p != null)
                                    p.val = val;
                                else {
                                    delta = 1;
                                    t.putTreeVal(h, key, val);
                                }
                            }
                            else if (p != null) {
                                delta = -1;
                                if (t.removeTreeNode(p))
                                    setTabAt(tab, i, untreeify(t.first));
                            }
                        }
                        else if (f instanceof ReservationNode)
                            throw new IllegalStateException("Recursive update");
                    }
                }
                if (binCount != 0) {
                    if (binCount >= TREEIFY_THRESHOLD)
                        treeifyBin(tab, i);
                    break;
                }
            }
        }
        if (delta != 0)
            addCount((long)delta, binCount);
        return val;
    }
```

### merge(K key, V value, BiFunction<? super V, ? super V, ? extends V> remappingFunction)
* 不存在就把value设置进去
* 存在函数范围不为null就设置
* 存在函数返回为null就删除
```
public V merge(K key, V value, BiFunction<? super V, ? super V, ? extends V> remappingFunction) {
        if (key == null || value == null || remappingFunction == null)
            throw new NullPointerException();
        int h = spread(key.hashCode());
        V val = null;
        int delta = 0;
        int binCount = 0;
        for (Node<K,V>[] tab = table;;) {//循环
            Node<K,V> f; int n, i, fh;
            if (tab == null || (n = tab.length) == 0)
                tab = initTable();
            else if ((f = tabAt(tab, i = (n - 1) & h)) == null) {//桶位为空
                if (casTabAt(tab, i, null, new Node<K,V>(h, key, value))) {
                    delta = 1;
                    val = value;
                    break;
                }
            }
            else if ((fh = f.hash) == MOVED)//扩容中
                tab = helpTransfer(tab, f);
            else {//存在值
                synchronized (f) {
                    if (tabAt(tab, i) == f) {
                        if (fh >= 0) {
                            binCount = 1;
                            for (Node<K,V> e = f, pred = null;; ++binCount) {
                                K ek;
                                if (e.hash == h &&
                                    ((ek = e.key) == key ||
                                     (ek != null && key.equals(ek)))) {
                                    val = remappingFunction.apply(e.val, value);
                                    if (val != null)
                                        e.val = val;
                                    else {
                                        delta = -1;
                                        Node<K,V> en = e.next;
                                        if (pred != null)
                                            pred.next = en;
                                        else
                                            setTabAt(tab, i, en);
                                    }
                                    break;
                                }
                                pred = e;
                                if ((e = e.next) == null) {
                                    delta = 1;
                                    val = value;
                                    pred.next = new Node<K,V>(h, key, val);
                                    break;
                                }
                            }
                        }
                        else if (f instanceof TreeBin) {//红黑树
                            binCount = 2;
                            TreeBin<K,V> t = (TreeBin<K,V>)f;
                            TreeNode<K,V> r = t.root;
                            TreeNode<K,V> p = (r == null) ? null :
                                r.findTreeNode(h, key, null);
                            val = (p == null) ? value :
                                remappingFunction.apply(p.val, value);
                            if (val != null) {
                                if (p != null)
                                    p.val = val;
                                else {
                                    delta = 1;
                                    t.putTreeVal(h, key, val);
                                }
                            }
                            else if (p != null) {
                                delta = -1;
                                if (t.removeTreeNode(p))
                                    setTabAt(tab, i, untreeify(t.first));
                            }
                        }
                        else if (f instanceof ReservationNode)
                            throw new IllegalStateException("Recursive update");
                    }
                }
                if (binCount != 0) {
                    if (binCount >= TREEIFY_THRESHOLD)
                        treeifyBin(tab, i);
                    break;
                }
            }
        }
        if (delta != 0)
            addCount((long)delta, binCount);
        return val;
    }
```


### contains(Object value)
```
 public boolean contains(Object value) {
        return containsValue(value);
    }

```


未完成...
