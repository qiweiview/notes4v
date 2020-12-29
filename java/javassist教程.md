# javassist教程

## 依赖
```
        <dependency>
            <groupId>org.javassist</groupId>
            <artifactId>javassist</artifactId>
            <version>3.27.0-GA</version>
        </dependency>

```

## 创建并加载类
* toClass不带参数调用，使用当前线程下的类加载器加载生成的类， 可以通过setContextClassLoader()修改当前线程下类加载器
* toClass先于代码内的同名包下的类加载，由于类加载机制，可能项目内原有的类永远不会被加载
```java
 		MyLoader myLoader = new MyLoader();
        ClassPool pool = ClassPool.getDefault();
        CtClass cc = pool.makeClass("java_ssist_test.DemoClass");
        Class<?> aClass = cc.toClass(myLoader,null);//如果不指定类加载器，这个方法会用当前线程下的类加载器去加载类
```

## 类冻结
CtClass 对象通过 writeFile(), toClass(), toBytecode() 被转换成一个类文件，此 CtClass 对象会被冻结起来，不允许再修改。因为一个类只能被 JVM 加载一次
```
 java.lang.RuntimeException: view.NewClass class is frozen
```

*  ClassPool.doPruning 被设置为 true，Javassist 在冻结 CtClass 时，会修剪 CtClass 的数据结构。为了减少内存的消耗，修剪操作会丢弃 CtClass 对象中不必要的属性。例如，Code_attribute 结构会被丢弃
```
ctClass.stopPruning(true);//这个值默认是false
```

* 想要再修改需要调用
```
ctClass.defrost();
```

## 设置类搜索路径

* 从类路径设置
* append 和insert区别在于插入的位置，inser会放在开头，append会放结尾
* 如果使用new ClassPool(false)那么就连本地类路径下类都不扫描
```
 new ClassPool(true);//会调用appendSystemPath()


pool.appendSystemPath()
pool.insertClassPath(new ClassClassPath(this.getClass()));
```

* 从磁盘设置
```
//绝对路径
pool.insertClassPath("/usr/local/javalib");
```

*  网络路径设置
```
ClassPath cp = new URLClassPath("www.javassist.org", 80, "/java/", "org.javassist.");
pool.insertClassPath(cp);

//将读取http://www.javassist.org:80/java/org/javassist/test/Main.class
```

* 从字节数组加载类
```
//字节数组
byte[] b = a byte array;
String name = class name;
cp.insertClassPath(new ByteArrayClassPath(name, b));
```

## 避免内存溢出,detach方法会将ctClass从池中移除
```
		CtClass ctClass = pool.makeClass("view.NewClass");
        ctClass.detach();//移除
        CtClass ctClass1 = pool.get("view.NewClass");//not found
```

## 创建一个新的池子
* new ClassPool(true)创建出的类池是新的，不与 ClassPool.getDefault()共享类
```
ClassPool cp = new ClassPool(true);

//等价
ClassPool cp = new ClassPool();
cp.appendSystemPath();  // or append another path by appendClassPath()
```

## 多级关联
```
  		ClassPool parent = ClassPool.getDefault();
        parent.makeClass("usr.view");
        ClassPool child = new ClassPool(parent);
        CtClass ctClass = child.get("usr.view");
```

## 子类先检索
```
ClassPool parent = ClassPool.getDefault();
ClassPool child = new ClassPool(parent);
child.appendSystemPath();         // the same class path as the default one.
child.childFirstLookup = true;    // changes the behavior of the child.
```

## 类重命名

```
 	    ClassPool parent = ClassPool.getDefault();
        CtClass ctClass = parent.makeClass("usr.View");
        ctClass.setName("usr.ClassRename");
        ctClass.writeFile();
```
* 同样在获取类或输出后，不能再操作,需要使用getAndRename重命名
```
 pool.getAndRename("usr.View","usr.ViewRename");
```

