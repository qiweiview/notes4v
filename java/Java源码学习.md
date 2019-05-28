## Java源码学习

### 复制数组public static native void arraycopy
参数(Object src,  int  srcPos,Object dest, int destPos,int length)
```
* @param src源数组。
* @param srcPos在源数组中的起始位置。
* @param dest目标数组。
* @param destPos在目标数据中的起始位置。
* @param length要复制的数组元素的数量。
```
* 调用范例
```
Integer[] integers={1,2,3,4};
System.arraycopy(integers,1,integers,0,3);
System.out.println(Arrays.toString(integers));//[2, 3, 4, 4]
```
### 复制数组Arrays.copyOf()
参数(T[] original, int newLength)
```
 public static <T> T[] copyOf(T[] original, int newLength) {
        return (T[]) copyOf(original, newLength, original.getClass());
    }
```
参数(U[] original, int newLength, Class<? extends T[]> newType)
```
@HotSpotIntrinsicCandidate
    public static <T,U> T[] copyOf(U[] original, int newLength, Class<? extends T[]> newType) {
        @SuppressWarnings("unchecked")
        T[] copy = ((Object)newType == (Object)Object[].class)
            ? (T[]) new Object[newLength]
            : (T[]) Array.newInstance(newType.getComponentType(), newLength);
        System.arraycopy(original, 0, copy, 0,
                         Math.min(original.length, newLength));
        return copy;
    }
```
