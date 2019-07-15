# HashMap


## 问题

### 转型问题ClassCastException
```
   HashMap<String,Object> hashMap=new HashMap<>();
        hashMap.put("name","view");
        hashMap.put("age",12);
        String rsp="{\"name\":\"view\",\"age\":12}";
        HashMap<String,String> parse = JSON.parseObject(rsp,HashMap.class);
        boolean age = parse.get("age") != null;
        String age1 = parse.get("age");
```


* 桶位通过(n - 1) & hash（即hash mod n）获取哈希桶的索引

## 属性
```

static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; //默认初始容量 (必须是2的幂)

  
static final int MAXIMUM_CAPACITY=1<<30;//最大容量，如果隐式指定更高的值，则使用该容量(必须是2的幂且小于等于1 << 30)

   
static final float DEFAULT_LOAD_FACTOR=0.75f;//默认负载系数(用来衡量HashMap满的程度)(默认0.75f)

   
static final int TREEIFY_THRESHOLD = 8;//（链表转树的阈值）

    
static final int UNTREEIFY_THRESHOLD = 6;//（树转链表的阈值）

 
static final int MIN_TREEIFY_CAPACITY = 64;//容器可以树化的最小容量。 （否则，如果bin中的节点太多，则会调整表的大小。）应该至少为4 * TREEIFY_THRESHOLD，以避免调整大小和树化阈值之间的冲突。

transient Node<K,V>[] table;//哈希桶数组(该表在首次使用时初始化)

    
transient Set<Map.Entry<K,V>> entrySet;//保持缓存的entrySet()  AbstractMap字段用于keySet()和values()
    
    
transient int size;//此映射中包含的键 - 值映射的数量

transient int modCount;//此HashMap已被结构修改的次数

   
int threshold;//下一次扩容的阈值（capacity * load factor）（初值为0）

   
final float loadFactor;//哈希表的负载因子
```

## 静态工具方法
```

    //计算hash值
    static final int hash(Object key) {
        int h;
        return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);//高16位异或低16位
    }

   //如果它是“C类实现”的形式，则返回x的类
    static Class<?> comparableClassFor(Object x) {
        if (x instanceof Comparable) {
            Class<?> c; Type[] ts, as; ParameterizedType p;
            if ((c = x.getClass()) == String.class) // bypass checks
                return c;
            if ((ts = c.getGenericInterfaces()) != null) {
                for (Type t : ts) {
                    if ((t instanceof ParameterizedType) &&
                        ((p = (ParameterizedType) t).getRawType() ==
                         Comparable.class) &&
                        (as = p.getActualTypeArguments()) != null &&
                        as.length == 1 && as[0] == c) // type arg is c
                        return c;
                }
            }
        }
        return null;
    }

   //如果x匹配kc（k的筛选可比较，则返回k.compareTo（x）
    @SuppressWarnings({"rawtypes","unchecked"}) // for cast to Comparable
    static int compareComparables(Class<?> kc, Object k, Object x) {
        return (x == null || x.getClass() != kc ? 0 :
                ((Comparable)k).compareTo(x));
    }

   //返回比cap大的最小2的幂
    static final int tableSizeFor(int cap) {
        int n = -1 >>> Integer.numberOfLeadingZeros(cap - 1);
        return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
    }
```

## 构造方法

```
public HashMap() {
        this.loadFactor = DEFAULT_LOAD_FACTOR; // 所有其他属性都是默认的(DEFAULT_LOAD_FACTOR = 0.75f)
    }
    
public HashMap(int initialCapacity) {//初始化容量
        this(initialCapacity, DEFAULT_LOAD_FACTOR);//(DEFAULT_LOAD_FACTOR = 0.75f)
    }    
    

    
public HashMap(int initialCapacity, float loadFactor) {//初始化容量，负载因子
        if (initialCapacity < 0)//容量小于0，抛出异常
            throw new IllegalArgumentException("Illegal initial capacity: " +
                                               initialCapacity);
        if (initialCapacity > MAXIMUM_CAPACITY)//容量大于最大容量1 << 30
            initialCapacity = MAXIMUM_CAPACITY;//则使用最大容量
        if (loadFactor <= 0 || Float.isNaN(loadFactor))//如果负载因子小于0或者不是数字，抛出异常
            throw new IllegalArgumentException("Illegal load factor: " +
                                               loadFactor);
        this.loadFactor = loadFactor;//赋值负载因子
        this.threshold = tableSizeFor(initialCapacity);//计算容量，为2的幂
    }
    
    
public HashMap(Map<? extends K, ? extends V> m) {
        this.loadFactor = DEFAULT_LOAD_FACTOR;
        putMapEntries(m, false);//旧值阀盖
    }
    
    
```

