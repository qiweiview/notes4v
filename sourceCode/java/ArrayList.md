## ArrayList

### 属性
```java
   
    private static final int DEFAULT_CAPACITY = 10;//默认的初始化空间

    private static final Object[] EMPTY_ELEMENTDATA = {};//空的数组用于空对象初始化

    private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};

    transient Object[] elementData; //存储数组，非私有简化了嵌套类访问

    private int size;//实际存储的数据量
    
    protected transient int modCount = 0;//集合被操作次数，次数对不上抛出ConcurrentModificationException();
```

### 构造方法

设置初始空间大小的构造方法
```
 public ArrayList(int initialCapacity) {
        if (initialCapacity > 0) {//大于0就构造对应长度的Object数组
            this.elementData = new Object[initialCapacity];
        } else if (initialCapacity == 0) {//等于0就直接赋值空的数组对象
            this.elementData = EMPTY_ELEMENTDATA;
        } else {//小于0就抛出异常
            throw new IllegalArgumentException("Illegal Capacity: "+
                                               initialCapacity);
        }
    }
```

无参构造方法
```
 public ArrayList() {
        this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;//直接赋值空的数组对象
    }
```

集合子类参数的构造方法
```
 public ArrayList(Collection<? extends E> c) {
        elementData = c.toArray();//参数c为实现了Collection的类，toArray为Collection接口定义方法
        if ((size = elementData.length) != 0) {
            if (elementData.getClass() != Object[].class)//Arrays.copyOf返回类型依赖于第一个参数的类型，此处防止Arrays.copyOf不返回 Object[]类型数据，bug见https://bugs.openjdk.java.net/browse/JDK-6260652
                elementData = Arrays.copyOf(elementData, size, Object[].class);//注意此处，仅拷贝实际数据长度
        } else {
            // replace with empty array.
            this.elementData = EMPTY_ELEMENTDATA;//c参数集合长度为0，那么elementData赋值为空的数组对象
        }
    }
```



### 基础方法


#### trimToSize  elementData长度修剪到实际存储数据长度
```
 public void trimToSize() {
        modCount++;//操作数+1
        if (size < elementData.length) {//如果实际存储数量小于elementData长度
            elementData = (size == 0)
              ? EMPTY_ELEMENTDATA//如果实际存储为0，那么elementData赋值为空的数组对象
              : Arrays.copyOf(elementData, size);//否则拷贝实际存储的长度的数据
        }
    }
```

#### ensureCapacity       确保elementData至少可以容纳minCapacity个数据
```
  public void ensureCapacity(int minCapacity) {
        if (
        minCapacity > elementData.length//最低容纳数量大于当前elementData长度
            && 
        !(elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA&& minCapacity <= DEFAULT_CAPACITY)//elementData不等于空数组对象并且最低容纳量大于默认空间(10)
        ) {
            modCount++;//操作数+1
            grow(minCapacity);//符合条件则扩展数组
        }
    }
```

#### grow  扩展数组
```
  private Object[] grow() {
        return grow(size + 1);//按照实际存储数据量+1来扩展
    }
```

#### grow(int minCapacity) 扩展数组
```
private Object[] grow(int minCapacity) {
        return elementData = Arrays.copyOf(elementData, newCapacity(minCapacity));//复制数组，长度为newCapacity(minCapacity)的返回
    }
```



#### newCapacity(int minCapacity) 返回至少与给定最小容量一样大的容量
```
 private int newCapacity(int minCapacity) {
        // overflow-conscious code
        int oldCapacity = elementData.length;//获取旧elementData长度
        int newCapacity = oldCapacity + (oldCapacity >> 1);//新的长度为旧的1.5倍
        if (newCapacity - minCapacity <= 0) {//如果新的长度比最小容量小
            if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA)
                return Math.max(DEFAULT_CAPACITY, minCapacity);//如果elementData是空的，返回10和最小容量中比较大的一个
            if (minCapacity < 0) // overflow
                throw new OutOfMemoryError();//最小容量不允许为负数
            return minCapacity;//如果新的长度比最小容量小，那么直接返回最小容量
        }
        return (newCapacity - MAX_ARRAY_SIZE <= 0)//如果新的长度比最大长度小，那么返回新的容量，否则返回hugeCapacity(minCapacity)返回值
            ? newCapacity
            : hugeCapacity(minCapacity);
    }
```

#### hugeCapacity(int minCapacity)  返回大的的容量

```
 private static int hugeCapacity(int minCapacity) {
        if (minCapacity < 0) // overflow
            throw new OutOfMemoryError();//最小容量不允许为负数
        return (minCapacity > MAX_ARRAY_SIZE)
            ? Integer.MAX_VALUE//如果最小容量大于MAX_ARRAY_SIZE返回Integer的最大值
            : MAX_ARRAY_SIZE;//否则返回MAX_ARRAY_SIZE (MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;)
    }
```


#### size  返回实际存储的数据数

```
public int size() {
        return size;
    }
```

#### isEmpty  判断实际存储的数据是否为空

```
  public boolean isEmpty() {
        return size == 0;
    }
```

#### contains  判断一个元素是否存在

```
 public boolean contains(Object o) {
        return indexOf(o) >= 0;
    }
```

