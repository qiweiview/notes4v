## LinkedList

## 基本属性
```
     transient int size = 0;//存储数据量

    /#### 
     * Pointer to first node.
     */
    transient Node<E> first;//指向第一个节点的指针

    /#### 
     * Pointer to last node.
     */
    transient Node<E> last;//指向最后一个节点的指针。

```

## 数据单位
```
private static class Node<E> {
        E item;
        Node<E> next;//下一个节点
        Node<E> prev;//上一个节点

        Node(Node<E> prev, E element, Node<E> next) {
            this.item = element;
            this.next = next;
            this.prev = prev;
        }
    }
```

## 方法

#### LinkedList(Collection<? extends E> c)构造方法
```
 public LinkedList(Collection<? extends E> c) {
        this();
        addAll(c);
    }
```

#### addAll(Collection<? extends E> c)将指定集合中的所有元素追加到末尾
```
public boolean addAll(Collection<? extends E> c) {
        return addAll(size, c);
    }
```

#### addAll(int index, Collection<? extends E> c)将指定集合中的所有元素，插入到指定索引处
```
 public boolean addAll(int index, Collection<? extends E> c) {
        checkPositionIndex(index);//下标在范围内

        Object[] a = c.toArray();//转化为对象数组
        int numNew = a.length;
        if (numNew == 0)
            return false;//长度为0直接返回false

        Node<E> pred, succ;
        if (index == size) {//如果是尾插入
            succ = null;//下一个节点：设置成null
            pred = last;//上一个节点：设置成last
        } else {//如果是中部插入
            succ = node(index);//下一个节点：获取指定索引的节点
            pred = succ.prev;//上一个节点：指定索引节点的上一个节点
        }

        for (Object o : a) {//循环对象数组
            @SuppressWarnings("unchecked") E e = (E) o;
            Node<E> newNode = new Node<>(pred, e, null);//构造方法（前一个节点，数据，下一个节点）
            if (pred == null)//如果pre为空说明集合没有数据
                first = newNode;//那么第一个节点指针指向newNode
            else
                pred.next = newNode;//前一个节点（上一次循环的newNode）的next设置为newNode
                
            pred = newNode;//把pre设置成newNode供下一次循环使用
        }

        if (succ == null) {//如果是尾插入
            last = pred;//把指向最后一个节点的指针设置成pred，即设置成，最后一个newNode
        } else {//如果不是尾插入
            pred.next = succ;//newNode的next变成suc
            succ.prev = pred;//next的pre变成newNode
        }

        size += numNew;//修改存储长度
        modCount++;
        return true;
    }
```

#### node(int index)返回指定元素索引处的（非null）节点
```
Node<E> node(int index) {
        // assert isElementIndex(index);

        if (index < (size >> 1)) {//小于一半
            Node<E> x = first;
            for (int i = 0; i < index; i++)//从0往后循环到index
                x = x.next;
            return x;
        } else {//大于一半
            Node<E> x = last;
            for (int i = size - 1; i > index; i--)//从size往前循环到index
                x = x.prev;
            return x;
        }
    }
```

#### linkFirst(E e)把e放置到链表开头
```
 private void linkFirst(E e) {
        final Node<E> f = first;//获取第一个节点
        final Node<E> newNode = new Node<>(null, e, f);//创建一个新的节点，并设置下一个节点为原来的第一个节点
        first = newNode;//第一个节点设置成newNode 
        if (f == null)//原本第一个节点为空，即链表是空的
            last = newNode;//设置最后一个节点设置成newNode
        else
            f.prev = newNode;//否则原本第一个节点的上一个节点设置成newNode
        size++;
        modCount++;
    }
```

#### linkLast(E e)把e放在链表末尾
```
void linkLast(E e) {
        final Node<E> l = last;//获取最后的节点
        final Node<E> newNode = new Node<>(l, e, null);//创建一个新的节点并设置上一个节点为原来的最后一个节点
        last = newNode;//最后一个节点设置成newNode
        if (l == null)//如果原本最后节点为空的，即链表是空的
            first = newNode;//设置第一个节点为newNode
            第一个节点为
        else
            l.next = newNode;//否则原来最后一个节点的下一个节点变成newNode
        size++;
        modCount++;
    }
```