## 方法

### putMapEntries
```
final void putMapEntries(Map<? extends K, ? extends V> m, boolean evict) {
        int s = m.size();//存入的map长度
        if (s > 0) {//长度大于0
            if (table == null) { //哈系桶是空的（没有数据）
                float ft = ((float)s / loadFactor) + 1.0F;//按照默认负载因子比例计算出的大小+1
                int t = ((ft<(float)MAXIMUM_CAPACITY)?(int)ft:MAXIMUM_CAPACITY);//小于最大容量就使用ft计算，大于最大容量使用最大容量计算
                if (t > threshold)//如果超过扩容阈值，那么就重新计算扩容阈值
                    threshold = tableSizeFor(t);//重新计算扩容阈值（2的幂）
            }
            else if (s > threshold)//如果哈系桶不是空的，且大小大于扩容阈值
                resize();//进行扩容
            
                
            for (Map.Entry<? extends K, ? extends V> e : m.entrySet()) {//循环插入
                K key = e.getKey();//获取key
                V value = e.getValue();//获取value
                putVal(hash(key), key, value, false, evict);
            }
            
        }
    }
```

#### size
```
public int size() {
        return size;
    }
```

#### isEmpty
```
 public boolean isEmpty() {
        return size == 0;
    }
```

#### get
```
public V get(Object key) {
        Node<K,V> e;
        return (e = getNode(hash(key), key)) == null ? null : e.value;
    }
```

#### getNode获取节点的值
```
final Node<K,V> getNode(int hash, Object key) {
        Node<K,V>[] tab; Node<K,V> first, e; int n; K k;
        if ((tab = table) != null && (n = tab.length) > 0 &&
            (first = tab[(n - 1) & hash]) != null) {//桶不为空，桶大小大于0，hash对应索引值不是空的
            if (first.hash == hash && // 总是确认第一个，，判断是否相等
                ((k = first.key) == key || (key != null && key.equals(k))))
                return first;//相等就返回
            if ((e = first.next) != null) {//存在下一个节点
                if (first instanceof TreeNode)//first是树节点
                    return ((TreeNode<K,V>)first).getTreeNode(hash, key);
                do {//first是链表节点
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        return e;
                } while ((e = e.next) != null);//循环链表
            }
        }
        return null;//链表没找到相等的
    }
```

#### containsKey 判断值是否存在
```
public boolean containsKey(Object key) {
        return getNode(hash(key), key) != null;
    }
```

#### put(K key, V value)
```
 public V put(K key, V value) {
        return putVal(hash(key), key, value, false, true);
    }
```

#### putVal设置键值（第三个参数onlyIfAbsent设置存在旧值时是否覆盖）
```
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        if ((tab = table) == null || (n = tab.length) == 0)//桶是空的或者桶的大小为0（table申明时候没有赋值）
            n = (tab = resize()).length;//扩容
        if ((p = tab[i = (n - 1) & hash]) == null)//hash对应桶位为空的（一定是链表，长的才会是树）
            tab[i] = newNode(hash, key, value, null);//直接赋值桶位
        else {//hash对应桶位不为空
            Node<K,V> e; K k;
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))//hash对应桶位节点和插入数据hash和key相同,同值插入（总检测第一个值）
                e = p;
            else if (p instanceof TreeNode)//如果节点是树节点
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else {//如果节点是链表
                for (int binCount = 0; ; ++binCount) {//循环链表
                    if ((e = p.next) == null) {//循环到链表的结尾
                        p.next = newNode(hash, key, value, null);//把插入的节点插入到链表尾
                        if (binCount >= TREEIFY_THRESHOLD - 1) // 大于树化的阈值
                            treeifyBin(tab, hash);//树化
                        break;
                    }
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))//如果键值相同，直接跳出
                        break;
                    p = e;//循环下标后移
                }
            }
            if (e != null) { //存在映射
                V oldValue = e.value;//旧值
                if (!onlyIfAbsent || oldValue == null)//判断是否覆盖
                    e.value = value;//覆盖旧值
                afterNodeAccess(e);
                return oldValue;//返回旧值
            }
        }
        ++modCount;
        if (++size > threshold)//判断添加后的映射数大于扩容阈值
            resize();//扩容
        afterNodeInsertion(evict);
        return null;
    }
```

