# LinkedHashMap源码


## 内部类

Entry (HashMap.Node的子类,提供给LinkedHashMap使用)
```
static class Entry<K,V> extends HashMap.Node<K,V> {
        Entry<K,V> before, after;
        Entry(int hash, K key, V value, Node<K,V> next) {
            super(hash, key, value, next);
        }
    }
```

## 属性
```
transient LinkedHashMap.Entry<K,V> head;//双向链表的头

transient LinkedHashMap.Entry<K,V> tail;//双向链表的尾巴

final boolean accessOrder;//true用于访问顺序,false表示插入顺序
```

## 公共方法

### linkNodeLast把集合插入到链表尾巴
```
private void linkNodeLast(LinkedHashMap.Entry<K,V> p) {
        LinkedHashMap.Entry<K,V> last = tail;//获取尾巴
        tail = p;//尾巴赋值为p
        if (last == null)//尾巴是空的
            head = p;//头也赋值为p
        else {//尾巴不是空的
            p.before = last;//before设置成原本的尾巴
            last.after = p;//原本尾巴的after设置成p
        }
    }
```

### transferLinks(LinkedHashMap.Entry<K,V> src,LinkedHashMap.Entry<K,V> dst)用dst替换src
```
private void transferLinks(LinkedHashMap.Entry<K,V> src,LinkedHashMap.Entry<K,V> dst) {
        LinkedHashMap.Entry<K,V> b = dst.before = src.before;//设置前一个元素
        LinkedHashMap.Entry<K,V> a = dst.after = src.after;//设置后一个元素
        if (b == null)//dst前一个元素是空
            head = dst;//那么dst就是头
        else
            b.after = dst;//前一个元素的after设置成dst
            
            
        if (a == null)//dst后一个元素是空
            tail = dst;//dst就是尾巴
        else
            a.before = dst;//后一个元素的before设置成dst
    }
    
    before----->dst----->after
    before----->src----->after
    

```

### reinitialize()重新初始化 
```
    void reinitialize() {
        super.reinitialize();
        head = tail = null;
    }
```

### newNode(int hash, K key, V value, Node<K,V> e) 创建一个新的节点
```
    Node<K,V> newNode(int hash, K key, V value, Node<K,V> e) {
        LinkedHashMap.Entry<K,V> p =
            new LinkedHashMap.Entry<>(hash, key, value, e);
        linkNodeLast(p);//把p连接到结尾
        return p;
    }
```

### replacementNode(Node<K,V> p, Node<K,V> next) 替换节点
```
    Node<K,V> replacementNode(Node<K,V> p, Node<K,V> next) {
        LinkedHashMap.Entry<K,V> q = (LinkedHashMap.Entry<K,V>)p;
        LinkedHashMap.Entry<K,V> t =
            new LinkedHashMap.Entry<>(q.hash, q.key, q.value, next);
        transferLinks(q, t);
        return t;
    }
```

### newTreeNode(int hash, K key, V value, Node<K,V> next) 创建树节点
```
    TreeNode<K,V> newTreeNode(int hash, K key, V value, Node<K,V> next) {
        TreeNode<K,V> p = new TreeNode<>(hash, key, value, next);
        linkNodeLast(p);
        return p;
    }
```

### replacementTreeNode(Node<K,V> p, Node<K,V> next) 替换树节点
```
    TreeNode<K,V> replacementTreeNode(Node<K,V> p, Node<K,V> next) {
        LinkedHashMap.Entry<K,V> q = (LinkedHashMap.Entry<K,V>)p;
        TreeNode<K,V> t = new TreeNode<>(q.hash, q.key, q.value, next);
        transferLinks(q, t);
        return t;
    }
```

### afterNodeRemoval(Node<K,V> e) 删除一个节点
```
    void afterNodeRemoval(Node<K,V> e) { // unlink
        LinkedHashMap.Entry<K,V> p =
            (LinkedHashMap.Entry<K,V>)e, b = p.before, a = p.after;//获取e的头尾
        p.before = p.after = null;//头尾置空
        if (b == null)//没有头，是头节点
            head = a;//设置头
        else
            b.after = a//before的后一个元素改成a
        
        if (a == null)//没有尾巴，是尾节点
            tail = b;//设置尾
        else
            a.before = b;//after的前一个元素改成b
    }
```

### afterNodeInsertion(boolean evict) 可能会删除最年长的（不知道干嘛用）
```
    void afterNodeInsertion(boolean evict) { // possibly remove eldest
        LinkedHashMap.Entry<K,V> first;
        if (evict && (first = head) != null && removeEldestEntry(first)) {//删除最老的，最不常用的
            K key = first.key;
            removeNode(hash(key), key, null, false, true);
        }
    }
```

