## Java源码学习

### 复制数组public static native void arraycopy
* 参数(Object src,  int  srcPos,Object dest, int destPos,int length)
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