#### resize 
```
final Node<K,V>[] resize() {
        Node<K,V>[] oldTab = table;//旧的哈希桶
        int oldCap = (oldTab == null) ? 0 : oldTab.length;//旧哈希桶长度
        int oldThr = threshold;//旧的扩容阈值
        int newCap, newThr = 0;//新的容量和新的阈值
        if (oldCap > 0) {//旧的容量大于0
            if (oldCap >= MAXIMUM_CAPACITY) {//桶内大小大于等于最大容量
                threshold = Integer.MAX_VALUE;//扩容阈值赋值成Integer.MAX_VALUE，即不再扩容
                return oldTab;
            }
            else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&oldCap >= DEFAULT_INITIAL_CAPACITY)//新桶容量（旧桶的两倍）小于最大容量,且旧桶的容量大于默认桶大小
                newThr = oldThr << 1; // double threshold
        }
        else if (oldThr > 0) // （不是新建的桶，阈值大于0）
            newCap = oldThr;//将新的容量设置成旧的阈值
        else { //是新的桶
            newCap = DEFAULT_INITIAL_CAPACITY;//默认容量
            newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);//默认阈值
        }
        
        if (newThr == 0) {//如果不是新建的桶，重新计算阈值
            float ft = (float)newCap * loadFactor;
            newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                      (int)ft : Integer.MAX_VALUE);
        }
        
        threshold = newThr;//赋值阈值
        
        @SuppressWarnings({"rawtypes","unchecked"})
        Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];//新的哈希桶数组
        table = newTab;//赋值
        
        if (oldTab != null) {//旧的桶不为空
            for (int j = 0; j < oldCap; ++j) {//循环旧桶
                Node<K,V> e;
                if ((e = oldTab[j]) != null) {//桶位j赋值给e不为空
                    oldTab[j] = null;//桶位j置空，猜测有利于gc
                    if (e.next == null)//没有下一个节点
                        newTab[e.hash & (newCap - 1)] = e;//计算新的桶数组下标并赋值
                    else if (e instanceof TreeNode)//e存在下一个节点，e是树节点
                        ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                    else { //e存在下一个节点，e是链表
                        Node<K,V> loHead = null, loTail = null;//low  head/tail
                        Node<K,V> hiHead = null, hiTail = null;//high head/tail
                        Node<K,V> next;
                        do {
                            next = e.next;
                       
                        // 例如
                        // 有一个值为 111001 的 hash
                        // 扩容前  n=16(10000)  n-1=15(1111)  (n - 1) & hash = 1111 & 111001= 001001
                        // 扩容后 n=32(100000) n-1=31(11111)  (n - 1) & hash = 11111 & 111001=011001
                        // 有一个值为 101001 的 hash
                        // 扩容前  n=16(10000)  n-1=15(1111)  (n - 1) & hash = 1111 & 101001 =001001
                        // 扩容后 n=32(100000) n-1=31(11111)  (n - 1) & hash = 11111 & 101001=001001
                        // for(var i=0;i<200;i++){
                        //    System.out.println(i+": "+(i&(16-1))+"/"+(i&(32-1))+"--->"+(i&16));
                        // }    
                    
                            if ((e.hash & oldCap) == 0) {//如果新的下标和原下标相同
                                if (loTail == null)
                                    loHead = e;
                                else
                                    loTail.next = e;
                                loTail = e;
                            }
                            else {//如果新的下标和原下标不同，下标为：原索引+原数组长度（oldCap）
                                if (hiTail == null)
                                    hiHead = e;
                                else
                                    hiTail.next = e;
                                hiTail = e;
                            }
                        } while ((e = next) != null);
                        
                        if (loTail != null) {//下标没有移动操作
                            loTail.next = null;
                            newTab[j] = loHead;
                        }
                        if (hiTail != null) {//下标后移了oldCap
                            hiTail.next = null;
                            newTab[j + oldCap] = hiHead;
                        }
                    }
                }
            }
        }
        return newTab;
    }
```
#### treeifyBin 转化为树
```
final void treeifyBin(Node<K,V>[] tab, int hash) {
        int n, index; Node<K,V> e;
        if (tab == null || (n = tab.length) < MIN_TREEIFY_CAPACITY)
            resize();
        else if ((e = tab[index = (n - 1) & hash]) != null) {
            TreeNode<K,V> hd = null, tl = null;
            do {
                TreeNode<K,V> p = replacementTreeNode(e, null);
                if (tl == null)
                    hd = p;
                else {
                    p.prev = tl;
                    tl.next = p;
                }
                tl = p;
            } while ((e = e.next) != null);
            if ((tab[index] = hd) != null)
                hd.treeify(tab);
        }
    }
```