## 类相关操作
* 创建类并创建属性和方法
* toClass调用前如果类已经被加载过，就会报异常 duplicate class definition 
```
  ClassPool pool = ClassPool.getDefault();
        CtClass ctClass = pool.get("java_ssist_test.crate_method.Egg");

        //属性
        CtField name = CtField.make("private String name=\"say hi to\";", ctClass);
        ctClass.addField(name);


        //方法
        CtMethod fly = CtMethod.make("public String fly(){ return null;}", ctClass);
        fly.addLocalVariable("value",pool.get("java.lang.String"));
        fly.addParameter(pool.get("java.lang.String"));

        fly.insertAfter("{ name+=\" view\"; return name; }");
        fly.addCatch("{return \"error\";} throw $e;",pool.get("java.lang.RuntimeException"));
        ctClass.addMethod(fly);




        //生成
        ctClass.writeFile();
        Class<?> aClass = ctClass.toClass();
        Object o = aClass.newInstance();
        Method fly1 = aClass.getDeclaredMethod("fly", String.class);
        Object invoke = fly1.invoke(o,"");
        System.out.println(invoke);
```

## 类加载Loader

* Loader可以用于装入用Javassist修改过的特定类
```
 	 ClassPool pool = ClassPool.getDefault();
     Loader cl = new Loader(pool);

     CtClass ct = pool.get("test.Rectangle");
     ct.setSuperclass(pool.get("test.Point"));

     Class c = cl.loadClass("test.Rectangle");
```

### 添加监听事件
* 接口Translator
* The method start() is called when this event listener is added to a javassist.Loader object by addTranslator() in javassist.Loader.
*  The method onLoad() is called before javassist.Loader loads a class. onLoad() can modify the definition of the loaded class.
```
public interface Translator {
    public void start(ClassPool pool)
        throws NotFoundException, CannotCompileException;
    public void onLoad(ClassPool pool, String classname)
        throws NotFoundException, CannotCompileException;
}
```
* 范例
```
   Loader cl = new Loader();
        cl.addTranslator(classPool,translator);
```


## 编译器
* javasist内嵌了一个小型的编译器
* 特殊符号变量
```
$0, $1, $2, ...    	this and actual parameters
$args	An array of parameters. The type of $args is Object[].
$$	All actual parameters.
For example, m($$) is equivalent to m($1,$2,...)
 
$cflow(...)	cflow variable
$r	The result type. It is used in a cast expression.
$w	The wrapper type. It is used in a cast expression.
$_	The resulting value
$sig	An array of java.lang.Class objects representing the formal parameter types.
$type	A java.lang.Class object representing the formal result type.
$class	A java.lang.Class object representing the class currently edited.
```

### $0, $1, $2
* $0代表this,静态方法没有
```
 ClassPool classPool = new ClassPool(true);
        CtClass ctClass = classPool.makeClass("java_ssist_test.NewClass");
        CtMethod make = CtMethod.make("public void sayHi(String a,String b){}", ctClass);
        make.setBody("{System.out.println($1+$2);}");
        ctClass.addMethod(make);

        Class<?> aClass = ctClass.toClass();
        Object o = aClass.newInstance();
        ReflectionUtils4Javassist.methodCall(o, "sayHi", "hello", "world");
```

### $args
* 代表所有入参
```
 ClassPool classPool = new ClassPool(true);
        CtClass ctClass = classPool.makeClass("java_ssist_test.NewClass");
        CtMethod make = CtMethod.make("public  void sayHi(String a,String b){}", ctClass);
        make.setBody("{ " +
                " for(int i=0;i<$args.length;i++){\n" +
                "            System.out.println($args[i]);\n" +
                "        }" +
                "}");
        ctClass.addMethod(make);


        Class<?> aClass = ctClass.toClass();
        Object o = aClass.newInstance();
        ReflectionUtils4Javassist.methodCall(o, "sayHi", "hello", "world");
```

### $$
* 动态数量入参
```
ClassPool classPool = new ClassPool(true);
        CtClass ctClass = classPool.makeClass("java_ssist_test.NewClass");

        CtMethod make1 = CtMethod.make("public  void sayHi1(String a,String b){}", ctClass);
        make1.setBody("{ System.out.println($1+\" \"+$2); }");
        ctClass.addMethod(make1);


        CtMethod make = CtMethod.make("public  void sayHi2(String a,String b){ sayHi1($$); sayHi1($1,$2);}", ctClass);
        ctClass.addMethod(make);


        Class<?> aClass = ctClass.toClass();
        Object o = aClass.newInstance();
        ReflectionUtils4Javassist.methodCall(o, "sayHi2", "hello", "world");
```