#### indexOf  获取一个元素位置

```
  public int indexOf(Object o) {
        return indexOfRange(o, 0, size);
    }
```

#### indexOfRange(Object o, int start, int end) 范围内查询目标数据在集合中的位置

```
   int indexOfRange(Object o, int start, int end) {
        Object[] es = elementData;
        if (o == null) {//如果目标数据为空
            for (int i = start; i < end; i++) {//从start循环到end
                if (es[i] == null) {
                    return i;//如果数据为null,则返回对应的下标
                }
            }
        } else {//目标数据不为空
            for (int i = start; i < end; i++) {//从start循环到end
                if (o.equals(es[i])) {//调用的是目标函数的equals方法，这很重要
                    return i;
                }
            }
        }
        return -1;
    }
```


#### lastIndexOf(Object o) 查找元素最后一次出现位置

```
 public int lastIndexOf(Object o) {
        return lastIndexOfRange(o, 0, size);
    }
```

#### lastIndexOfRange(Object o, int start, int end) 范围内查询元素最后一次出现位置（即逆第一次出现位置）

```
 int lastIndexOfRange(Object o, int start, int end) {
        Object[] es = elementData;
        if (o == null) {//如果目标数据为空
            for (int i = end - 1; i >= start; i--) {//从end-1
                if (es[i] == null) {
                    return i;
                }
            }
        } else {
            for (int i = end - 1; i >= start; i--) {
                if (o.equals(es[i])) {//调用的是目标函数的equals方法，这很重要
                    return i;
                }
            }
        }
        return -1;
    }
```

#### clone() 克隆集合

```
public Object clone() {
        try {
            ArrayList<?> v = (ArrayList<?>) super.clone();
            v.elementData = Arrays.copyOf(elementData, size);//克隆出elementData长度为实际元素长度
            v.modCount = 0;
            return v;
        } catch (CloneNotSupportedException e) {
            // this shouldn't happen, since we are Cloneable
            throw new InternalError(e);
        }
    }
```

#### toArray() 返回数组

```
 public Object[] toArray() {
        return Arrays.copyOf(elementData, size);//仅返回实际元素长度的数组
    }
```   

#### toArray(T[] a) 返回数组

```
 public <T> T[] toArray(T[] a) {
        if (a.length < size)
            // Make a new array of a's runtime type, but my contents:
            return (T[]) Arrays.copyOf(elementData, size, a.getClass());
        System.arraycopy(elementData, 0, a, 0, size);
        if (a.length > size)
            a[size] = null;//如果传入的数组长度大于集合实际存储数目，那么将a数组size位置空后返回（不理解）
        return a;
    }
```  

#### get(int index) 或许元素
```
public E get(int index) {
        Objects.checkIndex(index, size);//确认index>0,且index<size,否则抛出IndexOutOfBoundsException
        return elementData(index);
    }
```

#### set(int index, E element) 设置元素值
```
  public E set(int index, E element) {
        Objects.checkIndex(index, size);//确认index>0,且index<size,否则抛出IndexOutOfBoundsException
        E oldValue = elementData(index);//获取旧值
        elementData[index] = element;//设置新值
        return oldValue;//返回旧值
    }
```

#### elementData(int index)  获取元素
```
 E elementData(int index) {
        return (E) elementData[index];
    }
```

#### elementAt(Object[] es, int index) 获取传入数组的index位元素
```
static <E> E elementAt(Object[] es, int index) {
        return (E) es[index];
    }
```

#### add(E e) 添加元素到集合里（尾插入）
```
  public boolean add(E e) {
        modCount++;
        add(e, elementData, size);
        return true;//注意这里永远返回true
    }
```

#### add(E e, Object[] elementData, int s) 添加元素到集合里
```
 private void add(E e, Object[] elementData, int s) {
        if (s == elementData.length)
            elementData = grow();//满了就扩容
        elementData[s] = e;//把s位值设置为e, s一定会是空的
        size = s + 1;//手动将实际元素数+1
    }
```

#### add(int index, E element) 将元素插入到固定位置（中部插入）

```
public void add(int index, E element) {
        rangeCheckForAdd(index);//确认index>0,且index<size,否则抛出IndexOutOfBoundsException
        modCount++;
        final int s;
        Object[] elementData;
        if ((s = size) == (elementData = this.elementData).length)
            elementData = grow();//如果满了就扩容
        System.arraycopy(elementData, index,
                         elementData, index + 1,
                         s - index);//复制index位开始的元素到index+1位，即index位开始元素全部往后挪1位
        elementData[index] = element;//index位赋值为element
        size = s + 1;//手动将实际元素数+1
    }
```


#### remove(int index)删除index位处的数据
```
public E remove(int index) {
        Objects.checkIndex(index, size);//确认index>0,且index<size
        final Object[] es = elementData;

        @SuppressWarnings("unchecked") E oldValue = (E) es[index];
        fastRemove(es, index);//快速删除

        return oldValue;//返回旧值
    }
```


#### fastRemove(Object[] es, int i)快速删除
```
private void fastRemove(Object[] es, int i) {
        modCount++;
        final int newSize;
        if ((newSize = size - 1) > i)//i在实际存储数据范围内（数组下标从0开始）
            System.arraycopy(es, i + 1, es, i, newSize - i);//把i+1位后的newSize - i个数据往前移一位
        es[size = newSize] = null;//把末位置空
    }
```