#### putAll 添加值不覆盖 
```
public void putAll(Map<? extends K, ? extends V> m) {
        putMapEntries(m, true);
    }
```

#### remove 从映射中删除指定键的映射
```
public V remove(Object key) {
        Node<K,V> e;
        return (e = removeNode(hash(key), key, null, false, true)) == null ?
            null : e.value;
    }
```

#### removeNode删除节点
```
final Node<K,V> removeNode(int hash, Object key, Object value,boolean matchValue, boolean movable) {
        Node<K,V>[] tab; Node<K,V> p; int n, index;
        if ((tab = table) != null && (n = tab.length) > 0 &&
            (p = tab[index = (n - 1) & hash]) != null) {//桶不为空，桶长度大于0，映射桶位不为空
            Node<K,V> node = null, e; K k; V v;
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))//桶位节点相同
                node = p;//赋值
            else if ((e = p.next) != null) {//有后面的节点
                if (p instanceof TreeNode)//属于树节点
                    node = ((TreeNode<K,V>)p).getTreeNode(hash, key);
                else {
                    do {
                        if (e.hash == hash &&
                            ((k = e.key) == key ||
                             (key != null && key.equals(k)))) {
                            node = e;
                            break;
                        }
                        p = e;
                    } while ((e = e.next) != null);//循环链表节点
                }
            }
            if (node != null && (!matchValue || (v = node.value) == value ||
                                 (value != null && value.equals(v)))) {//获取的节点不为空
                if (node instanceof TreeNode)//移除树节点
                    ((TreeNode<K,V>)node).removeTreeNode(this, tab, movable);
                else if (node == p)//移除链表首节点
                    tab[index] = node.next;
                else//移除链表中间节点
                    p.next = node.next;
                ++modCount;
                --size;
                afterNodeRemoval(node);
                return node;
            }
        }
        return null;
    }
```

#### clear清空映射
```
  public void clear() {
        Node<K,V>[] tab;
        modCount++;
        if ((tab = table) != null && size > 0) {//哈希桶不为空
            size = 0;
            for (int i = 0; i < tab.length; ++i)//把每个哈希桶位置空
                tab[i] = null;
        }
    }
```

#### containsValue判断值是否存在
```
public boolean containsValue(Object value) {
        Node<K,V>[] tab; V v;
        if ((tab = table) != null && size > 0) {//哈希桶不为空
            for (Node<K,V> e : tab) {//循环桶位
                for (; e != null; e = e.next) {//循环每个桶位里的Node直至结束e.next == null
                    if ((v = e.value) == value ||
                        (value != null && value.equals(v)))//内存地址相等或者value调用equals相等
                        return true;
                }
            }
        }
        return false;//不存在值相等的
    }
```

#### keySet 列出所有的key
```
 public Set<K> keySet() {
        Set<K> ks = keySet;
        if (ks == null) {//空的话就创建一个，懒加载
            ks = new KeySet();
            keySet = ks;
        }
        return ks;
    }
```

#### KeySet类
```
final class KeySet extends AbstractSet<K> {
        public final int size()                 { return size; }
        public final void clear()               { HashMap.this.clear(); }//调用的是HashMap的clear
        public final Iterator<K> iterator()     { return new KeyIterator(); }
        public final boolean contains(Object o) { return containsKey(o); }
        public final boolean remove(Object key) {
            return removeNode(hash(key), key, null, false, true) != null;
        }
        public final Spliterator<K> spliterator() {
            return new KeySpliterator<>(HashMap.this, 0, -1, 0, 0);
        }
        public final void forEach(Consumer<? super K> action) {
            Node<K,V>[] tab;
            if (action == null)
                throw new NullPointerException();
            if (size > 0 && (tab = table) != null) {//桶位不为空
                int mc = modCount;
                for (Node<K,V> e : tab) {
                    for (; e != null; e = e.next)
                        action.accept(e.key);//循环执行accept
                }
                if (modCount != mc)
                    throw new ConcurrentModificationException();
            }
        }
    }
```