#### linkBefore(E e, Node<E> succ)在节点succ前插入e
```
 void linkBefore(E e, Node<E> succ) {
        // assert succ != null;  断言succ不是空的
        final Node<E> pred = succ.prev;//获取succ的上一个节点
        final Node<E> newNode = new Node<>(pred, e, succ);//新建一个节点，设置上一个节点为pred，下一个节点为succ
        succ.prev = newNode;//succ的上一个节点设置为newNode
        if (pred == null)//如果succ是第一个节点
            first = newNode;//第一个节点指针指向newNode
        else
            pred.next = newNode;//否则succ上一个节点的next设置成newNode
        size++;//数据量加1
        modCount++;
    }
```

#### unlinkFirst(Node<E> f)取消第一个节点
```
 private E unlinkFirst(Node<E> f) {
        // assert f == first && f != null;断言f是首节点，并且f不是空的
        final E element = f.item;//获取第一个节点的数据
        final Node<E> next = f.next;//获取第一个节点的next
        f.item = null;//第一个节点数据置空
        f.next = null; //第一个节点的next置空，取消无效的引用帮助gc
        first = next;//第一个节点的指针指向next
        if (next == null)//如果是唯一的节点
            last = null;//最后一个节点的指针也置空
        else
            next.prev = null;//否则下一个节点的prev置空，（由于成为新的第一个节点，第一个节点没有pre）
        size--;//数据量减1
        modCount++;
        return element;//返回取消的数据
    }
```


#### unlinkLast(Node<E> l)取消最后一个节点
```
private E unlinkLast(Node<E> l) {
        // assert l == last && l != null;断言l是最后一个节点，并且l不是空的
        final E element = l.item;//获取最后一个节点的数据
        final Node<E> prev = l.prev;//获取最后一个节点的prev
        l.item = null;//最后一个节点的数据置空
        l.prev = null; //最后一个节点的pre数据置空，取消无效的引用帮助gc
        last = prev;//最后一个节点指针指向prev
        if (prev == null)//如果是唯一的节点
            first = null;//第一个节点的指针也置空
        else
            prev.next = null;//否则上一个节点的next置空，（由于成为新的最后一个节点，最后一个节点没有next）
        size--;//数据量减1
        modCount++;
        return element;//返回取消的数据
    }
```

#### unlink(Node<E> x)取消某一个节点
```
E unlink(Node<E> x) {
        // assert x != null;断言节点x不是空的
        final E element = x.item;//获取节点值
        final Node<E> next = x.next;//获取节点的next
        final Node<E> prev = x.prev;//获取节点的pre

        if (prev == null) {//如果x是首节点
            first = next;//first指向next
        } else {//x不是首节点
            prev.next = next;//否则上一个节点next指向下一个节点
            x.prev = null;//x的上一个节点引用置空
        }

        if (next == null) {//如果x是尾节点
            last = prev;//last的指针指向pre
        } else {//x不是尾节点
            next.prev = prev;//下一个节点的pre指向上一个节点
            x.next = null;//下一个节点的引用置空
        }

        x.item = null;//x的值置空
        size--;//数据量减1
        modCount++;
        return element;//返回移除的数据
    }
```

#### getFirst()获取第一个节点的值
```
public E getFirst() {
        final Node<E> f = first;
        if (f == null)//空的集合
            throw new NoSuchElementException();
        return f.item;//返回第一个节点指针，指向节点，包含的值
    }
```

#### getLast()返回最后一个节点的值
```
public E getLast() {
        final Node<E> l = last;
        if (l == null)//空的集合
            throw new NoSuchElementException();
        return l.item;
    }
```

#### removeFirst()删除第一个节点指针，指向的节点
```
 public E removeFirst() {
        final Node<E> f = first;
        if (f == null)//空的集合
            throw new NoSuchElementException();
        return unlinkFirst(f);
    }
```

#### removeLast()删除最后一个节点指针，指向的节点
```
 public E removeLast() {
        final Node<E> l = last;
        if (l == null)
            throw new NoSuchElementException();
        return unlinkLast(l);
    }
```

#### addFirst(E e)在第一个节点指针，指向节点的，前面插入节点e
```
  public void addFirst(E e) {
        linkFirst(e);
    }
```

#### addLast(E e)在第最后一个节点指针，指向节点的，后面插入节点e
```
  public void addLast(E e) {
        linkLast(e);
    }
```

#### contains(Object o)查看集合是否存在对象o
```
public boolean contains(Object o) {
        return indexOf(o) >= 0;
    }
```