#### equals(Object o)比较对象是否相等
```
 public boolean equals(Object o) {
        if (o == this) {//判断内存地址
            return true;
        }

        if (!(o instanceof List)) {//不是List子类，直接返回false
            return false;
        }

        final int expectedModCount = modCount;//赋值期望的操作数
        // ArrayList can be subclassed and given arbitrary behavior, but we can
        // still deal with the common case where o is ArrayList precisely
        boolean equal = (o.getClass() == ArrayList.class)
            ? equalsArrayList((ArrayList<?>) o)//是ArrayList
            : equalsRange((List<?>) o, 0, size);//不是ArrayList

        checkForComodification(expectedModCount);//确认线程安全
        return equal;
    }
```

#### equalsArrayList(ArrayList<?> other)ArrayList判断相等
```
 private boolean equalsArrayList(ArrayList<?> other) {
        final int otherModCount = other.modCount;
        final int s = size;
        boolean equal;
        if (equal = (s == other.size)) {//比较存储数据量
            final Object[] otherEs = other.elementData;//传入的缓冲区
            final Object[] es = elementData;//当前的缓冲区
            if (s > es.length || s > otherEs.length) {
                throw new ConcurrentModificationException();//线程不安全
            }
            for (int i = 0; i < s; i++) {
                if (!Objects.equals(es[i], otherEs[i])) {//比较每个元素，一个不相等就break
                    equal = false;
                    break;
                }
            }
        }
        other.checkForComodification(otherModCount);//查看线程是否安全
        return equal;
    }

```


#### equalsRange(List<?> other, int from, int to)判断List相等
```
 boolean equalsRange(List<?> other, int from, int to) {
        final Object[] es = elementData;//当前缓冲区
        if (to > es.length) {
            throw new ConcurrentModificationException();//线程不安全
        }
        var oit = other.iterator();//获取迭代器
        for (; from < to; from++) {
            if (!oit.hasNext() || !Objects.equals(es[from], oit.next())) {//判断每个元素，跑不到oit.hasNext()为false,因为for循环会先进不来
                return false;
            }
        }
        return !oit.hasNext();//for循环结束后oit.hasNext()必定为false,即!oit.hasNext()是true
            }
```

#### checkForComodification(final int expectedModCount)确认线程是否安全
```
  private void checkForComodification(final int expectedModCount) {
        if (modCount != expectedModCount) {
            throw new ConcurrentModificationException();
        }
    }
```

#### hashCode()返回哈希码
```
public int hashCode() {
        int expectedModCount = modCount;
        int hash = hashCodeRange(0, size);//范围内哈希
        checkForComodification(expectedModCount);//确认线程安全
        return hash;
    }
```

#### hashCodeRange(int from, int to)范围内哈希
```
 int hashCodeRange(int from, int to) {
        final Object[] es = elementData;
        if (to > es.length) {
            throw new ConcurrentModificationException();//线程不安全
        }
        int hashCode = 1;
        for (int i = from; i < to; i++) {
            Object e = es[i];
            hashCode = 31 * hashCode + (e == null ? 0 : e.hashCode());//对象为空则取0
        }
        return hashCode;
    }
```

#### boolean remove(Object o)移除一个对象
```
public boolean remove(Object o) {
        final Object[] es = elementData;
        final int size = this.size;
        int i = 0;
        found: {
            if (o == null) {//空对象
                for (; i < size; i++)
                    if (es[i] == null)//循环比对内存地址获取被删除对象下标
                        break found;//跳出标记found
            } else {//不是空对象
                for (; i < size; i++)
                    if (o.equals(es[i]))//调用要被删除对象的equals方法
                        break found;//跳出标记found
            }
            return false;//要删除的数据不在缓冲区中，直接返回false
        }
        fastRemove(es, i);//调用快速删除，按照下标删除
        return true;//成功返回true
    }
```

#### clear()删除错有缓冲区里的数据
```
public void clear() {
        modCount++;
        final Object[] es = elementData;
        for (int to = size, i = size = 0; i < to; i++)//实际存储数据置0，从0到实际存储的位置循环置null
            es[i] = null;
    }
```

#### addAll(Collection<? extends E> c)添加集合到当前集合
```
 public boolean addAll(Collection<? extends E> c) {
        Object[] a = c.toArray();//转化为数组
        modCount++;
        int numNew = a.length;//添加数据长度
        if (numNew == 0)
            return false;//长度为0直接返回false
        Object[] elementData;
        final int s;
        if (numNew > (elementData = this.elementData).length - (s = size))//旧数据长度+新数据长度大于缓冲区大小，就扩容
            elementData = grow(s + numNew);//扩大为可以容纳旧数据+新数据大小
        System.arraycopy(a, 0, elementData, s, numNew);//新数据从0位开始复制到缓冲区的s位处，复制长度为新数据长度
        size = s + numNew;
        return true;
    }
```