#### KeyIterator类
```
 final class KeyIterator extends HashIterator
        implements Iterator<K> {
        public final K next() { return nextNode().key; }
    }
```

##### HashIterator类
```
abstract class HashIterator {
        Node<K,V> next;        // next entry to return
        Node<K,V> current;     // current entry
        int expectedModCount;  // for fast-fail
        int index;             // current slot

        HashIterator() {
            expectedModCount = modCount;
            Node<K,V>[] t = table;
            current = next = null;
            index = 0;
            if (t != null && size > 0) { // advance to first entry
                do {} while (index < t.length && (next = t[index++]) == null);//循环到第一个非空的桶位
            }
        }

        public final boolean hasNext() {
            return next != null;
        }

        final Node<K,V> nextNode() {
            Node<K,V>[] t;
            Node<K,V> e = next;
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();//线程不安全
            if (e == null)
                throw new NoSuchElementException();//越界
            if ((next = (current = e).next) == null && (t = table) != null) {//当前桶位遍历到末尾
                do {} while (index < t.length && (next = t[index++]) == null);//循环到下一个非空的桶位
            }
            return e;
        }

        public final void remove() {
            Node<K,V> p = current;
            if (p == null)//错误的状态
                throw new IllegalStateException();
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
            current = null;//清除引用
            removeNode(p.hash, p.key, null, false, false);
            expectedModCount = modCount;
        }
    }
```

#### values 返回所有值的集合
```
 public Collection<V> values() {
        Collection<V> vs = values;
        if (vs == null) {
            vs = new Values();
            values = vs;
        }
        return vs;
    }
```

#### Values类
```
final class Values extends AbstractCollection<V> {
        public final int size()                 { return size; }
        public final void clear()               { HashMap.this.clear(); }//调用的是HashMap的clear
        public final Iterator<V> iterator()     { return new ValueIterator(); }
        public final boolean contains(Object o) { return containsValue(o); }
        public final Spliterator<V> spliterator() {
            return new ValueSpliterator<>(HashMap.this, 0, -1, 0, 0);
        }
        public final void forEach(Consumer<? super V> action) {
            Node<K,V>[] tab;
            if (action == null)
                throw new NullPointerException();
            if (size > 0 && (tab = table) != null) {
                int mc = modCount;
                for (Node<K,V> e : tab) {
                    for (; e != null; e = e.next)
                        action.accept(e.value);//循环执行accept
                }
                if (modCount != mc)
                    throw new ConcurrentModificationException();
            }
        }
    }
```

#### ValueIterator类
```
final class ValueIterator extends HashIterator
        implements Iterator<V> {
        public final V next() { return nextNode().value; }
    }
```

#### entrySet
```
  public Set<Map.Entry<K,V>> entrySet() {
        Set<Map.Entry<K,V>> es;
        return (es = entrySet) == null ? (entrySet = new EntrySet()) : es;
    }
```

#### EntrySet类
```
final class EntrySet extends AbstractSet<Map.Entry<K,V>> {
        public final int size()                 { return size; }
        public final void clear()               { HashMap.this.clear(); }//调用的是HashMap的clear
        public final Iterator<Map.Entry<K,V>> iterator() {
            return new EntryIterator();
        }
        public final boolean contains(Object o) {
            if (!(o instanceof Map.Entry))//不是Map.Entry子类直接false
                return false;
            Map.Entry<?,?> e = (Map.Entry<?,?>) o;
            Object key = e.getKey();
            Node<K,V> candidate = getNode(hash(key), key);//调用的是getNode()
            return candidate != null && candidate.equals(e);
        }
        public final boolean remove(Object o) {
            if (o instanceof Map.Entry) {
                Map.Entry<?,?> e = (Map.Entry<?,?>) o;
                Object key = e.getKey();
                Object value = e.getValue();
                return removeNode(hash(key), key, value, true, true) != null;//调用的是removeNode（）
            }
            return false;
        }
        public final Spliterator<Map.Entry<K,V>> spliterator() {
            return new EntrySpliterator<>(HashMap.this, 0, -1, 0, 0);
        }
        public final void forEach(Consumer<? super Map.Entry<K,V>> action) {
            Node<K,V>[] tab;
            if (action == null)
                throw new NullPointerException();
            if (size > 0 && (tab = table) != null) {
                int mc = modCount;
                for (Node<K,V> e : tab) {
                    for (; e != null; e = e.next)
                        action.accept(e);//循环调用accept
                }
                if (modCount != mc)
                    throw new ConcurrentModificationException();
            }
        }
    }
```