#### indexOf(Object o)返回指定元素第一次出现的索引
```
public int indexOf(Object o) {
        int index = 0;//初始索引下标0
        if (o == null) {//o为空的时候
            for (Node<E> x = first; x != null; x = x.next) {//从第一个节点指针指向的节点循环到最后一个节点（最后一个节点指针last指向的节点的next是null）
                if (x.item == null)//直接对比内存地址
                    return index;//对等返回index
                index++;
            }
        } else {
            for (Node<E> x = first; x != null; x = x.next) {//从第一个节点指针指向的节点循环到最后一个节点（最后一个节点指针last指向的节点的next是null）
                if (o.equals(x.item))//调用o的equals方法
                    return index;//对等返回index
                index++;
            }
        }
        return -1;//没有找到返回-1
    }
```

#### size() 返回结合中存储的节点数量
```
public int size() {
        return size;
    }
```

#### add(E e) 向集合末尾添加一个元素
```
 public boolean add(E e) {
        linkLast(e);
        return true;
    }
```

#### remove(Object o) 移除一个元素
```
public boolean remove(Object o) {
        if (o == null) {//如果o是null
            for (Node<E> x = first; x != null; x = x.next) {//从第一个节点指针指向的节点开始循环
                if (x.item == null) {//比较节点的值，的内存地址
                    unlink(x);//取消节点
                    return true;//操作成功
                }
            }
        } else {//如果o是不是null
            for (Node<E> x = first; x != null; x = x.next) {//从第一个节点指针指向的节点开始循环
                if (o.equals(x.item)) {//调用o的equals方法和节点的值作比较
                    unlink(x);//取消节点
                    return true;//操作成功
                }
            }
        }
        return false;//操作失败
    }
```

#### addAll(Collection<? extends E> c) 向集合末尾加入集合c
```
public boolean addAll(Collection<? extends E> c) {
        return addAll(size, c);
    }
```

#### clear() 清空集合
```
 public void clear() {
        // Clearing all of the links between nodes is "unnecessary", but:
        // - helps a generational GC if the discarded nodes inhabit
        //   more than one generation
        // - is sure to free memory even if there is a reachable Iterator
        for (Node<E> x = first; x != null; ) {//从first指针指向的节点开始循环
            Node<E> next = x.next;//获取x的next
            x.item = null;//x的值置空
            x.next = null;//x的next置空
            x.prev = null;//x的prev置空
            x = next;//x赋值为next下一次循环使用
        }
        first = last = null;//第一个节点指针和最后一个节点的指针置空
        size = 0;//数据长度0
        modCount++;//操作数不清空
    }
```

#### get(int index) 获取index索引节点数据
```
public E get(int index) {
        checkElementIndex(index);
        return node(index).item;
    }

```

#### set(int index, E element) 设置index索引处的节点位数为element
```
public E set(int index, E element) {
        checkElementIndex(index);//index在范围内
        Node<E> x = node(index);//获取索引处的节点
        E oldVal = x.item;//获取节点旧的值
        x.item = element;//给节点的值赋值新值
        return oldVal;//返回旧的值
    }
```

#### add(int index, E element) 根据索引插入数据
```
 public void add(int index, E element) {
        checkPositionIndex(index);//index在范围内

        if (index == size)/、如果索引位index等于数据长度
            linkLast(element);//尾插入
        else
            linkBefore(element, node(index));//否则插入在index索引对应节点之前
    }
```

#### remove(int index) 移除索引index处的数据
```
 public E remove(int index) {
        checkElementIndex(index);//index在范围内
        return unlink(node(index));
    }
```

#### isElementIndex(int index) 判断参数是否是现有元素的索引
```
  private boolean isElementIndex(int index) {
        return index >= 0 && index < size;
    }
```


#### isPositionIndex(int index) 判断参数是否是现有元素的索引（迭代器或添加操作）
```
  private boolean isPositionIndex(int index) {
        return index >= 0 && index < size;
    }
```

#### 构造一个IndexOutOfBoundsException详细消息#### 
```
 private String outOfBoundsMsg(int index) {
        return "Index: "+index+", Size: "+size;
    }

    private void checkElementIndex(int index) {
        if (!isElementIndex(index))
            throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
    }

    private void checkPositionIndex(int index) {
        if (!isPositionIndex(index))
            throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
    }
```