#### addAll(int index, Collection<? extends E> c)添加集合到当前集合的固定位置
```
 public boolean addAll(int index, Collection<? extends E> c) {
        rangeCheckForAdd(index);//确认下标

        Object[] a = c.toArray();//转数组
        modCount++;
        int numNew = a.length;
        if (numNew == 0)
            return false;//长度为0直接返回
        Object[] elementData;
        final int s;
        if (numNew > (elementData = this.elementData).length - (s = size))//旧数据长度+新数据长度大于缓冲区大小，就扩容
            elementData = grow(s + numNew);

        int numMoved = s - index;//存储长度减去index得出就是要移动数据的长度
        if (numMoved > 0)
            System.arraycopy(elementData, index,elementData, index + numNew,numMoved);//把缓冲区从index移动到index + numNew，移动长度为numMoved 
        System.arraycopy(a, 0, elementData, index, numNew);//把集合从0位移动到缓冲区index位，共移动集合的长度个数据
        size = s + numNew;//实际存储数更改为size+集合长度
        return true;//返回true
    }
```

#### removeRange(int fromIndex, int toIndex)删除介于(包含)fromIndex和toIndex（不包含）的所有元素
```
  protected void removeRange(int fromIndex, int toIndex) {
        if (fromIndex > toIndex) {
            throw new IndexOutOfBoundsException(
                    outOfBoundsMsg(fromIndex, toIndex));
        }
        modCount++;
        shiftTailOverGap(elementData, fromIndex, toIndex);
    }
```

#### shiftTailOverGap(Object[] es, int lo, int hi)删除lo(包含)到hi（不包含）期间的元素
```
 private void shiftTailOverGap(Object[] es, int lo, int hi) {
        System.arraycopy(es, hi, es, lo, size - hi);//从hi位以后的数据复制到lo位，共复制size-hi个数据
        for (int to = size, i = (size -= hi - lo); i < to; i++)
            es[i] = null;//置0
    }
```

#### rangeCheckForAdd(int index)判断是否在区间内
```
private void rangeCheckForAdd(int index) {
        if (index > size || index < 0)
            throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
    }
```

#### 下标越界消息 
```
private String outOfBoundsMsg(int index) {
        return "Index: "+index+", Size: "+size;
    }
    
    
private static String outOfBoundsMsg(int fromIndex, int toIndex) {
        return "From Index: " + fromIndex + " > To Index: " + toIndex;
    }
```

#### removeAll(Collection<?> c)  删除缓冲区中，集合包含的数据
```
 public boolean removeAll(Collection<?> c) {
        return batchRemove(c, false, 0, size);
    }
```

#### retainAll(Collection<?> c)保留缓冲区中，集合包含的数据
```
public boolean retainAll(Collection<?> c) {
        return batchRemove(c, true, 0, size);
    }
```

#### batchRemove(Collection<?> c, boolean complement,final int from, final int end)false是删除传入集合包含元素，true是保留传入集合包含元素
```
boolean batchRemove(Collection<?> c, boolean complement,
                        final int from, final int end) {
        Objects.requireNonNull(c);
        final Object[] es = elementData;
        int r;
        // Optimize for initial run of survivors
        for (r = from;; r++) {
            if (r == end)//操作长度为0直接返回false
                return false;
            if (c.contains(es[r]) != complement)//为true的时候，查找到第一个不保留位r。为false时候查找到第一个要删除的位
                break;
        }
        int w = r++;
        try {
            for (Object e; r < end; r++)
                if (c.contains(e = es[r]) == complement)//为true时把在集合的元素往前移，为false时，不在集合的元素往前移动
                    es[w++] = e;
        } catch (Throwable ex) {
            // Preserve behavioral compatibility with AbstractCollection,
            // even if c.contains() throws.
            System.arraycopy(es, r, es, w, end - r);
            w += end - r;
            throw ex;
        } finally {
            modCount += end - w;
            shiftTailOverGap(es, w, end);//删除尾部元素
        }
        return true;
    }
```

#### writeObject(java.io.ObjectOutputStream s)输出对象
```
private void writeObject(java.io.ObjectOutputStream s)
        throws java.io.IOException {
        // Write out element count, and any hidden stuff
        int expectedModCount = modCount;
        s.defaultWriteObject();

        // Write out size as capacity for behavioral compatibility with clone()
        s.writeInt(size);

        // Write out all elements in the proper order.
        for (int i=0; i<size; i++) {
            s.writeObject(elementData[i]);//循环输出对象
        }

        if (modCount != expectedModCount) {
            throw new ConcurrentModificationException();//线程安全
        }
    }
```

#### readObject(java.io.ObjectInputStream s)读取对象
```
private void readObject(java.io.ObjectInputStream s) throws java.io.IOException, ClassNotFoundException {

        // Read in size, and any hidden stuff
        s.defaultReadObject();

        // Read in capacity
        s.readInt(); // ignored

        if (size > 0) {//数据量大于0
            // like clone(), allocate array based upon size not capacity
            SharedSecrets.getJavaObjectInputStreamAccess().checkArray(s, Object[].class, size);
            Object[] elements = new Object[size];

            // Read in all elements in the proper order.
            for (int i = 0; i < size; i++) {
                elements[i] = s.readObject();
            }

            elementData = elements;
        } else if (size == 0) {//数据量等于0
            elementData = EMPTY_ELEMENTDATA;
        } else {
            throw new java.io.InvalidObjectException("Invalid size: " + size);
        }
    }
```