#### EntryIterator类
```
 final class EntryIterator extends HashIterator
        implements Iterator<Map.Entry<K,V>> {
        public final Map.Entry<K,V> next() { return nextNode(); }
    }
```


## JDK8 API

#### getOrDefault
```
 @Override
    public V getOrDefault(Object key, V defaultValue) {
        Node<K,V> e;
        return (e = getNode(hash(key), key)) == null ? defaultValue : e.value;//调用的是getNode
    }
```

#### putIfAbsent 设置键值，存在就不覆盖
```
 @Override
    public V putIfAbsent(K key, V value) {
        return putVal(hash(key), key, value, true, true);//不覆盖
    }
```

#### remove
```
  @Override
    public boolean remove(Object key, Object value) {
        return removeNode(hash(key), key, value, true, true) != null;
    }
```

#### replace
```
@Override
    public boolean replace(K key, V oldValue, V newValue) {
        Node<K,V> e; V v;
        if ((e = getNode(hash(key), key)) != null &&
            ((v = e.value) == oldValue || (v != null && v.equals(oldValue)))) {//getNode获取节点，需要节点值和传入的旧值相等
            e.value = newValue;
            afterNodeAccess(e);
            return true;
        }
        return false;
    }

 @Override
    public V replace(K key, V value) {
        Node<K,V> e;
        if ((e = getNode(hash(key), key)) != null) {//getNode获取节点，直接覆盖
            V oldValue = e.value;
            e.value = value;
            afterNodeAccess(e);
            return oldValue;
        }
        return null;
    }    
    
    
```

#### computeIfAbsent 
* 不存在就插入计算后的值（不为空）
```
@Override
    public V computeIfAbsent(K key,
                             Function<? super K, ? extends V> mappingFunction) {
        if (mappingFunction == null)
            throw new NullPointerException();
        int hash = hash(key);
        Node<K,V>[] tab; Node<K,V> first; int n, i;
        int binCount = 0;
        TreeNode<K,V> t = null;
        Node<K,V> old = null;
        if (size > threshold || (tab = table) == null ||(n = tab.length) == 0)//空桶或者满了
            n = (tab = resize()).length;//扩容
        if ((first = tab[i = (n - 1) & hash]) != null) {//桶位的值不为空
            if (first instanceof TreeNode)//树节点
                old = (t = (TreeNode<K,V>)first).getTreeNode(hash, key);
            else {//链表节点
                Node<K,V> e = first; K k;
                do {
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k)))) {
                        old = e;
                        break;
                    }
                    ++binCount;
                } while ((e = e.next) != null);//xun'huan
            }
            V oldValue;
            if (old != null && (oldValue = old.value) != null) {//找到了符合key的节点
                afterNodeAccess(old);
                return oldValue;//返回节点的值
            }
        }
        
        int mc = modCount;
        V v = mappingFunction.apply(key);//用key去执行apply
        if (mc != modCount) { throw new ConcurrentModificationException(); }
        if (v == null) {//返回值是空就返回空
            return null;
        } else if (old != null) {//找到了节点
            old.value = v;//节点的值赋为计算的值
            afterNodeAccess(old);
            return v;
        }
        else if (t != null)//找到的是树节点
            t.putTreeVal(this, tab, hash, key, v);
        else {//没找到节点
            tab[i] = newNode(hash, key, v, first);//在桶位i处增加一个节点
            if (binCount >= TREEIFY_THRESHOLD - 1)//是否树化
                treeifyBin(tab, hash);
        }
        modCount = mc + 1;
        ++size;
        afterNodeInsertion(true);
        return v;
    }
```

#### computeIfPresent 节点存在，值不为空的情况下，计算的值为null就删除节点，不为null就替换节点值
```
@Override
    public V computeIfPresent(K key,
                              BiFunction<? super K, ? super V, ? extends V> remappingFunction) {
        if (remappingFunction == null)
            throw new NullPointerException();
        Node<K,V> e; V oldValue;
        int hash = hash(key);
        if ((e = getNode(hash, key)) != null &&
            (oldValue = e.value) != null) {//找到节点
            int mc = modCount;
            V v = remappingFunction.apply(key, oldValue);//key和节点值进行操作
            if (mc != modCount) { throw new ConcurrentModificationException(); }
            if (v != null) {//计算的值不为空
                e.value = v;//节点值设置成计算的值
                afterNodeAccess(e);
                return v;
            }
            else//计算的值为空
                removeNode(hash, key, null, false, true);//移除节点
        }
        return null;
    }
```