#### lastIndexOf(Object o) 返回指定元素最后一次出现的索引
```
 public int lastIndexOf(Object o) {
        int index = size;//初始下标赋值
        if (o == null) {//o为null
            for (Node<E> x = last; x != null; x = x.prev) {//last指针指向的节点开始向前循环
                index--;
                if (x.item == null)//节点的值作内存比较
                    return index;//返回下标
            }
        } else {//o不为null
            for (Node<E> x = last; x != null; x = x.prev) {//last指针指向的节点开始向前循环
                index--;
                if (o.equals(x.item))//调用o的equals方法和节点的值比较
                    return index;
            }
        }
        return -1;
    }
```

#### peek() 索但不删除此列表的头部(null返回null)
```
 public E peek() {
        final Node<E> f = first;
        return (f == null) ? null : f.item;//如果是null的话不返回对象，返回null
    }
```

#### element() 检索但不删除此列表的头部(null会抛出异常)
```
public E element() {
        return getFirst();
    }
```

#### getFirst() 返回此列表中的第一个元素(null会抛出异常)
```
public E getFirst() {
        final Node<E> f = first;
        if (f == null)
            throw new NoSuchElementException();
        return f.item;
    }
```

#### poll() 检索并删除此列表的头部(null返回null)
```
 public E poll() {
        final Node<E> f = first;
        return (f == null) ? null : unlinkFirst(f);//不为null时候，删除并返回第一个节点
    }
```

#### remove() 检索并删除此列表的头部
```
  public E remove() {
        return removeFirst();
    }
```

#### offer(E e) 将指定的元素添加为此列表的尾部
```
public boolean offer(E e) {
        return add(e);
    }
```

#### offerFirst(E e) 在指定列表第一个节点前面插入e
```
 public boolean offerFirst(E e) {
        addFirst(e);
        return true;
    }
```

#### offerLast(E e) 在指定列表最后一个节点后面插入e
```
  public boolean offerLast(E e) {
        addLast(e);
        return true;
    }

```

#### peekFirst() 检索但不删除此列表的第一个节点(null返回null)
```
 public E peekFirst() {
        final Node<E> f = first;
        return (f == null) ? null : f.item;
     }
```

#### peekFirst() 检索但不删除此列表的最后一个节点(null返回null)
```
 public E peekLast() {
        final Node<E> l = last;
        return (l == null) ? null : l.item;
    }
```

#### pollFirst() 检索并删除此列表的第一个节点(null返回null)
```
public E pollFirst() {
        final Node<E> f = first;
        return (f == null) ? null : unlinkFirst(f);
    }
```



#### pollLast() 检索并删除此列表的第最后一个节点(null返回null)
```
 public E pollLast() {
        final Node<E> l = last;
        return (l == null) ? null : unlinkLast(l);
    }
```

#### push(E e) 将元素插入到第一个节点签名
```
public void push(E e) {
        addFirst(e);
    }
````

#### pop() 移除第一个节点
```
  public E pop() {
        return removeFirst();
    }
```

#### removeFirstOccurrence(Object o) 删除此中第一次出现的指定元素
```
public boolean removeFirstOccurrence(Object o) {
        return remove(o);
    }
```

#### removeLastOccurrence(Object o) 删除此中最后一次出现的指定元素
```
//和lastIndexOf类似,找到后直接调用unlink
 public boolean removeLastOccurrence(Object o) {
        if (o == null) {
            for (Node<E> x = last; x != null; x = x.prev) {
                if (x.item == null) {
                    unlink(x);
                    return true;
                }
            }
        } else {
            for (Node<E> x = last; x != null; x = x.prev) {
                if (o.equals(x.item)) {
                    unlink(x);
                    return true;
                }
            }
        }
        return false;
    }
```

#### ListIterator<E> listIterator(int index) 返回集合迭代器
```
 public ListIterator<E> listIterator(int index) {
        checkPositionIndex(index);
        return new ListItr(index);
    }