#### listIterator()返回迭代器
```
public ListIterator<E> listIterator() {
        return new ListItr(0);
    }
```

#### listIterator(int index)返回迭代器
```
public ListIterator<E> listIterator(int index) {
        rangeCheckForAdd(index);//
        return new ListItr(index);
    }
```

## Itr内部类
```
private class Itr implements Iterator<E> {
        int cursor;       // 要返回的下一个元素的索引
        int lastRet = -1; // 返回最后一个元素的索引; 如果没有这样的话-1
        int expectedModCount = modCount;

        // prevent creating a synthetic constructor
        Itr() {}

        public boolean hasNext() {
            return cursor != size;
        }

        @SuppressWarnings("unchecked")
        public E next() {
            checkForComodification();//线程安全
            int i = cursor;
            if (i >= size)
                throw new NoSuchElementException();//光标越界
            Object[] elementData = ArrayList.this.elementData;//缓冲区
            if (i >= elementData.length)
                throw new ConcurrentModificationException();//线程不安全
            cursor = i + 1;
            return (E) elementData[lastRet = i];//最后一个元素的索引改成i
        }

        public void remove() {
            if (lastRet < 0)
                throw new IllegalStateException();
            checkForComodification();

            try {
                ArrayList.this.remove(lastRet);//移除最后返回的元素
                cursor = lastRet;//光标回退
                lastRet = -1;//最后返回的元素被删除，索引变为-1
                expectedModCount = modCount;
            } catch (IndexOutOfBoundsException ex) {
                throw new ConcurrentModificationException();
            }
        }

        @Override
        public void forEachRemaining(Consumer<? super E> action) {//循环剩余
            Objects.requireNonNull(action);
            final int size = ArrayList.this.size;
            int i = cursor;
            if (i < size) {//
                final Object[] es = elementData;
                if (i >= es.length)
                    throw new ConcurrentModificationException();//线程异常
                for (; i < size && modCount == expectedModCount; i++)
                    action.accept(elementAt(es, i));//把缓冲区es中i处元素放进accept方法里
                // update once at end to reduce heap write traffic
                cursor = i;
                lastRet = i - 1;
                checkForComodification();
            }
        }

        final void checkForComodification() {//线程安全
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
        }
    }
```

#### subList(int fromIndex, int toIndex)返回集合的部分（类型变成了SubList）
```
public List<E> subList(int fromIndex, int toIndex) {
        subListRangeCheck(fromIndex, toIndex, size);
        return new SubList<>(this, fromIndex, toIndex);
    }
```

## ListItr 内部类
```
 private class ListItr extends Itr implements ListIterator<E> {
        ListItr(int index) {
            super();
            cursor = index;
        }

        public boolean hasPrevious() {
            return cursor != 0;
        }

        public int nextIndex() {//下一个索引
            return cursor;
        }

        public int previousIndex() {//前一个索引
            return cursor - 1;
        }

        @SuppressWarnings("unchecked")
        public E previous() {//前一个
            checkForComodification();
            int i = cursor - 1;
            if (i < 0)
                throw new NoSuchElementException();
            Object[] elementData = ArrayList.this.elementData;
            if (i >= elementData.length)
                throw new ConcurrentModificationException();
            cursor = i;//光标前移
            return (E) elementData[lastRet = i];
        }

        public void set(E e) {
            if (lastRet < 0)//最后操作位必须大于0，即进行删除操作后得滑动索引，不然会报IllegalStateException
                throw new IllegalStateException();
            checkForComodification();

            try {
                ArrayList.this.set(lastRet, e);//最后操作位处插入
            } catch (IndexOutOfBoundsException ex) {
                throw new ConcurrentModificationException();
            }
        }

        public void add(E e) {
            checkForComodification();//线程安全

            try {
                int i = cursor;
                ArrayList.this.add(i, e);//在下一个操作位处添加元素
                cursor = i + 1;//后移光标
                lastRet = -1;//清空最后操作元素
                expectedModCount = modCount;
            } catch (IndexOutOfBoundsException ex) {
                throw new ConcurrentModificationException();
            }
        }
    }
```

#### subList(int fromIndex, int toIndex)  
```
public List<E> subList(int fromIndex, int toIndex) {
        subListRangeCheck(fromIndex, toIndex, size);
        return new SubList<>(this, fromIndex, toIndex);
    }
```

