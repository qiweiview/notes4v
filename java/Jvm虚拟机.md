# Jvm虚拟机

## 栈帧结构


![](https://img-blog.csdn.net/20180121103152636?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvcWlhbjUyMGFv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
* 栈帧主要由三部分组成：局部变量表、操作数栈、帧数据区

### 局部变量表 
* 局部变量表的容量以变量槽（Variable Slot）为最小单位，每个变量槽都可以存储32位长度的内存空间，从0开始计数的数组
* 并且在Java编译为Class文件时，就已经确定了该方法所需要分配的局部变量表的最大容量
* 类型为short、byte和char的值在存入数组前要被转换成int值
* 而long和 double在数组中占据连续的两项，在访问局部变量中的long或double时，只需取出连续两项的第一项的索引值即可(如某个long值在局部变量 区中占据的索引时3、4项，取值时，指令只需取索引为3的long值即可)
* 为了尽可能节省栈帧空间，局部变量表中的Slot是可以重用的，也就是说当PC计数器的指令指已经超出了某个变量的作用域（执行完毕），那这个变量对应的Slot就可以交给其他变量使用

### 动态连接
* 每个栈帧都包含一个指向运行时常量池中该栈帧所属方法的引用，持有这个引用是为了支付方法调用过程中的动态连接（Dynamic Linking）。

### 方法返回地址
* 在方法退出之后，都需要返回到方法被调用的位置，程序才能继续执行，方法返回时可能需要在栈帧中保存一些信息。

### 操作数栈
* 和局部变量表一样，操作数栈也被组织成一个以字长为单位的数组。
* 在编译时期就已经确定了该方法所需要分配的局部变量表的最大容量。
* 每一个元素可用是任意的Java数据类型，包括long和double。32位数据类型所占的栈容量为1，64位数据类型占用的栈容量为2
* 但和前者不同的是，它不是通过索引来访问的，而是通过入栈和出栈来访问的。
* 可把操作数栈理解为存储计算时，临时数据的存储区域。

### 帧数据区 
* 帧数据区除了局部变量表和操作数栈外，Java栈帧还需要一些数据来支持常量池解析、正常方法返回以及异常派发机制。这些数据都保存在Java栈帧的帧数据区中。
* 当JVM执行到需要常量池数据的指令时，它都会通过帧数据区中指向常量池的指针来访问它。
除了处理常量池解析外，帧里的数据还要处理Java方法的正常结束和异常终止。如果是通过return正常结束，则当前栈帧从Java栈中弹出，恢复发起调用的方法的栈。如果方法有返回值，JVM会把返回值压入到发起调用方法的操作数栈。
* 为了处理Java方法中的异常情况，帧数据区还必须保存一个对此方法异常引用表的引用。当异常抛出时，JVM给catch块中的代码。如果没发现，方法立即终止，然后JVM用帧区数据的信息恢复发起调用的方法的帧。然后再发起调用方法的上下文重新抛出同样的异常。

## 字节码
### 代码
```
package core.object_create;

public class ObjectTest {
    private String name = "v2";
    public void add() {
        int i10 = -1;
        int i0 = 5;
        int i1 = 6;
        int i2 = 127;
        int i3 = 32767;
        int i4 = 32768;
        int sum = i10 + i0 + i1 + i2 + i3+i4;
    }
}
```
### 字节码
```
// class version 56.0 (56)
// access flags 0x21
public class core/object_create/ObjectTest {

  // compiled from: ObjectTest.java

  // access flags 0x2
  private Ljava/lang/String; name

  // access flags 0x1
  public <init>()V
   L0
    LINENUMBER 3 L0
    ALOAD 0
    INVOKESPECIAL java/lang/Object.<init> ()V
   L1
    LINENUMBER 4 L1
    ALOAD 0
    LDC "v2"
    PUTFIELD core/object_create/ObjectTest.name : Ljava/lang/String; //为指定的类的实例域赋值
    RETURN
   L2
    LOCALVARIABLE this Lcore/object_create/ObjectTest; L0 L2 0
    MAXSTACK = 2
    MAXLOCALS = 1

  // access flags 0x1
  public add()V
   L0
    LINENUMBER 6 L0
    ICONST_M1 //将int型-1推送至栈顶
    ISTORE 1
   L1
    LINENUMBER 7 L1
    ICONST_5 //将int型5推送至栈顶
    ISTORE 2
   L2
    LINENUMBER 8 L2
    BIPUSH 6
    ISTORE 3
   L3
    LINENUMBER 9 L3
    BIPUSH 127 //将单字节的常量值(-128~127)推送至栈顶
    ISTORE 4
   L4
    LINENUMBER 10 L4
    SIPUSH 32767 //将一个短整型常量值(-32768~32767)推送至栈顶
    ISTORE 5
   L5
    LINENUMBER 11 L5
    LDC 32768 //将int, float或String型常量值从常量池中推送至栈顶
    ISTORE 6
   L6
    LINENUMBER 12 L6
    ILOAD 1
    ILOAD 2
    IADD
    ILOAD 3
    IADD
    ILOAD 4
    IADD
    ILOAD 5
    IADD
    ILOAD 6
    IADD
    ISTORE 7
   L7
    LINENUMBER 13 L7
    RETURN
   L8
    LOCALVARIABLE this Lcore/object_create/ObjectTest; L0 L8 0
    LOCALVARIABLE i10 I L1 L8 1
    LOCALVARIABLE i0 I L2 L8 2
    LOCALVARIABLE i1 I L3 L8 3
    LOCALVARIABLE i2 I L4 L8 4
    LOCALVARIABLE i3 I L5 L8 5
    LOCALVARIABLE i4 I L6 L8 6
    LOCALVARIABLE sum I L7 L8 7
    MAXSTACK = 2
    MAXLOCALS = 8
}

```