```

## 迭代器类ListItr
```
  private class ListItr implements ListIterator<E> {
        private Node<E> lastReturned;//最后返回的节点
        private Node<E> next;//下一个节点
        private int nextIndex;//下一个节点的索引
        private int expectedModCount = modCount;

        ListItr(int index) {
            // assert isPositionIndex(index);
            next = (index == size) ? null : node(index);//构造下一个节点的索引
            nextIndex = index;
        }

        public boolean hasNext() {
            return nextIndex < size;//判断是否有下一个节点
        }

        public E next() {
            checkForComodification();//线程安全
            if (!hasNext())
                throw new NoSuchElementException();//迭代器到尾部

            lastReturned = next;//迭代器越过next
            next = next.next;//next赋值为next的下一个节点
            nextIndex++;//下一个节点的索引+1
            return lastReturned.item;//返回迭代器越过节点的值
        }

        public boolean hasPrevious() {
            return nextIndex > 0;//是否有前一个节点
        }

        public E previous() {
            checkForComodification();//线程安全
            if (!hasPrevious())
                throw new NoSuchElementException();//迭代器到达头部

            lastReturned = next = (next == null) ? last : next.prev;//如果是空返回last指针指向的节点（不理解）
            nextIndex--;//下一个节点索引自减
            return lastReturned.item;//返回迭代器越过节点的值
        }

        public int nextIndex() {
            return nextIndex;//返回下一个索引
        }

        public int previousIndex() {
            return nextIndex - 1;//返回上一个索引
        }

        public void remove() {
            checkForComodification();
            if (lastReturned == null)//迭代器没有越过任何元素
                throw new IllegalStateException();

            Node<E> lastNext = lastReturned.next;//获取迭代器越过节点的下一个节点
            unlink(lastReturned);//移除越过的元素
            if (next == lastReturned)//不理解为什么会进去
                next = lastNext;
            else
                nextIndex--;//下一个节点索引自减
            lastReturned = null;
            expectedModCount++;
        }

        public void set(E e) {
            if (lastReturned == null)//迭代器没有越过任何元素
                throw new IllegalStateException();
            checkForComodification();//线程安全
            lastReturned.item = e;//迭代器越过节点的值
        }

        public void add(E e) {
            checkForComodification();//线程安全
            lastReturned = null;
            if (next == null)//尾巴插入
                linkLast(e);
            else
                linkBefore(e, next);//next节点前插入
            nextIndex++;//下一个节点的索引加1
            expectedModCount++;
        }

        public void forEachRemaining(Consumer<? super E> action) {
            Objects.requireNonNull(action);
            while (modCount == expectedModCount && nextIndex < size) {//下一个节点的索引小于节点数
                action.accept(next.item);//运行accept方法
                lastReturned = next;
                next = next.next;
                nextIndex++;
            }
            checkForComodification();//线程安全
        }

        final void checkForComodification() {
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
        }
    }
```

#### descendingIterator() 适配器通过ListItr.previous提供降序迭代器
```
 public Iterator<E> descendingIterator() {
        return new DescendingIterator();
    }
```

## 降序迭代器DescendingIterato（调用的就是ListItr，反着调用）
```
 private class DescendingIterator implements Iterator<E> {
        private final ListItr itr = new ListItr(size());
        public boolean hasNext() {
            return itr.hasPrevious();
        }
        public E next() {
            return itr.previous();
        }
        public void remove() {
            itr.remove();
        }
    }
```

#### superClone() 超类复制
```
@SuppressWarnings("unchecked")
private LinkedList<E> superClone() {
        try {
            return (LinkedList<E>) super.clone();
        } catch (CloneNotSupportedException e) {
            throw new InternalError(e);
        }
    }
```

#### clone() 复制集合对象
```
 public Object clone() {
        LinkedList<E> clone = superClone();

        // Put clone into "virgin" state
        clone.first = clone.last = null;//第一个节点和最后一个节点置空
        clone.size = 0;//数据数置0
        clone.modCount = 0;//操作数置0

        // Initialize clone with our elements
        for (Node<E> x = first; x != null; x = x.next)//从first节点开始循环初始化clone对象
            clone.add(x.item);

        return clone;
    }
```

#### toArray() 返回集合元素组成的数组
```
  public Object[] toArray() {
        Object[] result = new Object[size];
        int i = 0;
        for (Node<E> x = first; x != null; x = x.next)
            result[i++] = x.item;
        return result;
    }
```

#### toArray(T[] a) 返回集合元素组成的数组（传入数组的类型）
```
 @SuppressWarnings("unchecked")
    public <T> T[] toArray(T[] a) {
        if (a.length < size)
            a = (T[])java.lang.reflect.Array.newInstance(
                                a.getClass().getComponentType(), size);//创建数组
        int i = 0;
        Object[] result = a;
        for (Node<E> x = first; x != null; x = x.next)
            result[i++] = x.item;

        if (a.length > size)
            a[size] = null;

        return a;
    }
```