## 静态内部类SubList
```
private static class SubList<E> extends AbstractList<E> implements RandomAccess {
        private final ArrayList<E> root;
        private final SubList<E> parent;
        private final int offset;
        private int size;

        /#### 
         * Constructs a sublist of an arbitrary ArrayList.
         */
        public SubList(ArrayList<E> root, int fromIndex, int toIndex) {
            this.root = root;
            this.parent = null;
            this.offset = fromIndex;
            this.size = toIndex - fromIndex;
            this.modCount = root.modCount;
        }

        /#### 
         * Constructs a sublist of another SubList.
         */
        private SubList(SubList<E> parent, int fromIndex, int toIndex) {
            this.root = parent.root;
            this.parent = parent;
            this.offset = parent.offset + fromIndex;
            this.size = toIndex - fromIndex;
            this.modCount = root.modCount;
        }

        public E set(int index, E element) {
            Objects.checkIndex(index, size);
            checkForComodification();
            E oldValue = root.elementData(offset + index);
            root.elementData[offset + index] = element;
            return oldValue;
        }

        public E get(int index) {
            Objects.checkIndex(index, size);
            checkForComodification();
            return root.elementData(offset + index);
        }

        public int size() {
            checkForComodification();
            return size;
        }

        public void add(int index, E element) {
            rangeCheckForAdd(index);
            checkForComodification();
            root.add(offset + index, element);
            updateSizeAndModCount(1);
        }

        public E remove(int index) {
            Objects.checkIndex(index, size);
            checkForComodification();
            E result = root.remove(offset + index);
            updateSizeAndModCount(-1);
            return result;
        }

        protected void removeRange(int fromIndex, int toIndex) {
            checkForComodification();
            root.removeRange(offset + fromIndex, offset + toIndex);
            updateSizeAndModCount(fromIndex - toIndex);
        }

        public boolean addAll(Collection<? extends E> c) {
            return addAll(this.size, c);
        }

        public boolean addAll(int index, Collection<? extends E> c) {
            rangeCheckForAdd(index);
            int cSize = c.size();
            if (cSize==0)
                return false;
            checkForComodification();
            root.addAll(offset + index, c);
            updateSizeAndModCount(cSize);
            return true;
        }

        public void replaceAll(UnaryOperator<E> operator) {
            root.replaceAllRange(operator, offset, offset + size);
        }

        public boolean removeAll(Collection<?> c) {
            return batchRemove(c, false);
        }

        public boolean retainAll(Collection<?> c) {
            return batchRemove(c, true);
        }

        private boolean batchRemove(Collection<?> c, boolean complement) {
            checkForComodification();
            int oldSize = root.size;
            boolean modified =
                root.batchRemove(c, complement, offset, offset + size);
            if (modified)
                updateSizeAndModCount(root.size - oldSize);
            return modified;
        }

        public boolean removeIf(Predicate<? super E> filter) {
            checkForComodification();
            int oldSize = root.size;
            boolean modified = root.removeIf(filter, offset, offset + size);
            if (modified)
                updateSizeAndModCount(root.size - oldSize);
            return modified;
        }

        public Object[] toArray() {
            checkForComodification();
            return Arrays.copyOfRange(root.elementData, offset, offset + size);
        }

        @SuppressWarnings("unchecked")
        public <T> T[] toArray(T[] a) {
            checkForComodification();
            if (a.length < size)
                return (T[]) Arrays.copyOfRange(
                        root.elementData, offset, offset + size, a.getClass());
            System.arraycopy(root.elementData, offset, a, 0, size);
            if (a.length > size)
                a[size] = null;
            return a;
        }

        public boolean equals(Object o) {
            if (o == this) {
                return true;
            }

            if (!(o instanceof List)) {
                return false;
            }

            boolean equal = root.equalsRange((List<?>)o, offset, offset + size);
            checkForComodification();
            return equal;
        }

        public int hashCode() {
            int hash = root.hashCodeRange(offset, offset + size);
            checkForComodification();
            return hash;
        }

        public int indexOf(Object o) {
            int index = root.indexOfRange(o, offset, offset + size);
            checkForComodification();
            return index >= 0 ? index - offset : -1;
        }

        public int lastIndexOf(Object o) {
            int index = root.lastIndexOfRange(o, offset, offset + size);
            checkForComodification();
            return index >= 0 ? index - offset : -1;
        }

        public boolean contains(Object o) {
            return indexOf(o) >= 0;
        }

        public Iterator<E> iterator() {
            return listIterator();
        }

        public ListIterator<E> listIterator(int index) {
            checkForComodification();
            rangeCheckForAdd(index);

            return new ListIterator<E>() {
                int cursor = index;
                int lastRet = -1;
                int expectedModCount = root.modCount;

                public boolean hasNext() {
                    return cursor != SubList.this.size;
                }

                @SuppressWarnings("unchecked")
                public E next() {
                    checkForComodification();
                    int i = cursor;
                    if (i >= SubList.this.size)
                        throw new NoSuchElementException();
                    Object[] elementData = root.elementData;
                    if (offset + i >= elementData.length)
                        throw new ConcurrentModificationException();
                    cursor = i + 1;
                    return (E) elementData[offset + (lastRet = i)];
                }

                public boolean hasPrevious() {
                    return cursor != 0;
                }

                @SuppressWarnings("unchecked")
                public E previous() {
                    checkForComodification();
                    int i = cursor - 1;
                    if (i < 0)
                        throw new NoSuchElementException();
                    Object[] elementData = root.elementData;
                    if (offset + i >= elementData.length)
                        throw new ConcurrentModificationException();
                    cursor = i;
                    return (E) elementData[offset + (lastRet = i)];
                }

                public void forEachRemaining(Consumer<? super E> action) {
                    Objects.requireNonNull(action);
                    final int size = SubList.this.size;
                    int i = cursor;
                    if (i < size) {
                        final Object[] es = root.elementData;
                        if (offset + i >= es.length)
                            throw new ConcurrentModificationException();
                        for (; i < size && modCount == expectedModCount; i++)
                            action.accept(elementAt(es, offset + i));
                        // update once at end to reduce heap write traffic
                        cursor = i;
                        lastRet = i - 1;
                        checkForComodification();
                    }
                }

                public int nextIndex() {
                    return cursor;
                }

                public int previousIndex() {
                    return cursor - 1;
                }

                public void remove() {
                    if (lastRet < 0)
                        throw new IllegalStateException();
                    checkForComodification();

                    try {
                        SubList.this.remove(lastRet);
                        cursor = lastRet;
                        lastRet = -1;
                        expectedModCount = root.modCount;
                    } catch (IndexOutOfBoundsException ex) {
                        throw new ConcurrentModificationException();
                    }
                }

                public void set(E e) {
                    if (lastRet < 0)
                        throw new IllegalStateException();
                    checkForComodification();

                    try {
                        root.set(offset + lastRet, e);
                    } catch (IndexOutOfBoundsException ex) {
                        throw new ConcurrentModificationException();
                    }
                }

                public void add(E e) {
                    checkForComodification();

                    try {
                        int i = cursor;
                        SubList.this.add(i, e);
                        cursor = i + 1;
                        lastRet = -1;
                        expectedModCount = root.modCount;
                    } catch (IndexOutOfBoundsException ex) {
                        throw new ConcurrentModificationException();
                    }
                }

                final void checkForComodification() {
                    if (root.modCount != expectedModCount)
                        throw new ConcurrentModificationException();
                }
            };
        }

        public List<E> subList(int fromIndex, int toIndex) {
            subListRangeCheck(fromIndex, toIndex, size);
            return new SubList<>(this, fromIndex, toIndex);
        }

        private void rangeCheckForAdd(int index) {
            if (index < 0 || index > this.size)
                throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
        }

        private String outOfBoundsMsg(int index) {
            return "Index: "+index+", Size: "+this.size;
        }

        private void checkForComodification() {
            if (root.modCount != modCount)
                throw new ConcurrentModificationException();
        }

        private void updateSizeAndModCount(int sizeChange) {
            SubList<E> slist = this;
            do {
                slist.size += sizeChange;
                slist.modCount = root.modCount;
                slist = slist.parent;
            } while (slist != null);
        }

        public Spliterator<E> spliterator() {
            checkForComodification();

            // ArrayListSpliterator not used here due to late-binding
            return new Spliterator<E>() {
                private int index = offset; // current index, modified on advance/split
                private int fence = -1; // -1 until used; then one past last index
                private int expectedModCount; // initialized when fence set

                private int getFence() { // initialize fence to size on first use
                    int hi; // (a specialized variant appears in method forEach)
                    if ((hi = fence) < 0) {
                        expectedModCount = modCount;
                        hi = fence = offset + size;
                    }
                    return hi;
                }

                public ArrayList<E>.ArrayListSpliterator trySplit() {
                    int hi = getFence(), lo = index, mid = (lo + hi) >>> 1;
                    // ArrayListSpliterator can be used here as the source is already bound
                    return (lo >= mid) ? null : // divide range in half unless too small
                        root.new ArrayListSpliterator(lo, index = mid, expectedModCount);
                }

                public boolean tryAdvance(Consumer<? super E> action) {
                    Objects.requireNonNull(action);
                    int hi = getFence(), i = index;
                    if (i < hi) {
                        index = i + 1;
                        @SuppressWarnings("unchecked") E e = (E)root.elementData[i];
                        action.accept(e);
                        if (root.modCount != expectedModCount)
                            throw new ConcurrentModificationException();
                        return true;
                    }
                    return false;
                }

                public void forEachRemaining(Consumer<? super E> action) {
                    Objects.requireNonNull(action);
                    int i, hi, mc; // hoist accesses and checks from loop
                    ArrayList<E> lst = root;
                    Object[] a;
                    if ((a = lst.elementData) != null) {
                        if ((hi = fence) < 0) {
                            mc = modCount;
                            hi = offset + size;
                        }
                        else
                            mc = expectedModCount;
                        if ((i = index) >= 0 && (index = hi) <= a.length) {
                            for (; i < hi; ++i) {
                                @SuppressWarnings("unchecked") E e = (E) a[i];
                                action.accept(e);
                            }
                            if (lst.modCount == mc)
                                return;
                        }
                    }
                    throw new ConcurrentModificationException();
                }

                public long estimateSize() {
                    return getFence() - index;
                }

                public int characteristics() {
                    return Spliterator.ORDERED | Spliterator.SIZED | Spliterator.SUBSIZED;
                }
            };
        }
    }
```


