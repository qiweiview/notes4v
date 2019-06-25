# Spliterator

## 接口属性
```
    //特征值其实就是为表示该Spliterator有哪些特性，用于可以更好控制和优化Spliterator的使用

    public static final int ORDERED    = 0x00000010;//表示已定义遭遇订单的特征值

    public static final int DISTINCT   = 0x00000001;//特征值表示对于每对遇到的元素

    public static final int SORTED     = 0x00000004;//表示遭遇顺序遵循定义的特征值

    public static final int SIZED      = 0x00000040;
    //表示从遍历或分裂之前返回的值表示有限大小的特征值

    public static final int NONNULL    = 0x00000100;//特征值表示源保证遇到的元素不会是null

    public static final int IMMUTABLE  = 0x00000400;//表示元素源不能进行结构修改的特征值

    public static final int CONCURRENT = 0x00001000;//表示元素源可能安全的特征值

    public static final int SUBSIZED   = 0x00004000;
```

## 接口方法


### tryAdvance(Consumer<? super T> action)
* 如果存在剩余元素，则对其执行给定操作
```
boolean tryAdvance(Consumer<? super T> action);
```

### forEachRemaining(Consumer<? super T> action)
* 在当前线程中按顺序对每个剩余元素执行给定操作，直到所有元素都已处理或操作引发异常
```
default void forEachRemaining(Consumer<? super T> action) {
        do { } while (tryAdvance(action));
    }
```
### trySplit()对任务分割，返回一个新的Spliterator迭代器
```
Spliterator<T> trySplit();
```

### estimateSize()用于估算还剩下多少个元素需要遍历
```
long estimateSize();
```

### getExactSizeIfKnown()当迭代器拥有SIZED特征时，返回剩余元素个数；否则返回-1
```
default long getExactSizeIfKnown() {
        return (characteristics() & SIZED) == 0 ? -1L : estimateSize();
    }
```

### characteristics()返回当前对象有哪些特征值
```
 int characteristics();
```

### hasCharacteristics(int characteristics)是否具有当前特征值
```
 default boolean hasCharacteristics(int characteristics) {
        return (characteristics() & characteristics) == characteristics;
    }
```

### getComparator()
```
default Comparator<? super T> getComparator() {
        throw new IllegalStateException();
    }
```