### $cflow
* 递归计数
```
 ClassPool classPool = new ClassPool(true);
        CtClass ctClass = classPool.makeClass("java_ssist_test.NewClass");
        CtMethod make1 = CtMethod.make("public  void sayHi1(String a,String b){}", ctClass);
        ctClass.addMethod(make1);
        make1.useCflow("tag");
        make1.insertBefore("{_cflow$0.enter();if(_cflow$0.value()>10){System.exit(1);}else{System.out.println($1+$2+_cflow$0.value());sayHi1($$);} }");
        ctClass.writeFile();
        
        Class<?> aClass = ctClass.toClass();
        Object o = aClass.newInstance();
        ReflectionUtils4Javassist.methodCall(o, "sayHi1", "hello", "world");
```

###  $r
* 响应类型转型
```
 ClassPool classPool = new ClassPool(true);
        CtClass ctClass = classPool.makeClass("java_ssist_test.NewClass");
        CtMethod make1 = CtMethod.make("public  double sayHi1(String a,String b){ return 1d;}", ctClass);
        ctClass.addMethod(make1);
        make1.insertBefore("{return ($r)1;}");
        ctClass.writeFile();

        Class<?> aClass = ctClass.toClass();
        Object o = aClass.newInstance();
        ReflectionUtils4Javassist.methodCall(o, "sayHi1", "hello", "world");
```
* void 方法中，等价于return;
```
return ($r)result; //等价于 return
```

### $w
* 将原始类型转换成包装类

### $_
* 方法调用的返回值，$_会调用一次方法
* 只能用于insertAfter
```
 
        ClassPool classPool = new ClassPool(true);
        CtClass ctClass = classPool.makeClass("java_ssist_test.NewClass");

        CtMethod getDouble = CtMethod.make("public  double getDouble(){ System.out.println(\"method has been called\"); return 777d;}", ctClass);
        ctClass.addMethod(getDouble);

        CtMethod make1 = CtMethod.make("public  double sayHi1(String a,String b){ return getDouble();}", ctClass);
        ctClass.addMethod(make1);
        make1.insertAfter("{System.out.println($_); return ($r)666;}");
        ctClass.writeFile();

        Class<?> aClass = ctClass.toClass();
        Object o = aClass.newInstance();
        ReflectionUtils4Javassist.methodCall(o, "sayHi1", "hello", "world");

```

### $sig
* 方法入参的class数组
```
make1.insertAfter("{System.out.println(java.util.Arrays.toString($sig));}");
```

### $type
* 返回值类型
```
 make1.insertAfter("{System.out.println($type);}");
```

### $class
* 方法所属类，即$0(this)的类
```
 make1.insertAfter("{System.out.println($class);}");
```

### addCatch()抛出异常
* 编码
```
CtMethod m = ...;
CtClass etype = ClassPool.getDefault().get("java.io.IOException");
m.addCatch("{ System.out.println($e); throw $e; }", etype);
```
* 编译后
```
try {
    the original method body
}
catch (java.io.IOException e) {
    System.out.println(e);
    throw e;
}
```

### 方法内调用替换
* instrument()方法搜索方法体
* $proceed($$)表示搜索到的方法调用
* _$代表返回值
* 替换的方法不能有try...catch
```
 ClassPool classPool = new ClassPool(true);
        CtClass ctClass = classPool.makeClass("java_ssist_test.NewClass");


        CtMethod sayHi = CtNewMethod.make("public void sayHi() { System.out.println(\"do business\");}", ctClass);
        ctClass.addMethod(sayHi);

        CtMethod getString = CtNewMethod.make("public String getString(int i,int z) { System.out.println(\"执行一次\");  return \"im view \"; }", ctClass);
        ctClass.addMethod(getString);


        CtMethod cm = CtNewMethod.make("public String hi(String a,String b) { sayHi();  return getString(1,2); }", ctClass);
        ctClass.addMethod(cm);




        cm.instrument(new ExprEditor() {
            public void edit(MethodCall m) throws CannotCompileException {
                if (m.getMethodName().equals("sayHi")){
                    m.replace("{   System.out.println(\"before\"); $proceed(); System.out.println(\"after\");  }");
                    return;
                }
                if (m.getMethodName().equals("getString")){
                    m.replace("{    System.out.println(\"before\"); $_=$proceed($$); System.out.println(\"after\");  }");
                    return;
                }

                System.out.println("method");

            }
        });



        Class<?> aClass = ctClass.toClass();
        ctClass.writeFile();
        Object o = aClass.newInstance();
        ReflectionUtils4Javassist.methodCall(o, "hi", "hello", "world");
```

