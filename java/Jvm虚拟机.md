# Jvm虚拟机

## 栈帧结构


![](https://img-blog.csdn.net/20180121103152636?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvcWlhbjUyMGFv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
* 栈帧主要由三部分组成：局部变量表、操作数栈、帧数据区

### 局部变量表 
* 局部变量表（Local Variables Table）是一组变量值的存储空间，用于存放方法参数和方法内部定义
的局部变量。在Java程序被编译为Class文件时，就在方法的Code属性的max_locals数据项中确定了该方
法所需分配的局部变量表的最大容量。
局部变量表的容量以变量槽（Variable Slot）为最小单位，《Java虚拟机规范》中并没有明确指出
一个变量槽应占用的内存空间大小，只是很有导向性地说到每个变量槽都应该能存放一个boolean、
byte、char、short、int、float、reference或returnAddress类型的数据，这8种数据类型，都可以使用32位
或更小的物理内存来存储，但这种描述与明确指出“每个变量槽应占用32位长度的内存空间”是有本质
差别的，它允许变量槽的长度可以随着处理器、操作系统或虚拟机实现的不同而发生变化，保证了即
使在64位虚拟机中使用了64位的物理内存空间去实现一个变量槽，虚拟机仍要使用对齐和补白的手段
让变量槽在外观上看起来与32位虚拟机中的一致

### 动态连接
* 每个栈帧都包含一个指向运行时常量池中该栈帧所属方法的引用，持有这个引用是为了支付方法调用过程中的动态连接（Dynamic Linking）。

### 方法返回地址
* 在方法退出之后，都需要返回到方法被调用的位置，程序才能继续执行，方法返回时可能需要在栈帧中保存一些信息。

### 操作数栈
* 操作数栈（Operand Stack）也常被称为操作栈，它是一个后入先出（Last In First Out，LIFO）
栈。同局部变量表一样，操作数栈的最大深度也在编译的时候被写入到Code属性的max_stacks数据项
之中。操作数栈的每一个元素都可以是包括long和double在内的任意Java数据类型。32位数据类型所占
的栈容量为1，64位数据类型所占的栈容量为2。Javac编译器的数据流分析工作保证了在方法执行的任
何时候，操作数栈的深度都不会超过在max_stacks数据项中设定的最大值

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
        double d1=20.12;
        long l1=111l;
        int i10 = -1;
        int i0 = 5;
        int i1 = 6;
        int i2 = 127;
        int i3 = 32767;
        int i4 = 32768;
        int sum = i10 + i0 + i1 + i2 + i3+i4;
        double sum2=d1+l1;
        sum= (int) (sum2+111);
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
    PUTFIELD core/object_create/ObjectTest.name : Ljava/lang/String;
    RETURN
   L2
    LOCALVARIABLE this Lcore/object_create/ObjectTest; L0 L2 0
    MAXSTACK = 2
    MAXLOCALS = 1

  // access flags 0x1
  public add()V
   L0
    LINENUMBER 6 L0
    LDC 20.12 //将int, float或String型常量值从常量池中推送至栈顶
    DSTORE 1 //将栈顶double型数值存入指定本地变量,下标为1
   L1
    LINENUMBER 7 L1
    LDC 111 //将int, float或String型常量值从常量池中推送至栈顶
    LSTORE 3 //将栈顶long型数值存入指定本地变量,下标为3
   L2
    LINENUMBER 8 L2
    ICONST_M1 //将int型-1推送至栈顶
    ISTORE 5 将栈顶int型数值存入指定本地变量,下标为5
   L3
    LINENUMBER 9 L3
    ICONST_5 //将int型5推送至栈顶
    ISTORE 6 //将栈顶int型数值存入指定本地变量,下标为6
   L4
    LINENUMBER 10 L4
    BIPUSH 6 //将单字节的常量值(-128~127)推送至栈顶
    ISTORE 7 //将栈顶int型数值存入指定本地变量,下标为7
   L5
    LINENUMBER 11 L5
    BIPUSH 127 //将单字节的常量值(-128~127)推送至栈顶
    ISTORE 8 //将栈顶int型数值存入指定本地变量,下标为8
   L6
    LINENUMBER 12 L6
    SIPUSH 32767 //将一个短整型常量值(-32768~32767)推送至栈顶
    ISTORE 9 //将栈顶int型数值存入指定本地变量,下标为9
   L7
    LINENUMBER 13 L7
    LDC 32768 //将int, float或String型常量值从常量池中推送至栈顶
    ISTORE 10 //将栈顶int型数值存入指定本地变量,下标为10
   L8
    LINENUMBER 14 L8
    ILOAD 5 //将指定的int型本地变量推送至栈顶
    ILOAD 6
    IADD //将栈顶两int型数值相加并将结果压入栈顶
    ILOAD 7
    IADD //将栈顶两int型数值相加并将结果压入栈顶
    ILOAD 8
    IADD //将栈顶两int型数值相加并将结果压入栈顶
    ILOAD 9
    IADD //将栈顶两int型数值相加并将结果压入栈顶
    ILOAD 10
    IADD //将栈顶两int型数值相加并将结果压入栈顶
    ISTORE 11 //将栈顶int型数值存入指定本地变量,下标为11
   L9
    LINENUMBER 15 L9
    DLOAD 1 //将指定的double型本地变量推送至栈顶
    LLOAD 3 //将指定的long型本地变量推送至栈顶
    L2D //将栈顶long型数值强制转换成double型数值并将结果压入栈顶
    DADD //将栈顶两double型数值相加并将结果压入栈顶
    DSTORE 12 //将栈顶double型数值存入指定本地变量,下标为12
   L10
    LINENUMBER 16 L10
    DLOAD 12 //将指定的double型本地变量推送至栈顶
    LDC 111.0 //将int, float或String型常量值从常量池中推送至栈顶
    DADD //将栈顶两double型数值相加并将结果压入栈顶
    D2I //将栈顶double型数值强制转换成int型数值并将结果压入栈顶
    ISTORE 11 //将栈顶int型数值存入指定本地变量,下标为1
   L11
    LINENUMBER 17 L11
    RETURN
   L12
    LOCALVARIABLE this Lcore/object_create/ObjectTest; L0 L12 0
    LOCALVARIABLE d1 D L1 L12 1   //申明变量对应下标
    LOCALVARIABLE l1 J L2 L12 3
    LOCALVARIABLE i10 I L3 L12 5
    LOCALVARIABLE i0 I L4 L12 6
    LOCALVARIABLE i1 I L5 L12 7
    LOCALVARIABLE i2 I L6 L12 8
    LOCALVARIABLE i3 I L7 L12 9
    LOCALVARIABLE i4 I L8 L12 10
    LOCALVARIABLE sum I L9 L12 11
    LOCALVARIABLE sum2 D L10 L12 12
    MAXSTACK = 4
    MAXLOCALS = 14
}

```