#### compute 节点存在，计算值为空的就删除，不为空就赋值，节点不存且计算不为空，就插入
```
@Override
    public V compute(K key,
                     BiFunction<? super K, ? super V, ? extends V> remappingFunction) {
        if (remappingFunction == null)
            throw new NullPointerException();
        int hash = hash(key);
        Node<K,V>[] tab; Node<K,V> first; int n, i;
        int binCount = 0;
        TreeNode<K,V> t = null;
        Node<K,V> old = null;
        if (size > threshold || (tab = table) == null ||(n = tab.length) == 0)//满了或者空的
            n = (tab = resize()).length;//扩容
        if ((first = tab[i = (n - 1) & hash]) != null) {//桶位存在节点
            if (first instanceof TreeNode)//树节点
                old = (t = (TreeNode<K,V>)first).getTreeNode(hash, key);
            else {//链表节点
                Node<K,V> e = first; K k;
                do {
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k)))) {
                        old = e;
                        break;
                    }
                    ++binCount;
                } while ((e = e.next) != null);//循环链表
            }
        }
        V oldValue = (old == null) ? null : old.value;
        int mc = modCount;
        V v = remappingFunction.apply(key, oldValue);//用key,和节点值执行apply
        if (mc != modCount) { throw new ConcurrentModificationException(); }
        if (old != null) {//存在节点
            if (v != null) {//计算值不为空
                old.value = v;//赋值
                afterNodeAccess(old);
            }
            else//计算值为空
                removeNode(hash, key, null, false, true);//删除
        }
        else if (v != null) {//节点不存在，且计算值不为空
            if (t != null)//桶位放的是树
                t.putTreeVal(this, tab, hash, key, v);//插入节点
            else {//桶位放的是链表
                tab[i] = newNode(hash, key, v, first);//插入节点
                if (binCount >= TREEIFY_THRESHOLD - 1)//判断树化
                    treeifyBin(tab, hash);
            }
            modCount = mc + 1;
            ++size;
            afterNodeInsertion(true);
        }
        return v;
    }
```

#### merge 
* 节点存在：
* 节点值不为空，用节点的值和value进行计算做计算结果
* 节点值为空用value做计算结果。
* 
* 算结果不为空，计算结果赋值给节点
* 计算结果为空，删除节点
* 
* 节点不存在(和计算结果不挂钩)：
* 且传入的value不为空，添加节点，值为value
```
@Override
    public V merge(K key, V value,
                   BiFunction<? super V, ? super V, ? extends V> remappingFunction) {
        if (value == null)
            throw new NullPointerException();
        if (remappingFunction == null)
            throw new NullPointerException();
        int hash = hash(key);
        Node<K,V>[] tab; Node<K,V> first; int n, i;
        int binCount = 0;
        TreeNode<K,V> t = null;
        Node<K,V> old = null;
        if (size > threshold || (tab = table) == null ||(n = tab.length) == 0)//满或空
            n = (tab = resize()).length;//扩容
        if ((first = tab[i = (n - 1) & hash]) != null) {//桶位节点不为空
            if (first instanceof TreeNode)//树节点
                old = (t = (TreeNode<K,V>)first).getTreeNode(hash, key);
            else {//链表节点
                Node<K,V> e = first; K k;
                do {
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k)))) {
                        old = e;
                        break;
                    }
                    ++binCount;
                } while ((e = e.next) != null);//链表循环
            }
        }
        
        if (old != null) {//节点存在，不为空
            V v;
            
            if (old.value != null) {//节点值不为空
                int mc = modCount;
                v = remappingFunction.apply(old.value, value);//节点的值和value进行操作作为计算结果
                if (mc != modCount) {
                    throw new ConcurrentModificationException();
                }
            } else {//节点值是空，那么把value设置成计算结果
                v = value;
            }
            
            
            if (v != null) {//计算结果不是空的
                old.value = v;//节点值设置成value
                afterNodeAccess(old);
            }
            else//计算结果为空
                removeNode(hash, key, null, false, true);//删除节点
            return v;
        }
        
        //节点不存在
        if (value != null) {//传入的value不为空
            if (t != null)//桶位是树
                t.putTreeVal(this, tab, hash, key, value);//插入节点
            else {//桶位是链表
                tab[i] = newNode(hash, key, value, first);//插入节点
                if (binCount >= TREEIFY_THRESHOLD - 1)//判断树化
                    treeifyBin(tab, hash);
            }
            ++modCount;
            ++size;
            afterNodeInsertion(true);
        }
        return value;
    }
```