### afterNodeAccess(Node<K,V> e) 将节点移动到最后(不理解是干嘛用的)
```
    void afterNodeAccess(Node<K,V> e) { // move node to last
        LinkedHashMap.Entry<K,V> last;
        if (accessOrder && (last = tail) != e) {
            LinkedHashMap.Entry<K,V> p =
                (LinkedHashMap.Entry<K,V>)e, b = p.before, a = p.after;
            p.after = null;
            if (b == null)
                head = a;
            else
                b.after = a;
            if (a != null)
                a.before = b;
            else
                last = b;
            if (last == null)
                head = p;
            else {
                p.before = last;
                last.after = p;
            }
            tail = p;
            ++modCount;
        }
    }
```

## 构造函数


### LinkedHashMap(int initialCapacity, float loadFactor)初始容量和负载因子
```
 public LinkedHashMap(int initialCapacity, float loadFactor) {
        super(initialCapacity, loadFactor);
        accessOrder = false;//将accessOrder置为sals
    }
```

### LinkedHashMap(int initialCapacity)初始容量
```
 public LinkedHashMap(int initialCapacity) {
        super(initialCapacity);
        accessOrder = false;
    }
```

### LinkedHashMap()
```
 public LinkedHashMap() {
        super();
        accessOrder = false;
    }
```


### LinkedHashMap(Map<? extends K, ? extends V> m)
```
 public LinkedHashMap(Map<? extends K, ? extends V> m) {
        super();
        accessOrder = false;
        putMapEntries(m, false);
    }
```

### LinkedHashMap(int initialCapacity, float loadFactor, boolean accessOrder)可以设置accessOrder
``` 
public LinkedHashMap(int initialCapacity, float loadFactor, boolean accessOrder) {
        super(initialCapacity, loadFactor);
        this.accessOrder = accessOrder;
    }
```

## 方法

### containsValue(Object value)是否有某个对象
```
 public boolean containsValue(Object value) {
        for (LinkedHashMap.Entry<K,V> e = head; e != null; e = e.after) {//从头节点开始循环
            V v = e.value;
            if (v == value || (value != null && value.equals(v)))
                return true;
        }
        return false;
    }
```

### get(Object key)
```
 public V get(Object key) {
        Node<K,V> e;
        if ((e = getNode(hash(key), key)) == null)//调用的hashMap的方法
            return null;
        if (accessOrder)
            afterNodeAccess(e);//会把查询出的节点放到最后
        return e.value;
    }
```

### getOrDefault(Object key, V defaultValue)
```
public V getOrDefault(Object key, V defaultValue) {
       Node<K,V> e;
       if ((e = getNode(hash(key), key)) == null)//获取不到返回默认值
           return defaultValue;
       if (accessOrder)
           afterNodeAccess(e);//会把查询出的节点放到最后
       return e.value;
   }
```

###  clear()
```
 public void clear() {
        super.clear();//HashMap的clear
        head = tail = null;//头尾置空
    }
```

### removeEldestEntry(Map.Entry<K,V> eldest)
* 当你要实现LRUCache时可以重写该方法
```
  protected boolean removeEldestEntry(Map.Entry<K,V> eldest) {
        return false;
    }
```


### keySet()获取所有key的集合
```
 public Set<K> keySet() {
        Set<K> ks = keySet;//AbstractMap里的属性
        if (ks == null) {
            ks = new LinkedKeySet();//空就赋值
            keySet = ks;
        }
        return ks;
    }
```

### LinkedKeySet内部类
```
 final class LinkedKeySet extends AbstractSet<K> {
        public final int size()                 { return size; }
        public final void clear()               { LinkedHashMap.this.clear(); }//LinkedHashMap的clear
        public final Iterator<K> iterator() {
            return new LinkedKeyIterator();
        }
        public final boolean contains(Object o) { return containsKey(o); }//HashMap中的containsKey
        public final boolean remove(Object key) {//HashMap中的remove
            return removeNode(hash(key), key, null, false, true) != null;
        }
        public final Spliterator<K> spliterator()  {
            return Spliterators.spliterator(this, Spliterator.SIZED |
                                            Spliterator.ORDERED |
                                            Spliterator.DISTINCT);
        }
        public final void forEach(Consumer<? super K> action) {//迭代
            if (action == null)
                throw new NullPointerException();
            int mc = modCount;
            for (LinkedHashMap.Entry<K,V> e = head; e != null; e = e.after)//从head开始往后迭代
                action.accept(e.key);//放的是key
            if (modCount != mc)
                throw new ConcurrentModificationException();
        }
    }
```

