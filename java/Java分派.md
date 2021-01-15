# Java分派

## 静态分派
* 范例将打印两个A method
* 运行的结果是打印出连个“A method”。原因在于静态类型的变化仅仅在使用时发生，变量本省的类型不会发生变化
* 发生重载的时候，Java虚拟机是通过参数的静态类型而不是实际参数类型作为判断依据的
```
public class O{
    static class A{}
    static class B extends A{}
    static class C extends A{}
    public void a(A a){
        System.out.println("A method");
    }
    public void a(B b){
        System.out.println("B method");
    }
    public void a(C c){
        System.out.println("C method");
    }
    public static void main(String[] args){
        O o = new O();
        A b = new B();
        A c = new C();
        o.a(b);
        o.a(c);
    }
}
```


## 动态分派
* 动态分派的一个最直接的例子是重写，涉及Java虚拟机的invokevirtual指令
* 指令解析过程为：

 1. 找到操作数栈栈顶的第一个元素所指向的对象的实际类型，记为C
 2. 如果在类型C中找到与常量中描述符和简单名称都相符的方法，则进行访问权限的校验，如果通过则返回这个方法的直接引用，查找结束；如果不通过，则返回非法访问异常
 3. 如果在类型C中没有找到，则按照继承关系从下到上依次对C的各个父类进行第2步的搜索和验证过程
 4. 如果始终没有找到合适的方法，则抛出抽象方法错误的异常

* 从这个过程可以发现，在第一步的时候就在运行期确定接收对象（执行方法的所有者程称为接受者）的实际类型，所以当调用invokevirtual指令就会把运行时常量池中符号引用解析为不同的直接引用，这就是方法重写的本质。