#### forEach
```
@Override
    public void forEach(BiConsumer<? super K, ? super V> action) {
        Node<K,V>[] tab;
        if (action == null)
            throw new NullPointerException();
        if (size > 0 && (tab = table) != null) {
            int mc = modCount;
            for (Node<K,V> e : tab) {//循环桶数组
                for (; e != null; e = e.next)//循环桶位
                    action.accept(e.key, e.value);
            }
            if (modCount != mc)
                throw new ConcurrentModificationException();
        }
    }
```

#### replaceAll
```
@Override
    public void replaceAll(BiFunction<? super K, ? super V, ? extends V> function) {
        Node<K,V>[] tab;
        if (function == null)
            throw new NullPointerException();
        if (size > 0 && (tab = table) != null) {
            int mc = modCount;
            for (Node<K,V> e : tab) {//循环桶数组
                for (; e != null; e = e.next) {//循环桶位
                    e.value = function.apply(e.key, e.value);//分别重新赋值为计算结果
                }
            }
            if (modCount != mc)
                throw new ConcurrentModificationException();
        }
    }
```

#### 创建节点方法
```
 // Create a regular (non-tree) node
    Node<K,V> newNode(int hash, K key, V value, Node<K,V> next) {
        return new Node<>(hash, key, value, next);
    }

    // For conversion from TreeNodes to plain nodes
    Node<K,V> replacementNode(Node<K,V> p, Node<K,V> next) {
        return new Node<>(p.hash, p.key, p.value, next);
    }

    // Create a tree bin node
    TreeNode<K,V> newTreeNode(int hash, K key, V value, Node<K,V> next) {
        return new TreeNode<>(hash, key, value, next);
    }

    // For treeifyBin
    TreeNode<K,V> replacementTreeNode(Node<K,V> p, Node<K,V> next) {
        return new TreeNode<>(p.hash, p.key, p.value, next);
    }
```

## 线程不安全情况

### put过程

* 假设线程A，B计算出的hash桶位相同(x)
* 首先A希望插入一个key-value对到HashMap中，首先计算记录所要落到的桶的索引坐标(x)，然后获取到该桶里面的链表头结点，此时线程A的时间片用完了
* 线程B被调度得以执行，和线程A一样执行，只不过线程B成功将记录插到了桶位(x)里面
* 当线程B成功插入之后，线程A再次被调度运行时，它依然持有过期的链表头,但是它对此一无所知，以至于它认为它应该这样做,继续插入(x)
* 如此一来就覆盖了线程B插入的记录，这样线程B插入的记录就凭空消失了，造成了数据不一致的行为

```
 public static void main(String[] args) {
        HashMap<Integer, Mt> hashMap = new HashMap<>(2,0.75f);


        CompletableFuture.runAsync(()->{
            for(var i=0;i<16;i=i+16){
                Mt mt = new Mt(123580);
                hashMap.put(i,mt);//debug
            }
        });
        CompletableFuture.runAsync(()->{
            for(var i=16*1;i<16*2;i=i+16){
                Mt mt = new Mt(66666);
                hashMap.put(i,mt);//debug
            }
        });

        while (true){
            if (hashMap.size()>0){
                System.out.println(hashMap);
            }
            try {
                TimeUnit.SECONDS.sleep(1);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }


    }
    
```

### resize过程引起死循环

* 1.7会出现循环链表
```
void transfer(Entry[] newTable) {
    Entry[] src = table;
    int newCapacity = newTable.length;
    for (int j = 0; j < src.length; j++) {
        Entry e = src[j];
        if (e != null) {
            src[j] = null;
            do {
                Entry next = e.next;
                int i = indexFor(e.hash, newCapacity);
                e.next = newTable[i];
                newTable[i] = e;
                e = next;
            } while (e != null);
        }
    }
}
```

* 1.8中hashmap不会死循环



## 红黑树部分未编写

...