* 可以用来实现切面
```
{ before-statements;
  $_ = $proceed($$);
  after-statements; }
```

### ExprEditor类的edit方法
```
public void edit(NewExpr e) throws CannotCompileException {
    }

    public void edit(NewArray a) throws CannotCompileException {
    }

    public void edit(MethodCall m) throws CannotCompileException {
    }

    public void edit(ConstructorCall c) throws CannotCompileException {
    }

    public void edit(FieldAccess f) throws CannotCompileException {
    }

    public void edit(Instanceof i) throws CannotCompileException {
    }

    public void edit(Cast c) throws CannotCompileException {
    }

    public void edit(Handler h) throws CannotCompileException {
    }
```
* javassist.expr.MethodCall 代码中方法调用
* javassist.expr.ConstructorCall 代码中构造方法调用
* javassist.expr.FieldAccess 代码中对象访问
* javassist.expr.NewExpr 代码中对象创建，但不包含数组创建
* javassist.expr.NewArray 代码中数组创建,例如如下
```
String[][] s = new String[3][4];//$1 and $2 分别是3和4 $3不存在
String[][] s = new String[3][];//$1是3 $2不存在
```
* javassist.expr.Instanceof Instanceof 代码中表达式被调用
* javassist.expr.Cast 代码中出现显示转型
* javassist.expr.Handler  try...catch出现，edit方法修改catch里的内容

### 方法修改
* 可以使用变量
```
cm.insertAfter("{  System.out.println($0); }");
```
* 方法申明一
```
  CtMethod make = CtMethod.make("public void sayHi(){int z=0;}", ctClass);
        ctClass.addMethod(make);
```
* 方法申明二
```
   CtMethod m = new CtMethod(CtClass.intType, "move", new CtClass[] { CtClass.intType }, ctClass);
        m.setBody("{ int i =0; return i;}");
        ctClass.addMethod(m);
```
* 如果添加抽象方法必须显示的转为非抽象
```
cc.setModifiers(cc.getModifiers() & ~Modifier.ABSTRACT);
```

* 可变参数方法
```
 ClassPool classPool = new ClassPool(true);
        CtClass ctClass = classPool.get("java_ssist_test.edit.FunctionDemo");
        CtMethod m = CtMethod.make("public int length(int[] args) { return args.length; }", ctClass);
        m.setModifiers(m.getModifiers() | Modifier.VARARGS);
        ctClass.addMethod(m);
```

### 属性修改
```
//范例一
CtField f = new CtField(CtClass.intType, "z", point);
point.addField(f);
point.addField(f, "0");//带有初值，是表达式

//范例二
CtField f = CtField.make("public int z = 0;", point);
point.addField(f);

```

### 包引用
* 请注意importPackage()不会影响ClassPool中的get()方法。只有编译器会考虑导入的包。get()的参数必须始终是完全限定名
```
 ClassPool classPool = new ClassPool(true);
        classPool.importPackage("java.util");
        CtClass string = classPool.makeClass("Demo");
        CtMethod make = CtMethod.make("public HashMap sayHi(){return null;}", string);//这里可以直接使用HashMap是因为上面调用了引用
        string.addMethod(make);
```

### 注解
* 获取注解
```
 CtClass ctClass = classPool.getCtClass("java_ssist_test.edit.FunctionDemo");
        Object[] annotations = ctClass.getAnnotations();
```

## 运行支持
* 大部分生成的字节码不再需要额外javassist库支持，部分需要javassist.runtime包下的类支持


## 不完全支持
* 不支持分派，没有实现分派算法
* 建议用户使用#作为类名和静态方法或字段名之间的分隔符
```
javassist.CtClass.intType.getName()
javassist.CtClass#intType.getName()//用分隔#符分开
```
* 拆箱和装箱要手动操作

## 更低级的字节码操作支持
* ClassFile 类
```
BufferedInputStream fin
    = new BufferedInputStream(new FileInputStream("Point.class"));
ClassFile cf = new ClassFile(new DataInputStream(fin));
```