### values()获取所有值
```
public Collection<V> values() {
        Collection<V> vs = values;//AbstractMap中的属性
        if (vs == null) {
            vs = new LinkedValues();//空就赋值
            values = vs;
        }
        return vs;
    }
```

### entrySet()
```
 public Set<Map.Entry<K,V>> entrySet() {
        Set<Map.Entry<K,V>> es;
        return (es = entrySet) == null ? (entrySet = new LinkedEntrySet()) : es;//entrySet是hashMap中的
    }
```

### LinkedEntrySet内部类
```
final class LinkedEntrySet extends AbstractSet<Map.Entry<K,V>> {
        public final int size()                 { return size; }
        public final void clear()               { LinkedHashMap.this.clear(); }
        public final Iterator<Map.Entry<K,V>> iterator() {
            return new LinkedEntryIterator();
        }
        public final boolean contains(Object o) {
            if (!(o instanceof Map.Entry))//判断是不是Map.Entry
                return false;
            Map.Entry<?,?> e = (Map.Entry<?,?>) o;
            Object key = e.getKey();
            Node<K,V> candidate = getNode(hash(key), key);//HashMap中的getNode
            return candidate != null && candidate.equals(e);//调用candidate的equals
        }
        public final boolean remove(Object o) {
            if (o instanceof Map.Entry) {//判断是不是Map.Entry
                Map.Entry<?,?> e = (Map.Entry<?,?>) o;
                Object key = e.getKey();
                Object value = e.getValue();
                return removeNode(hash(key), key, value, true, true) != null;//HashMap中的removeNode
            }
            return false;
        }
        public final Spliterator<Map.Entry<K,V>> spliterator() {
            return Spliterators.spliterator(this, Spliterator.SIZED |
                                            Spliterator.ORDERED |
                                            Spliterator.DISTINCT);
        }
        public final void forEach(Consumer<? super Map.Entry<K,V>> action) {//迭代
            if (action == null)
                throw new NullPointerException();
            int mc = modCount;
            for (LinkedHashMap.Entry<K,V> e = head; e != null; e = e.after)//从head循环after
                action.accept(e);//放的是Entry
            if (modCount != mc)
                throw new ConcurrentModificationException();
        }
    }
```



### forEach(BiConsumer<? super K, ? super V> action) 
```
 public void forEach(BiConsumer<? super K, ? super V> action) {
        if (action == null)
            throw new NullPointerException();
        int mc = modCount;
        for (LinkedHashMap.Entry<K,V> e = head; e != null; e = e.after)//从head开始迭代
            action.accept(e.key, e.value);
        if (modCount != mc)
            throw new ConcurrentModificationException();//线程不安全
    }
```


### replaceAll(BiFunction<? super K, ? super V, ? extends V> function)
```
 public void replaceAll(BiFunction<? super K, ? super V, ? extends V> function) {
        if (function == null)
            throw new NullPointerException();
        int mc = modCount;
        for (LinkedHashMap.Entry<K,V> e = head; e != null; e = e.after)//从head开始迭代
            e.value = function.apply(e.key, e.value);//赋值为function的执行结果
        if (modCount != mc)
            throw new ConcurrentModificationException();
    }
```


### LinkedHashIterator内部类
```
abstract class LinkedHashIterator {
        LinkedHashMap.Entry<K,V> next;//下一个指针指向
        LinkedHashMap.Entry<K,V> current;//当前指向
        int expectedModCount;

        LinkedHashIterator() {
            next = head;
            expectedModCount = modCount;
            current = null;
        }

        public final boolean hasNext() {
            return next != null;
        }

        final LinkedHashMap.Entry<K,V> nextNode() {//下一个节点
            LinkedHashMap.Entry<K,V> e = next;
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
            if (e == null)
                throw new NoSuchElementException();
            current = e;
            next = e.after;//next指针移动到下一位
            return e;
        }

        public final void remove() {
            Node<K,V> p = current;
            if (p == null)
                throw new IllegalStateException();
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
            current = null;
            removeNode(p.hash, p.key, null, false, false);//调用HashMap的removeNode
            expectedModCount = modCount;
        }
    }
```

### LinkedKeyIterator / LinkedValueIterator / LinkedEntryIterator
```
final class LinkedKeyIterator extends LinkedHashIterator
        implements Iterator<K> {
        public final K next() { return nextNode().getKey(); }//重写next
    }

    final class LinkedValueIterator extends LinkedHashIterator
        implements Iterator<V> {
        public final V next() { return nextNode().value; }//重写next
    }

    final class LinkedEntryIterator extends LinkedHashIterator
        implements Iterator<Map.Entry<K,V>> {
        public final Map.Entry<K,V> next() { return nextNode(); }//重写next
    }
```