#### forEach(Consumer<? super E> action)迭代元素
```
 @Override
    public void forEach(Consumer<? super E> action) {
        Objects.requireNonNull(action);
        final int expectedModCount = modCount;
        final Object[] es = elementData;//缓冲区
        final int size = this.size;
        for (int i = 0; modCount == expectedModCount && i < size; i++)//循环0到实际长度
            action.accept(elementAt(es, i));//对应下标值放入accept方法
        if (modCount != expectedModCount)
            throw new ConcurrentModificationException();//线程安全
    }
```

#### spliterator() 返回分裂器
```
 @Override
    public Spliterator<E> spliterator() {
        return new ArrayListSpliterator(0, -1, 0);
    }
```

## 内部类ArrayListSpliterator (基于索引的二分裂，懒惰初始化的Spliterator)
```
final class ArrayListSpliterator implements Spliterator<E> {


        private int index; // 当前指数，在提前/拆分时修改
        private int fence; // -1直到使用; 然后是最后一个索引
        private int expectedModCount; // 栅栏设置时初始化

        /####  创建覆盖给定范围的新分裂器. */
        ArrayListSpliterator(int origin, int fence, int expectedModCount) {
            this.index = origin;
            this.fence = fence;
            this.expectedModCount = expectedModCount;
        }

        private int getFence() { // 首次使用时将fence初始化为size
            int hi; // (a specialized variant appears in method forEach)
            if ((hi = fence) < 0) {
                expectedModCount = modCount;
                hi = fence = size;
            }
            return hi;
        }

        public ArrayListSpliterator trySplit() {//五五拆分
            int hi = getFence(), lo = index, mid = (lo + hi) >>> 1;
            return (lo >= mid) ? null : // divide range in half unless too small
                new ArrayListSpliterator(lo, index = mid, expectedModCount);
        }

        public boolean tryAdvance(Consumer<? super E> action) {//迭代，若有下一位返回true，支持并行
            if (action == null)
                throw new NullPointerException();
            int hi = getFence(), i = index;
            if (i < hi) {
                index = i + 1;
                @SuppressWarnings("unchecked") E e = (E)elementData[i];
                action.accept(e);
                if (modCount != expectedModCount)
                    throw new ConcurrentModificationException();
                return true;
            }
            return false;
        }

        public void forEachRemaining(Consumer<? super E> action) {//迭代
            int i, hi, mc; // hoist accesses and checks from loop
            Object[] a;
            if (action == null)
                throw new NullPointerException();
            if ((a = elementData) != null) {
                if ((hi = fence) < 0) {
                    mc = modCount;
                    hi = size;
                }
                else
                    mc = expectedModCount;
                if ((i = index) >= 0 && (index = hi) <= a.length) {
                    for (; i < hi; ++i) {
                        @SuppressWarnings("unchecked") E e = (E) a[i];
                        action.accept(e);
                    }
                    if (modCount == mc)
                        return;
                }
            }
            throw new ConcurrentModificationException();
        }

        public long estimateSize() {
            return getFence() - index;
        }

        public int characteristics() {
            return Spliterator.ORDERED | Spliterator.SIZED | Spliterator.SUBSIZED;
        }
    }
```

#### removeIf(Predicate<? super E> filter)   删除表达式返回true的元素
```
 @Override
    public boolean removeIf(Predicate<? super E> filter) {
        return removeIf(filter, 0, size);
    }
```

#### removeIf(Predicate<? super E> filter, int i, final int end)删除范围呃逆，表达式返回true的元素
```
boolean removeIf(Predicate<? super E> filter, int i, final int end) {
        Objects.requireNonNull(filter);
        int expectedModCount = modCount;
        final Object[] es = elementData;//缓冲区
        // Optimize for initial run of survivors
        for (; i < end && !filter.test(elementAt(es, i)); i++)
            ;
        // Tolerate predicates that reentrantly access the collection for
        // read (but writers still get CME), so traverse once to find
        // elements to delete, a second pass to physically expunge.
        if (i < end) {
            final int beg = i;
            final long[] deathRow = nBits(end - beg);
            deathRow[0] = 1L;   // set bit 0
            for (i = beg + 1; i < end; i++)
                if (filter.test(elementAt(es, i)))
                    setBit(deathRow, i - beg);
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
            modCount++;
            int w = beg;
            for (i = beg; i < end; i++)
                if (isClear(deathRow, i - beg))
                    es[w++] = es[i];
            shiftTailOverGap(es, w, end);
            return true;
        } else {
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
            return false;
        }
    }
```

#### replaceAll(UnaryOperator<E> operator)替换范围内元素
```
 @Override
    public void replaceAll(UnaryOperator<E> operator) {
        replaceAllRange(operator, 0, size);
        modCount++;
    }
```

#### replaceAllRange(UnaryOperator<E> operator, int i, int end)替换范围内元素，每个元素都替换成执行UnaryOperator后的结果
```
private void replaceAllRange(UnaryOperator<E> operator, int i, int end) {
        Objects.requireNonNull(operator);
        final int expectedModCount = modCount;
        final Object[] es = elementData;
        for (; modCount == expectedModCount && i < end; i++)
            es[i] = operator.apply(elementAt(es, i));
        if (modCount != expectedModCount)
            throw new ConcurrentModificationException();
    }
```

#### sort(Comparator<? super E> c)排序集合
```
 public void sort(Comparator<? super E> c) {
        final int expectedModCount = modCount;
        Arrays.sort((E[]) elementData, 0, size, c);//调用Arrays.sort
        if (modCount != expectedModCount)
            throw new ConcurrentModificationException();
        modCount++;
    }
```

#### checkInvariants()  检查不变量
```
void checkInvariants() {
        // assert size >= 0;
        // assert size == elementData.length || elementData[size] == null;
    }
````
